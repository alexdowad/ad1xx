module test7_bench;
  ad100 ad100();

  wire [31:0] inst = ad100.cpu.instruction;

  task show;
    begin
      $display("pc = %h", {ad100.addr_1, 2'b00});
      $display("instruction = %h", inst);
      $display("x12 = %h", ad100.cpu.regfile.registers[12]);
      $display("x13 = %h", ad100.cpu.regfile.registers[13]);
      $display("x14 = %h", ad100.cpu.regfile.registers[14]);
      $display("**************");
    end
  endtask

  initial begin
    // Test function call

    $display("trying SRLI and SLLI");
    #1   show();
    #100 show();
    #100 show();
    #100 show();

    $display("trying SRAI");
    #100 show();
    #100 show();
    #100 show();
    #100 show();

    $display("trying SUB");
    #100 show();
    $display("trying XORI");
    #100 show();
    $display("trying ANDI");
    #100 show();
    $display("trying ORI");
    #100 show();

    $display("trying AND, OR, XOR");
    #100 show();
    #100 show();
    #100 show();
    #100 show();
    #100 show();
    #100 show();
    #100 show();
    #100 show();

    $display("trying SLTI and SLTIU");
    #100 show();
    #100 show();
    #100 show();
    #100 show();
    #100 show();
    #100 show();
    #100 show();
    #100 show();

    $display("trying ADD");
    #100 show();
    #100 show();
    #100 show();
    #100 show();
    #100 show();

    $display("trying SLT and SLTU");
    #100 show();
    #100 show();
    #100 show();
    #100 show();
    #100 show();
    #100 show();
    #100 show();

    $display("trying SRL, SLL, and SRA");
    #100 show();
    #100 show();
    #100 show();
    #100 show();
    #100 show();
    #100 show();
    #100 show();
    #100 show();

    $finish();
  end

endmodule
