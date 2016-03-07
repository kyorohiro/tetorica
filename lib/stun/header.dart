part of hetimanet_turn;

class StunMessageHeader {
  static const int bindingRequest = 0x0001;
  static const int bindingResponse = 0x0101;
  static const int bindingErrorResponse = 0x0111;
  static const int sharedSecretRequest = 0x0002;
  static const int sharedSecretResponse = 0x0102;
  static const int sharedSecretErrorResponse = 0x0112;

  int type;

  StunMessageHeaderTransactionID transactionID;
  List<StunMessageAttribute> attributes = [];

  StunMessageHeader(this.type, {this.transactionID: null}) {
    if (transactionID == null) {
      transactionID = new StunMessageHeaderTransactionID.random();
    }
  }

  // header bytes length is +20
  int get messageLength {
    int ret = 0;
    for (StunMessageAttribute a in attributes) {
      ret += a.length + 4;
    }
    return ret;
  }

  Uint8List encode() {
    List<int> buffer = [];
    buffer.addAll(core.ByteOrder.parseShortByte(type, core.ByteOrder.BYTEORDER_BIG_ENDIAN));
    buffer.addAll(core.ByteOrder.parseShortByte(messageLength, core.ByteOrder.BYTEORDER_BIG_ENDIAN));
    buffer.addAll(transactionID.value);
    for (StunMessageAttribute a in attributes) {
      buffer.addAll(a.encode());
    }
    return new Uint8List.fromList(buffer);
  }

  //
  //
  static StunMessageHeader decode(List<int> buffer, int start) {
    int type = core.ByteOrder.parseShort(buffer, start + 0, core.ByteOrder.BYTEORDER_BIG_ENDIAN);
    StunMessageHeader header = new StunMessageHeader(type);

    int length = core.ByteOrder.parseShort(buffer, start + 2, core.ByteOrder.BYTEORDER_BIG_ENDIAN);
    header.transactionID = StunMessageHeaderTransactionID.decode(buffer, start+4);
    header.attributes.addAll(StunMessageAttribute.decode(buffer,start:(start+20),end:(start+20+length)));
    return header;
  }
}
