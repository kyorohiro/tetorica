import 'package:tetorica/cipher/aes.dart';
import 'package:tetorica/cipher/hex.dart';
import 'package:test/test.dart' as test;
import 'dart:typed_data';

main() {
  //http://csrc.nist.gov/publications/nistpubs/800-38a/sp800-38a.pdf
  //
  test.group("arcfour", () {
    test.test("xor", () {
      // 16bit
      {
        List<int> iv = Hex.decodeWithNew("0x000102030405060708090a0b0c0d0e0f");
        List<int> plainText = Hex.decodeWithNew("0x6bc1bee22e409f96e93d7e117393172a");
        AES.xor(plainText, 0, iv, 0, iv.length);
        test.expect(Hex.encodeWithNew(plainText), "0x6bc0bce12a459991e134741a7f9e1925");
      }
    });

    test.test("Nk Nb Nr", () {
      test.expect(4, AES.calcNk(16));
      test.expect(4, AES.calcNb(16));
      test.expect(10, AES.calcNr(16));
      test.expect(6, AES.calcNk(24));
      test.expect(4, AES.calcNb(24));
      test.expect(12, AES.calcNr(24));
      test.expect(8, AES.calcNk(32));
      test.expect(4, AES.calcNb(32));
      test.expect(14, AES.calcNr(32));
      test.expect(60, AES.calcExKeyItemLength(32));
    });

    test.test("keyExpansion", () {
      // 16bit
      {
        String result = "0x" + "2b7e151628aed2a6abf7158809cf4f3ca0fafe17" + "88542cb123a339392a6c7605f2c295f27a96b943" + "5935807a7359f67f3d80477d4716fe3e1e237e44" + "6d7a883bef44a541a8525b7fb671253bdb0bad00" + "d4d1c6f87c839d87caf2b8bc11f915bc6d88a37a" + "110b3efddbf98641ca0093fd4e54f70e5f5fc9f3" + "84a64fb24ea6dc4fead27321b58dbad2312bf560" + "7f8d292fac7766f319fadc2128d12941575c006e" + "d014f9a8c9ee2589e13f0cc8b6630ca6";
        List<int> key = Hex.decodeWithNew("0x2b7e151628aed2a6abf7158809cf4f3c");
        List<int> words = new Uint8List(4 * AES.calcExKeyItemLength(16));
        AES.createExKeyFromKey(key, key.length, words);
        test.expect(Hex.encodeWithNew(words), result);
        test.expect(words.length, 4 * AES.calcExKeyItemLength(16));
      }
      // 32bit
      {
        String result = "0x" + "603deb1015ca71be2b73aef0857d77811f352c07" + "3b6108d72d9810a30914dff49ba354118e6925af" + "a51a8b5f2067fcdea8b09c1a93d194cdbe49846e" + "b75d5b9ad59aecb85bf3c917fee94248de8ebe96" + "b5a9328a2678a647983122292f6c79b3812c81ad" + "dadf48ba24360af2fab8b46498c5bfc9bebd198e" + "268c3ba709e0421468007bacb2df331696e939e4" + "6c518d80c814e20476a9fb8a5025c02d59c58239" + "de1369676ccc5a71fa2563959674ee155886ca5d" + "2e2f31d77e0af1fa27cf73c3749c47ab18501dda" + "e2757e4f7401905acafaaae3e4d59b349adf6ace" + "bd10190dfe4890d1e6188d0b046df344706c631e";

        List<int> key = Hex.decodeWithNew("0x603deb1015ca71be2b73aef0857d77811f352c073b6108d72d9810a30914dff4");
        List<int> iv = Hex.decodeWithNew("0x000102030405060708090a0b0c0d0e0f");
        List<int> plainText = Hex.decodeWithNew("0x6bc1bee22e409f96e93d7e117393172a");
        List<int> cipherText = Hex.decodeWithNew("0xf58c4c04d6e5f1ba779eabfb5f7bfbd6");
        List<int> outputBlock = Hex.decodeWithNew("0x6bc0bce12a459991e134741a7f9e1925");

        List<int> words = new Uint8List(4 * AES.calcExKeyItemLength(32));
        AES.createExKeyFromKey(key, key.length, words);
        test.expect(Hex.encodeWithNew(words), result);
        test.expect(words.length, 4 * AES.calcExKeyItemLength(32));
      }
    });

    test.test("encrypt", () {
      // 16bit
      {
        List<int> key = Hex.decodeWithNew("0x2b7e151628aed2a6abf7158809cf4f3c");
        List<int> iv = Hex.decodeWithNew("0x000102030405060708090a0b0c0d0e0f");
        List<int> plainText = Hex.decodeWithNew("0x6bc1bee22e409f96e93d7e117393172a");
        List<int> output = new Uint8List(16);

        //
        List<int> words = new Uint8List(4 * AES.calcExKeyItemLength(key.length));
        AES.createExKeyFromKey(key, key.length, words);
        //
        AES.xor(plainText, 0, iv, 0, iv.length);
        AES.encrypt(plainText, 0, key.length, words, output, 0);
        test.expect(Hex.encodeWithNew(output), "0x7649abac8119b246cee98e9b12e9197d");
      }
    });
    test.test("decrypt 128bit", () {
      {
        List<int> key = Hex.decodeWithNew("0x2b7e151628aed2a6abf7158809cf4f3c");
        List<int> iv = Hex.decodeWithNew("0x000102030405060708090a0b0c0d0e0f");
        List<int> plainText = Hex.decodeWithNew("0x6bc1bee22e409f96e93d7e117393172a");
        List<int> cipherText = Hex.decodeWithNew("0x7649abac8119b246cee98e9b12e9197d");
        List<int> output = new Uint8List(16);

        //
        List<int> words = new Uint8List(4 * AES.calcExKeyItemLength(key.length));
        AES.createExKeyFromKey(key, key.length, words);
        //
        AES.decrypt(cipherText, 0, key.length, words, output, 0);
        AES.xor(output, 0, iv, 0, iv.length);
        test.expect(Hex.encodeWithNew(output), "0x6bc1bee22e409f96e93d7e117393172a");
      }
    });
    test.test("encrypt 128bit", () {
      {
        List<int> key = Hex.decodeWithNew("0x2b7e151628aed2a6abf7158809cf4f3c");
        List<int> iv = Hex.decodeWithNew("0x000102030405060708090a0b0c0d0e0f");
        List<int> plainText = Hex.decodeWithNew("0x6bc1bee22e409f96e93d7e117393172a");
        List<int> output = new Uint8List(16);

        //
        List<int> words = new Uint8List(4 * AES.calcExKeyItemLength(key.length));
        AES.createExKeyFromKey(key, key.length, words);
        //
        AES.xor(plainText, 0, iv, 0, iv.length);
        AES.encrypt(plainText, 0, key.length, words, output, 0);
        test.expect(Hex.encodeWithNew(output), "0x7649abac8119b246cee98e9b12e9197d");
      }
    });


    test.test("encrypt CBC 4 128bit", () {
      // 16bit
      {
        List<int> key = Hex.decodeWithNew("0x2b7e151628aed2a6abf7158809cf4f3c");
        List<int> iv = Hex.decodeWithNew("0x000102030405060708090a0b0c0d0e0f");
        List<int> plainText = Hex.decodeWithNew("0x" + "6bc1bee22e409f96e93d7e117393172a" + "ae2d8a571e03ac9c9eb76fac45af8e51" + "30c81c46a35ce411e5fbc1191a0a52ef" + "f69f2445df4f9b17ad2b417be66c3710");
        List<int> output = new Uint8List(16 * 4);

        AES.encryptWithCBC(plainText, iv, key, output);
        test.expect(Hex.encodeWithNew(output), "0x7649abac8119b246cee98e9b12e9197d" + "5086cb9b507219ee95db113a917678b2" + "73bed6b8e3c1743b7116e69e22229516" + "3ff1caa1681fac09120eca307586e1a7");
      }
    });

    test.test("decrypt CBC 4 128 bit", () {
      // 16bit
      {
        List<int> key = Hex.decodeWithNew("0x2b7e151628aed2a6abf7158809cf4f3c");
        List<int> iv = Hex.decodeWithNew("0x000102030405060708090a0b0c0d0e0f");
        List<int> cypherText = Hex.decodeWithNew("0x7649abac8119b246cee98e9b12e9197d" + "5086cb9b507219ee95db113a917678b2" + "73bed6b8e3c1743b7116e69e22229516" + "3ff1caa1681fac09120eca307586e1a7");
        List<int> output = new Uint8List(16 * 4);

        AES.decryptWithCBC(cypherText, iv, key, output);
        test.expect(Hex.encodeWithNew(output), "0x6bc1bee22e409f96e93d7e117393172a" + "ae2d8a571e03ac9c9eb76fac45af8e51" + "30c81c46a35ce411e5fbc1191a0a52ef" + "f69f2445df4f9b17ad2b417be66c3710");
      }
    });
    //

    test.test("encrypt CBC 4 256bit", () {
      // 16bit
      {
        List<int> key = Hex.decodeWithNew(
          "0x603deb1015ca71be2b73aef0857d7781"+
          "1f352c073b6108d72d9810a30914dff4");
        List<int> iv = Hex.decodeWithNew(
          "0x000102030405060708090a0b0c0d0e0f");
        List<int> plainText = Hex.decodeWithNew(
          "0x6bc1bee22e409f96e93d7e117393172a" +
          "ae2d8a571e03ac9c9eb76fac45af8e51" +
          "30c81c46a35ce411e5fbc1191a0a52ef" +
          "f69f2445df4f9b17ad2b417be66c3710");
        List<int> output = new Uint8List(16 * 4);

        AES.encryptWithCBC(plainText, iv, key, output);
        test.expect(Hex.encodeWithNew(output),
        "0xf58c4c04d6e5f1ba779eabfb5f7bfbd6" +
          "9cfc4e967edb808d679f777bc6702c7d" +
          "39f23369a9d9bacfa530e26304231461" +
          "b2eb05e2c39be9fcda6c19078c6a9d1b");
      }
    });

    test.test("decrypt CBC 4 256bit", () {
      // 16bit
      {
        List<int> key = Hex.decodeWithNew(
          "0x603deb1015ca71be2b73aef0857d7781"+
          "1f352c073b6108d72d9810a30914dff4");
        List<int> iv = Hex.decodeWithNew(
          "0x000102030405060708090a0b0c0d0e0f");
        List<int> cipherText = Hex.decodeWithNew(
          "0xf58c4c04d6e5f1ba779eabfb5f7bfbd6" +
            "9cfc4e967edb808d679f777bc6702c7d" +
            "39f23369a9d9bacfa530e26304231461" +
            "b2eb05e2c39be9fcda6c19078c6a9d1b");

        List<int> output = new Uint8List(16 * 4);

        AES.decryptWithCBC(cipherText, iv, key, output);
        test.expect(Hex.encodeWithNew(output),
        "0x6bc1bee22e409f96e93d7e117393172a" +
        "ae2d8a571e03ac9c9eb76fac45af8e51" +
        "30c81c46a35ce411e5fbc1191a0a52ef" +
        "f69f2445df4f9b17ad2b417be66c3710");
      }
    });
  });
}
