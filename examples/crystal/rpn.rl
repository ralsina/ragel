# Reverse Polish Notation Calculator
# Copyright (c) 2010 J.A. Roberts Tunney
# MIT License
#
# Ported to Crystal from the Go original
#
# To compile:
#
#   ragel -Y -o rpn.cr rpn.rl
#   crystal build rpn.cr -o rpn
#   ./rpn
#
# To show a diagram of your state machine:
#
#   ragel -V -Y -p -o rpn.dot rpn.rl

%%{
  machine rpn;
  write data;
}%%

class RPNCalculator
  @items : Array(Int32)
  @count : Int32

  def initialize
    @items = Array(Int32).new(128, 0)
    @count = 0
  end

  def pop : Int32
    @count -= 1
    @items[@count]
  end

  def push(v : Int32)
    @items[@count] = v
    @count += 1
  end
end

def abs(v : Int32) : Int32
  v < 0 ? -v : v
end

def rpn_eval(data : Slice(UInt8)) : Tuple(Int32, String?)
  cs, p, pe = 0, 0, data.size
  mark = 0
  st = RPNCalculator.new

  %%{
    action mark { mark = p }
    action push {
      x = String.new(data[mark...p]).to_i
      st.push(x)
    }
    action add {
      y, x = st.pop, st.pop
      st.push(x + y)
    }
    action sub {
      y, x = st.pop, st.pop
      st.push(x - y)
    }
    action mul {
      y, x = st.pop, st.pop
      st.push(x * y)
    }
    action div {
      y, x = st.pop, st.pop
      st.push((x / y).to_i32)
    }
    action abs { st.push(abs(st.pop)) }
    action abba { st.push(666) }

    stuff  = digit+ >mark %push
           | '+' @add
           | '-' @sub
           | '*' @mul
           | '/' @div
           | 'abs' %abs
           | 'add' %add
           | 'abba' %abba
           ;

    main := ( space | stuff space )* ;

    write init;
    write exec;
  }%%

  if cs < Rpn_first_final
    if p == pe
      return {0, "unexpected eof"}
    else
      return {0, "error at position #{p}"}
    end
  end

  if st.@count == 0
    return {0, "rpn stack empty on result"}
  end

  {st.pop, nil}
end

# Test cases
tests = [
  {"666\n", 666},
  {"666 111\n", 111},
  {"4 3 add\n", 7},
  {"4 3 +\n", 7},
  {"4 3 -\n", 1},
  {"4 3 *\n", 12},
  {"6 2 /\n", 3},
  {"0 3 -\n", -3},
  {"0 3 - abs\n", 3},
  {" 2  2 + 3 - \n", 1},
  {"10 7 3 2 * - +\n", 11},
  {"abba abba add\n", 1332},
]

fail_tests = [
  {"\n", "rpn stack empty on result"},
]

rc = 0

tests.each do |test|
  input, expected = test
  res, err = rpn_eval(input.to_slice)
  if err
    STDERR.puts "FAIL rpn(#{input.inspect}) #{err}"
    rc = 1
  elsif res != expected
    STDERR.puts "FAIL rpn(#{input.inspect}) -> #{res.inspect} != #{expected.inspect}"
    rc = 1
  else
    STDERR.puts "SUCCESS rpn(#{input.inspect}) -> #{res.inspect}"
  end
end

fail_tests.each do |test|
  input, expected_err = test
  res, err = rpn_eval(input.to_slice)
  if err.nil?
    STDERR.puts "FAIL rpn(#{input.inspect}) -> #{res.inspect} should fail: #{expected_err.inspect}"
    rc = 1
  elsif err != expected_err
    STDERR.puts "FAIL rpn(#{input.inspect}) #{err.inspect} should be #{expected_err.inspect}"
    rc = 1
  end
end

exit rc
