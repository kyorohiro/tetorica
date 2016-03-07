part of hetimanet_stun;

class StunChangeRequest extends StunAttribute {
  int type; //2byte
  int get length => 4; //32bit 4byte
  bool changeIP;
  bool changePort;

  Uint8List encode() {
    List<int> buffer = [];
    buffer.addAll(core.ByteOrder.parseShortByte(type, core.ByteOrder.BYTEORDER_BIG_ENDIAN));
    buffer.addAll(core.ByteOrder.parseShortByte(length, core.ByteOrder.BYTEORDER_BIG_ENDIAN));
    int v = 0;
    v |= (changePort == true ? (0x01 << 1) : 0);
    v |= (changeIP == true ? (0x01 << 2) : 0);
    buffer.addAll(core.ByteOrder.parseIntByte(v, core.ByteOrder.BYTEORDER_BIG_ENDIAN));
    return new Uint8List.fromList(buffer);
  }

  static StunChangeRequest decode(List<int> buffer, int start) {
    int type = core.ByteOrder.parseShort(buffer, start + 0, core.ByteOrder.BYTEORDER_BIG_ENDIAN);
    if (StunAttribute.changeRequest != type) {
      throw {"mes": ""};
    }
    int tlength = core.ByteOrder.parseShort(buffer, start + 2, core.ByteOrder.BYTEORDER_BIG_ENDIAN);
    if (tlength != 4) {
      throw {"mes": ""};
    }
    int v = core.ByteOrder.parseInt(buffer, start + 4, core.ByteOrder.BYTEORDER_BIG_ENDIAN);
    bool changePort = (v & (0x01 << 1) != 0);
    bool changeIP = (v & (0x01 << 2) != 0);

    return new StunChangeRequest(changeIP, changePort);
  }

  StunChangeRequest(this.changeIP, this.changePort) {
    type = StunAttribute.changeRequest;
  }

  int get hashCode {
    int result = type.hashCode;
    result = 37 * result + changeIP.hashCode;
    result = 37 * result + changePort.hashCode;
    return result;
  }

  bool operator ==(o) {
    if (o == null || false == (o is StunChangeRequest)) {
      return false;
    }
    StunChangeRequest p = o;
    return (type == p.type && changeIP == p.changeIP && changePort == p.changePort);
  }
}
