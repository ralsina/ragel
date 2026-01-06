# Simple Scanner Example for Crystal
# Demonstrates basic scanning with actions

%%{
  machine scanner;
  write data;

  action see_a { puts "Saw an 'a'" }
  action see_b { puts "Saw a 'b'" }

  main := (
    'a' @see_a |
    'b' @see_b |
    any+
  );
}%%

def scan(data : Slice(UInt8))
  cs, p, pe = Scanner_start, 0, data.size

  %%{
    write init;
    write exec;
  }%%

  if cs >= Scanner_first_final
    puts "Scan complete!"
  else
    puts "Scan failed"
  end
end

# Test the scanner
puts "Test 1: Scan with 'a'"
scan("a".to_slice)

puts "\nTest 2: Scan with 'b'"
scan("b".to_slice)

puts "\nTest 3: Scan with other text"
scan("hello world".to_slice)

