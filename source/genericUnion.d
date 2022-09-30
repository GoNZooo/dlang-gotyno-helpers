import std.stdio;
import asdf;
import fluent.asserts : should;
import std.sumtype;
import structs;
import std.meta;
import std.algorithm : splitter;

struct JustHasIntData
{
  JustHasInt data;
}

struct GenericTypeData(T)
{
  GenericType!T data;
}

struct EmptyPayloadData
{
}

struct OtherEmptyPayloadData
{
}

private alias takeBaseTypeName(alias t) = Alias!(t.stringof.splitter('!').front());

struct GenericUnion(T)
{
  alias Type = SumType!(JustHasIntData, GenericTypeData!T, EmptyPayloadData, OtherEmptyPayloadData);
  Type data;
  alias data this;

  static foreach (T; Type.Types)
    this(T v) @safe pure nothrow @nogc { data = v; }

  static string[] Tags = [staticMap!(takeBaseTypeName, AliasSeq!(Type.Types))];

  SerdeException deserializeFromAsdf(Asdf asdfData)
  {
    string tag;
    if (auto e = asdfData["type"].deserializeValue(tag)) return e;

    final switch (tag)
    {
      case "JustHasInt": {
        JustHasIntData v = void;
        if (auto e = asdfData.deserializeValue(v)) return e;
        data = v;
        return null;
      }

      case "GenericType": {
        GenericTypeData!T v = void;
        if (auto e = asdfData.deserializeValue(v)) return e;
        data = v;
        return null;
      }

      case "EmptyPayload": {
        data = EmptyPayloadData();
        return null;
      }

      case "OtherEmptyPayload": {
        data = OtherEmptyPayloadData();
        return null;
      }
    }
  }
}

unittest
{
  GenericUnion!int.Type expected = GenericTypeData!int(GenericType!int(42));
  writeln(GenericUnion!int.Tags);
  auto string = `{"type": "GenericType", "data": {"value": 42}}`;
  auto decoded = string.deserialize!(GenericUnion!int);
  decoded.data.should.equal(expected);

  decoded.match!(
    (JustHasIntData _) => assert(false),
    (GenericTypeData!int v) => assert(v.data.value == 42),
    (EmptyPayloadData _) => assert(false),
    (OtherEmptyPayloadData _) => assert(false)
  );

  GenericUnion!int.Type expected2 = JustHasIntData(JustHasInt(1337));
  auto string2 = `{"type": "JustHasInt", "data": {"otherValue": 1337}}`;
  auto decoded2 = string2.deserialize!(GenericUnion!int);
  decoded2.data.should.equal(expected2);

  decoded2.match!(
    (JustHasIntData v) => v.data.otherValue.should.equal(1337),
    (GenericTypeData!int _) => assert(false),
    (EmptyPayloadData _) => assert(false),
    (OtherEmptyPayloadData _) => assert(false)
  );

  GenericUnion!int.Type expected3 = EmptyPayloadData();
  auto string3 = `{"type": "EmptyPayload"}`;
  auto decoded3 = string3.deserialize!(GenericUnion!int);
  decoded3.data.should.equal(expected3);

  decoded3.match!(
    (JustHasIntData _) => assert(false),
    (GenericTypeData!int _) => assert(false),
    (EmptyPayloadData _) => assert(true),
    (OtherEmptyPayloadData _) => assert(false)
  );

  GenericUnion!int.Type expected4 = OtherEmptyPayloadData();
  auto string4 = `{"type": "OtherEmptyPayload"}`;
  auto decoded4 = string4.deserialize!(GenericUnion!int);
  decoded4.data.should.equal(expected4);

  decoded4.match!(
    (JustHasIntData _) => assert(false),
    (GenericTypeData!int _) => assert(false),
    (EmptyPayloadData _) => assert(false),
    (OtherEmptyPayloadData _) => assert(true)
  );
}


