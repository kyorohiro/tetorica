import 'package:tetorica/cipher/hex.dart';
import 'package:tetorica/cipher/bigint.dart';
//import 'package:tetorica/cipher/biginta.dart' as aaa;
import 'dart:convert';
import 'package:test/test.dart' as test;
import 'dart:typed_data';
import 'dart:math' as m;
import 'package:bignum/bignum.dart' as big;
import 'package:bignum/src/big_integer_v8.dart' as big;

main() {
  test.group("bigint", () {

    test.test("[left shift]", () {
      {
        BigInt v1 = new BigInt.fromBytes([0x01, 0xff,0xff, 0xff], 8);
        test.expect(v1.compareWithRightShift(new BigInt.fromBytes([0x01, 0xff,0xff, 0xff], 8), 0), 0);
        test.expect(v1.compareWithRightShift(new BigInt.fromBytes([0x00, 0xff,0xff, 0xff], 8), 1), 0);
        test.expect(v1.compareWithRightShift(new BigInt.fromBytes([0x00, 0x7f,0xff, 0xff], 8), 2), 0);
        test.expect(v1.compareWithRightShift(new BigInt.fromBytes([0x00, 0x3f,0xff, 0xff], 8), 3), 0);
        test.expect(v1.compareWithRightShift(new BigInt.fromBytes([0x00, 0x1f,0xff, 0xff], 8), 4), 0);
        test.expect(v1.compareWithRightShift(new BigInt.fromBytes([0x00, 0x0f,0xff, 0xff], 8), 5), 0);
        test.expect(v1.compareWithRightShift(new BigInt.fromBytes([0x00, 0x07,0xff, 0xff], 8), 6), 0);
        test.expect(v1.compareWithRightShift(new BigInt.fromBytes([0x00, 0x03,0xff, 0xff], 8), 7), 0);
        test.expect(v1.compareWithRightShift(new BigInt.fromBytes([0x00, 0x01,0xff, 0xff], 8), 8), 0);
        test.expect(v1.compareWithRightShift(new BigInt.fromBytes([0x00, 0x00,0xff, 0xff], 8), 9), 0);
        test.expect(v1.compareWithRightShift(new BigInt.fromBytes([0x00, 0x00,0x7f, 0xff], 8), 10), 0);
        test.expect(v1.compareWithRightShift(new BigInt.fromBytes([0x00, 0x00,0x3f, 0xff], 8), 11), 0);
        test.expect(v1.compareWithRightShift(new BigInt.fromBytes([0x00, 0x00,0x1f, 0xff], 8), 12), 0);
        test.expect(v1.compareWithRightShift(new BigInt.fromBytes([0x00, 0x00,0x0f, 0xff], 8), 13), 0);
      }
      {
        BigInt v1 = new BigInt.fromBytes([0x6f, 0xff,0xff, 0xff,0xff,0xff, 0xff, 0xff], 8);
        BigInt v2 = new BigInt.fromBytes([0x37, 0xff,0xff, 0xff,0xff,0xff, 0xff, 0xff], 8);

        test.expect(v1.compareWithRightShift(v2, 1), 0);
//        test.expect(v1.compareWithRightShift(new BigInt.fromBytes([0xD7, 0xff,0xff, 0xff,0xff,0xff, 0xff, 0xff], 8), 1), -1);

      }
//        test.expect(v1.compareWithRightShift(v3, 5), -1);
//        test.expect(v1.compareWithRightShift(v2, 6), 1);
//        test.expect(v1.compareWithRightShift(v2, 7), 0);
//        test.expect(v1.compareWithRightShift(v2, 8), -1);
//        print("${v1.compareWithRightShift(v2, )}");
        //print("${v1.compareWithRightShift(v2, 2)}");
    });
/*
    test.test("", () {
      String mod = "0xC4F8E9E15DCADF2B96C763D981006A644FFB4415030A16ED1283883340F2AA0E2BE2BE8FA60150B9046965837C3E7D151B7DE237EBB957C20663898250703B3F";
      String pub = "0x8a7e79f3fbfea8ebfd18351cb9979136f705b4d9114a06d4aa2fd1943816677a5374661846a30c45b30a024b4d22b15ab323622b2de47ba29115f06ee42c41";
      BigInt v1 = new BigInt.fromBytes(Hex.decodeWithNew(mod), 260);
      BigInt v2 = new BigInt.fromBytes(Hex.decodeWithNew(pub), 260);
      BigInt m2 = new BigInt.fromInt(0xbc, 260);

      num t4 = new DateTime.now().millisecondsSinceEpoch;
      m2.exponentiateWithMod(v2, v1);
      num t5 = new DateTime.now().millisecondsSinceEpoch;
      print("TIME2: ${t5-t4}");

      {
        num t6 = new DateTime.now().millisecondsSinceEpoch;
        for (int i = 0; i < 0xfff; i++) {
          v1 ~/ m2;
        }
        num t7 = new DateTime.now().millisecondsSinceEpoch;
        print("TIME2A: ${t7-t6}");
      }

      {
        num t6 = new DateTime.now().millisecondsSinceEpoch;
        for (int i = 0; i < 0xfff; i++) {
          v1 * m2;
        }
        num t7 = new DateTime.now().millisecondsSinceEpoch;
        print("TIME2B: ${t7-t6}");
      }
      {
        num t6 = new DateTime.now().millisecondsSinceEpoch;
        for (int i = 0; i < 0xfff; i++) {
          v1 + v2;
        }
        num t7 = new DateTime.now().millisecondsSinceEpoch;
        print("TIME2C: ${t7-t6}");
      }
    });
    test.test("", () {
      {
        String mod = "0xC4F8E9E15DCADF2B96C763D981006A644FFB4415030A16ED1283883340F2AA0E2BE2BE8FA60150B9046965837C3E7D151B7DE237EBB957C20663898250703B3F";
        String pub = "0x8a7e79f3fbfea8ebfd18351cb9979136f705b4d9114a06d4aa2fd1943816677a5374661846a30c45b30a024b4d22b15ab323622b2de47ba29115f06ee42c41";
        big.BigInteger d = new big.BigIntegerV8.fromBytes(1, Hex.decodeWithNew(mod));
        big.BigInteger pu = new big.BigIntegerV8.fromBytes(1, Hex.decodeWithNew(pub));
        big.BigInteger m1 = new big.BigIntegerV8.fromBytes(1, [0xbc]);

        int b = (new DateTime.now().millisecondsSinceEpoch);
        m1.modPow(m1, d);
        int c = (new DateTime.now().millisecondsSinceEpoch);
        print("TIME3: ${c-b} ");
        {
          int e = (new DateTime.now().millisecondsSinceEpoch);
          for (int i = 0; i < 0xfff; i++) {
            d.divide(m1);
          }
          int f = (new DateTime.now().millisecondsSinceEpoch);
          print("TIME3A: ${f-e} ");
        }

        {
          int e = (new DateTime.now().millisecondsSinceEpoch);
          for (int i = 0; i < 0xfff; i++) {
            d.multiply(m1);
          }
          int f = (new DateTime.now().millisecondsSinceEpoch);
          print("TIME3B: ${f-e} ");
        }

        {
          int e = (new DateTime.now().millisecondsSinceEpoch);
          for (int i = 0; i < 0xfff; i++) {
            d.add(pu);
          }
          int f = (new DateTime.now().millisecondsSinceEpoch);
          print("TIME3C: ${f-e} ");
        }
      }
    });
*/
  });
}
