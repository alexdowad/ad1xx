module test3_bench;
  ad100 ad100();

  wire [31:0] inst = ad100.cpu.instruction;

  task show;
    begin
      $display("pc = %h", {ad100.addr_1, 2'b00});
      $display("instruction = %h", inst);
      $display("x12 = %h", ad100.cpu.regfile.registers[12]);
      $display("**************");
    end
  endtask

  initial begin
    // Test unconditional jump

    #1   show();
    #100 show();
    #100 show();
    #100 show();

    $finish();
  end

endmodule
