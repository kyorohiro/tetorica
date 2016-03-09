part of hetimanet_stun;

class StunHeader {
  static const int bindingRequest = 0x0001;
  static const int bindingResponse = 0x0101;
  static const int bindingErrorResponse = 0x0111;
  static const int sharedSecretRequest = 0x0002;
  static const int sharedSecretResponse = 0x0102;
  static const int sharedSecretErrorResponse = 0x0112;

  int type;

  StunTransactionID transactionID;
  List<StunAttribute> attributes = [];

  StunHeader(this.type, {this.transactionID: null}) {
    if (transactionID == null) {
      transactionID = new StunTransactionID.random();
    }
  }

  @override
  String toString() {
    Map t = {};
    t["type"] = toStringFromType(type);
    t["transactionID"] = transactionID.toString();
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
