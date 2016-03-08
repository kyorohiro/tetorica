part of hetimanet_chrome;

class HetimaSocketChrome extends TetSocket {
  bool _isClose = false;
  int _mode = TetSocketBuilder.BUFFER_NOTIFY;
  int get mode => _mode;
  int clientSocketId;

  StreamController<HetimaReceiveInfo> _controllerReceive = new StreamController.broadcast();
  StreamController<HetimaCloseInfo> _controllerClose = new StreamController.broadcast();

  HetimaSocketChrome.empty({int mode:TetSocketBuilder.BUFFER_NOTIFY}) {
    _mode = mode;
  }

  HetimaSocketChrome(int _clientSocketId,{int mode:TetSocketBuilder.BUFFER_NOTIFY}) {
    HetimaChromeSocketManager.getInstance().addClient(_clientSocketId, this);
    chrome.sockets.tcp.setPaused(_clientSocketId, false);
    clientSocketId = _clientSocketId;
    _mode = mode;
  }

  Stream<HetimaReceiveInfo> get onReceive => _controllerReceive.stream;

  void onReceiveInternal(chrome.ReceiveInfo info) {
    updateTime();
    List<int> tmp = info.data.getBytes();
    buffer.appendIntList(tmp, 0, tmp.length);
    List<int> b= [];
    if(_mode == TetSocketBuilder.BUFFER_NOTIFY) {
      b = info.data.getBytes();
    }
    _controllerReceive.add(new HetimaReceiveInfo(b));
  }

  Future<HetimaSendInfo> send(List<int> data) async {
    updateTime();
    chrome.ArrayBuffer buffer = new chrome.ArrayBuffer.fromBytes(data);
    chrome.SendInfo info = await chrome.sockets.tcp.send(clientSocketId, buffer);
    updateTime();
    if(info.resultCode < 0) {
      throw info.resultCode;
    }
    return new HetimaSendInfo(info.resultCode);
  }

  Future<HetimaSocketInfo> getSocketInfo() async {
    chrome.SocketInfo info = await chrome.sockets.tcp.getInfo(clientSocketId);
    HetimaSocketInfo ret = new HetimaSocketInfo()
      ..localAddress = info.localAddress
      ..localPort = info.localPort
      ..peerAddress = info.peerAddress
      ..peerPort = info.peerPort;
    return ret;
  }

  Future<TetSocket> connect(String peerAddress, int peerPort) async {
    chrome.SocketProperties properties = new chrome.SocketProperties();
    chrome.CreateInfo info = await chrome.sockets.tcp.create(properties);
    await chrome.sockets.tcp.connect(info.socketId, peerAddress, peerPort);
    chrome.sockets.tcp.setPaused(info.socketId, false);
    clientSocketId = info.socketId;
    HetimaChromeSocketManager.getInstance().addClient(info.socketId, this);
    return this;
  }

  void close() {
    super.close();
    if (_isClose) {
      return;
    }
    updateTime();
    chrome.sockets.tcp.close(clientSocketId).then((d) {
      //print("##closed()");
    });
    _controllerClose.add(new HetimaCloseInfo());
    HetimaChromeSocketManager.getInstance().removeClient(clientSocketId);
    _isClose = true;
  }

  Stream<HetimaCloseInfo> get onClose => _controllerClose.stream;
}
