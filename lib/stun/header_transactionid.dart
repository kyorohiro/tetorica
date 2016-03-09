part of hetimanet_stun;

class StunTransactionID {
  List<int> value;
  static math.Random _random = new math.Random();
  StunTransactionID.random() {
    value = [];
    for (int i = 0; i < 16; i++) {
      value.add(_random.nextInt(0xFF));
    }
  }

  StunTransactionID._empty() {}

  static StunTransactionID decode(List<int> buffer, int start) {
    StunTransactionID ret = new StunTransactionID._empty();
    ret.value = [];
    for (int i = 0; i < 16; i++) {
      ret.value.add(buffer[start + i]);
    }
    return ret;
  }
}
