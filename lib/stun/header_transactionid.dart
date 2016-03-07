part of hetimanet_turn;

class StunMessageHeaderTransactionID {
  List<int> value;
  static math.Random _random = new math.Random();
  StunMessageHeaderTransactionID.random() {
    for (int i = 0; i < 16; i++) {
      value.add(_random.nextInt(0xFF));
    }
  }
}
