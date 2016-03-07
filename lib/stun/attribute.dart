part of hetimanet_turn;

abstract class StunMessageAttribute {
  static const int mappedAddress = 0x0001;
  static const int responseAddress = 0x0002;
  static const int changeRequest = 0x0003;
  static const int sourceAddress = 0x0004;
  static const int changedAddress = 0x0005;
  static const int userName = 0x0006;
  static const int password = 0x0007;
  static const int messageIntegrity = 0x0008;
  static const int errorCode = 0x0009;
  static const int unknownAttribute = 0x000a;
  static const int reflectedFrom = 0x000b;
  int get type; //2byte
  int get length; //2byte
  Uint8List encode();
//  List<int> get value; //...
}

class StunAddressAttribute extends StunMessageAttribute {
  static const int familyIPv4 = 0x0001;
  static const int familyIPv6 = 0x0002;

  int type;
  int get length => (family == familyIPv4 ? (2 + 2 + 4) : (2 + 2 + 8));
  int family;
  int port;
  String address;

  StunAddressAttribute(this.type, this.family, this.port, this.address) {}

  static StunAddressAttribute decode(List<int> buffer, int start, {List<int> expectType: const [StunMessageAttribute.mappedAddress, StunMessageAttribute.responseAddress, StunMessageAttribute.changedAddress]}) {
    int type = core.ByteOrder.parseShort(buffer, start + 0, core.ByteOrder.BYTEORDER_BIG_ENDIAN);
    if (false == expectType.contains(type)) {
      throw {"mes": ""};
    }
    int tlength = core.ByteOrder.parseShort(buffer, start + 2, core.ByteOrder.BYTEORDER_BIG_ENDIAN);
    int family = core.ByteOrder.parseShort(buffer, start + 4, core.ByteOrder.BYTEORDER_BIG_ENDIAN);
    if (tlength != (family == familyIPv4 ? (2 + 2 + 4) : (2 + 2 + 8))) {
      throw {"mes": ""};
    }
    int port = core.ByteOrder.parseShort(buffer, start + 6, core.ByteOrder.BYTEORDER_BIG_ENDIAN);
    String address = net.HetiIP.toIPString(buffer, start: start + 8);

    return new StunAddressAttribute(type, family, port, address);
  }

  Uint8List encode() {
    List<int> buffer = [];
    buffer.addAll(core.ByteOrder.parseShortByte(type, core.ByteOrder.BYTEORDER_BIG_ENDIAN));
    buffer.addAll(core.ByteOrder.parseShortByte((family == familyIPv4 ? (2 + 2 + 4) : (2 + 2 + 8)), core.ByteOrder.BYTEORDER_BIG_ENDIAN));
    buffer.addAll(core.ByteOrder.parseShortByte(family, core.ByteOrder.BYTEORDER_BIG_ENDIAN));
    buffer.addAll(core.ByteOrder.parseShortByte(port, core.ByteOrder.BYTEORDER_BIG_ENDIAN));
    buffer.addAll(net.HetiIP.toRawIP(this.address));
    return new Uint8List.fromList(buffer);
  }
}
