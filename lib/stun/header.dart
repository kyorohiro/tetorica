part of hetimanet_stun;

enum StunRfcVersion { ref3489, ref5389 }

class StunHeader {
  static const int bindingRequest = 0x0001;
  static const int bindingResponse = 0x0101;
  static const int bindingErrorResponse = 0x0111;
  static const int sharedSecretRequest = 0x0002;
  static const int sharedSecretResponse = 0x0102;
  static const int sharedSecretErrorResponse = 0x0112;

  // rfc 5xxx  classs
  static const int classRequest = 0x00;
  static const int classIndication = 0x01;
  static const int classSuccessResponse = 0x02;
  static const int classFailureResponse = 0x03;
  static const int classInvalidMessageClass = 0xff;

  static const int typeBinding = 0x0001;
  static const int typeInvalid = 0xffff;


  int type;

  StunTransactionID transactionID;
  List<StunAttribute> attributes = [];

  StunHeader(this.type, {this.transactionID: null, StunRfcVersion version: StunRfcVersion.ref3489}) {
    if (transactionID == null) {
      if (version == StunRfcVersion.ref3489) {
        transactionID = new StunTransactionID.random();
      } else {
        transactionID = new StunTransactionID.randomRFC5389();
      }
    }
  }

  StunRfcVersion rfcVersion() {
    return transactionID.rfcVersion();
  }

  StunAttribute getAttribute(List<int> types) {
    for (StunAttribute a in attributes) {
      if (types.contains(a.type)) {
        return a;
      }
    }
    return null;
  }

  String mappedAddress() {
    StunAddressAttribute mappedAddress = getAttribute([StunAttribute.mappedAddress]);
    StunAddressAttribute xorMappedAddress = getAttribute([StunAttribute.xorMappedAddress]);

    if(StunRfcVersion.ref3489 == rfcVersion() || xorMappedAddress == null) {
      return (mappedAddress == null? "" : mappedAddress.address);
    } else {
      return (xorMappedAddress == null? "" : xorMappedAddress.xAddress(transactionID));
    }
  }

  int mappedPort() {
    StunAddressAttribute mappedAddress = getAttribute([StunAttribute.mappedAddress]);
    StunAddressAttribute xorMappedAddress = getAttribute([StunAttribute.xorMappedAddress]);

    if(StunRfcVersion.ref3489 == rfcVersion() || xorMappedAddress == null) {
      return (mappedAddress == null? 0 : mappedAddress.port);
    } else {
      return (xorMappedAddress == null? 0 : xorMappedAddress.port);
    }
  }

  bool haveError() {
    StunErrorCodeAttribute errorCode = getAttribute([StunAttribute.errorCode]);
    return (errorCode != null);
  }

  int errorCode() {
    StunErrorCodeAttribute errorCode = getAttribute([StunAttribute.errorCode]);
    if (errorCode == null) {
      return 0;
    } else {
      return errorCode.code;
    }
  }

  String errorMessage() {
    StunErrorCodeAttribute errorCode = getAttribute([StunAttribute.errorCode]);
    if (errorCode == null) {
      return "";
    } else {
      return errorCode.pharse;
    }
  }

  @override
  String toString() {
    Map t = {};
    t["type"] = toStringFromType(type);
    t["transactionID"] = transactionID.toString();
    List attr = [];
    for (StunAttribute a in attributes) {
      attr.add(a.toString());
    }
    t["attributes"] = attr;

    return "${t}";
  }

  // header bytes length is +20
  int get messageLength {
    int ret = 0;
    for (StunAttribute a in attributes) {
      ret += a.length + 4;
    }
    return ret;
  }

  Uint8List encode() {
    List<int> buffer = [];
    buffer.addAll(core.ByteOrder.parseShortByte(type, core.ByteOrderType.BigEndian));
    buffer.addAll(core.ByteOrder.parseShortByte(messageLength, core.ByteOrderType.BigEndian));
    buffer.addAll(transactionID.value);
    for (StunAttribute a in attributes) {
      buffer.addAll(a.encode());
    }
    return new Uint8List.fromList(buffer);
  }

  //
  //
  static StunHeader decode(List<int> buffer, int start) {
    int type = core.ByteOrder.parseShort(buffer, start + 0, core.ByteOrderType.BigEndian);
    StunHeader header = new StunHeader(type);

    int length = core.ByteOrder.parseShort(buffer, start + 2, core.ByteOrderType.BigEndian);
    header.transactionID = StunTransactionID.decode(buffer, start + 4);
    header.attributes.addAll(StunAttribute.decode(buffer, start: (start + 20), end: (start + 20 + length)));
    return header;
  }

  static String toStringFromType(int type) {
    switch (type) {
      case bindingRequest:
        return "bindingRequest (${type})";
      case bindingResponse:
        return "bindingResponse (${type})";
      case bindingErrorResponse:
        return "bindingErrorResponse (${type})";
      case sharedSecretRequest:
        return "sharedSecretRequest (${type})";
      case sharedSecretResponse:
        return "sharedSecretResponse (${type})";
      case sharedSecretErrorResponse:
        return "sharedSecretErrorResponse (${type})";
      default:
        return "none (${type})";
    }
  }
}
