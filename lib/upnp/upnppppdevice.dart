part of hetimanet_upnp;

class UpnpPPPDevice {
  static const String KEY_SOAPACTION = "SOAPAction";
  static const String VALUE_PORT_MAPPING_PROTOCOL_UDP = "UDP";
  static const String VALUE_PORT_MAPPING_PROTOCOL_TCP = "TCP";
  static const int MODE_M_POST = 0;
  static const int MODE_POST = 1;
  static const int VALUE_ENABLE = 1;
  static const int VALUE_DISABLE = 0;

  UpnpDeviceInfo _base = null;
  String _serviceName = "WANPPPConnection";
  String _version = "1";
  bool _verbose = false;
  bool get verbose => _verbose;

  UpnpPPPDevice(UpnpDeviceInfo base, {bool verbose:false}) {
    _base = base;
    _verbose = verbose;

    String st = _base.getValue(UpnpDeviceInfo.KEY_ST, "WANIPConnection");
    if (st.contains("WANIPConnection")) {
      _serviceName = "WANIPConnection";
    }
//    String b = "";
    List<String> v = st.replaceAll(" |\t|\r|\n", "").split(":");
    _version = v.last;
    //print("${_version}");
  }

  /**
   * response.resultCode
   *  200 OK
   *  402 Invalid Args See UPnP Device Architecture section on Control.
   *  713 SpecifiedArrayIndexInvalid The specified array index is out of bounds
   */
  Future<UpnpGetGenericPortMappingResponse> requestGetGenericPortMapping(int newPortMappingIndex, [int mode = MODE_POST, UpnpDeviceServiceInfo serviceInfo = null]) async {
    if (getPPPService().length == 0) {
      throw {};
    }
    if (serviceInfo == null) {
      serviceInfo = getPPPService().first;
    }

    String requestBody =
        """<?xml version="1.0"?>\r\n<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><SOAP-ENV:Body><m:GetGenericPortMappingEntry xmlns:m="urn:schemas-upnp-org:service:${_serviceName}:${_version}"><NewPortMappingIndex>${newPortMappingIndex}</NewPortMappingIndex></m:GetGenericPortMappingEntry></SOAP-ENV:Body></SOAP-ENV:Envelope>\r\n""";
    String headerValue = """\"urn:schemas-upnp-org:service:${_serviceName}:${_version}#GetGenericPortMappingEntry\"""";

    UpnpPPPDeviceRequestResponse response = await request(serviceInfo, headerValue, requestBody, mode);
    return new UpnpGetGenericPortMappingResponse(response);
  }

  /**
   * return resultCode. if success then. return 200. ;
   */
  Future<UpnpAddPortMappingResponse> requestAddPortMapping(
      int newExternalPort, String newProtocol, int newInternalPort, String newInternalClient, int newEnabled, String newPortMappingDescription, int newLeaseDuration,
      [int mode = MODE_POST, UpnpDeviceServiceInfo serviceInfo = null]) async {
    if (getPPPService().length == 0) {
      throw {};
    }
    if (serviceInfo == null) {
      serviceInfo = getPPPService().first;
    }
    String headerValue = """\"urn:schemas-upnp-org:service:${_serviceName}:${_version}#AddPortMapping\"""";
    String requestBody =
        """<?xml version="1.0"?>\r\n<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><SOAP-ENV:Body><m:AddPortMapping xmlns:m="urn:schemas-upnp-org:service:${_serviceName}:${_version}">""" +
            """<NewRemoteHost></NewRemoteHost><NewExternalPort>${newExternalPort}</NewExternalPort><NewProtocol>${newProtocol}</NewProtocol><NewInternalPort>${newInternalPort}</NewInternalPort><NewInternalClient>${newInternalClient}</NewInternalClient><NewEnabled>${newEnabled}</NewEnabled><NewPortMappingDescription>${newPortMappingDescription}</NewPortMappingDescription><NewLeaseDuration>${newLeaseDuration}</NewLeaseDuration></m:AddPortMapping></SOAP-ENV:Body></SOAP-ENV:Envelope>\r\n""";

    UpnpPPPDeviceRequestResponse response = await request(serviceInfo, headerValue, requestBody, mode);
    return new UpnpAddPortMappingResponse(response.resultCode);
  }

  /**
   * return resultCode. if success then. return 200. ;
   */
  Future<UpnpDeletePortMappingResponse> requestDeletePortMapping(int newExternalPort, String newProtocol, [int mode = MODE_POST, UpnpDeviceServiceInfo serviceInfo = null]) async {
    if (getPPPService().length == 0) {
      throw {};
    }
    if (serviceInfo == null) {
      serviceInfo = getPPPService().first;
    }
    String requestBody =
        """<?xml version=\"1.0\"?>\r\n<SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\" SOAP-ENV:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\"><SOAP-ENV:Body><m:DeletePortMapping xmlns:m=\"urn:schemas-upnp-org:service:${_serviceName}:${_version}\">""" +
            """<NewRemoteHost></NewRemoteHost><NewExternalPort>${newExternalPort}</NewExternalPort><NewProtocol>${newProtocol}</NewProtocol></m:DeletePortMapping></SOAP-ENV:Body></SOAP-ENV:Envelope>\r\n""";
    String headerValue = """\"urn:schemas-upnp-org:service:${_serviceName}:${_version}#DeletePortMapping\"""";
    UpnpPPPDeviceRequestResponse response = await request(serviceInfo, headerValue, requestBody, mode);
    return new UpnpDeletePortMappingResponse(response.resultCode);
  }

  Future<UpnpGetExternalIPAddressResponse> requestGetExternalIPAddress([int mode = MODE_POST, UpnpDeviceServiceInfo serviceInfo = null]) async {
    if (getPPPService().length == 0) {
      throw {};
    }
    if (serviceInfo == null) {
      serviceInfo = getPPPService().first;
    }
    String headerValue = """\"urn:schemas-upnp-org:service:${_serviceName}:${_version}#GetExternalIPAddress\"""";
    String requestBody =
        """<?xml version="1.0"?>\r\n<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><m:GetExternalIPAddress xmlns:m="urn:schemas-upnp-org:service:${_serviceName}:${_version}"></m:GetExternalIPAddress></s:Body></s:Envelope>\r\n""";

    UpnpPPPDeviceRequestResponse response = await request(serviceInfo, headerValue, requestBody, mode);
    xml.XmlDocument document = xml.parse(response.body);
    Iterable<xml.XmlElement> elements = document.findAllElements("NewExternalIPAddress");
    if (elements.length > 0) {
      return new UpnpGetExternalIPAddressResponse(response.resultCode, elements.first.text);
    } else {
      return new UpnpGetExternalIPAddressResponse(response.resultCode, "");
    }
  }

  List<UpnpDeviceServiceInfo> getPPPService() {
    List<UpnpDeviceServiceInfo> deviceInfo = [];
    for (UpnpDeviceServiceInfo info in _base.serviceList) {
      if (info.serviceType.contains("WANIPConnection") || info.serviceType.contains("WANPPPConnection")) {
        deviceInfo.add(info);
      }
    }
    return deviceInfo;
  }

  Future<UpnpPPPDeviceRequestResponse> request(UpnpDeviceServiceInfo info, String soapAction, String bbody, int mode) async {
    String location = _base.getValue(UpnpDeviceInfo.KEY_LOCATION, "");
    if ("" == location) {
      throw {};
    }
    HttpClient client = new HttpClient(_base.getSocketBuilder());
    HttpUrl url = HttpUrlDecoder.decodeUrl(location);
    String host = url.host;
    String path = "/";
    int port = url.port;
    if (_base.urlBase != null && _base.urlBase.length != 0) {
      HttpUrl urlBase = HttpUrlDecoder.decodeUrl(location);
      host = urlBase.host;
      path = urlBase.path;
      port = urlBase.port;
    }

    if (info.controlURL != null && info.controlURL.length != 0) {
      path = info.controlURL;
    }
    log("upnppppdevice.request ${host}:${port}");
    await client.connect(host, port);
    HttpClientResponse response = null;
    if (mode == MODE_POST) {
      response = await client.post(path, convert.UTF8.encode(bbody), header:{KEY_SOAPACTION: soapAction, "Content-Type": "text/xml"});
    } else {
      response = await client.mpost(path, convert.UTF8.encode(bbody), header:{"MAN": "\"http://schemas.xmlsoap.org/soap/envelope/\"; ns=01", "01-SOAPACTION": soapAction, "Content-Type": "text/xml"});
    }

    await response.body.rawcompleterFin.future;
    int length = await response.body.getLength();
    List<int> body = await response.body.getBytes(0, length);
    return new UpnpPPPDeviceRequestResponse(response.message.line.statusCode, convert.UTF8.decode(body));
  }

  log(String message) {
    if (_verbose == true) {
      print("--${message}");
    }
  }
}
