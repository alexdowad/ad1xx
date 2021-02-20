module test9_bench;
  ad100 ad100();

  wire [31:0] inst = ad100.cpu.instruction;
  reg  [31:0] prev = 0;

  task show;
      $display("instruction = %h", inst);
  endtask

  integer i;

  initial begin
    // C program which uses loops and recursive function calls

    #1 show();

    // After the program finishes, it should go into an infinite loop
    while (prev != inst) begin
      prev = inst;
      #100 show();
    end

    $display("factorial(10) = %d", {ad100.ram[3], ad100.ram[2], ad100.ram[1], ad100.ram[0]});

    for (i = 1; i <= 11; i++) begin
      $display("RAM[%D] = %d", i, {ad100.ram[(i*4)+3], ad100.ram[(i*4)+2], ad100.ram[(i*4)+1], ad100.ram[i*4]});
    end

    $finish();
  end

endmodule
