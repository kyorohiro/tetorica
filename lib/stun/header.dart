part of hetimanet_turn;

class StunMessageHeader {
  static const int bindingRequest = 0x0001;
  static const int bindingResponse = 0x0101;
  static const int bindingErrorResponse = 0x0111;
  static const int sharedSecretRequest = 0x0002;
  static const int sharedSecretResponse = 0x0102;
  static const int sharedSecretErrorResponse = 0x0112;
  int type;
  int get messageLength => message.length;
  StunMessageHeaderTransactionID transactionID;
  List<int> message;
  Uint8List toBytes() {
    Uint8List ret = new Uint8List(20 + messageLength);
    return ret;
  }
}
