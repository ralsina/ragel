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

  if neg
    val = -val
  end

  if cs < Atoi_first_final
    STDERR.puts "atoi: there was an error"
  end

  return val
end

# Test it
puts atoi(STDIN.gets.not_nil!)
