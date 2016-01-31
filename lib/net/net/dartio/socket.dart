part of hetimanet_dartio;

class HetimaSocketDartIo extends TetSocket {
  static Random _random = new Random(new DateTime.now().millisecond);
  bool _verbose = false;
  bool get verbose => _verbose;
  Socket _socket = null;
  int _mode = 0;
  bool _isSecure = false;
  bool get isSecure => _isSecure;

  HetimaSocketDartIo({verbose: false, int mode:TetSocketBuilder.BUFFER_NOTIFY, bool isSecure:false}) {
    _verbose = verbose;
    _mode = mode;
    _isSecure = isSecure;
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
      if(isSecure == true) {
        _socket = await SecureSocket.connect(peerAddress, peerPort);
      } else {
        _socket = await Socket.connect(peerAddress, peerPort);
      }

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
