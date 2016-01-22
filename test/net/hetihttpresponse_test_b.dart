//import 'package:unittest/unittest.dart' as unit;
import 'package:tetorica/core.dart' as hetima;
import 'package:tetorica/hetimanet.dart' as hetima;
import 'package:unittest/unittest.dart' as unit;

import 'dart:async';

void main() {
  unit.group("response_b", () {
    unit.test("http/1.1", () async {
      hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
      hetima.EasyParser parser = new hetima.EasyParser(builder);
      Future<String> ret = hetima.HetiHttpResponse.decodeHttpVersion(parser);
      builder.appendString("HTTP/1.1");
      unit.expect("HTTP/1.1", await ret);
    });
  });
/*
  {
    hetima.HetiTestTicket ticket = test.test("reasonphase", 3000);
    new async.Future.sync(() {
      hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
      hetima.EasyParser parser = new hetima.EasyParser(builder);
      async.Future<String> ret = hetima.HetiHttpResponse.decodeReasonPhrase(parser);
      builder.appendString("aaa bbb");
      builder.appendString(" ccc");
      builder.appendString("\r\n");
      return ret;
    }).then((String v) {
      ticket.assertTrue(""+v, "aaa bbb ccc" == v);
      ticket.fin();
    });
  }

  {
    hetima.HetiTestTicket ticket = test.test("reasonphase_2", 3000);
    new async.Future.sync(() {
      hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
      hetima.EasyParser parser = new hetima.EasyParser(builder);
      async.Future<String> ret = hetima.HetiHttpResponse.decodeReasonPhrase(parser);
      builder.appendString("aaa bbb");
      builder.appendString(" ccc");
      builder.fin();
      return ret;
    }).then((String v) {
      ticket.assertTrue(""+v, "aaa bbb ccc" == v);
      ticket.fin();
    });
  }

  {
    hetima.HetiTestTicket ticket = test.test("decodeCrlf_1", 3000);
    new async.Future.sync(() {
      hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
      hetima.EasyParser parser = new hetima.EasyParser(builder);
      async.Future<String> ret = hetima.HetiHttpResponse.decodeCrlf(parser);
      builder.appendString("\n");
      builder.fin();
      return ret;
    }).then((String v) {
      ticket.assertTrue(""+v, "\n" == v);
    }).catchError((e){

    }).whenComplete((){
      ticket.fin();
    });
  }

  {
    hetima.HetiTestTicket ticket = test.test("decodeCrlf_2", 3000);
    new async.Future.sync(() {
      hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
      hetima.EasyParser parser = new hetima.EasyParser(builder);
      async.Future<String> ret = hetima.HetiHttpResponse.decodeCrlf(parser);
      builder.appendString(" ");
      builder.fin();
      return ret;
    }).then((String v) {
      ticket.assertTrue("f="+v+":", false);
    }).catchError((e){
      ticket.assertTrue("", true);
    }).whenComplete((){
      ticket.fin();
    });
  }
  {
    hetima.HetiTestTicket ticket = test.test("statusline", 3000);
    new async.Future.sync(() {
      hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
      hetima.EasyParser parser = new hetima.EasyParser(builder);
      async.Future<hetima.HetiHttpResponseStatusLine> ret = hetima.HetiHttpResponse.decodeStatusline(parser);
      builder.appendString("HTTP/1.1 200 tes test test\r\n");
      builder.fin();
      return ret;
    }).then((hetima.HetiHttpResponseStatusLine v) {
      ticket.assertTrue("statusCode"+v.statusCode.toString(), v.statusCode ==200);
      ticket.assertTrue("statusCode"+v.version, v.version == "HTTP/1.1");
      ticket.assertTrue("statusCode"+v.statusPhrase, v.statusPhrase == "tes test test");
    }).catchError((e){
      ticket.assertTrue("", false);
    }).whenComplete((){
      ticket.fin();
    });
  }

  {
    hetima.HetiTestTicket ticket = test.test("decodeHeaderField_1f", 3000);
    new async.Future.sync(() {
      hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
      hetima.EasyParser parser = new hetima.EasyParser(builder);
      async.Future<hetima.HetiHttpResponseHeaderField> ret = hetima.HetiHttpResponse.decodeHeaderField(parser);
      builder.appendString("test:   aaa\r\n");
      builder.fin();
      return ret;
    }).then((hetima.HetiHttpResponseHeaderField v) {
      ticket.assertTrue("fn="+v.fieldName+":", v.fieldName ==  "test");
      ticket.assertTrue("fv="+v.fieldValue+":", v.fieldValue ==  "aaa");
    }).catchError((e){
      ticket.assertTrue("", false);
    }).whenComplete((){
      ticket.fin();
    });
  }

  {
    hetima.HetiTestTicket ticket = test.test("decodeHeaderField_2f", 3000);
    new async.Future.sync(() {
      hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
      hetima.EasyParser parser = new hetima.EasyParser(builder);
      async.Future<hetima.HetiHttpResponseHeaderField> ret = hetima.HetiHttpResponse.decodeHeaderField(parser);
      builder.appendString("test   aaa\r\n");
      builder.fin();
      return ret;
    }).then((hetima.HetiHttpResponseHeaderField v) {
      ticket.assertTrue("", false);
    }).catchError((e){
      ticket.assertTrue("", true);
    }).whenComplete((){
      ticket.fin();
    });
  }
  {
    hetima.HetiTestTicket ticket = test.test("decodeHeaderFields_1f", 3000);
    new async.Future.sync(() {
      hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
      hetima.EasyParser parser = new hetima.EasyParser(builder);
      async.Future<List<hetima.HetiHttpResponseHeaderField>> ret = hetima.HetiHttpResponse.decodeHeaderFields(parser);
      builder.appendString("test1:   aaa\r\n");
      builder.appendString("test2:   bbb\r\n\r\n");
      builder.fin();
      return ret;
    }).then((List<hetima.HetiHttpResponseHeaderField> v) {
      ticket.assertTrue("fn0="+v[0].fieldName+":", v[0].fieldName ==  "test1");
      ticket.assertTrue("fv0="+v[0].fieldValue+":", v[0].fieldValue ==  "aaa");
      ticket.assertTrue("fn1="+v[1].fieldName+":", v[1].fieldName ==  "test2");
      ticket.assertTrue("fv1="+v[1].fieldValue+":", v[1].fieldValue ==  "bbb");
    }).catchError((e){
      ticket.assertTrue("", false);
    }).whenComplete((){
      ticket.fin();
    });
  }

  {
    hetima.HetiTestTicket ticket = test.test("decodeHttpMessage_1f", 3000);
    new async.Future.sync(() {
      hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
      hetima.EasyParser parser = new hetima.EasyParser(builder);
      async.Future<hetima.HetiHttpMessageWithoutBody> ret =
          hetima.HetiHttpResponse.decodeHttpMessage(parser);
      builder.appendString("HTTP/1.1 200 tes test test\r\n");
      builder.appendString("test1:   aaa\r\n");
      builder.appendString("test2:   bbb\r\n\r\n");
      builder.fin();
      return ret;
    }).then((hetima.HetiHttpMessageWithoutBody v) {
      ticket.assertTrue("fn0="+v.headerField[0].fieldName+":", v.headerField[0].fieldName ==  "test1");
      ticket.assertTrue("fv0="+v.headerField[0].fieldValue+":", v.headerField[0].fieldValue ==  "aaa");
      ticket.assertTrue("fn1="+v.headerField[1].fieldName+":", v.headerField[1].fieldName ==  "test2");
      ticket.assertTrue("fv1="+v.headerField[1].fieldValue+":", v.headerField[1].fieldValue ==  "bbb");
    }).catchError((e){
      ticket.assertTrue("", false);
    }).whenComplete((){
      ticket.fin();
    });
  }
  {
    hetima.HetiTestTicket ticket = test.test("decodeHttpMessage_2f", 3000);
    new async.Future.sync(() {
      hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
      hetima.EasyParser parser = new hetima.EasyParser(builder);
      async.Future<hetima.HetiHttpMessageWithoutBody> ret =
          hetima.HetiHttpResponse.decodeHttpMessage(parser);
      builder.appendString("HTTP/1.1 200 tes test test\r\n");
      builder.appendString("test1:   aaa\r\n");
      builder.appendString("test2   bbb\r\n\r\n");
      builder.fin();
      return ret;
    }).then((hetima.HetiHttpMessageWithoutBody v) {
      ticket.assertTrue("fn0="+v.headerField[0].fieldName+":", v.headerField[0].fieldName ==  "test1");
      ticket.assertTrue("fv0="+v.headerField[0].fieldValue+":", v.headerField[0].fieldValue ==  "aaa");
      ticket.assertTrue("fn1="+v.headerField[1].fieldName+":", v.headerField[1].fieldName ==  "test2");
      ticket.assertTrue("fv1="+v.headerField[1].fieldValue+":", v.headerField[1].fieldValue ==  "bbb");
      ticket.assertTrue("", false);
    }).catchError((e){
      ticket.assertTrue("", true);
    }).whenComplete((){
      ticket.fin();
    });
  }
  */
}
