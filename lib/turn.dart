library hetimanet_turn;

import 'dart:math' as math;
import 'dart:typed_data';

class TurnClient {

}

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


class StunClient {

}

class StunMessageHeaderType {
  static const List<int> bindingRequest       = const [0x00, 0x01];
  static const List<int> bindingResponse      = const [0x01, 0x01];
  static const List<int> bindingErrorResponse = const [0x01, 0x11];
  static const List<int> sharedSecretRequest  = const [0x00, 0x02];
  static const List<int> sharedSecretResponse = const [0x01, 0x02];
  static const List<int> sharedSecretErrorResponse = const [0x01, 0x12];
  List<int> value;
  StunMessageHeaderType(this.value){}
}

class StunMessageHeaderTransactionID {
  List<int> value;
  static math.Random _random = new math.Random();
  StunMessageHeaderTransactionID.random() {
    for(int i=0;i<16;i++) {
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
    Uint8List ret = new Uint8List(20+messageLength);
    // todo
    return ret;
  }
}

class StunAttribute {
  var type;//2byte
  var length;//2byte
  var value;//...
}

class StunMappedAddress {
  var zeros;//1byte
  var family;// 0x01:ipv4 0x02:ipv6
  var port;//
  var address;//4byte or 8byte
}

class StunUserName {

}

class StunMessageIntegrity {

}

class StunFingerPrint {

}

class StunErrorCode {

}

class StunXorMappedAddress {
    var xxxx;//1byte
    var family;//
    var xPort;//
    var xAddress;
}

class StunMessage {
  // 20 byte header
  var zeroes; // message first 2bits be zero
  var messageType; // 2
  var messagelength;// 2
  var magicCookie; // 4 byte magic value
  var transactionId;// 96bit uniformaly value 12 byte

  // 2type request / response and 4 message
  //
  // M0-M11 and C0-C1
  var resuest = [0x0b, 0x00];
  var indication = [0x0b, 0x01];
  var successResponse = [0x0b, 0x10];
  var errorResponse = [0x0b, 0x11];
  //
  var exBindingRequest = [0x0b,0x00,0x00,0x00,0x00,0x00,0x01];
  //
  var coolieFixedValue = [0x21,0x12,0xA4,0x42]; //network byte order (big)127.0.0.1-->  0x7f000001;

}
