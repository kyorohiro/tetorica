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

class StunErrorCode extends StunMessageAttribute {
  static const int code400BadRequest = 400;
  static const int code401Unauthorized = 401;
  static const int code420UnknownAttribute = 420;
  static const int code430StaleCredentials = 430;
  static const int code431IntegrityCheckFailure = 431;
  static const int code432MissingUsername = 432;
  static const int code433UseTLS = 433;
  static const int code500ServerError = 500;
  static const int code600GlobalFailure = 600;

  int type; //2byte
  int length; //2byte

  int code;
  String pharse;
  StunErrorCode(this.code, this.pharse) {
    type = StunMessageAttribute.errorCode;
  }

  Uint8List encode() {
    List<int> buffer = [];
    List<int> pharseBytes = conv.UTF8.encode(pharse);
    buffer.addAll(core.ByteOrder.parseShortByte(type, core.ByteOrder.BYTEORDER_BIG_ENDIAN));
    buffer.addAll(core.ByteOrder.parseShortByte(4 + pharseBytes.length, core.ByteOrder.BYTEORDER_BIG_ENDIAN));
    int v = 0;
    v |= (code ~/ 100) << 8;
    v |= (code % 100);
    buffer.addAll(core.ByteOrder.parseIntByte(v, core.ByteOrder.BYTEORDER_BIG_ENDIAN));
    buffer.addAll(pharseBytes);
    return new Uint8List.fromList(buffer);
  }

  static StunErrorCode decode(List<int> buffer, int start) {
    int type = core.ByteOrder.parseShort(buffer, start + 0, core.ByteOrder.BYTEORDER_BIG_ENDIAN);
    int tlength = core.ByteOrder.parseShort(buffer, start + 2, core.ByteOrder.BYTEORDER_BIG_ENDIAN);
    int v = core.ByteOrder.parseInt(buffer, start + 4, core.ByteOrder.BYTEORDER_BIG_ENDIAN);
    int clazz = (v >> 8) & 0x07;
    int nzzber = v & 0xff;
    String pharse = conv.UTF8.decode(buffer.sublist(start + 8, start + 8 + tlength - 4), allowMalformed: true);

    return new StunErrorCode(clazz * 100 + nzzber, pharse);
  }
}

class StunBasicMessage extends StunMessageAttribute {
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

    if (type == StunMessageAttribute.userName || type == StunMessageAttribute.password) {
      if ((tlength % 4) != 0) {
        throw {"mes": ""};
      }
    }
    if (type == StunMessageAttribute.messageIntegrity) {
      if (tlength != 64) {
        throw {"mes": ""};
      }
    }

    return new StunBasicMessage(type, buffer.sublist(start + 4, start + 4 + tlength));
  }
}

class StunChangeRequest extends StunMessageAttribute {
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
    if (StunMessageAttribute.changeRequest != type) {
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
    type = StunMessageAttribute.changeRequest;
  }
}

class StunAddressAttribute extends StunMessageAttribute {
  static const int familyIPv4 = 0x0001;
  static const int familyIPv6 = 0x0002;
  static int _length(family) => (family == familyIPv4 ? (2 + 2 + 4) : (2 + 2 + 16));

  int type;
  int get length => _length(family);
  int family;
  int port;
  String address;

  StunAddressAttribute(this.type, this.family, this.port, this.address) {}

  static StunAddressAttribute decode(List<int> buffer, int start, {List<int> expectType: const [StunMessageAttribute.mappedAddress, StunMessageAttribute.responseAddress, StunMessageAttribute.changedAddress, StunMessageAttribute.sourceAddress, StunMessageAttribute.reflectedFrom]}) {
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
      address = net.HetiIP.toIPv4String(buffer, start: start + 8);
    } else {
      address = net.HetiIP.toIPv6String(buffer, start: start + 8);
    }
    return new StunAddressAttribute(type, family, port, address);
  }

  Uint8List encode() {
    List<int> buffer = [];
    buffer.addAll(core.ByteOrder.parseShortByte(type, core.ByteOrder.BYTEORDER_BIG_ENDIAN));
    buffer.addAll(core.ByteOrder.parseShortByte(_length(family), core.ByteOrder.BYTEORDER_BIG_ENDIAN));
    buffer.addAll(core.ByteOrder.parseShortByte(family, core.ByteOrder.BYTEORDER_BIG_ENDIAN));
    buffer.addAll(core.ByteOrder.parseShortByte(port, core.ByteOrder.BYTEORDER_BIG_ENDIAN));
    buffer.addAll(net.HetiIP.toRawIP(this.address));
    return new Uint8List.fromList(buffer);
  }
}
