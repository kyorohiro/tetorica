part of hetimanet_chrome;

class TetServerSocketChrome extends TetServerSocket {
  StreamController<TetSocket> _controller = new StreamController();
  chrome.CreateInfo _mInfo = null;
  TetSocketMode _mode = TetSocketMode.bufferAndNotify;

  TetServerSocketChrome._internal(chrome.CreateInfo info, {TetSocketMode mode:TetSocketMode.bufferAndNotify}) {
    _mInfo = info;
    _mode = mode;
  }

  Stream<TetSocket> onAccept() => _controller.stream;

  void onAcceptInternal(chrome.AcceptInfo info) {
    _controller.add(new TetSocketChrome(info.clientSocketId,mode:_mode));
  }

  void close() {
    chrome.sockets.tcpServer.close(_mInfo.socketId);
    TetChromeSocketManager.getInstance().removeServer(_mInfo);
  }

  static Future<TetServerSocket> startServer(String address, int port, {TetSocketMode mode:TetSocketMode.bufferAndNotify}) async {
    chrome.CreateInfo info = await chrome.sockets.tcpServer.create(new chrome.SocketProperties());
    TetChromeSocketManager.getInstance();
    try {
      await chrome.sockets.tcpServer.listen(info.socketId, address, port);
      TetServerSocketChrome server = new TetServerSocketChrome._internal(info, mode:mode);
      TetChromeSocketManager.getInstance().addServer(info, server);
      return server;
    } catch (e) {
      throw {};
    }
  }
}
