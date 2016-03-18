import 'package:tetorica/cipher/arcfour.dart';
import 'package:tetorica/cipher/cipher.dart';
import 'package:tetorica/cipher/hex.dart';
import 'dart:convert';
import 'package:test/test.dart' as test;

main() {
  List<int> key = Hex.decodeWithNew("0xABCDEF");
  List<int> value = Hex.decodeWithNew("0xA1B2C3D4E5F6A7B8C9");
  BBuffer result = new BBuffer(0, 100);

}
