part of hetimanet_dartio;

class TetSocketBuilderDartIO extends TetSocketBuilder {
  bool _verbose = false;
  bool get verbose => _verbose;

  TetSocketBuilderDartIO({verbose: false}) {
    _verbose = verbose;
  }

  TetSocket createClient({int mode:TetSocketBuilder.BUFFER_NOTIFY, isSecure: false}) {
    return new HetimaSocketDartIo(verbose: _verbose,mode:mode);
  }

  TetSocket createSecureClient({int mode:TetSocketBuilder.BUFFER_NOTIFY}) {
    return new HetimaSocketDartIo(verbose: _verbose,mode:mode, isSecure: true);
  }

  Future<TetServerSocket> startServer(String address, int port, {int mode:TetSocketBuilder.BUFFER_NOTIFY}) async {
    return HetimaServerSocketDartIo.startServer(address, port, verbose: _verbose, mode:mode);
  }

  TetUdpSocket createUdpClient() {
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
