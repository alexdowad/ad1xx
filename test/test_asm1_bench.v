module test1_bench;
  ad100 ad100();

  wire [31:0] pc = {ad100.cpu.program_counter, 2'b00};
  wire [31:0] inst = ad100.cpu.instruction;

  task show;
    begin
      $display("pc = %h", pc);
      $display("instruction = %h", inst);
      $display("x1 = %h", ad100.cpu.regfile.registers[1]);
      $display("x2 = %h", ad100.cpu.regfile.registers[2]);
      $display("**************");
    end
  endtask

  initial begin
    // Test loading constant values into registers
    // li x1, 0x12345678

    #1 show();
    #100 show();
    #100 show();
    #100 show();
    #100 show();
    #100 show();
    #100 show();

    $finish();
  end

endmodule
