import 'package:unittest/unittest.dart' as unit;
import 'package:tetorica/hetimacore.dart' as hetima;
import 'package:tetorica/hetimanet.dart' as hetima;
import 'dart:async' as async;

void main() {
  hetima.HetiTest test = new hetima.HetiTest("tt");
  {
    hetima.HetiTestTicket ticket = test.test("001", 3000);
    String v = "";

    new async.Future.sync(() {
      hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
      hetima.EasyParser parser = new hetima.EasyParser(builder);
      async.Future<hetima.HetiHttpRequestRange> f = hetima.HetiHttpResponse.decodeRequestRangeValue(parser);
      builder.appendString("bytes=0-100");
      builder.fin();
      return f;
    }).then((hetima.HetiHttpRequestRange  v) {
      ticket.assertTrue("a0", 0==v.start);
      ticket.assertTrue("a1", 100==v.end);
      ticket.fin();
    });
  }

  {
    hetima.HetiTestTicket ticket = test.test("002", 3000);
    String v = "";

    new async.Future.sync(() {
      hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
      hetima.EasyParser parser = new hetima.EasyParser(builder);
      async.Future<hetima.HetiHttpRequestRange> f = hetima.HetiHttpResponse.decodeRequestRangeValue(parser);
      builder.appendString("bytes=0-");
      builder.fin();
      return f;
    }).then((hetima.HetiHttpRequestRange  v) {
      ticket.assertTrue("a0", 0==v.start);
      ticket.assertTrue("a1", -1==v.end);
      ticket.fin();
    });
  }
}
