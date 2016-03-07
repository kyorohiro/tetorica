library hetimanet_turn;

import 'dart:math' as math;
import 'dart:typed_data';
import 'core.dart' as core;
import 'net.dart' as net;

class TurnClient {}

// stun.l.google.com:19302
// https://tools.ietf.org/html/rfc5389
// https://tools.ietf.org/html/rfc3489
// 3478
// 5349
//stun   3478/tcp   Session Traversal Utilities for NAT (STUN) port
//  stun   3478/udp   Session Traversal Utilities for NAT (STUN

//Full Cone
//Restricted Cone
//Port Restricted Cone
//Symmetric

class StunClient {}

class StunMessageHeaderType {
  static const int bindingRequest = 0x0001;
  static const int bindingResponse = 0x0101;
  static const int bindingErrorResponse = 0x0111;
  static const int sharedSecretRequest = 0x0002;
  static const int sharedSecretResponse = 0x0102;
  static const int sharedSecretErrorResponse = 0x0112;
  int value;
  StunMessageHeaderType(this.value) {}
}

class StunMessageHeaderTransactionID {
  List<int> value;
  static math.Random _random = new math.Random();
  StunMessageHeaderTransactionID.random() {
    for (int i = 0; i < 16; i++) {
      value.add(_random.nextInt(0xFF));
    }
  }
}

class StunMessageHeader {
  StunMessageHeaderType type;
  int get messageLength => message.length;
  StunMessageHeaderTransactionID transactionID;
  List<int> message;
  Uint8List toBytes() {
    Uint8List ret = new Uint8List(20 + messageLength);
    return ret;
  }
}

class StunMessageAttributeType {
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
  int value;
  StunMessageAttributeType(this.value) {}
}

abstract class StunMessageAttribute {
  StunMessageAttributeType get type; //2byte
  int get length; //2byte
  Uint8List encode();
//  List<int> get value; //...
}

class StunMappedAddressAttribute extends StunMessageAttribute {
  static const int familyIPv4 = 0x0001;
  static const int familyIPv6 = 0x0002;

  StunMessageAttributeType type;
  int get length => (family == familyIPv4 ? (2 + 2 + 4) : (2 + 2 + 8));
  int family;
  int port;
  String address;

  StunMappedAddressAttribute(this.family, this.port, this.address) {
    type = new StunMessageAttributeType(StunMessageAttributeType.mappedAddress);
  }

  static StunMappedAddressAttribute decode(List<int> buffer, int start) {
    int type = core.ByteOrder.parseShort(buffer, start + 0, core.ByteOrder.BYTEORDER_BIG_ENDIAN);
    if (type == StunMessageAttributeType.mappedAddress) {
      throw {"mes": ""};
    }
    int tlength = core.ByteOrder.parseShort(buffer, start + 2, core.ByteOrder.BYTEORDER_BIG_ENDIAN);
    int family = core.ByteOrder.parseShort(buffer, start + 4, core.ByteOrder.BYTEORDER_BIG_ENDIAN);
    if (tlength != (family == familyIPv4 ? (2 + 2 + 4) : (2 + 2 + 8))) {
      throw {"mes": ""};
    }
    int port = core.ByteOrder.parseShort(buffer, start + 6, core.ByteOrder.BYTEORDER_BIG_ENDIAN);
    String address = net.HetiIP.toIPString(buffer, start: start + 8);

    return new StunMappedAddressAttribute(family, port, address);
  }

  Uint8List encode() {
    List<int> buffer = [];
    buffer.addAll(core.ByteOrder.parseShortByte(type.value, core.ByteOrder.BYTEORDER_BIG_ENDIAN));
    buffer.addAll(core.ByteOrder.parseShortByte((family == familyIPv4 ? (2 + 2 + 4) : (2 + 2 + 8)), core.ByteOrder.BYTEORDER_BIG_ENDIAN));
    buffer.addAll(core.ByteOrder.parseShortByte(family, core.ByteOrder.BYTEORDER_BIG_ENDIAN));
    buffer.addAll(core.ByteOrder.parseShortByte(port, core.ByteOrder.BYTEORDER_BIG_ENDIAN));
    buffer.addAll(net.HetiIP.toRawIP(this.address));
    return new Uint8List.fromList(buffer);
  }
}

class StunMappedAddress {
  var zeros; //1byte
  var family; // 0x01:ipv4 0x02:ipv6
  var port; //
  var address; //4byte or 8byte
}

class StunUserName {}

class StunMessageIntegrity {}

class StunFingerPrint {}

class StunErrorCode {}

class StunXorMappedAddress {
  var xxxx; //1byte
  var family; //
  var xPort; //
  var xAddress;
}

class StunMessage {
  // 20 byte header
  var zeroes; // message first 2bits be zero
  var messageType; // 2
  var messagelength; // 2
  var magicCookie; // 4 byte magic value
  var transactionId; // 96bit uniformaly value 12 byte

  // 2type request / response and 4 message
  //
  // M0-M11 and C0-C1
  var resuest = [0x0b, 0x00];
  var indication = [0x0b, 0x01];
  var successResponse = [0x0b, 0x10];
  var errorResponse = [0x0b, 0x11];
  //
  var exBindingRequest = [0x0b, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01];
  //
  var coolieFixedValue = [0x21, 0x12, 0xA4, 0x42]; //network byte order (big)127.0.0.1-->  0x7f000001;

}
