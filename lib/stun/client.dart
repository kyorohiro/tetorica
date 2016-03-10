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

enum StunNatType { openInternet, blockUdp, symmetricUdp, fullConeNat, symmetricNat, restricted, portRestricted, stunServerThrowError }

// https://tools.ietf.org/html/rfc3489
// 9 Client Behavior
class StunClient {
  net.TetSocketBuilder builder;
  String address;
  int port;
  String stunServer;
  int stunServerPort;
  Duration _defaultTimeout = new Duration(seconds: 2);

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
      StunHeader header = StunHeader.decode(info.data, 0);
      if (cash.containsKey(header.transactionID)) {
        cash.remove(header.transactionID).complete(new StunClientSendHeaderResult(info.remoteAddress, info.remotePort, header));
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
      header.transactionID = new StunTransactionID.random();
    }
    cash[header.transactionID] = new Completer();
    _udp.send(header.encode(), stunServer, stunServerPort);
    cash[header.transactionID].future.timeout(timeout, onTimeout: () {
      cash.remove(header.transactionID).completeError({"mes": "timeout"});
    });
    return cash[header.transactionID].future;
  }

}
