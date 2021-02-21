#!/usr/bin/env ruby

require 'erb'
require 'freetype'

# Geometric objects describing the contour of a glyph:

class Line
  def initialize(x1, y1, x2, y2)
    @x1, @y1, @x2, @y2 = x1, y1, x2, y2
  end

  # 1 if this line passes from left to right over the top of (x, y)
  # -1 if it passes right to left over the top of (x, y)
  def winding_number(x, y)
    return 0 if @x1 == @x2 || @x1 == x
    slope = (@y2 - @y1).to_f / (@x2 - @x1)
    y_intercept = @y1 + ((x - @x1) * slope)
    return 0 if y_intercept <= y
    if @x1 < x
      @x2 >= x ? 1 : 0
    else
      @x2 <= x ? -1 : 0
    end
  end
end

class Parabola
  # (x1,y1) is starting point; (x2,y2) is control point for quadratic Beziér
  # (x3,y3) is ending point

  # a quadratic Beziér is a parametric curve defined by:
  # x(t) = x₁(1 - t)² + 2x₂t(1 - t) + x₃t²
  # y(t) = y₁(1 - t)² + 2y₂t(1 - t) + y₃t²

  def initialize(x1, y1, x2, y2, x3, y3)
    @x1, @y1, @x2, @y2, @x3, @y3 = x1, y1, x2, y2, x3, y3
  end

  def winding_number(x, y)
    result, second = 0, false # this parabola might cross the line of interest twice

    t_for_x(x) do |t|
      # If we test for `t` ∈ [0,1], then if `x` happens to land exactly on the
      # point where one segment joins another, then _both_ segments will be
      # counted as crossing `x`. To avoid that, test for `t` ∈ (0,1].
      # (Limited floating-point precision can still cause this problem though...)
      next if t <= 0 || t > 1 # intersection point isn't on the parabola

      # It doesn't count if we cross under the point of interest
      next if y_for_t(t) <= y

      # the first intersection point counts as 1 if x₁ was to the left of x,
      # or -1 otherwise; the second intersection point is the other way around
      # (because if the parabola intersects the line of interest twice, it will
      # be travelling in the opposite direction at the second intersection)
      result += ((@x1 < x) ^ second) ? 1 : -1
      second = true
    end rescue nil

    result
  end

  def t_for_x(x, &block)
    # solve the above x(t) equation to get a quadratic equation in `t`
    quadratic_real_roots(@x1 - 2*@x2 + @x3, 2*(@x2 - @x1), @x1 - x, &block)
  end

  def x_for_t(t)
    # just use the above x(t) equation
    (@x1 * ((1 - t) ** 2)) + (2 * @x2 * t * (1 - t)) + (@x3 * (t ** 2))
  end

  def y_for_t(t)
    # just use the above y(t) equation
    (@y1 * ((1 - t) ** 2)) + (2 * @y2 * t * (1 - t)) + (@y3 * (t ** 2))
  end

  # yield roots of ax² + bx + c = 0
  def quadratic_real_roots(a, b, c)
    if a != 1
      if a == 0
        if b != 0
          yield -c.to_f / b
          return
        else
          raise "0x + c = 0 has either infinitely many or no solutions"
        end
      else
        b = b.to_f / a
        c = c.to_f / a
      end
    end

    d = b*b - 4*c # if d is negative, equation has no real roots
    if d > 0
      d = Math.sqrt(d)
      yield (d - b) / 2
      yield (-d - b) / 2
    elsif d == 0
      yield -b.to_f / 2 # only one real root
    end
  end
end

include FreeType::API

def gen_font_rom
  result = ''
  font = Font.open('/home/alex/Fonts/otherfonts/mononoki-Regular.ttf')
  font.set_char_size(8*64, 8*64, 120, 120)

  # our font data will cover the first 256 Unicode characters, each at 8x16 resolution
  0.upto(127) do |byte|
    if byte >= 0x21 && byte < 0x7F
      # puts "Rasterizing #{byte.chr} (0x#{byte.to_s(16)})"

      # rasterize each glyph at 8x16 resolution
      # if the 'winding number' for a pixel > 0, the pixel will be filled
      # but first convert TrueType contours into a format which is easier to work with
      outline = font.glyph(byte.chr).outline
      segments = []

      # `outline.contours` contains indexes into `outline.points` which end the
      # series of points for each contour
      ([-1] + outline.contours).each_cons(2) do |lo_index, hi_index|
        points = outline.points[(lo_index+1)..hi_index]
        # Looking at the font data, it seems that each contour _ends_, but does not
        # necessarily start, with an on-curve point
        # Therefore, copy the last point back to the beginning of the list of points
        # to close the contour
        points.unshift(points[-1])

        # 'on-curve' points are starting/ending points for line or curve segments
        # 'off-curve' points are control points for quadratic Beziér curves
        # a numeric tag identifies which type they are
        oncurve  = lambda { |p| p.tag & 1 == 1 }
        offcurve = lambda { |p| p.tag & 1 == 0 }

        # two successive off-curve points implies an on-curve point between them
        # add an explicit on-curve point so it will be easier to generate a list
        # of lines and parabolas for this glyph
        i = 1
        while i < points.size
          if offcurve[points[i-1]] && offcurve[points[i]]
            x_mid = (points[i-1].x + points[i].x).to_f / 2
            y_mid = (points[i-1].y + points[i].y).to_f / 2
            points.insert(i, FreeType::API::Point.new(1, x_mid, y_mid))
            i += 2
          else
            i += 1
          end
        end

        # now convert list of points to a list of straight/curved line segments
        i = 0
        while i < points.size-1
          raise "Unexpected offcurve point" if !oncurve[points[i]]
          if oncurve[points[i+1]]
            # Straight line
            segments << Line.new(points[i].x, points[i].y, points[i+1].x, points[i+1].y)
            i += 1
          else
            # Curve
            segments << Parabola.new(points[i].x, points[i].y, points[i+1].x, points[i+1].y, points[i+2].x, points[i+2].y)
            i += 2
          end
        end
      end

      # each position in this array represents a pixel
      # if it ends up with a number > 0, the pixel will be drawn
      winding = Array.new(16) { [0] * 8 }

      baseline  = 4 # which row to place Y=0 on (0 is the bottom, 15 is the top)
      left_side = 0 # which column to place X=0 on

      # for each pixel, run through all the segments, and sum their winding numbers
      segments.each do |segment|
        0.upto(7) do |x|
          x_pos = x + 0.5 - left_side
          0.upto(15) do |y|
            # in our array, row '0' is the top of the glyph,
            # but in the coordinate space, zero is the bottom
            y_pos = ((15 - y) + 0.5) - baseline
            winding[y][x] += segment.winding_number(x_pos * 64, y_pos * 64)
          end
        end
      end

      # puts winding.map { |a| a.map { |n| n > 0 ? "\u{2588}" : " " }.join }.join("|\n")

      winding.each_with_index do |pixels, row|
        pixels.map! { |val| val > 0 ? 1 : 0 }
        result << "    12'h#{byte.to_s(16).rjust(2, '0')}#{row.to_s(16)}: line = 8'b#{pixels.join};\n"
      end
    else
      0.upto(15) do |row|
        result << "    12'h#{byte.to_s(16).rjust(2, '0')}#{row.to_s(16)}: line = 8'b00000000;\n"
      end
    end
  end

  result
end

template = ERB.new(File.read('font_rom.v.erb'))
File.open('font_rom.v', 'w') do |f|
 f.write(template.result(binding))
end
