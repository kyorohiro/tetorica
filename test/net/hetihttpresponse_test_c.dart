//import 'package:unittest/unittest.dart' as unit;
import 'package:tetorica/core.dart' as hetima;
import 'package:tetorica/hetimanet.dart' as hetima;
import 'dart:async' as async;

void main() {
  hetima.HetiTest test = new hetima.HetiTest("tt");
  {
    hetima.HetiTestTicket ticket = test.test("request-line", 3000);
    new async.Future.sync(() {
      hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
      hetima.EasyParser parser = new hetima.EasyParser(builder);
      async.Future<hetima.HetiRequestLine> ret = hetima.HetiHttpResponse.decodeRequestLine(parser);
      builder.appendString("GET /xxx/yy/zz HTTP/1.1\r\n");
      return ret;
    }).then((hetima.HetiRequestLine v) {
      ticket.assertTrue("a0", "GET" == v.method);
      ticket.assertTrue("a1", "HTTP/1.1" == v.httpVersion);
      ticket.assertTrue("a2", "/xxx/yy/zz" == v.requestTarget);
      ticket.fin();
    });
  }

  {
    hetima.HetiTestTicket ticket = test.test("request message", 3000);
    new async.Future.sync(() {
      hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
      hetima.EasyParser parser = new hetima.EasyParser(builder);
      async.Future<hetima.HetiHttpRequestMessageWithoutBody> ret = hetima.HetiHttpResponse.decodeRequestMessage(parser);
      builder.appendString("GET /xxx/yy/zz HTTP/1.1\r\n");
      builder.appendString("aaa: bb\r\n");
      builder.appendString("ccc: ddd\r\n");
      builder.appendString("\r\n");
      builder.fin();
      return ret;
    }).then((hetima.HetiHttpRequestMessageWithoutBody v) {
      ticket.assertTrue("a0", "GET" == v.line.method);
      ticket.assertTrue("a1", "HTTP/1.1" == v.line.httpVersion);
      ticket.assertTrue("a2", "/xxx/yy/zz" == v.line.requestTarget);
      ticket.assertTrue("a3", "bb" == v.find("aaa").fieldValue);
      ticket.assertTrue("a4", "ddd" == v.find("ccc").fieldValue);
      ticket.fin();
    });
  }

}
