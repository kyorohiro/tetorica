library hetimanet_turn;


class TurnClient {

}

// stun.l.google.com:19302
// https://tools.ietf.org/html/rfc5389

class StunClient {

}

class StunMessage {
  // 20 byte header
  var messageType;
  var messagelength;
  var magicCookie;
  var transactionId;
}
