module test5_bench;
  ad100 ad100();

  wire [31:0] inst = ad100.cpu.instruction;

  task show;
    begin
      $display("pc = %h", {ad100.addr_1, 2'b00});
      $display("instruction = %h", inst);
      $display("RAM = %h", {ad100.ram[3], ad100.ram[2], ad100.ram[1], ad100.ram[0]});
      $display("x1  = %h", ad100.cpu.regfile.registers[1]);
      $display("x2  = %h", ad100.cpu.regfile.registers[2]);
      $display("x3  = %h", ad100.cpu.regfile.registers[3]);
      $display("x4  = %h", ad100.cpu.regfile.registers[4]);
      $display("x5  = %h", ad100.cpu.regfile.registers[5]);
      $display("x6  = %h", ad100.cpu.regfile.registers[6]);
      $display("x7  = %h", ad100.cpu.regfile.registers[7]);
      $display("x8  = %h", ad100.cpu.regfile.registers[8]);
      $display("x9  = %h", ad100.cpu.regfile.registers[9]);
      $display("x10 = %h", ad100.cpu.regfile.registers[10]);
      $display("x11 = %h", ad100.cpu.regfile.registers[11]);
      $display("x12 = %h", ad100.cpu.regfile.registers[12]);
      $display("x13 = %h", ad100.cpu.regfile.registers[13]);
      $display("x14 = %h", ad100.cpu.regfile.registers[14]);
      $display("x15 = %h", ad100.cpu.regfile.registers[15]);
      $display("**************");
    end
  endtask

  initial begin
    // Test function call

    #1   show();
    #100 show();
    #100 show();
    #100 show();
    #100 show();
    #100 show();
    $display("loading with LB");
    #100 show();
    #100 show();
    #100 show();
    #100 show();
    $display("loading with LBU");
    #100 show();
    #100 show();
    #100 show();
    #100 show();

    $display("loading with LH");
    #100 show();
    #100 show();
    $display("loading with LHU");
    #100 show();
    #100 show();

    #100 show();
    #100 show();
    $display("storing with SB");
    #100 show();
    $display("storing with SH");
    #100 show();

    $finish();
  end

endmodule
