import std.stdio;
import asdf;
import fluent.asserts : should;
import std.sumtype;
import structs;

struct GenericUnion(T)
{
  alias Type = SumType!(JustHasInt, GenericType!T);
  Type data;
  alias data this;

  enum Tag
  {
    JustHasInt = "JustHasInt",
    GenericType = "GenericType"
  }

  static foreach (T; Type.Types)
    this(T v) @safe pure nothrow @nogc { data = v; }

  SerdeException deserializeFromAsdf(Asdf asdfData)
  {
    Tag tag;
    if (auto e = asdfData["type"].deserializeValue(tag)) return e;

    final switch (tag)
    {
      case Tag.JustHasInt: {
        auto v = JustHasInt(0);
        if (auto e = asdfData["data"].deserializeValue(v)) return e;
        data = v;
        return null;
      }

      case Tag.GenericType: {
        GenericType!T v = void;
        if (auto e = asdfData["data"].deserializeValue(v)) return e;
        data = v;
        return null;
      }
    }
  }
}

unittest
{
  GenericUnion!int.Type expected = GenericType!int(42);
  auto string = `{"type": "GenericType", "data": {"value": 42}}`;
  auto decoded = string.deserialize!(GenericUnion!int);
  decoded.data.should.equal(expected);

  GenericUnion!int.Type expected2 = JustHasInt(1337);
  auto string2 = `{"type": "JustHasInt", "data": {"otherValue": 1337}}`;
  auto decoded2 = string2.deserialize!(GenericUnion!int);
  decoded2.data.should.equal(expected2);

  decoded2.match!(
    (JustHasInt v) => v.otherValue.should.equal(1337),
    (GenericType!int _) => assert(false)
  );
}

