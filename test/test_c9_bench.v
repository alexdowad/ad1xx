module test9_bench;
  ad100 ad100();

  wire [31:0] inst = ad100.cpu.instruction;
  reg  [31:0] prev = 0;

  task show;
      $display("instruction = %h", inst);
  endtask

  initial begin
    // C program which uses loops and recursive function calls

    #1 show();

    // After the program finishes, it should go into an infinite loop
    while (prev != inst) begin
      prev = inst;
      #100 show();
    end

    $display("factorial(10) = %d", ad100.ram[0]);
    $display("RAM[1] = %d", ad100.ram[1]);
    $display("RAM[2] = %d", ad100.ram[2]);
    $display("RAM[3] = %d", ad100.ram[3]);
    $display("RAM[4] = %d", ad100.ram[4]);
    $display("RAM[5] = %d", ad100.ram[5]);
    $display("RAM[6] = %d", ad100.ram[6]);
    $display("RAM[7] = %d", ad100.ram[7]);
    $display("RAM[8] = %d", ad100.ram[8]);
    $display("RAM[9] = %d", ad100.ram[9]);
    $display("RAM[10] = %d", ad100.ram[10]);
    $display("RAM[11] = %d", ad100.ram[11]);

    $finish();
  end

endmodule
