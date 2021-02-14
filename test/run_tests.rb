#!/usr/bin/env ruby

require 'minitest/autorun'

class AsmTest < Minitest::Test
  def vvp_test(file)
    output = `vvp #{__dir__}/#{file}.vvp`
    expect = File.read("#{__dir__}/expect/#{file}")
    assert_equal expect, output
  end

  def test_loading_immediates
    vvp_test('test_asm1')
  end

  def test_register_moves
    vvp_test('test_asm2')
  end

  def test_unconditional_jump
    vvp_test('test_asm3')
  end

  def test_function_call
    vvp_test('test_asm4')
  end

  def test_loads_and_stores
    vvp_test('test_asm5')
  end

  def test_conditional_branches
    vvp_test('test_asm6')
  end

  def test_arithmetic_and_logic_ops
    vvp_test('test_asm7')
  end

  def test_trivial_c_program
    vvp_test('test_c8')
  end

  def test_loops_and_recursive_function_calls
    vvp_test('test_c9')
  end
end
