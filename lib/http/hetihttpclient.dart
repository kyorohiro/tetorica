library hetimanet.http.client;

import 'dart:convert' as convert;
import 'dart:async' as async;
import 'package:tetorica/core.dart';
import '../net.dart';
import 'hetihttpresponse.dart';
import 'chunkedbuilderadapter.dart';
import '../net/tmp/rfctable.dart';

class HetiHttpClientResponse {
  HetiHttpMessageWithoutBody message;
  HetimaReader body;
  int getContentLength() {
    HetiHttpResponseHeaderField contentLength = message.find(RfcTable.HEADER_FIELD_CONTENT_LENGTH);
    if (contentLength != null) {
      try {
        return int.parse(contentLength.fieldValue);
      } catch (e) {}
    }
    return -1;
  }
}

class HetiHttpClientConnectResult {}

class HetiHttpClient {
  TetSocketBuilder _socketBuilder;
  TetSocket socket = null;
  String host;
  int port;

  bool _verbose = false;

  HetiHttpClient(TetSocketBuilder socketBuilder, {HetimaDataBuilder dataBuilder: null, bool verbose: false}) {
    _socketBuilder = socketBuilder;
    _verbose = verbose;
  }

  async.Future<HetiHttpClientConnectResult> connect(String _host, int _port) async {
    host = _host;
    port = _port;
    socket = _socketBuilder.createClient();
    if (socket == null) {
      throw {};
    }
    log("<hetihttpclient f=connect> ${socket}");
    TetSocket s = await socket.connect(host, port);
    if (s == null) {
      throw {};
    }
    return new HetiHttpClientConnectResult();
  }

  async.Future<HetiHttpClientResponse> get(String path, [Map<String, String> header]) async {
    Map<String, String> headerTmp = {};
    headerTmp["Host"] = host + ":" + port.toString();
    headerTmp["Connection"] = "Close";
    if (header != null) {
      for (String key in header.keys) {
        headerTmp[key] = header[key];
      }
    }

    ArrayBuilder builder = new ArrayBuilder();
    builder.appendString("GET" + " " + path + " " + "HTTP/1.1" + "\r\n");
    for (String key in headerTmp.keys) {
      builder.appendString("" + key + ": " + headerTmp[key] + "\r\n");
    }
    builder.appendString("\r\n");

    socket.onReceive.listen((HetimaReceiveInfo info) {
      if (_verbose == true) {
        log("<hetihttpclient f=onReceive> Length${path}:${info.data.length} ${convert.UTF8.decode(info.data, allowMalformed:true)}</hetihttpclient>");
      }
    });
    socket.send(builder.toList()).then((HetimaSendInfo info) {});
    return handleResponse();
  }

  //
  // post
  //
  async.Future<HetiHttpClientResponse> post(String path, List<int> body, [Map<String, String> header]) async {
    Map<String, String> headerTmp = {};
    headerTmp["Host"] = host + ":" + port.toString();
    headerTmp["Connection"] = "Close";
    if (header != null) {
      for (String key in header.keys) {
        headerTmp[key] = header[key];
      }
    }
    headerTmp[RfcTable.HEADER_FIELD_CONTENT_LENGTH] = body.length.toString();

    ArrayBuilder builder = new ArrayBuilder();
    builder.appendString("POST" + " " + path + " " + "HTTP/1.1" + "\r\n");
    for (String key in headerTmp.keys) {
      builder.appendString("" + key + ": " + headerTmp[key] + "\r\n");
    }

    builder.appendString("\r\n");
    builder.appendIntList(body, 0, body.length);

    //
    socket.onReceive.listen((HetimaReceiveInfo info) {});
    socket.send(builder.toList()).then((HetimaSendInfo info) {});

    return handleResponse();
  }

  //
  // mpost for upnp protocol
  //
  async.Future<HetiHttpClientResponse> mpost(String path, List<int> body, [Map<String, String> header]) async {
    Map<String, String> headerTmp = {};
    headerTmp["Host"] = host + ":" + port.toString();
    headerTmp["Connection"] = "Close";
    if (header != null) {
      for (String key in header.keys) {
        headerTmp[key] = header[key];
      }
    }
    headerTmp[RfcTable.HEADER_FIELD_CONTENT_LENGTH] = body.length.toString();

    ArrayBuilder builder = new ArrayBuilder();
    builder.appendString("M-POST" + " " + path + " " + "HTTP/1.1" + "\r\n");
    for (String key in headerTmp.keys) {
      builder.appendString("" + key + ": " + headerTmp[key] + "\r\n");
    }

    builder.appendString("\r\n");
    builder.appendIntList(body, 0, body.length);
    //
    socket.onReceive.listen((HetimaReceiveInfo info) {});
    socket.send(builder.toList()).then((HetimaSendInfo info) {});

    return handleResponse();
  }

  async.Future<HetiHttpClientResponse> handleResponse() async {
    EasyParser parser = new EasyParser(socket.buffer);
    HetiHttpMessageWithoutBody message = await HetiHttpResponse.decodeHttpMessage(parser);
    HetiHttpClientResponse result = new HetiHttpClientResponse();
    result.message = message;

    HetiHttpResponseHeaderField transferEncodingField = message.find("Transfer-Encoding");

    if (transferEncodingField == null || transferEncodingField.fieldValue != "chunked") {
      result.body = new HetimaReaderAdapter(socket.buffer, message.index);
      if (result.message.contentLength > 0) {
        await  result.body.getByteFuture(0, result.message.contentLength);
        result.body.immutable = true;
      } else {
        result.body.immutable = true;
      }
    } else {
      result.body = new ChunkedBuilderAdapter(new HetimaReaderAdapter(socket.buffer, message.index)).start();
    }
    return result;
  }

  void close() {
    if (socket != null) {
      socket.close();
    }
  }

  void log(String message) {
    if (_verbose) {
      print("++${message}");
    }
  }
}
