import 'package:tetorica/cipher/arcfour.dart';
import 'package:tetorica/cipher/cipher.dart';
import 'package:tetorica/cipher/hex.dart';
import 'dart:convert';
import 'package:test/test.dart' as test;

main() {

  test.group("arcfour", (){
    test.test("operate", (){
      List<int> key    = Hex.decodeWithNew("0xABCDEF");
      List<int> value  = Hex.decodeWithNew("0xA1B2C3D4E5F6A7B8C9");
//      List<int> result = Hex.decodeWithNew();

      List<int> output = new List(value.length);
      List<int> state = new List(256);
      List<int> stateIJ = [0,0];

      ARCFOUR.makeState(key, 0, key.length, state, 0);
      ARCFOUR.operate(
        value, 0, value.length,
        state, 0,
        stateIJ, 0,
        output, 0);
      test.expect(Hex.encodeWithNew(output), "0x91b44728ff906c143d");
    });
  });

}
