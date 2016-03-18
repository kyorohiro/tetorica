import 'package:tetorica/cipher/base64.dart';
import 'package:tetorica/cipher/cipher.dart';
import 'package:tetorica/cipher/hex.dart';
import 'dart:convert';
import 'package:test/test.dart' as test;
import 'dart:typed_data';

main() {
  print("### ${Base64.equalByte} ${Base64.base64Bytes}");
  test.group("base64", () {
    test.test("encode A", () {
      Uint8List r = new Uint8List(100);
      List<int> inputValue = ASCII.encode("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/");
      int l = Base64.encode(inputValue, 0, inputValue.length, r, 0, r.length);
      print(ASCII.decode(r));
      test.expect(ASCII.decode(r.sublist(0, l)), "QUJDREVGR0hJSktMTU5PUFFSU1RVVldYWVphYmNkZWZnaGlqa2xtbm9wcXJzdHV2d3h5ejAxMjM0NTY3ODkrLw==");
    });

    test.test("decode A", () {
      Uint8List bbuffer = new Uint8List(100);
      List<int> inputValue = ASCII.encode("QUJDREVGR0hJSktMTU5PUFFSU1RVVldYWVphYmNkZWZnaGlqa2xtbm9wcXJzdHV2d3h5ejAxMjM0NTY3ODkrLw==");
      int l = Base64.decode(inputValue, 0, inputValue.length, bbuffer, 0, bbuffer.length);
      print(ASCII.decode(bbuffer.sublist(0, l), allowInvalid: true));
      test.expect(ASCII.decode(bbuffer.sublist(0, l)), "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/");
    });

    test.test("encode B", () {
      Uint8List bbuffer = new Uint8List(500);
      List<int> inputValue = [];
      for (int i = 0; i <= 0xff; i++) {
        inputValue.add(i);
      }
      int l = Base64.encode(inputValue, 0, inputValue.length, bbuffer, 0, bbuffer.length);
      List<int> v = bbuffer.sublist(0, l);

      l = Base64.decode(v, 0, v.length, bbuffer, 0, bbuffer.length);
      test.expect(inputValue, bbuffer.sublist(0, l));
    });

    test.test("encode E", () {
      Uint8List bbuffer = new Uint8List(500);
      List<int> inputValue = [];
      for (int j = 0; j < 0xff; j++) {
        //
        inputValue.clear();
        for (int i = j; i <= 0xff; i++) {
          inputValue.add(i);
        }
        //
        int l = Base64.encode(inputValue, 0, inputValue.length, bbuffer, 0, bbuffer.length);

        int ll = Base64.decode(bbuffer.sublist(0, l), 0, bbuffer.sublist(0, l).length, bbuffer, 0, bbuffer.length);
        test.expect(inputValue.length, ll);
        test.expect(Hex.encodeWithNew(inputValue), Hex.encodeWithNew(bbuffer.sublist(0, ll)));
      }
    });

    test.test("encode F", () {
      Uint8List bbuffer = new Uint8List(1000);
      List<int> inputValue = [];
      for (int s = 0; s <30; s++) {
        for (int j = 0; j < 0xff-s; j++) {
          //
          inputValue.clear();
          for (int i = j; i <= 0xff; i++) {
            inputValue.add(i);
          }
          //
//          print("#-------------------------#");
          int l = Base64.encode(inputValue, s, inputValue.length, bbuffer, s, bbuffer.length);
//          print("##A# ${s} ${inputValue.length} ${ASCII.decode(bbuffer.sublist(s, s+l))} ${l}");

          int ll = Base64.decode(
            bbuffer.sublist(0, s+l), s, l,
            bbuffer, s, bbuffer.length);
//          print("##B# ${s} ${j} ${inputValue.length} ${ll}");
          test.expect(inputValue.length-s, ll);
          test.expect(
            Hex.encodeWithNew(inputValue.sublist(s)),
            Hex.encodeWithNew(bbuffer.sublist(s, s+ll)));
        }
      }
    });
  });
}
