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
      int t = core.ByteOrder.parseShort(buffer, start + 0, core.ByteOrderType.BYTEORDER_BIG_ENDIAN);
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
