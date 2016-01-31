library hetimanet.base;
import 'dart:async' as async;
import 'package:tetorica/core.dart' as heti;

abstract class TetSocketBuilder {
  static const int BUFFER_NOTIFY = 0;
  static const int BUFFER_ONLY = 1;
  TetSocket createClient({int mode:BUFFER_NOTIFY});
  HetimaUdpSocket createUdpClient();
  async.Future<TetServerSocket> startServer(String address, int port, {int mode:BUFFER_NOTIFY}) ;
  async.Future<List<TetNetworkInterface>> getNetworkInterfaces();
}

abstract class TetServerSocket {
  async.Stream<TetSocket> onAccept();
  void close();
}

class HetimaServerSocketError {
  static const ID_NONE = 0;
  static const ID_START = 1;
  static const REASON_NONE = 0;
  int id = 0;
  int reason = 0;
}

abstract class TetSocket {
  int lastUpdateTime = 0;
  heti.ArrayBuilder _buffer = new heti.ArrayBuilder();
  heti.ArrayBuilder get buffer => _buffer;
  async.Future<TetSocket> connect(String peerAddress, int peerPort) ;
  async.Future<HetimaSendInfo> send(List<int> data);
  async.Future<HetimaSocketInfo> getSocketInfo();
  async.Stream<HetimaReceiveInfo> onReceive;
  async.Stream<HetimaCloseInfo> onClose;
  bool isClosed = false;
  void close() {
    _buffer.immutable = true;
    isClosed = true;
  }

  void updateTime() {
    lastUpdateTime = (new DateTime.now()).millisecondsSinceEpoch;
  }

  async.Future clearBuffer() async {
    _buffer.clearInnerBuffer(_buffer.size(),reuse:false);
    _buffer.clear();
  }
}

abstract class HetimaUdpSocket {
  ///
  /// The result code returned from the underlying network call. A
  /// negative value indicates an error.
  ///
  async.Future<HetimaBindResult> bind(String address, int port, {bool multicast:false});
  async.Future<HetimaUdpSendInfo> send(List<int> buffer, String address, int port);
  async.Stream<HetimaReceiveUdpInfo> onReceive;
  async.Future<dynamic> close();
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
