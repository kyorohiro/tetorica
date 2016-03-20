import 'package:tetorica/cipher/hex.dart';
import 'package:tetorica/cipher/bigint.dart';
import 'dart:convert';
import 'package:test/test.dart' as test;
import 'dart:typed_data';

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
    });
    test.test("[-]", () {
      {
        BigInt v1 = new BigInt.fromInt(0xf, 4);
        BigInt v2 = new BigInt.fromInt(0xf, 4);
        test.expect("${v1-v2}", "0x0000000000000000");
      }

      {
        BigInt v1 = new BigInt.fromInt(0xf, 4);
        BigInt v2 = new BigInt.fromInt(0xe, 4);
        test.expect("${v1-v2}", "0x0000000000000001");
      }
      {
        BigInt v1 = new BigInt.fromInt(0xe, 4);
        BigInt v2 = new BigInt.fromInt(0xf, 4);
        test.expect("${v1-v2}", "0xffffffffffffffff");
      }
      {
        BigInt v1 = new BigInt.fromInt(0xd, 4);
        BigInt v2 = new BigInt.fromInt(0xf, 4);
        BigInt v3 = new BigInt.fromInt(0x3, 4);
        test.expect("${v1-v2}", "0xfffffffffffffffe");
        test.expect("${v1-v2+v3}", "0x0000000000000001");
      }

      {
        BigInt v1 = new BigInt.fromInt(0x1000, 4);
        BigInt v2 = new BigInt.fromInt(0x1, 4);
        test.expect("${v1-v2}", "0x0000000000000fff");
      }
    });
  });
}
