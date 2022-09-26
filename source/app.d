import std.stdio;
import asdf;
import fluent.asserts : should;

struct GenericType(T)
{
  T value;
}

unittest
{
  auto s = `{"value": 42}`;
  auto a = GenericType!int(42);
  s.deserialize!(GenericType!(int)).should.equal(a);
}

void main()
{
  auto s = `{"value": 42}`;
  auto a = s.deserialize!(GenericType!(int));
	writeln(a);
}
