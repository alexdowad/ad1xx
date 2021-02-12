module test4_bench;
  ad100 ad100();

  wire [31:0] inst = ad100.cpu.instruction;

  task show;
    begin
      $display("pc = %h", {ad100.addr_1, 2'b00});
      $display("instruction = %h", inst);
      // x1 is also known as ra; it's where the return address of a function call
      // is stored (by convention)
      $display("ra = %h", ad100.cpu.regfile.registers[1]);
      $display("a0 = %h", ad100.cpu.regfile.registers[10]);
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

    $finish();
  end

endmodule
