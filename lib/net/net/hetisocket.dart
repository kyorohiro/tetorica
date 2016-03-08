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
  Future<HetimaSendInfo> send(List<int> data);
  Future<HetimaSocketInfo> getSocketInfo();
  Stream<HetimaReceiveInfo> onReceive;
  Stream<HetimaCloseInfo> onClose;
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
  Future<HetimaBindResult> bind(String address, int port, {bool multicast:false});
  Future<HetimaUdpSendInfo> send(List<int> buffer, String address, int port);
  Stream<HetimaReceiveUdpInfo> onReceive;
  Future<dynamic> close();
}

class HetimaBindResult {

}

class TetNetworkInterface
{
  String address;
  int prefixLength;
  String name;
}

class HetimaSocketInfo {
  String peerAddress = "";
  int peerPort = 0;
  String localAddress = "";
  int localPort = 0;
}

class HetimaSendInfo {
  int resultCode = 0;
  HetimaSendInfo(int _resultCode) {
    resultCode = _resultCode;
  }
}

class HetimaReceiveInfo {
  List<int> data;
  HetimaReceiveInfo(List<int> _data) {
    data = _data;
  }
}

class HetimaCloseInfo {

}

//
// print("a:"+s["remoteAddress"]);
// print("p:"+s["remotePort"]
//
class HetimaReceiveUdpInfo {
  List<int> data;
  String remoteAddress;
  int remotePort;
  HetimaReceiveUdpInfo(List<int> adata, String aremoteAddress, int aport) {
    data = adata;
    remoteAddress = aremoteAddress;
    remotePort = aport;
  }
}

class HetimaUdpSendInfo {
  int resultCode = 0;
  HetimaUdpSendInfo(int _resultCode) {
    resultCode = _resultCode;
  }
}
