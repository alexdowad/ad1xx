module test8_bench;
  ad100 ad100();

  wire [31:0] inst = ad100.cpu.instruction;

  task show;
    begin
      $display("pc = %h", {ad100.addr_1, 2'b00});
      $display("instruction = %h", inst);
      $display("x1 (ra) = %h", ad100.cpu.regfile.registers[1]);
      $display("x2 (sp) = %h", ad100.cpu.regfile.registers[2]);
      $display("**************");
    end
  endtask

  initial begin
    // Simple C program

    #1   show();
    #100 show();
    #100 show();
    #100 show();
    #100 show();
    #100 show();
    #100 show();
    #100 show();

    #100 show();
    #100 show();
    #100 show();
    #100 show();

    #100 show();
    #100 show();
    #100 show();
    #100 show();
    #100 show();
    #100 show();
    #100 show();
    #100 show();

    #100 show();
    #100 show();
    #100 show();
    #100 show();
    #100 show();
    #100 show();
    #100 show();
    #100 show();
    #100 show();

    $display("RAM = %h", {ad100.ram[3], ad100.ram[2], ad100.ram[1], ad100.ram[0]});

    $finish();
  end

endmodule
