part of hetimanet_dartio;

class TetSocketBuilderDartIO extends TetSocketBuilder {
  bool _verbose = false;
  bool get verbose => _verbose;

  TetSocketBuilderDartIO({verbose: false}) {
    _verbose = verbose;
  }

  TetSocket createClient({int mode:TetSocketBuilder.BUFFER_NOTIFY}) {
    return new HetimaSocketDartIo(verbose: _verbose,mode:mode);
  }

  Future<TetServerSocket> startServer(String address, int port, {int mode:TetSocketBuilder.BUFFER_NOTIFY}) async {
    return HetimaServerSocketDartIo.startServer(address, port, verbose: _verbose, mode:mode);
  }

  HetimaUdpSocket createUdpClient() {
    return new HetimaUdpSocketDartIo(verbose: _verbose);
  }

  Future<List<TetNetworkInterface>> getNetworkInterfaces() async {
    List<NetworkInterface> interfaces = await NetworkInterface.list(includeLoopback: true, includeLinkLocal: true);
    List<TetNetworkInterface> ret = [];
    for (NetworkInterface i in interfaces) {
      for (InternetAddress a in i.addresses) {
        int prefixLength = 24;
        if (a.rawAddress.length > 4) {
          prefixLength = 64;
        }
        ret.add(new TetNetworkInterface()
          ..address = a.address
          ..name = i.name
          ..prefixLength = prefixLength);
      }
    }
    return ret;
  }
}

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

class HetimaSocketDartIo extends TetSocket {
  static Random _random = new Random(new DateTime.now().millisecond);
  bool _verbose = false;
  bool get verbose => _verbose;
  Socket _socket = null;
  int _mode = 0;

  HetimaSocketDartIo({verbose: false, int mode:TetSocketBuilder.BUFFER_NOTIFY}) {
    _verbose = verbose;
    _mode = mode;
  }

  HetimaSocketDartIo.fromSocket(Socket socket, {verbose: false, int mode:TetSocketBuilder.BUFFER_NOTIFY}) {
    _verbose = verbose;
    _socket = socket;
    _mode = mode;
  }

  bool _nowConnecting = false;
  StreamController<HetimaCloseInfo> _closeStream = new StreamController.broadcast();
  StreamController<HetimaReceiveInfo> _receiveStream = new StreamController.broadcast();

  @override
  Future<TetSocket> connect(String peerAddress, int peerPort) async {
    if (_nowConnecting == true || _socket != null) {
      throw "connecting now";
    }

    try {
      HetiIP.toRawIP(peerAddress);
    } catch (e) {
      List<InternetAddress> hosts = await InternetAddress.lookup(peerAddress);
      if (hosts == null || hosts.length == 0) {
        throw {"error": "not found ip from host ${peerAddress}"};
      }
      int n = 0;
      if (hosts.length > 1) {
        n = _random.nextInt(hosts.length - 1);
      }
      peerAddress = hosts[n].address;
    }
    try {
      _nowConnecting = true;
      _socket = await Socket.connect(peerAddress, peerPort);
      _socket.listen((List<int> data) {
        log('<<<lis>>> '); //${data.length} ${UTF8.decode(data)}');
        this.buffer.appendIntList(data, 0, data.length);
        List<int> b= [];
        if(_mode == TetSocketBuilder.BUFFER_NOTIFY) {
          b = data;
        }
        _receiveStream.add(new HetimaReceiveInfo(b));
      }, onDone: () {
        log('<<<Done>>>');
        _socket.close();
        _closeStream.add(new HetimaCloseInfo());
      }, onError: (e) {
        log('<<<Got error>>> $e');
        _socket.close();
        _closeStream.add(new HetimaCloseInfo());
      });
      return this;
    } finally {
      _nowConnecting = false;
    }
  }

  @override
  Future<HetimaSocketInfo> getSocketInfo() async {
    HetimaSocketInfo info = new HetimaSocketInfo();
    info.localAddress = _socket.address.address;
    info.localPort = _socket.port;
    info.peerAddress = _socket.remoteAddress.address;
    info.peerPort = _socket.remotePort;
    return info;
  }

  void close() {
    if (isClosed == false) {
      _socket.close();
    }
    super.close();
  }

  @override
  Stream<HetimaCloseInfo> get onClose => _closeStream.stream;

  @override
  Stream<HetimaReceiveInfo> get onReceive => _receiveStream.stream;

  @override
  Future<HetimaSendInfo> send(List<int> data) async {
    await _socket.add(data);
    return new HetimaSendInfo(0);
  }

  log(String message) {
    if (_verbose) {
      print("d..${message}");
    }
  }
}

class HetimaUdpSocketDartIo extends HetimaUdpSocket {
  static Random _random = new Random(new DateTime.now().millisecond);
  bool _verbose = false;
  bool get verbose => _verbose;
  RawDatagramSocket _udpSocket = null;
  HetimaUdpSocketDartIo({verbose: false}) {
    _verbose = verbose;
  }

  bool _isBindingNow = false;
  StreamController<HetimaReceiveUdpInfo> _receiveStream = new StreamController.broadcast();

  @override
  Future<HetimaBindResult> bind(String address, int port, {bool multicast: false}) async {
    if (_isBindingNow != false) {
      throw "now binding";
    }
    _isBindingNow = true;
    try {
      RawDatagramSocket socket = await RawDatagramSocket.bind(address, port, reuseAddress: true);
      _udpSocket = socket;
      socket.multicastLoopback = multicast;
      socket.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.READ) {
          Datagram dg = socket.receive();
          if (dg != null) {
            log("read ${dg.address}:${dg.port} ${dg.data.length}");
            _receiveStream.add(new HetimaReceiveUdpInfo(dg.data, dg.address.address, dg.port));
          }
        }
      });
    } finally {
      _isBindingNow = false;
    }
    return new HetimaBindResult();
  }

  @override
  Future close() async {
    _udpSocket.close();
    return 0;
  }

  @override
  Stream<HetimaReceiveUdpInfo> get onReceive => _receiveStream.stream;

  @override
  Future<HetimaUdpSendInfo> send(List<int> buffer, String address, int port) async {
    try {
      try {
        HetiIP.toRawIP(address);
      } catch (e) {
        List<InternetAddress> hosts = await InternetAddress.lookup(address);
        if (hosts == null || hosts.length == 0) {
          throw {"error": "not found ip from host ${address}"};
        }
        int n = 0;
        if (hosts.length > 1) {
          n = _random.nextInt(hosts.length - 1);
        }
        address = hosts[n].address;
      }
      _udpSocket.send(buffer, new InternetAddress(address), port);
      return await new HetimaUdpSendInfo(0);
    } catch (e) {
      throw e;
    }
  }

  log(String message) {
    if (_verbose) {
      print("d..${message}");
    }
  }
}
