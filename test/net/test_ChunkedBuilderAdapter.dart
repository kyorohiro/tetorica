//import 'package:unittest/unittest.dart' as unit;
import 'package:tetorica/core.dart' as hetima;
import 'package:tetorica/net.dart' as hetima;
import 'dart:async';
import 'dart:convert' as conv;
import 'package:unittest/unittest.dart' as unit;

void main() {
  unit.test("ChunkedBuilderAdapter_a", () async {
    hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
    hetima.ChunkedBuilderAdapter a = new hetima.ChunkedBuilderAdapter(builder);
    Future r = a.getByteFuture(0, 3);
    a.start();
    builder.appendString("3\r\nabc");

    String s = conv.UTF8.decode(await r);
    unit.expect("abc", s);
  });

  unit.test("ChunkedBuilderAdapter_b", () async {
    hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
    hetima.ChunkedBuilderAdapter a = new hetima.ChunkedBuilderAdapter(builder);
    Future r = a.getByteFuture(0, 13);
    builder.appendString("3\r\nabc\r\n10\r\n1234567890");
    builder.fin();
    String s = conv.UTF8.decode(await r);
    unit.expect("abc1234567890", s);
  });

  unit.test("ChunkedBuilderAdapter_c", () async {
    hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
    hetima.ChunkedBuilderAdapter a = new hetima.ChunkedBuilderAdapter(builder);
    Future r = a.getByteFuture(0, 13);
    builder.appendString("3\r\nabc\r\n10\r\n12345678");
    builder.fin();
    try {
      await r;
      unit.fail("--");
    } catch (e) {}
  });

  unit.test("ChunkedBuilderAdapter_d", () async {
    hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
    hetima.ChunkedBuilderAdapter a = new hetima.ChunkedBuilderAdapter(builder);
    Future r = a.getByteFuture(0, 13);
    builder.appendString("3\r\nabc10\r\n12345678");
    builder.fin();
    try {
      await r;
      unit.fail("--");
    } catch (e) {}
  });

  unit.test("ChunkedBuilderAdapter_f", () async {
    hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
    hetima.ChunkedBuilderAdapter a = new hetima.ChunkedBuilderAdapter(builder);
    Future r = a.getByteFuture(0, 13);
    new Future.delayed(new Duration(milliseconds: 500), () {
      builder.appendString("3\r\nabc\r\n");
    });
    new Future.delayed(new Duration(milliseconds: 1000), () {
      builder.appendString("a\r\n12345678");
    });
    new Future.delayed(new Duration(milliseconds: 1300), () {
      builder.appendString("90\r\n0\r\n");
//      builder.fin();
    });
    String s = conv.UTF8.decode(await r);
    unit.expect("abc1234567890", s);
  });
}
