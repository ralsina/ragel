# Convert a string to an integer.
# Crystal version of atoi example

%%{
	machine atoi;
	write data;
}%%

def atoi(data : String) : Int64
  val = 0_i64
  neg = false

  %%{
    action see_neg {
      neg = true
    }

    action add_digit {
      val = val * 10 + (data[p].ord - 48)
    }

    main :=
      ( '-' @see_neg | '+' )? ( digit @add_digit )+;

    # Initialize and execute.
    write init;
    write exec;
  }%%

  STDERR.puts "After exec: p=#{p}, pe=#{pe}, cs=#{cs}, data.size=#{data.size}, data='#{data.inspect}', val=#{val}"

  if neg
    val = -val
  end

  if cs < Atoi_first_final
    STDERR.puts "atoi: there was an error (cs=#{cs}, first_final=#{Atoi_first_final})"
  end

  return val
end

# Test it
puts atoi(STDIN.gets.not_nil!)
