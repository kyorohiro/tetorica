import 'package:tetorica/cipher/hex.dart';
import 'package:tetorica/cipher/bigint.dart';
//import 'package:tetorica/cipher/biginta.dart' as aaa;
import 'dart:convert';
import 'package:test/test.dart' as test;
import 'dart:typed_data';
import 'dart:math' as m;
main() {
  test.group("bigint", () {
    test.test("[+]", () {
      {
        BigInt v1 = new BigInt.fromInt(0xf, 4);
        BigInt v2 = new BigInt.fromInt(0xf, 4);
        test.expect("${v1+v2}", "0x000000000000001e");
      }

      {
        BigInt v1 = new BigInt.fromInt(0x1, 4);
        BigInt v2 = new BigInt.fromInt(0xffff, 4);
        test.expect("${v1+v2}", "0x0000000000010000");
      }
      for (int i = 0; i < 0x3ff; i += 2) {
        for (int j = 0; j < 0x3ff; j += 3) {
          BigInt v1 = new BigInt.fromInt(i, 32);
          BigInt v2 = new BigInt.fromInt(j, 32);
          BigInt v3 = new BigInt.fromInt(i + j, 32);
          test.expect("${v3}", "${v1+v2}");
        }
      }
    });

    test.test("[-]", () {
      {
        BigInt v1 = new BigInt.fromInt(-1, 10);
        test.expect("${v1}", "0xffffffffffffffffffff");
      }
      {
        BigInt v1 = new BigInt.fromInt(0xf, 4);
        BigInt v2 = new BigInt.fromInt(0xf, 4);
        test.expect("${v1-v2}", "0x0000000000000000");
        test.expect(v1.isNegative, false);
        test.expect(v2.isNegative, false);
        test.expect((v1 - v2).isNegative, false);
      }

      {
        BigInt v1 = new BigInt.fromInt(0xf, 4);
        BigInt v2 = new BigInt.fromInt(0xe, 4);
        test.expect("${v1-v2}", "0x0000000000000001");
        test.expect(v1.isNegative, false);
        test.expect(v2.isNegative, false);
        test.expect((v1 - v2).isNegative, false);
      }
      {
        BigInt v1 = new BigInt.fromInt(0xe, 4);
        BigInt v2 = new BigInt.fromInt(0xf, 4);
        test.expect("${v1-v2}", "0xffffffffffffffff");
        test.expect(v1.isNegative, false);
        test.expect(v2.isNegative, false);
        test.expect((v1 - v2).isNegative, true);
      }
      {
        BigInt v1 = new BigInt.fromInt(0xd, 4);
        BigInt v2 = new BigInt.fromInt(0xf, 4);
        BigInt v3 = new BigInt.fromInt(0x3, 4);
        test.expect("${v1-v2}", "0xfffffffffffffffe");
        test.expect("${v1-v2+v3}", "0x0000000000000001");
        test.expect((v1 - v2).isNegative, true);
        test.expect((v1 - v2 + v3).isNegative, false);
      }

      {
        BigInt v1 = new BigInt.fromInt(0x1000, 4);
        BigInt v2 = new BigInt.fromInt(0x1, 4);
        test.expect("${v1-v2}", "0x0000000000000fff");
      }

      for (int i = -1 * 0xff; i < 0xff; i += 2) {
        for (int j = -1 * 0xff; j < 0xff; j += 3) {
          BigInt v1 = new BigInt.fromInt(i, 32);
          BigInt v2 = new BigInt.fromInt(j, 32);
          BigInt v3 = new BigInt.fromInt(i - j, 32);
          test.expect("${v3}", "${v1-v2}");
        }
      }
    });

    test.test("[*]", () {
      {
        BigInt v1 = new BigInt.fromInt(0x2, 4);
        BigInt v2 = new BigInt.fromInt(0x2, 4);
        test.expect("${v1*v2}", "0x0000000000000004");
      }
      {
        BigInt v1 = new BigInt.fromInt(0xf, 4);
        BigInt v2 = new BigInt.fromInt(0xf, 4);
        test.expect("${v1*v2}", "0x00000000000000e1");
      }
      {
        BigInt v1 = new BigInt.fromInt(0xff, 4);
        BigInt v2 = new BigInt.fromInt(0xff, 4);
        test.expect("${v1*v2}", "0x000000000000fe01");
      }
      {
        BigInt v1 = new BigInt.fromInt(0xff, 4);
        BigInt v2 = new BigInt.fromInt(0x2, 4);
        test.expect("${v1*v2}", "0x00000000000001fe");
      }

      {
        BigInt v1 = new BigInt.fromInt(0xffff, 4);
        BigInt v2 = new BigInt.fromInt(0x2, 4);
        test.expect("${v1*v2}", "0x000000000001fffe");
      }

      {
        BigInt v1 = new BigInt.fromInt(0x100, 4);
        BigInt v2 = new BigInt.fromInt(0x3, 4);
        test.expect("${v1*v2}", "0x0000000000000300");
      }

      //
      //
      for (int i = 0x0; i < 0xffffffff; i = 1 + i * 2) {
        for (int j = 0x0; j < 0xffffffff; j = 1 + j * 3) {
          BigInt v1 = new BigInt.fromInt(i, 32);
          BigInt v2 = new BigInt.fromInt(j, 32);
          BigInt v3 = new BigInt.fromInt(i * j, 32);
          test.expect("${v3}", "${v1*v2}");
        }
      }

      {
        BigInt v1 = new BigInt.fromInt(0x1ff, 4);
        BigInt v2 = new BigInt.fromInt(0x1ff, 4);
        BigInt v3 = new BigInt.fromInt(0x1ff * 0x1ff, 4);
        test.expect("${v1*v2}", "${v3}");
      }
    });

    test.test("[mutableMinus]", () {
      {
        BigInt v1 = new BigInt.fromInt(-1, 10);
        BigInt v2 = new BigInt.fromInt(1, 10);
        v1.innerMutableMinusOne();
        test.expect("${v1}", "${v2}");
      }
      {
        BigInt v1 = new BigInt.fromInt(1, 10);
        BigInt v2 = new BigInt.fromInt(-1, 10);
        v1.innerMutableMinusOne();
        test.expect("${v1}", "${v2}");
      }

      {
        BigInt v1 = new BigInt.fromInt(0xfff, 10);
        BigInt v2 = new BigInt.fromInt(-0xfff, 10);
        v1.innerMutableMinusOne();
        test.expect("${v1}", "${v2}");
      }
      {
        BigInt v1 = new BigInt.fromInt(-0xfff, 10);
        BigInt v2 = new BigInt.fromInt(0xfff, 10);
        v1.innerMutableMinusOne();
        test.expect("${v1}", "${v2}");
      }

      {
        BigInt v1 = new BigInt.fromInt(-0xfff, 10);
        BigInt v2 = new BigInt.fromInt(0xfff, 10);
        test.expect("${-v1}", "${v2}");
      }
    });

    test.test("[*] B", () {
      {
        BigInt v1 = new BigInt.fromInt(-0x2, 4);
        BigInt v2 = new BigInt.fromInt(-0x2, 4);
        BigInt v3 = new BigInt.fromInt(0x4, 4);
        test.expect("${v1*v2}", "${v3}");
      }
      {
        BigInt v1 = new BigInt.fromInt(0x2, 4);
        BigInt v2 = new BigInt.fromInt(-0x2, 4);
        BigInt v3 = new BigInt.fromInt(-0x4, 4);
        test.expect("${v1*v2}", "${v3}");
      }

      {
        BigInt v1 = new BigInt.fromInt(-0x2, 4);
        BigInt v2 = new BigInt.fromInt(0x2, 4);
        BigInt v3 = new BigInt.fromInt(-0x4, 4);
        test.expect("${v1*v2}", "${v3}");
      }
      {
        BigInt v1 = new BigInt.fromInt(-0x2, 4);
        BigInt v2 = new BigInt.fromInt(-0x2, 4);
        BigInt v3 = new BigInt.fromInt(0x4, 4);
        test.expect("${v1*v2}", "${v3}");
      }

      {
        // todo
        BigInt v1 = new BigInt.fromInt(0x7fffffffffffffff, 8);
        BigInt v2 = new BigInt.fromInt(0x7fffffffffffffff, 8);
        BigInt v3 = new BigInt.fromInt(0x01, 8);
//        BigInt v1 = new BigInt.fromInt(0x7fff, 10);
//        BigInt v2 = new BigInt.fromInt(0x7fff, 10);
//        BigInt v3 = new BigInt.fromInt(0x01, 10);

//        test.expect("${v1*v2}", "${v3}");
      }
    });

    test.test("compareTo", () {
      {
        BigInt v1 = new BigInt.fromInt(0xFFFFF, 4);
        BigInt v2 = new BigInt.fromInt(0xFFFFF, 4);
        test.expect(v1.compareTo(v2), 0);
        test.expect((-v1).compareTo(-v2), 0);
        test.expect((-v1 == -v2), true);
        test.expect((-v1 >= -v2), true);
        test.expect((-v1 <= -v2), true);
      }
      {
        BigInt v1 = new BigInt.fromInt(0xFFFFF, 4);
        BigInt v2 = new BigInt.fromInt(0xFFFFE, 4);
        test.expect(v1.compareTo(v2), 1);
        test.expect((-v1).compareTo(-v2), 1);
        test.expect(v2.compareTo(v1), -1);
        test.expect((-v2).compareTo(-v1), -1);
        //
        test.expect((v1 > v2), true);
        test.expect((-v2 < -v1), true);
        test.expect((v1 >= v2), true);
        test.expect((-v2 <= -v1), true);
      }
    });

    test.test("[~/] B", () {
      {
        BigInt v1 = new BigInt.fromInt(0x8, 4);
        BigInt v2 = new BigInt.fromInt(0x2, 4);
        BigInt v3 = new BigInt.fromInt(0x4, 4);
        test.expect("${v1~/v2}", "${v3}");
      }

      {
        BigInt v1 = new BigInt.fromInt(-0x8, 4);
        BigInt v2 = new BigInt.fromInt(0x2, 4);
        BigInt v3 = new BigInt.fromInt(-0x4, 4);
        test.expect("${v1~/v2}", "${v3}");
      }

      {
        BigInt v1 = new BigInt.fromInt(0x8, 4);
        BigInt v2 = new BigInt.fromInt(-0x2, 4);
        BigInt v3 = new BigInt.fromInt(-0x4, 4);
        test.expect("${v1~/v2}", "${v3}");
      }

      {
        BigInt v1 = new BigInt.fromInt(0x2, 4);
        BigInt v2 = new BigInt.fromInt(-0x8, 4);
        BigInt v3 = new BigInt.fromInt(0x0, 4);
        test.expect("${v1~/v2}", "${v3}");
      }

      {
        BigInt v1 = new BigInt.fromInt(0x100, 4);
        BigInt v2 = new BigInt.fromInt(0x3, 4);
        test.expect("${v1*v2}", "0x0000000000000300");
        test.expect("${v2*v1}", "0x0000000000000300");
      }

      {
        BigInt v1 = new BigInt.fromInt(0xfffff, 8);
        BigInt v2 = new BigInt.fromInt(0x3, 8);
        BigInt v3 = new BigInt.fromInt(0x55555, 8);
        num t1 = new DateTime.now().millisecondsSinceEpoch;
        for (int i = 0; i < 0x40; i++) {
          test.expect("${v1~/v2}", "${v3}");
        }
        num t2 = new DateTime.now().millisecondsSinceEpoch;
        print("##${t2-t1}");
      }
      {
        BigInt v1 = new BigInt.fromInt(0xffffffffffffffff, 9);
        BigInt v2 = new BigInt.fromInt(0x3, 9);
        BigInt v3 = new BigInt.fromInt(0x5555555555555555, 9);
        print("### ${v3} : ${v1~/v2}");
        test.expect("${v1~/v2}", "${v3}");
      }
      {
        BigInt v1 = new BigInt.fromInt(-0xffffffffffffffff, 9);
        BigInt v2 = new BigInt.fromInt(0x3, 9);
        BigInt v3 = new BigInt.fromInt(-0x5555555555555555, 9);
        print("### ${v3} : ${v1~/v2}");
        test.expect("${v1~/v2}", "${v3}");
      }
      {
        // todo
        BigInt v1 = new BigInt.fromInt(256, 4);
        BigInt v2 = new BigInt.fromInt(128, 4);
        BigInt v3 = new BigInt.fromInt(256 ~/ 128, 4);
        test.expect("${v1~/v2}", "${v3}");
      }

      {
        for (int i = 0; i < 0xfff; i = 1 + i) {
          for (int j = 1; j < 0xfff; j = 1 + j * 2) {
            BigInt v1 = new BigInt.fromInt(i, 4);
            BigInt v2 = new BigInt.fromInt(j, 4);
            BigInt v3 = new BigInt.fromInt(i ~/ j, 4);
            test.expect("${i}:${j}:${v1~/v2}", "${i}:${j}:${v3}");
          }
        }
      }
      {
        BigInt v1 = new BigInt.fromInt(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, 82);
        //BigInt v2 = new BigInt.fromInt(0x3, 82);
        BigInt v2 = new BigInt.fromInt(0x3, 82);
        BigInt v3 = new BigInt.fromInt(0x55555555555555555555555555555555555555555555555555555555555555555555555555555555, 82);
        num t1 = new DateTime.now().millisecondsSinceEpoch;
        for (int i = 0; i < 0xff; i++) {
          //  v1~/v2;
          test.expect("${v1~/v2}", "${v3}");
        }
        num t2 = new DateTime.now().millisecondsSinceEpoch;
        print("##${t2-t1}");
      }
/*
      {
        aaa.BigInt v1 = new aaa.BigInt(Hex.decodeWithNew("0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"), true);
        aaa.BigInt v2 = new aaa.BigInt(Hex.decodeWithNew("0x03"), true);
        aaa.BigInt v3 = new aaa.BigInt(Hex.decodeWithNew("0x55555555555555555555555555555555555555555555555555555555555555555555555555555555"), true);
        num t1 = new DateTime.now().millisecondsSinceEpoch;
        for (int i = 0; i < 0xff; i++) {
          v1~/v2;
          //test.expect("${v1~/v2}", "${v3}");
        }
        num t2 = new DateTime.now().millisecondsSinceEpoch;
        print("##AA#${t2-t1}");
      }*/
    });
    test.test("[%] B", () {
      test.expect("${new BigInt.fromInt(0x5, 4)%new BigInt.fromInt(0x2, 4)}", "${new BigInt.fromInt(0x1, 4)}");
      test.expect("${new BigInt.fromInt(0x4, 4)%new BigInt.fromInt(0x2, 4)}", "${new BigInt.fromInt(0x0, 4)}");
      test.expect("${new BigInt.fromInt(-0x5, 4)%new BigInt.fromInt(0x2, 4)}", "${new BigInt.fromInt(0x1, 4)}");
      test.expect("${new BigInt.fromInt(-0x4, 4)%new BigInt.fromInt(0x2, 4)}", "${new BigInt.fromInt(0x0, 4)}");
      //
      test.expect("${new BigInt.fromInt(0x5, 4)%new BigInt.fromInt(-0x2, 4)}", "${new BigInt.fromInt(-0x1, 4)}");
      test.expect("${new BigInt.fromInt(0x4, 4)%new BigInt.fromInt(-0x2, 4)}", "${new BigInt.fromInt(-0x0, 4)}");
      test.expect("${new BigInt.fromInt(-0x5, 4)%new BigInt.fromInt(-0x2, 4)}", "${new BigInt.fromInt(-0x1, 4)}");
      test.expect("${new BigInt.fromInt(-0x4, 4)%new BigInt.fromInt(-0x2, 4)}", "${new BigInt.fromInt(-0x0, 4)}");
    });

    test.test("[increment]", () {
      BigInt b = new BigInt.fromInt(-0x1ff, 4);
      for (int i = -0x1ff; i < 0x1ff; i++) {
        test.expect("[${i}]:${b}", "[${i}]:${new BigInt.fromInt(i, 4)}");
        b.innerIncrement();
      }
    });

    test.test("[decrement]", () {
      BigInt b = new BigInt.fromInt(0x1ff, 4);
      for (int i = 0x1ff; i > -0x1ff; i--) {
        test.expect("[${i}]:${b}", "[${i}]:${new BigInt.fromInt(i, 4)}");
        b.innerDecrement();
      }
    });

    test.test("[document]", () {
      BigInt a = new BigInt.fromInt(0xffffffffffffffffff, 9);
      BigInt b = new BigInt.fromBytes(a.binary, 10);
      BigInt c = new BigInt.fromBytes(a.binary, 8);
      test.expect("${a}","0x00ffffffffffffffff");
      test.expect("${b}","0x0000ffffffffffffffff");
      test.expect("${c}","0xffffffffffffffff");
    });

    test.test("[size]", () {
      BigInt b0 = new BigInt.fromInt(0x0, 4);
      BigInt b1aa = new BigInt.fromInt(2, 4);
      BigInt b1a = new BigInt.fromInt(0xf, 4);
      BigInt b1b = new BigInt.fromInt(0xff, 4);
      BigInt b2a = new BigInt.fromInt(0xfff, 4);
      BigInt b2b = new BigInt.fromInt(0xffff, 4);
      BigInt b3a = new BigInt.fromInt(0xfffff, 4);
      test.expect(b0.sizePerByte, 0);
      test.expect(b1aa.sizePerByte, 1);
      test.expect(b1a.sizePerByte, 1);
      test.expect(b1b.sizePerByte, 1);
      test.expect(b2a.sizePerByte, 2);
      test.expect(b2b.sizePerByte, 2);
      test.expect(b3a.sizePerByte, 3);
    });

    test.test("[exp]", () {
      test.expect("${(new BigInt.fromInt(0x2,8)).exponentiate(new BigInt.fromInt(2, 8))}", "${(new BigInt.fromInt(0x2*0x2,8))}");
      test.expect("${(new BigInt.fromInt(0x3,8)).exponentiate(new BigInt.fromInt(3, 8))}", "${(new BigInt.fromInt(0x3*0x3*0x3,8))}");
      test.expect("${(new BigInt.fromInt(0x4,8)).exponentiate(new BigInt.fromInt(4, 8))}", "${(new BigInt.fromInt(0x4*0x4*0x4*0x4,8))}");
      test.expect("${(new BigInt.fromInt(0x5,8)).exponentiate(new BigInt.fromInt(5, 8))}", "${(new BigInt.fromInt(0x5*0x5*0x5*0x5*0x5,8))}");
      test.expect("${(new BigInt.fromInt(0x6,8)).exponentiate(new BigInt.fromInt(6, 8))}", "${(new BigInt.fromInt(0x6*0x6*0x6*0x6*0x6*0x6,8))}");
      {
        int bufferSize = 3 * 620;
        BigInt m1 = new BigInt.fromInt(0x2b0, bufferSize);
        BigInt e = new BigInt.fromInt(0x4f, bufferSize);
        test.expect("${m1.exponentiate(e)}",
            "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000198b472507a8d727bcb930ddfe957a22fce4840d4c5a0ee6b23aef0187899e06067ca39c64d0e9dfc4723a57b40b8d0e54bc3c5449c30000000000000000000000000000000000000000000000000000000000000000000000000000000");
      }
      {
        int bufferSize = 10 * 620;
        for(int i=0xff;i<0xffff;i=2*i+1){
          BigInt m1 = new BigInt.fromInt(2, bufferSize);
          BigInt e = new BigInt.fromInt(i, bufferSize);
          String expect = "0${(m.pow(2, i)).toInt().toRadixString(16)}";
          String actual = m1.exponentiate(e).toString();
          actual.substring(actual.length-expect.length);
          test.expect(actual.substring(actual.length-expect.length), expect);
        }
      }
    });

    test.test("[mod]", () {
      {
        int bufferSize = 10 * 620;
        for(int i=0xff;i<0xffffffff;i=21*i+1){
          print("[i== ${i}]");
          BigInt m1 = new BigInt.fromInt(2, bufferSize);
          BigInt e = new BigInt.fromInt(i, bufferSize);
          BigInt mod = new BigInt.fromInt(3, bufferSize);
          String expect = "0${(m.pow(2, i)%3).toInt().toRadixString(16)}";
          String actual = m1.exponentiateWithMod(e, mod).toString();
          actual.substring(actual.length-expect.length);
          test.expect(actual.substring(actual.length-expect.length), expect);
          print("${expect}");
        }
      }
      {
        int mod = 0xC4F8E9E15DCADF2B96C763D981006A644FFB4415030A16ED1283883340F2AA0E2BE2BE8FA60150B9046965837C3E7D151B7DE237EBB957C20663898250703B3F;
        int public = 0x010001;
        int message = 0xbc;
        BigInt d = new BigInt.fromBytes(Hex.decodeWithNew("0xC4F8E9E15DCADF2B96C763D981006A644FFB4415030A16ED1283883340F2AA0E2BE2BE8FA60150B9046965837C3E7D151B7DE237EBB957C20663898250703B3F"), 300);
        BigInt pu = new BigInt.fromBytes(Hex.decodeWithNew("0x010001"), 300);
        //BigInt pr = new BigInt.fromBytes(Hex.decodeWithNew(testPrivateKey), 300);
        BigInt m1 = new BigInt.fromBytes(Hex.decodeWithNew("0xBC"), 300);
        //
        String expect = "0${(m.pow(message, public) % mod).toInt().toRadixString(16)}";
        String actual = m1.exponentiateWithMod(pu,d).toString();
        test.expect("${expect}","${actual.substring(actual.length-expect.length)}");
      }
    });

  });
}
