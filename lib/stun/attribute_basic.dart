part of hetimanet_stun;

class StunBasicMessage extends StunAttribute {
  int type; //2byte
  int get length => value.length; //32bit 4byte
  List<int> value = [];

  StunBasicMessage(this.type, List<int> v) {
    value.addAll(v);
  }

  Uint8List encode() {
    List<int> buffer = [];
    buffer.addAll(core.ByteOrder.parseShortByte(type, core.ByteOrder.BYTEORDER_BIG_ENDIAN));
    buffer.addAll(core.ByteOrder.parseShortByte(value.length, core.ByteOrder.BYTEORDER_BIG_ENDIAN));
    buffer.addAll(value);
    return new Uint8List.fromList(buffer);
  }

  static StunBasicMessage decode(List<int> buffer, int start) {
    int type = core.ByteOrder.parseShort(buffer, start + 0, core.ByteOrder.BYTEORDER_BIG_ENDIAN);
    int tlength = core.ByteOrder.parseShort(buffer, start + 2, core.ByteOrder.BYTEORDER_BIG_ENDIAN);

    if (type == StunAttribute.userName || type == StunAttribute.password) {
      if ((tlength % 4) != 0) {
        throw {"mes": ""};
      }
    }
    if (type == StunAttribute.messageIntegrity) {
      if (tlength != 64) {
        throw {"mes": ""};
      }
    }

    return new StunBasicMessage(type, buffer.sublist(start + 4, start + 4 + tlength));
  }

  int get hashCode {
    int result = type.hashCode;
    for (int i in value) {
      result = 37 * result + i.hashCode;
    }
    return result;
  }

  bool operator ==(o) {
    if (o == null || false == (o is StunBasicMessage)) {
      return false;
    }
    StunBasicMessage p = o;
    if (type != p.type || value.length != p.value.length) {
      return false;
    }

    for (int i = 0; i < value.length; i++) {
      if (value[i] != p.value[i]) {
        return false;
      }
    }
    return true;
  }
}
