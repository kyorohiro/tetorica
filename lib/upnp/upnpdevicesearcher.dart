part of hetimanet_upnp;


class UpnpDeviceSearcher {
  static const String SSDP_ADDRESS = "239.255.255.250";
  static const int SSDP_PORT = 1900;
  static const String SSDP_M_SEARCH =
      """M-SEARCH * HTTP/1.1\r\n""" + """MX: 3\r\n""" + """HOST: 239.255.255.250:1900\r\n""" + """MAN: "ssdp:discover"\r\n""" + """ST: upnp:rootdevice\r\n""" + """\r\n""";
  static const String SSDP_M_SEARCH_WANPPPConnectionV1 = """M-SEARCH * HTTP/1.1\r\n""" +
      """MX: 3\r\n""" +
      """HOST: 239.255.255.250:1900\r\n""" +
      """MAN: "ssdp:discover"\r\n""" +
      """ST: urn:schemas-upnp-org:service:WANPPPConnection:1\r\n""" +
      """\r\n""";
  static const String SSDP_M_SEARCH_WANIPConnectionV1 = """M-SEARCH * HTTP/1.1\r\n""" +
      """MX: 3\r\n""" +
      """HOST: 239.255.255.250:1900\r\n""" +
      """MAN: "ssdp:discover"\r\n""" +
      """ST: urn:schemas-upnp-org:service:WANIPConnection:1\r\n""" +
      """\r\n""";
  static const String SSDP_M_SEARCH_WANIPConnectionV2 = """M-SEARCH * HTTP/1.1\r\n""" +
      """MX: 3\r\n""" +
      """HOST: 239.255.255.250:1900\r\n""" +
      """MAN: "ssdp:discover"\r\n""" +
      """ST: urn:schemas-upnp-org:service:WANIPConnection:2\r\n""" +
      """\r\n""";

  static Future<UpnpDeviceSearcher> createInstance(TetSocketBuilder builder, {String ip: "0.0.0.0", bool verbose: false}) async {
    UpnpDeviceSearcher returnValue = new UpnpDeviceSearcher._fromSocketBuilder(builder, verbose: verbose);
    try {
      await returnValue._initialize(ip);
      return returnValue;
    } catch (e) {
      throw new UpnpDeviceSearcherException("unexpected(${e})", UpnpDeviceSearcherException.UNEXPECTED);
    }
  }

  TetSocketBuilder _socketBuilder = null;
  TetUdpSocket _socket = null;
  TetUdpSocket get rawsocket => _socket;
  StreamController<UpnpDeviceInfo> _streamer = new StreamController.broadcast();
  Stream<UpnpDeviceInfo> get onReceive => _streamer.stream;
  List<UpnpDeviceInfo> deviceInfoList = new List();
  bool _nowSearching = false;
  bool get nowSearching => _nowSearching;
  bool _verbose = false;

  UpnpDeviceSearcher._fromSocketBuilder(TetSocketBuilder builder, {bool verbose: false}) {
    _socketBuilder = builder;
    _verbose = verbose;
  }

  Future<int> close() => _socket.close();

  Future<dynamic> searchWanPPPDevice([int timeoutSec = 6]) async {
    if (_nowSearching == true) {
      throw new UpnpDeviceSearcherException("already run", UpnpDeviceSearcherException.ALREADY_RUN);
    }
    _nowSearching = true;
    deviceInfoList.clear();

    try {
      await _socket.send(convert.UTF8.encode(SSDP_M_SEARCH_WANPPPConnectionV1.replaceAll("MX: 3", "MX: ${timeoutSec~/2}")), SSDP_ADDRESS, SSDP_PORT).catchError((e){});
      await _socket.send(convert.UTF8.encode(SSDP_M_SEARCH_WANIPConnectionV1.replaceAll("MX: 3", "MX: ${timeoutSec~/2}")), SSDP_ADDRESS, SSDP_PORT).catchError((e){});
      await _socket.send(convert.UTF8.encode(SSDP_M_SEARCH_WANIPConnectionV2.replaceAll("MX: 3", "MX: ${timeoutSec~/2}")), SSDP_ADDRESS, SSDP_PORT).catchError((e){});
    } catch (e) {
      _nowSearching = false;
      throw new UpnpDeviceSearcherException("failed search", UpnpDeviceSearcherException.FAILED_SEARCH);
    }

    return new Future.delayed(new Duration(seconds: (timeoutSec)), () {
      _nowSearching = false;
      return {};
    });
  }

  extractDeviceInfoFromUdpResponse(List<int> buffer) async {
    ArrayBuilder builder = new ArrayBuilder();
    EasyParser parser = new EasyParser(builder);
    builder.appendIntList(buffer, 0, buffer.length);
    HttpClientResponseInfo message = await HetiHttpResponse.decodeHttpMessage(parser);
    UpnpDeviceInfo info = new UpnpDeviceInfo(message.headerField, _socketBuilder, verbose:_verbose);

    if (!deviceInfoList.contains(info)) {
      await info.extractService();
      if(!deviceInfoList.contains(info)){
        log("find ${info}");
        deviceInfoList.add(info);
        _streamer.add(info);
      }
    }
  }

  Future<TetBindResult> _initialize(String address) {
    _socket = _socketBuilder.createUdpClient();
    _socket.onReceive.listen((TetReceiveUdpInfo info) {
      log("<udp f=onReceive>" + convert.UTF8.decode(info.data) + "</udp>");
      extractDeviceInfoFromUdpResponse(info.data);
    });
    return _socket.bind(address, 0, multicast: true);
  }

  log(String message) {
    if (_verbose == true) {
      print("--${message}");
    }
  }
}

class UpnpDeviceSearcherException extends StateError {
  static const int ALREADY_RUN = 0;
  static const int UNEXPECTED = 1;
  static const int FAILED_SEARCH = 2;
  int id = 0;
  UpnpDeviceSearcherException(String mes, int id) : super(mes) {
    this.id = id;
  }

  String toString() {
    return message;
  }
}
