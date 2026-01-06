%%{
  machine utf8_test;
  write data;

  action match_2byte {
    puts "2byte matched: ts=#{ts}, te=#{te}"
  }

  action match_1byte {
    puts "1byte matched: #{data[ts]}"
  }

  utf8_2byte = 0xC2..0xDF 0x80..0xBF >match_2byte;
  utf8_1byte = 0x00..0x7F >match_1byte;

  main := utf8_2byte | utf8_1byte;
}%%

module Utf8Test
  class Parser
    def initialize(@data : Bytes); end

    def parse
      data = @data; p = 0; pe = data.size
      ts = 0; te = 0; cs = 0; act = 0
      %% write init;
      %% write exec;
      puts "p=#{p}, pe=#{pe}"
    end
  end
end

Utf8Test::Parser.new(Bytes[0xC3, 0xB1]).parse  # ñ in UTF-8
