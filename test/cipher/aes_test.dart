import 'package:tetorica/cipher/aes.dart';
import 'package:tetorica/cipher/hex.dart';
import 'package:test/test.dart' as test;

main() {
  //http://csrc.nist.gov/publications/nistpubs/800-38a/sp800-38a.pdf
  //
  test.group("arcfour", () {
    test.test("xor",(){
      List<int> iv        = Hex.decodeWithNew("0x000102030405060708090a0b0c0d0e0f");
      List<int> plainText = Hex.decodeWithNew("0x6bc1bee22e409f96e93d7e117393172a");
      AES.xor(plainText, 0, iv, 0, iv.length);
      test.expect(Hex.encodeWithNew(plainText), "0x6bc0bce12a459991e134741a7f9e1925");
    });
    test.test("operateA", () {
      List<int> key = Hex.decodeWithNew("0x2b7e151628aed2a6abf7158809cf4f3c");
      List<int> iv = Hex.decodeWithNew("0x000102030405060708090a0b0c0d0e0f");
      List<int> plainText = Hex.decodeWithNew("0x6bc1bee22e409f96e93d7e117393172a");
      List<int> cipherText = Hex.decodeWithNew("0x7649abac8119b246cee98e9b12e9197d");

      //for(int i=0;i<0xff;i++) {
        //print("[${i}] : ${AES.xtime(i)}");
      //}
    });
  });
}
