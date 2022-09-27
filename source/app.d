import std.stdio;
import asdf;
import fluent.asserts : should;
import std.sumtype;
import genericUnion;

unittest
{
  auto s = `{"value": 42}`;
  auto a = s.deserialize!(GenericType!(int));
	writeln(a);
}

void main()
{
  auto s = `{"value": 42}`;
  auto a = s.deserialize!(GenericType!(int));
	writeln(a);
}
