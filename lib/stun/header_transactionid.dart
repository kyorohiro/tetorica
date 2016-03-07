part of hetimanet_stun;

class StunMessageHeaderTransactionID {
  List<int> value;
  static math.Random _random = new math.Random();
  StunMessageHeaderTransactionID.random() {
    value = [];
    for (int i = 0; i < 16; i++) {
      value.add(_random.nextInt(0xFF));
    }
  }

  StunMessageHeaderTransactionID._empty() {}

  static StunMessageHeaderTransactionID decode(List<int> buffer, int start) {
    StunMessageHeaderTransactionID ret = new StunMessageHeaderTransactionID._empty();
    ret.value = [];
    for (int i = 0; i < 16; i++) {
      ret.value.add(buffer[start + i]);
    }
    return ret;
  }
}
