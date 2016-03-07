part of hetimanet_stun;

abstract class StunAttribute {
  static const int mappedAddress = 0x0001; //
  static const int responseAddress = 0x0002; //
  static const int changeRequest = 0x0003; ////
  static const int sourceAddress = 0x0004; //
  static const int changedAddress = 0x0005; //
  static const int userName = 0x0006; ////
  static const int password = 0x0007; ////
  static const int messageIntegrity = 0x0008;
  static const int errorCode = 0x0009;
  static const int unknownAttribute = 0x000a;
  static const int reflectedFrom = 0x000b; //
  int get type; //2byte
  int get length; //2byte
  Uint8List encode();

  static List<StunAttribute> decode(List<int> buffer, {int start: 0, int end: null}) {
    if (end == null) {
      end = buffer.length;
    }
    List<StunAttribute> ret = [];

    while (start < buffer.length) {
      StunAttribute a = null;
      int t = core.ByteOrder.parseShort(buffer, start + 0, core.ByteOrder.BYTEORDER_BIG_ENDIAN);
      switch (t) {
        case StunAttribute.mappedAddress:
        case StunAttribute.responseAddress:
        case StunAttribute.changedAddress:
        case StunAttribute.sourceAddress:
        case StunAttribute.reflectedFrom:
          a = StunAddressAttribute.decode(buffer, start);
          break;
        case StunAttribute.changeRequest:
          a = StunChangeRequest.decode(buffer, start);
          break;
        case StunAttribute.errorCode:
          a = StunErrorCode.decode(buffer, start);
          break;
        case StunAttribute.userName:
        case StunAttribute.password:
        case StunAttribute.userName:
        case StunAttribute.messageIntegrity:
        default:
          a = StunBasicMessage.decode(buffer, start);
          break;
      }
      start += a.length + 4;
      ret.add(a);
    }
    return ret;
  }
}

class StunErrorCode extends StunAttribute {
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
  int get length => 4+conv.UTF8.encode(pharse).length; //2byte

  int code;
  String pharse;
  StunErrorCode(this.code, this.pharse) {
    type = StunAttribute.errorCode;
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
    if (type != StunAttribute.errorCode) {
      throw {"mes": ""};
    }
    int tlength = core.ByteOrder.parseShort(buffer, start + 2, core.ByteOrder.BYTEORDER_BIG_ENDIAN);
    int v = core.ByteOrder.parseInt(buffer, start + 4, core.ByteOrder.BYTEORDER_BIG_ENDIAN);
    int clazz = (v >> 8) & 0x07;
    int nzzber = v & 0xff;
    String pharse = conv.UTF8.decode(buffer.sublist(start + 8, start + 8 + tlength - 4), allowMalformed: true);

    return new StunErrorCode(clazz * 100 + nzzber, pharse);
  }
}
