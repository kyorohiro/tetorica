part of hetimanet_upnp;

class UpnpPPPDeviceRequestResponse {
  UpnpPPPDeviceRequestResponse(int _resultCode, String _body) {
    body = _body;
    resultCode = _resultCode;
  }
  String body;
  int resultCode;
}

class UpnpGetExternalIPAddressResponse {
  int resultCode = 200;
  String externalIp = "";
  UpnpGetExternalIPAddressResponse(int _resultCode, String _externalIp) {
    resultCode = _resultCode;
    externalIp = _externalIp;
  }
}

class UpnpAddPortMappingResponse {
  int resultCode = 200;
  UpnpAddPortMappingResponse(int _resultCode) {
    resultCode = _resultCode;
  }
}

class UpnpDeletePortMappingResponse {
  int resultCode = 200;
  UpnpDeletePortMappingResponse(int _resultCode) {
    resultCode = _resultCode;
  }
}

class UpnpGetGenericPortMappingResponse {
  static final String KEY_NewRemoteHost = "NewRemoteHost";
  static final String KEY_NewExternalPort = "NewExternalPort";
  static final String KEY_NewProtocol = "NewProtocol";
  static final String KEY_NewInternalPort = "NewInternalPort";
  static final String KEY_NewInternalClient = "NewInternalClient";
  static final String KEY_NewEnabled = "NewEnabled";
  static final String KEY_NewPortMappingDescription = "NewPortMappingDescription";
  static final String KEY_NewLeaseDuration = "NewLeaseDuration";

  UpnpPPPDeviceRequestResponse _response = null;
  UpnpGetGenericPortMappingResponse(UpnpPPPDeviceRequestResponse response) {
    _response = response;
  }

  int get resultCode => _response.resultCode;

  String getValue(String key, String defaultValue) {
    if (_response.resultCode != 200) {
      return defaultValue;
    }
    xml.XmlDocument document = xml.parse(_response.body);
    Iterable<xml.XmlElement> elements = document.findAllElements(key);
    if (elements == null || elements.length <= 0) {
      return defaultValue;
    }
    return elements.first.text;
  }

  @override
  String toString() {
    return _response.body.toString();
  }
}
