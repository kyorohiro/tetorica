part of hetimanet_stun;

class StunClientSendHeaderResult {
  String remoteAddress;
  int remotePort;
  StunHeader header;
  StunClientSendHeaderResult(this.remoteAddress, this.remotePort, this.header) {}

  bool passed() {
    return (false == header.haveError() && null != header.getAttribute([StunAttribute.mappedAddress]));
  }
}

enum StunNatType {
   openInternet,
   blockUdp,
   symmetricUdpFirewall,
   symmetricUdp, fullConeNat, symmetricNat, restricted, portRestricted, stunServerThrowError }

// https://tools.ietf.org/html/rfc3489
// 9 Client Behavior
class StunClient {
  net.TetSocketBuilder builder;
  String address;
  int port;
  String stunServer;
  int stunServerPort;
  Duration _defaultTimeout = new Duration(seconds: 5);

  Map<StunTransactionID, Completer<StunClientSendHeaderResult>> cash = {};
  net.TetUdpSocket _udp = null;

  StunClient(this.builder, this.stunServer, this.stunServerPort, {this.address: "0.0.0.0", this.port: 0}) {
    ;
  }

  Future prepare() async {
    if (_udp != null) {
      return;
    }

    net.TetUdpSocket u = builder.createUdpClient();
    await u.bind(address, port);
    _udp = u;
    _udp.onReceive.listen((net.TetReceiveUdpInfo info) {
      //print("-- ${info.data}");
      StunHeader header = StunHeader.decode(info.data, 0);
      if (cash.containsKey(header.transactionID)) {
        //print("-AA- ${cash.containsKey(header.transactionID)} \n -AB-${header} ${cash}");
        cash.remove(header.transactionID).complete(new StunClientSendHeaderResult(info.remoteAddress, info.remotePort, header));
        //print("-B- ${cash.containsKey(header.transactionID)} ${cash}");
      }
    });
  }

  Future close() async {
    if (_udp != null) {
      _udp.close();
      _udp = null;
    }
  }

  Future<StunClientSendHeaderResult> sendHeader(StunHeader header, {Duration timeout}) async {
    if (timeout == null) {
      timeout = _defaultTimeout;
    }
    if (cash.containsKey(header.transactionID)) {
      cash.remove(header.transactionID).completeError({"mes": "id is deprecated"});
    }
    cash[header.transactionID] = new Completer();
    _udp.send(header.encode(), stunServer, stunServerPort);
    cash[header.transactionID].future.timeout(timeout, onTimeout: () {
      //print("+1+ ${cash.containsKey(header.transactionID)} ${cash}");
      cash.remove(header.transactionID).completeError({"mes": "timeout"});
    });
    //print("+2+");
    return cash[header.transactionID].future;
  }

}
