import 'package:tetorica/cipher/aes.dart';
import 'package:tetorica/cipher/hex.dart';
import 'package:test/test.dart' as test;
import 'dart:typed_data';

main() {
  //http://csrc.nist.gov/publications/nistpubs/800-38a/sp800-38a.pdf
  //
  test.group("arcfour", () {
    test.test("xor",(){
      List<int> iv        =   Hex.decodeWithNew("0x000102030405060708090a0b0c0d0e0f");
      List<int> plainText =   Hex.decodeWithNew("0x6bc1bee22e409f96e93d7e117393172a");
      AES.xor(plainText, 0, iv, 0, iv.length);
      test.expect(Hex.encodeWithNew(plainText), "0x6bc0bce12a459991e134741a7f9e1925");
//      List<int> key = Hex.decodeWithNew("0x2b7e151628aed2a6abf7158809cf4f3c");
//      List<int> iv = Hex.decodeWithNew("0x000102030405060708090a0b0c0d0e0f");
//      List<int> plainText = Hex.decodeWithNew("0x6bc1bee22e409f96e93d7e117393172a");
//      List<int> cipherText = Hex.decodeWithNew("0x7649abac8119b246cee98e9b12e9197d");
    });

    test.test("Nk Nb Nr",(){
      test.expect(4, AES.calcNk(16));
      test.expect(4, AES.calcNb(16));
      test.expect(10, AES.calcNr(16));
      test.expect(6, AES.calcNk(24));
      test.expect(4, AES.calcNb(24));
      test.expect(12, AES.calcNr(24));
      test.expect(8, AES.calcNk(32));
      test.expect(4, AES.calcNb(32));
      test.expect(14, AES.calcNr(32));
      test.expect(60, AES.calcWordLength(32));
    });

    test.test("keyExpansion", () {
      //0x
      String result =
      "0x"+
     //2b7e151628aed2a6abf7158809cf4f3c491d767528aed2a6abf7158809cf4f3c287e151628aed2a6abf7158809cf4f3c4f1d767528aed2a6abf7158809cf4f3c247e151628aed2a6abf7158809cf4f3c571d767528aed2a6abf7158809cf4f3c147e151628aed2a6abf7158809cf4f3c371d767528aed2a6abf7158809cf4f3cd47e151628aed2a6abf7158809cf4f3cac1d767528aed2a6abf7158809cf4f3cf97e151628aed2a6abf7158809cf4f3c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
      "2b7e151628aed2a6abf7158809cf4f3ca0fafe17"+
      "88542cb123a339392a6c7605f2c295f27a96b943"+
      "5935807a7359f67f3d80477d4716fe3e1e237e44"+
      "6d7a883bef44a541a8525b7fb671253bdb0bad00"+
      "d4d1c6f87c839d87caf2b8bc11f915bc6d88a37a"+
      "110b3efddbf98641ca0093fd4e54f70e5f5fc9f3"+
      "84a64fb24ea6dc4fead27321b58dbad2312bf560"+
      "7f8d292fac7766f319fadc2128d12941575c006e"+
      "d014f9a8c9ee2589e13f0cc8b6630ca6008a5e02"+
      "0100000010000000000000000000000000000000"+
      "00505e0201000000010000000000000000140000"+
      "0000000002100000000080ffffff000000000000";
      List<int> key = Hex.decodeWithNew("0x2b7e151628aed2a6abf7158809cf4f3c");
      List<int> words = new Uint8List(4*60);
      AES.keyExpansion(key, key.length, words);
      print("## -b- ${Hex.encodeWithNew(words)}");
    });
  });
}
