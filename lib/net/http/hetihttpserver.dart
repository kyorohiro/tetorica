library hetimanet.http.server;

import 'dart:async' as async;
import 'package:tetorica/core.dart';
import '../net/hetisocket.dart';
import 'hetihttpresponse.dart';

class HetiHttpServer {

  async.StreamController _controllerOnNewRequest = new async.StreamController.broadcast();
//  HetimaSocketBuilder _builder;
  String host;
  int port;
  HetimaServerSocket _serverSocket = null;
  HetiHttpServer._internal(HetimaServerSocket s) {
    _serverSocket = s;
  }

  void close() {
    if(_serverSocket != null) {
      _serverSocket.close();
      _serverSocket = null;
      _controllerOnNewRequest.close();
      _controllerOnNewRequest = null;
    }
  }

  static async.Future<HetiHttpServer> bind(HetimaSocketBuilder builder, String address, int port) {
    async.Completer<HetiHttpServer> completer = new async.Completer();
    builder.startServer(address, port).then((HetimaServerSocket serverSocket){
      if(serverSocket == null) {
        completer.completeError({});
        return;
      }
      HetiHttpServer server = new HetiHttpServer._internal(serverSocket);
      completer.complete(server);
      serverSocket.onAccept().listen((HetimaSocket socket){
        EasyParser parser = new EasyParser(socket.buffer);
        HetiHttpResponse.decodeRequestMessage(parser).then((HetiHttpRequestMessageWithoutBody body){
          HetiHttpServerRequest request = new HetiHttpServerRequest();
          request.socket = socket;
          request.info = body;
          server._controllerOnNewRequest.add(request);
          parser.buffer.getByteFuture(0, body.index).then((List v) {
            //print(convert.UTF8.decode(v));
          }).catchError((e){
            ;
          });
        });
      });
    }).catchError((e){
      completer.completeError(e);
    });
    return completer.future;
  }

  async.Stream<HetiHttpServerRequest> onNewRequest() {
    return _controllerOnNewRequest.stream;
  }
}

class HetiHttpServerRequest
{
  HetimaSocket socket;
  HetiHttpRequestMessageWithoutBody info;
}
