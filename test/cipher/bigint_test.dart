import 'package:tetorica/cipher/hex.dart';
import 'package:tetorica/cipher/bigint.dart';
import 'dart:convert';
import 'package:test/test.dart' as test;
import 'dart:typed_data';

main() {
  test.group("bigint", () {
    /*
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
    */
    /*
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
    */

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
      for (int i = 0x0; i < 0xffffffff; i = 1+i*2) {
        for (int j = 0x0; j < 0xffffffff; j = 1+j*3) {
          BigInt v1 = new BigInt.fromInt(i, 32);
          BigInt v2 = new BigInt.fromInt(j, 32);
          BigInt v3 = new BigInt.fromInt(i * j, 32);
          test.expect("${v3}", "${v1*v2}");
        }
      }

      {
        BigInt v1 = new BigInt.fromInt(0x1ff, 4);
        BigInt v2 = new BigInt.fromInt(0x1ff, 4);
        BigInt v3 = new BigInt.fromInt(0x1ff*0x1ff, 4);
          test.expect("${v1*v2}","${v3}");
      }
    });
/*
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
    */
/*
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
*/
/*
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
      BigInt v1 = new BigInt.fromInt(256, 4);
      BigInt v2 = new BigInt.fromInt(128, 4);
      BigInt v3 = new BigInt.fromInt(256~/128, 4);
      test.expect("${v1~/v2}", "${v3}");
      }
      {
        for(int i=0;i<0xffff;i++){
          for(int j=1;j<0xffff;j++){
          BigInt v1 = new BigInt.fromInt(i, 4);
          BigInt v2 = new BigInt.fromInt(j, 4);
          BigInt v3 = new BigInt.fromInt(i~/j, 4);
          test.expect("${i}:${j}:${v1~/v2}", "${i}:${j}:${v3}");
        }
        }
      }

      {
        BigInt v1 = new BigInt.fromInt(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, 128);
        BigInt v2 = new BigInt.fromInt(0x3, 128);
        BigInt v3 = new BigInt.fromInt(0x55555555555555555555555555555555555555555555555555555555555555555555555555555555, 128);
        num t1 = new DateTime.now().millisecondsSinceEpoch;
        for (int i = 0; i < 0xf; i++) {
          test.expect("${v1~/v2}", "${v3}");
        }
        num t2 = new DateTime.now().millisecondsSinceEpoch;
        print("##${t2-t1}");
      }
    });
*/
/*
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
*/
  });
}
