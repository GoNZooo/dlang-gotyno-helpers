import std.stdio;
import asdf;
import fluent.asserts : should;
import std.sumtype;

struct JustHasInt
{
  int otherValue;
}

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

