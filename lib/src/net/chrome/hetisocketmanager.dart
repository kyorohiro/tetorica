part of hetimanet.chrome;

class HetimaSocketBuilderChrome extends HetimaSocketBuilder {
  HetimaSocket createClient({int mode:HetimaSocketBuilder.BUFFER_NOTIFY}) {
    return new HetimaSocketChrome.empty(mode:mode);
  }

  Future<HetimaServerSocket> startServer(String address, int port, {int mode:HetimaSocketBuilder.BUFFER_NOTIFY}) {
    return HetimaServerSocketChrome.startServer(address, port, mode:mode);
  }

  HetimaUdpSocket createUdpClient() {
    return new HetimaUdpSocketChrome.empty();
  }

  Future<List<HetimaNetworkInterface>> getNetworkInterfaces() async {
    List<HetimaNetworkInterface> interfaceList = new List();
    List<chrome.NetworkInterface> nl = await chrome.system.network.getNetworkInterfaces();
    for (chrome.NetworkInterface i in nl) {
      HetimaNetworkInterface inter = new HetimaNetworkInterface();
      inter.address = i.address;
      inter.prefixLength = i.prefixLength;
      inter.name = i.name;
      interfaceList.add(inter);
    }
    return interfaceList;
  }
}

class HetimaChromeSocketManager {
  Map<int, HetimaServerSocket> _serverList = new Map();
  Map<int, HetimaSocket> _clientList = new Map();
  Map<int, HetimaUdpSocket> _udpList = new Map();
  static final HetimaChromeSocketManager _instance = new HetimaChromeSocketManager._internal();
  factory HetimaChromeSocketManager() {
    return _instance;
  }

  HetimaChromeSocketManager._internal() {
    manageServerSocket();
  }

  static HetimaChromeSocketManager getInstance() {
    return _instance;
  }

  void manageServerSocket() {
    chrome.sockets.tcpServer.onAccept.listen((chrome.AcceptInfo info) {
      //print("--accept ok " + info.socketId.toString() + "," + info.clientSocketId.toString());
      HetimaServerSocketChrome server = _serverList[info.socketId];
      if (server != null) {
        server.onAcceptInternal(info);
      }
    });

    chrome.sockets.tcpServer.onAcceptError.listen((chrome.AcceptErrorInfo info) {
     // print("--accept error");
    });

    bool closeChecking = false;
    chrome.sockets.tcp.onReceive.listen((chrome.ReceiveInfo info) {
      // core.print("--receive " + info.socketId.toString() + "," + info.data.getBytes().length.toString());
      HetimaSocketChrome socket = _clientList[info.socketId];
      if (socket != null) {
        socket.onReceiveInternal(info);
      }
    });
    chrome.sockets.tcp.onReceiveError.listen((chrome.ReceiveErrorInfo info) {
      //print("--receive error " + info.socketId.toString() + "," + info.resultCode.toString());
      HetimaSocketChrome socket = _clientList[info.socketId];
      if (socket != null) {
        closeChecking = true;
        socket.close();
      }
    });

    chrome.sockets.udp.onReceive.listen((chrome.ReceiveInfo info) {
      HetimaUdpSocketChrome socket = _udpList[info.socketId];
      if (socket != null) {
        socket.onReceiveInternal(info);
      }
    });
    chrome.sockets.udp.onReceiveError.listen((chrome.ReceiveErrorInfo info) {
      //print("--receive udp error " + info.socketId.toString() + "," + info.resultCode.toString());
    });
  }

  void addServer(chrome.CreateInfo info, HetimaServerSocketChrome socket) {
    _serverList[info.socketId] = socket;
  }

  void removeServer(chrome.CreateInfo info) {
    _serverList.remove(info.socketId);
  }

  void addClient(int socketId, HetimaSocketChrome socket) {
    _clientList[socketId] = socket;
  }

  void removeClient(int socketId) {
    _clientList.remove(socketId);
  }

  void addUdp(int socketId, HetimaUdpSocket socket) {
    _udpList[socketId] = socket;
  }

  void removeUdp(int socketId) {
    _udpList.remove(socketId);
  }
}
