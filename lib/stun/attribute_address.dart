part of hetimanet_stun;

class StunAddressAttribute extends StunAttribute {
  static const int familyIPv4 = 0x0001;
  static const int familyIPv6 = 0x0002;
  static int _length(family) => (family == familyIPv4 ? (2 + 2 + 4) : (2 + 2 + 16));

  int type;
  int get length => _length(family);
  int family;
  int port;
  String address;

  StunAddressAttribute(this.type, this.family, this.port, this.address) {}

  static StunAddressAttribute decode(List<int> buffer, int start, {List<int> expectType: const [StunAttribute.mappedAddress, StunAttribute.responseAddress, StunAttribute.changedAddress, StunAttribute.sourceAddress, StunAttribute.reflectedFrom]}) {
    int type = core.ByteOrder.parseShort(buffer, start + 0, core.ByteOrder.BYTEORDER_BIG_ENDIAN);
    if (false == expectType.contains(type)) {
      throw {"mes": ""};
    }
    int tlength = core.ByteOrder.parseShort(buffer, start + 2, core.ByteOrder.BYTEORDER_BIG_ENDIAN);
    int family = core.ByteOrder.parseShort(buffer, start + 4, core.ByteOrder.BYTEORDER_BIG_ENDIAN);
    if (tlength != _length(family)) {
      throw {"mes": ""};
    }
    int port = core.ByteOrder.parseShort(buffer, start + 6, core.ByteOrder.BYTEORDER_BIG_ENDIAN);
    String address = null;
    if (family == familyIPv4) {
      address = net.IPConv.toIPv4String(buffer, start: start + 8);
    } else {
      address = net.IPConv.toIPv6String(buffer, start: start + 8);
    }
    return new StunAddressAttribute(type, family, port, address);
  }

  Uint8List encode() {
    List<int> buffer = [];
    buffer.addAll(core.ByteOrder.parseShortByte(type, core.ByteOrder.BYTEORDER_BIG_ENDIAN));
    buffer.addAll(core.ByteOrder.parseShortByte(_length(family), core.ByteOrder.BYTEORDER_BIG_ENDIAN));
    buffer.addAll(core.ByteOrder.parseShortByte(family, core.ByteOrder.BYTEORDER_BIG_ENDIAN));
    buffer.addAll(core.ByteOrder.parseShortByte(port, core.ByteOrder.BYTEORDER_BIG_ENDIAN));
    buffer.addAll(net.IPConv.toRawIP(this.address));
    return new Uint8List.fromList(buffer);
  }

  int get hashCode {
    int result = type.hashCode;
    result = 37 * result + family.hashCode;
    result = 37 * result + port.hashCode;
    result = 37 * result + address.hashCode;
    return result;
  }

  bool operator ==(o) {
    if (o == null || false == (o is StunAddressAttribute)) {
      return false;
    }
    StunAddressAttribute p = o;
    return (type == p.type && family == p.family &&port == p.port && address == p.address);
  }
}
