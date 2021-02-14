module test2_bench;
  ad100 ad100();

  wire [31:0] inst = ad100.cpu.instruction;

  initial begin
    // Test moving values from one register to another

    #1
    $display("instruction = %h", inst);
    $display("x1 = %h", ad100.cpu.regfile.registers[1]);
    $display("x2 = %h", ad100.cpu.regfile.registers[2]);
    $display("x3 = %h", ad100.cpu.regfile.registers[3]);
    $display("x4 = %h", ad100.cpu.regfile.registers[4]);
    $display("x5 = %h", ad100.cpu.regfile.registers[5]);
    $display("**************");

    #100
    $display("instruction = %h", inst);
    $display("x1 = %h", ad100.cpu.regfile.registers[1]);
    $display("x2 = %h", ad100.cpu.regfile.registers[2]);
    $display("x3 = %h", ad100.cpu.regfile.registers[3]);
    $display("x4 = %h", ad100.cpu.regfile.registers[4]);
    $display("x5 = %h", ad100.cpu.regfile.registers[5]);
    $display("**************");

    #100
    $display("instruction = %h", inst);
    $display("x1 = %h", ad100.cpu.regfile.registers[1]);
    $display("x2 = %h", ad100.cpu.regfile.registers[2]);
    $display("x3 = %h", ad100.cpu.regfile.registers[3]);
    $display("x4 = %h", ad100.cpu.regfile.registers[4]);
    $display("x5 = %h", ad100.cpu.regfile.registers[5]);
    $display("**************");

    #100
    $display("instruction = %h", inst);
    $display("x1 = %h", ad100.cpu.regfile.registers[1]);
    $display("x2 = %h", ad100.cpu.regfile.registers[2]);
    $display("x3 = %h", ad100.cpu.regfile.registers[3]);
    $display("x4 = %h", ad100.cpu.regfile.registers[4]);
    $display("x5 = %h", ad100.cpu.regfile.registers[5]);
    $display("**************");

    #100
    $display("instruction = %h", inst);
    $display("x1 = %h", ad100.cpu.regfile.registers[1]);
    $display("x2 = %h", ad100.cpu.regfile.registers[2]);
    $display("x3 = %h", ad100.cpu.regfile.registers[3]);
    $display("x4 = %h", ad100.cpu.regfile.registers[4]);
    $display("x5 = %h", ad100.cpu.regfile.registers[5]);
    $display("**************");

    #100
    $display("instruction = %h", inst);
    $display("x1 = %h", ad100.cpu.regfile.registers[1]);
    $display("x2 = %h", ad100.cpu.regfile.registers[2]);
    $display("x3 = %h", ad100.cpu.regfile.registers[3]);
    $display("x4 = %h", ad100.cpu.regfile.registers[4]);
    $display("x5 = %h", ad100.cpu.regfile.registers[5]);
    $display("**************");

    #100
    $display("instruction = %h", inst);
    $display("x1 = %h", ad100.cpu.regfile.registers[1]);
    $display("x2 = %h", ad100.cpu.regfile.registers[2]);
    $display("x3 = %h", ad100.cpu.regfile.registers[3]);
    $display("x4 = %h", ad100.cpu.regfile.registers[4]);
    $display("x5 = %h", ad100.cpu.regfile.registers[5]);
    $display("**************");

    #100
    $display("instruction = %h", inst);
    $display("x1 = %h", ad100.cpu.regfile.registers[1]);
    $display("x2 = %h", ad100.cpu.regfile.registers[2]);
    $display("x3 = %h", ad100.cpu.regfile.registers[3]);
    $display("x4 = %h", ad100.cpu.regfile.registers[4]);
    $display("x5 = %h", ad100.cpu.regfile.registers[5]);
    $display("**************");

    #100
    $display("instruction = %h", inst);
    $display("x1 = %h", ad100.cpu.regfile.registers[1]);
    $display("x2 = %h", ad100.cpu.regfile.registers[2]);
    $display("x3 = %h", ad100.cpu.regfile.registers[3]);
    $display("x4 = %h", ad100.cpu.regfile.registers[4]);
    $display("x5 = %h", ad100.cpu.regfile.registers[5]);
    $display("**************");

    $finish();
  end

endmodule
