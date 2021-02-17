module test10_bench;
  ad100 ad100();

  wire [31:0] inst = ad100.cpu.instruction;
  reg  [31:0] prev = 0;

  task show;
    $display("instruction = %h", inst);
  endtask

  initial begin
    // C program which uses function pointers

    #1 show();

    // After the program finishes, it should go into an infinite loop
    while (prev != inst) begin
      prev = inst;
      #100 show();
    end

    $display("RAM[0] = %d", ad100.ram[0]);
    $finish();
  end

endmodule
