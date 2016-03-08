part of hetimanet;


class HetiSocketBuilderSimu extends TetSocketBuilder {
  TetSocket createClient({int mode:TetSocketBuilder.BUFFER_NOTIFY}) {
    return null;
  }
  TetUdpSocket createUdpClient() {
    return new HetiUdpSocketSimu();
  }
  TetSocket createSecureClient({int mode:TetSocketBuilder.BUFFER_NOTIFY}) {
    return null;
  }
  Future<TetServerSocket> startServer(String address, int port, {int mode:TetSocketBuilder.BUFFER_NOTIFY}) {
    return null;
  }
  Future<List<TetNetworkInterface>> getNetworkInterfaces() {
    return null;
  }
}

class HetiUdpSocketSimuMane {
  HetiUdpSocketSimuMane._em();
  static HetiUdpSocketSimuMane _mane = new HetiUdpSocketSimuMane._em();
  static HetiUdpSocketSimuMane get instance => _mane;

  Map<String, HetiUdpSocketSimu> nodes = {};
}

class HetiUdpSocketSimu extends TetUdpSocket {
  String _ip = "";
  int _port;

  String get ip => _ip;
  int get port => _port;

  Future<TetBindResult> bind(String ip, int port,{bool multicast:false}) {
    this._ip = ip;
    this._port = port;
    return new Future(() {
      if (HetiUdpSocketSimuMane.instance.nodes.containsKey("${ip}:${port}")) {
        throw {"": "already start"};
      }
      HetiUdpSocketSimuMane.instance.nodes["${ip}:${port}"] = this;
    });
  }

  Future<dynamic> close() {
    return new Future(() {
      HetiUdpSocketSimuMane.instance.nodes["${ip}:${port}"] = this;
    });
  }

  Future<TetUdpSendInfo> send(List<int> buffer, String ip, int port) {
    return new Future(() {
      if (!HetiUdpSocketSimuMane.instance.nodes.containsKey("${ip}:${port}")) {
        throw {"": "not found"};
      }
      return HetiUdpSocketSimuMane.instance.nodes["${ip}:${port}"].receive(buffer, _ip, _port);
    });
  }

  StreamController _receiveMessage = new StreamController.broadcast();
  Stream<TetReceiveUdpInfo> get onReceive => _receiveMessage.stream;

  Future receive(List<int> bytes, String ip, int port) {
    return new Future(() {
      _receiveMessage.add(new TetReceiveUdpInfo(bytes, ip, port));
    });
  }
}
