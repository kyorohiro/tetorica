import 'package:tetorica/cipher/hex.dart';
import 'package:tetorica/cipher/cipher.dart';
import 'dart:convert';
import 'package:test/test.dart' as test;

main() {
  test.group("hex", () {
    test.test("decode A", () {
      BBuffer r = new BBuffer(0, 100);
      List<int> inputValue = ASCII.encode("0xAFFA0990");
      List<int> vv = Hex.decode(inputValue, 0, inputValue.length, r);
      print("${inputValue}");
      print("${r.index} ${r.length}");
      test.expect(vv.sublist(r.index, r.index+r.length), [0xAF, 0xFA, 0x09, 0x90]);
    });

    //[48, 120, 65, 70, 70, 65, 48, 57, 57, 48]
    test.test("encode A", () {
      BBuffer r = new BBuffer(0, 100);
      List<int> inputValue = [0xAF, 0xFA, 0x09, 0x90];
      List<int> vv = Hex.encode(inputValue, 0, inputValue.length, r);
      print("${inputValue}");
      print("${r.index} ${r.length}");
      test.expect(ASCII.decode(vv.sublist(r.index, r.index+r.length)), "0xaffa0990");
    });

  });
}
