import 'package:tetorica/cipher/hex.dart';
import 'package:tetorica/cipher/bigint.dart';
import 'dart:convert';
import 'package:test/test.dart' as test;
import 'dart:typed_data';

main() {
  test.group("bigint", () {
    test.test("[+]", () {
      BigInt v1 = new BigInt.fromInt(0xf, 4);
      BigInt v2 = new BigInt.fromInt(0xf, 4);
      print("${v1} ${v2} ${v1+v2}");
    });
  });
}
