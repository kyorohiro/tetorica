part of hetimanet_chrome;

class HetimaUdpSocketChrome extends TetUdpSocket {
  chrome.CreateInfo _info = null;
  StreamController<HetimaReceiveUdpInfo> _receiveStream = new StreamController();
  HetimaUdpSocketChrome.empty() {}

  Future<HetimaBindResult> bind(String address, int port, {bool multicast: false}) async {
    chrome.SocketProperties properties = new chrome.SocketProperties();
    chrome.CreateInfo info = _info = await chrome.sockets.udp.create(properties);

    HetimaChromeSocketManager.getInstance().addUdp(info.socketId, this);
    await chrome.sockets.udp.setMulticastLoopbackMode(_info.socketId, multicast);
    int v = await chrome.sockets.udp.bind(_info.socketId, address, port);
    if (v < 0) {
      throw {"resultCode": v};
    }
    return new HetimaBindResult();
  }

  void onReceiveInternal(chrome.ReceiveInfo info) {
    if (_info.socketId != info.socketId) {
      return;
    }
    js.JsObject s = info.toJs();
    String remoteAddress = s["remoteAddress"];
    int remotePort = s["remotePort"];
    _receiveStream.add(new HetimaReceiveUdpInfo(info.data.getBytes(), remoteAddress, remotePort));
  }

  Future close() {
    HetimaChromeSocketManager.getInstance().removeUdp(_info.socketId);
    return chrome.sockets.udp.close(_info.socketId);
  }

  Stream<HetimaReceiveUdpInfo> get onReceive => _receiveStream.stream;

  Future<HetimaUdpSendInfo> send(List<int> buffer, String address, int port) async {
    chrome.SendInfo info = await chrome.sockets.udp.send(_info.socketId, new chrome.ArrayBuffer.fromBytes(buffer), address, port);
    if (info.resultCode < 0) {
      throw {"resultCode": info.resultCode};
    }
    return new HetimaUdpSendInfo(info.resultCode);
  }

}
