//import 'package:tetorica/cipher/bigint.dart';

import 'package:bignum/bignum.dart';
import 'package:tetorica/cipher/rsa.dart';
import 'package:tetorica/cipher/hex.dart';
import 'package:test/test.dart' as test;
String testModulus = "0xC4F8E9E15DCADF2B96C763D981006A644FFB4415030A16ED1283883340F2AA0E2BE2BE8FA60150B9046965837C3E7D151B7DE237EBB957C20663898250703B3F";
String testPrivateKey = "0x8a7e79f3fbfea8ebfd18351cb9979136f705b4d9114a06d4aa2fd1943816677a5374661846a30c45b30a024b4d22b15ab323622b2de47ba29115f06ee42c41";
String testPublicKey =  "0x010001";

main() {
  test.group("rsa", () {
    test.test("aa",(){
      BigInteger d = new BigInteger.fromBytes(1, Hex.decodeWithNew(testModulus));
      BigInteger pu = new BigInteger.fromBytes(1, Hex.decodeWithNew(testPublicKey));
      BigInteger pr = new BigInteger.fromBytes(1,Hex.decodeWithNew(testPrivateKey));
      BigInteger m = new BigInteger.fromBytes(1, [0xbc]);
      print(":d: ${d}");
      print(":m: ${m}");
      print(":pu: ${pu}");
      BigInteger c = RSA.compute(m, pu, d);
      print(">>> ${c.toRadix(16)}");
      print(">>> ${RSA.compute(c, pr, d).toRadix(16)}");
      test.expect(RSA.compute(c, pr, d).toRadix(16), "bc");

      print("==> ${m.bitCount()} ${m.bitLength()}");
      print("==> ${pu.bitCount()} ${pu.bitLength()}");
      print("==> ${d.bitCount()} ${d.bitLength()}");
      print("==> ${d.toByteArray()}");
    });

    test.test("compute 001", () {
      {
        //
        // n = pq
        // c = m**e % n
        // m = c**d % n
        // sigma = (p-1)(q-1)
        // e := (ex 2**16+1)
        // ed % sigma = 1
        int bufferSize = 3*620;
        BigInteger e = new BigInteger.fromBytes(1, [0x4f]);
        BigInteger d = new BigInteger.fromBytes(1,[0x03,0xfb]);
        BigInteger n = new BigInteger.fromBytes(1,[0x0d,0x09]);
        BigInteger m1 = new BigInteger.fromBytes(1, [0x02,0xb0]);

        // encrypt
        BigInteger c = RSA.compute(m1, e, n);
        test.expect("${c}","1570");

        // decrypt
        BigInteger m2 = RSA.compute(c, d, n);
        test.expect("${m2}","688");
      }

    });

    test.test("co", () {
        BigInteger d = new BigInteger.fromBytes(1, Hex.decodeWithNew(testModulus));
        BigInteger pu = new BigInteger.fromBytes(1, Hex.decodeWithNew(testPublicKey));
        var v = RSA.encrypt([0xbc], 1, d, pu);
        test.expect("${Hex.encodeWithNew(v)}","0x0dcd1cd87361a8554b3ae0c4001be26308ff34a8a9b7d11585c90ea02dd02f85e34f6b72078dad9c5eae37030584167a6de31320488c757a68f5e2f3ab6a286d");
    });

    test.test("en", () {
        BigInteger d = new BigInteger.fromBytes(1, Hex.decodeWithNew(testModulus));
        BigInteger pu = new BigInteger.fromBytes(1, Hex.decodeWithNew(testPrivateKey));
        List<int> input = Hex.decodeWithNew("0x0dcd1cd87361a8554b3ae0c4001be26308ff34a8a9b7d11585c90ea02dd02f85e34f6b72078dad9c5eae37030584167a6de31320488c757a68f5e2f3ab6a286d");
        var v = RSA.decrypt(input, input.length, d, pu);
        test.expect("${Hex.encodeWithNew(v)}","0xbc");
    });

    test.test("co", () {
        String message =
        "0x40f73315d3f74703904e51e1c72686801de06a55417110e56280f1f8471a3802406d2110011e1f387f7b4c43258b0a1eedc558a3aac5aa2d20cf5e0d65d80db340f73315d3f74703904e51e1c72686801de06a55417110e56280f1f8471a3802406d2110011e1f387f7b4c43258b0a1eedc558a3aac5aa2d20cf5e0d65d80db3";
        BigInteger d = new BigInteger.fromBytes(1, Hex.decodeWithNew(testModulus));
        BigInteger pu = new BigInteger.fromBytes(1, Hex.decodeWithNew(testPublicKey));
        BigInteger pr = new BigInteger.fromBytes(1,Hex.decodeWithNew(testPrivateKey));
        List<int> intput = Hex.decodeWithNew(message);
        var c = RSA.encrypt(intput, intput.length, d, pu);
        //print("#>#># ${Hex.encodeWithNew(c)}");
        var v = RSA.decrypt(c, c.length, d, pr);
        //print("#>#># ${Hex.encodeWithNew(v)}");
        test.expect("${Hex.encodeWithNew(v)}",message);
        //"0x0dcd1cd87361a8554b3ae0c4001be26308ff34a8a9b7d11585c90ea02dd02f85e34f6b72078dad9c5eae37030584167a6de31320488c757a68f5e2f3ab6a286d");
    });
  });
}


// p = 3
// q = 5
// n = 15
// sigma = 8
// e = 13 : 1<e<n
// ed = 3 % sigma
// c = m**e % n
// m = c**d % n
