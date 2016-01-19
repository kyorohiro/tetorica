import 'package:unittest/unittest.dart' as unit;
import 'package:tetorica/core.dart' as hetima;
import 'package:tetorica/hetimanet.dart' as hetima;
import 'dart:async' as async;
import 'dart:convert' as conv;
void main() {
  hetima.HetiTest test = new hetima.HetiTest("tt");

  {
    hetima.HetiTestTicket ticket = test.test("ChunkedBuilderAdapter_a", 3000);
    hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
    hetima.ChunkedBuilderAdapter a = new hetima.ChunkedBuilderAdapter(builder);
    a.getByteFuture(0, 3).then((List<int> v) {
      String s = conv.UTF8.decode(v);
      ticket.assertTrue(""+s, "abc" == s);
      ticket.fin();
    });
    a.start();
    builder.appendString("3\r\nabc");
  }

  {
    hetima.HetiTestTicket ticket = test.test("ChunkedBuilderAdapter_b", 3000);
    hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
    hetima.ChunkedBuilderAdapter a = new hetima.ChunkedBuilderAdapter(builder);
    a.getByteFuture(0, 13).then((List<int> v) {
      String s = conv.UTF8.decode(v);
      ticket.assertTrue(""+s, "abc1234567890" == s);
      ticket.fin();
    });
    builder.appendString("3\r\nabc\r\n10\r\n1234567890");
    builder.fin();
  }

  {
    hetima.HetiTestTicket ticket = test.test("ChunkedBuilderAdapter_c", 3000);
    hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
    hetima.ChunkedBuilderAdapter a = new hetima.ChunkedBuilderAdapter(builder);
    a.getByteFuture(0, 13).then((List<int> v) {
      String s = conv.UTF8.decode(v);
      ticket.assertTrue(""+s, "abc12345678" == s);
    }).catchError((e){
      ticket.assertTrue("", true);
    }).whenComplete(() {
      ticket.fin();
    });
    builder.appendString("3\r\nabc\r\n10\r\n12345678");
    builder.fin();
  }

  {
    hetima.HetiTestTicket ticket = test.test("ChunkedBuilderAdapter_d", 3000);
    hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
    hetima.ChunkedBuilderAdapter a = new hetima.ChunkedBuilderAdapter(builder);
    a.getByteFuture(0, 13).then((List<int> v) {
      String s = conv.UTF8.decode(v);
      ticket.assertTrue(""+s, "abc" == s);
    }).catchError((e){
      ticket.assertTrue("", true);
    }).whenComplete(() {
      ticket.fin();
    });
    builder.appendString("3\r\nabc10\r\n12345678");
    builder.fin();
  }

  {
    hetima.HetiTestTicket ticket = test.test("ChunkedBuilderAdapter_f", 3000);
    hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
    hetima.ChunkedBuilderAdapter a = new hetima.ChunkedBuilderAdapter(builder);
    a.getByteFuture(0, 13).then((List<int> v) {
      String s = conv.UTF8.decode(v);
      ticket.assertTrue(""+s, "abc1234567890" == s);
      ticket.fin();
    });
    new async.Future.delayed(new Duration(milliseconds: 500),(){
      builder.appendString("3\r\nabc\r\n");
    });
    new async.Future.delayed(new Duration(milliseconds: 1000),(){
      builder.appendString("a\r\n12345678");
    });
    new async.Future.delayed(new Duration(milliseconds: 1300),(){
      builder.appendString("90\r\n0\r\n");
//      builder.fin();
    });

  }
}
