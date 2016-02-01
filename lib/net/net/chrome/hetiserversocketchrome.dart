part of hetimanet_chrome;

class HetimaServerSocketChrome extends TetServerSocket {
  StreamController<TetSocket> _controller = new StreamController();
  chrome.CreateInfo _mInfo = null;
  int _mode = 0;

  HetimaServerSocketChrome._internal(chrome.CreateInfo info, {int mode:TetSocketBuilder.BUFFER_NOTIFY}) {
    _mInfo = info;
    _mode = mode;
  }

  Stream<TetSocket> onAccept() => _controller.stream;

  void onAcceptInternal(chrome.AcceptInfo info) {
    _controller.add(new HetimaSocketChrome(info.clientSocketId,mode:_mode));
  }

  void close() {
    chrome.sockets.tcpServer.close(_mInfo.socketId);
    HetimaChromeSocketManager.getInstance().removeServer(_mInfo);
  }

  static Future<TetServerSocket> startServer(String address, int port, {int mode:TetSocketBuilder.BUFFER_NOTIFY}) async {
    chrome.CreateInfo info = await chrome.sockets.tcpServer.create(new chrome.SocketProperties());
    HetimaChromeSocketManager.getInstance();
    try {
      await chrome.sockets.tcpServer.listen(info.socketId, address, port);
      HetimaServerSocketChrome server = new HetimaServerSocketChrome._internal(info, mode:mode);
      HetimaChromeSocketManager.getInstance().addServer(info, server);
      return server;
    } catch (e) {
      throw new HetimaServerSocketError()..id = HetimaServerSocketError.ID_START;
    }
  }
}
