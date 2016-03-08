part of hetimanet;


abstract class TetSocketBuilder {
  static const int BUFFER_NOTIFY = 0;
  static const int BUFFER_ONLY = 1;
  TetSocket createClient({int mode:BUFFER_NOTIFY});
  TetSocket createSecureClient({int mode:BUFFER_NOTIFY});
  TetUdpSocket createUdpClient();
  Future<TetServerSocket> startServer(String address, int port, {int mode:BUFFER_NOTIFY}) ;
  Future<List<TetNetworkInterface>> getNetworkInterfaces();
}

abstract class TetServerSocket {
  Stream<TetSocket> onAccept();
  void close();
}

abstract class TetSocket {
  int lastUpdateTime = 0;
  heti.ArrayBuilder _buffer = new heti.ArrayBuilder();
  heti.ArrayBuilder get buffer => _buffer;
  Future<TetSocket> connect(String peerAddress, int peerPort) ;
  Future<TetSendInfo> send(List<int> data);
  Future<TetSocketInfo> getSocketInfo();
  Stream<TetReceiveInfo> onReceive;
  Stream<TetCloseInfo> onClose;
  bool isClosed = false;
  void close() {
    _buffer.immutable = true;
    isClosed = true;
  }

  void updateTime() {
    lastUpdateTime = (new DateTime.now()).millisecondsSinceEpoch;
  }

  Future clearBuffer() async {
    _buffer.clearInnerBuffer(_buffer.currentSize,reuse:false);
    _buffer.clear();
  }
}

abstract class TetUdpSocket {
  ///
  /// The result code returned from the underlying network call. A
  /// negative value indicates an error.
  ///
  Future<TetBindResult> bind(String address, int port, {bool multicast:false});
  Future<TetUdpSendInfo> send(List<int> buffer, String address, int port);
  Stream<TetReceiveUdpInfo> onReceive;
  Future<dynamic> close();
}

class TetBindResult {

}

class TetNetworkInterface
{
  String address;
  int prefixLength;
  String name;
}

class TetSocketInfo {
  String peerAddress = "";
  int peerPort = 0;
  String localAddress = "";
  int localPort = 0;
}

class TetSendInfo {
  int resultCode = 0;
  TetSendInfo(int _resultCode) {
    resultCode = _resultCode;
  }
}

class TetReceiveInfo {
  List<int> data;
  TetReceiveInfo(List<int> _data) {
    data = _data;
  }
}

class TetCloseInfo {

}

//
// print("a:"+s["remoteAddress"]);
// print("p:"+s["remotePort"]
//
class TetReceiveUdpInfo {
  List<int> data;
  String remoteAddress;
  int remotePort;
  TetReceiveUdpInfo(List<int> adata, String aremoteAddress, int aport) {
    data = adata;
    remoteAddress = aremoteAddress;
    remotePort = aport;
  }
}

class TetUdpSendInfo {
  int resultCode = 0;
  TetUdpSendInfo(int _resultCode) {
    resultCode = _resultCode;
  }
}
