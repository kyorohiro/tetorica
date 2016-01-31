part of hetimanet_dartio;

class HetimaServerSocketDartIo extends TetServerSocket {
  bool _verbose = false;
  bool get verbose => _verbose;

  ServerSocket _server = null;
  StreamController<TetSocket> _acceptStream = new StreamController.broadcast();
  int _mode = 0;

  HetimaServerSocketDartIo(ServerSocket server, {verbose: false, int mode:TetSocketBuilder.BUFFER_NOTIFY}) {
    _verbose = verbose;
    _server = server;
    _mode = mode;
    _server.listen((Socket socket) {
      _acceptStream.add(new HetimaSocketDartIo.fromSocket(socket, verbose: _verbose, mode:mode));
    });
  }

  static Future<TetServerSocket> startServer(String address, int port,
      {verbose: false,int mode:TetSocketBuilder.BUFFER_NOTIFY}) async {
    ServerSocket server = await ServerSocket.bind(address, port);
    return new HetimaServerSocketDartIo(server, verbose: verbose, mode:mode);
  }

  @override
  void close() {
    _server.close();
  }

  @override
  Stream<TetSocket> onAccept() {
    return _acceptStream.stream;
  }
}
