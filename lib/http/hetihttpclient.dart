part of hetimanet_http;

class HttpClientResponse {
  HttpClientResponseInfo message;
  TetReader body;
}

//class HttpClientConnectResult {}

class HttpClient {
  TetSocketBuilder _socketBuilder;
  TetSocket socket = null;
  String host;
  int port;

  bool _verbose = false;

  HttpClient(TetSocketBuilder socketBuilder, {HetimaDataBuilder dataBuilder: null, bool verbose: false}) {
    _socketBuilder = socketBuilder;
    _verbose = verbose;
  }

//  Future<HttpClientConnectResult>
  Future connect(String _host, int _port) async {
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
    //return new HttpClientConnectResult();
  }

  Future<HttpClientResponse> get(String path, {Map<String, String> header}) async {
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
  Future<HttpClientResponse> post(String path, List<int> body, {Map<String, String> header}) async {
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
  Future<HttpClientResponse> mpost(String path, List<int> body, [Map<String, String> header]) async {
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

  Future<HttpClientResponse> handleResponse() async {
    EasyParser parser = new EasyParser(socket.buffer);
    HttpClientResponseInfo message = await HetiHttpResponse.decodeHttpMessage(parser);
    HttpClientResponse result = new HttpClientResponse();
    result.message = message;

    HetiHttpResponseHeaderField transferEncodingField = message.find("Transfer-Encoding");

    if (transferEncodingField == null || transferEncodingField.fieldValue != "chunked") {
      result.body = new TetReaderAdapter(socket.buffer, message.index);
      if (result.message.contentLength > 0) {
        await result.body.getBytes(0, result.message.contentLength);
        result.body.immutable = true;
      } else {
        result.body.immutable = true;
      }
    } else {
      result.body = new ChunkedBuilderAdapter(new TetReaderAdapter(socket.buffer, message.index)).start();
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
