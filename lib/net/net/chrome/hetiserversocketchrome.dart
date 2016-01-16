part of hetimanet.chrome;

class HetimaServerSocketChrome extends HetimaServerSocket {
  StreamController<HetimaSocket> _controller = new StreamController();
  chrome.CreateInfo _mInfo = null;
  int _mode = 0;

  HetimaServerSocketChrome._internal(chrome.CreateInfo info, {int mode:HetimaSocketBuilder.BUFFER_NOTIFY}) {
    _mInfo = info;
    _mode = mode;
  }

  Stream<HetimaSocket> onAccept() => _controller.stream;

  void onAcceptInternal(chrome.AcceptInfo info) {
    _controller.add(new HetimaSocketChrome(info.clientSocketId,mode:_mode));
  }

  void close() {
    chrome.sockets.tcpServer.close(_mInfo.socketId);
    HetimaChromeSocketManager.getInstance().removeServer(_mInfo);
  }

  static Future<HetimaServerSocket> startServer(String address, int port, {int mode:HetimaSocketBuilder.BUFFER_NOTIFY}) async {
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
