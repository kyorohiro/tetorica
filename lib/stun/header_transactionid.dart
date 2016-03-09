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

  @override
  String toString() {
    StringBuffer b = new StringBuffer();
    for(int i in value) {
      String t = i.toRadixString(16);
      b.write(t);
      if(t.length == 1) {
        b.write("0");
      }
    }
    return b.toString();
  }
}
