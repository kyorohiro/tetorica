import 'package:tetorica/cipher/base64.dart';
import 'dart:async';
import 'dart:convert';
import 'package:test/test.dart' as test;

main() {
  print("### ${Base64.equalByte} ${Base64.base64Bytes}");
  test.group("base64", () {
    test.test("encode A", () {
      Result r = new Result(0, 100);
      List<int> inputValue = ASCII.encode("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/");
      List<int> v = Base64.encode(inputValue, 0, inputValue.length, r);
      print(ASCII.decode(v));
      print("${r.index} ${r.length}");
      test.expect(ASCII.decode(v.sublist(r.index, r.index + r.length)), "QUJDREVGR0hJSktMTU5PUFFSU1RVVldYWVphYmNkZWZnaGlqa2xtbm9wcXJzdHV2d3h5ejAxMjM0NTY3ODkrLw==");
    });
    test.test("decode A", () {
      Result r = new Result(0, 100);
      List<int> inputValue = ASCII.encode("QUJDREVGR0hJSktMTU5PUFFSU1RVVldYWVphYmNkZWZnaGlqa2xtbm9wcXJzdHV2d3h5ejAxMjM0NTY3ODkrLw==");
      List<int> w = Base64.decode(inputValue, 0, inputValue.length, r);
      print("${r.index} ${r.length}");
      print(ASCII.decode(w.sublist(0, r.length), allowInvalid: true));
      test.expect(ASCII.decode(w.sublist(r.index, r.index + r.length)), "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/");
    });

    test.test("encode B", () {
      Result r = new Result(0, 500);
      List<int> inputValue = [];
      for (int i = 0; i <= 0xff; i++) {
        inputValue.add(i);
      }
      List<int> v = Base64.encode(inputValue, 0, inputValue.length, r);
      v = v.sublist(r.index, r.index + r.length);
      List<int> w = Base64.decode(v, 0, v.length, r);
      w = w.sublist(r.index, r.index + r.length);
      test.expect(inputValue, w);
    });

    test.test("encode E", () {
      for (int j = 0; j < 0xff; j++) {
        Result r = new Result(0, 500);
        List<int> inputValue = [];
        for (int i = j; i <= 0xff; i++) {
          inputValue.add(i);
        }
        List<int> v = Base64.encode(inputValue, 0, inputValue.length, r);
        v = v.sublist(r.index, r.index + r.length);
        List<int> w = Base64.decode(v, 0, v.length, r);
        w = w.sublist(r.index, r.index + r.length);
      }
    });

    test.test("encode F", () {
      int s = 1;
      for (int s = 0; s < 20; s++) {
        for (int j = 0; j < 0xdd; j++) {
          Result r = new Result(s, 500);
          List<int> inputValue = [];
          for (int i = j; i <= 0xff; i++) {
            inputValue.add(i);
          }
          List<int> v = Base64.encode(inputValue, s, inputValue.length, r);
          v = v.sublist(0, r.index + r.length);
          List<int> w = Base64.decode(v, s, v.length - s, r);
          w = w.sublist(r.index, r.index + r.length);
        }
      }
    });
  });
}
