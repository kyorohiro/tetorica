library hetimanet.http.client.helper;

import 'dart:async' as async;
import 'package:tetorica/core.dart';
import '../net/hetisocket.dart';
import 'hetihttpclient.dart';


class HetiHttpClientHelper {
  String _address;
  int _port;
  HetimaSocketBuilder _socketBuilder;
  //HetimaDataBuilder _fileBuilder;
  String get address => _address;
  int get port => _port;

  HetiHttpClientHelper(String address, int port, HetimaSocketBuilder socketBuilder, HetimaDataBuilder fileBuilder) {
    this._address = address;
    this._port = port;
    this._socketBuilder = socketBuilder;
  //  this._fileBuilder = fileBuilder;
  }

  async.Future<HetimaData> get(String pathAndOption) {
    HetiHttpClient client  = new HetiHttpClient(_socketBuilder);
    client.connect(_address, _port).then((HetiHttpClientConnectResult b){
      return client.get(pathAndOption);
    }).then((HetiHttpClientResponse res) {
      ;
    });
  }
}
