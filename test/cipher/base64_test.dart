import 'package:tetorica/cipher/base64.dart';
import 'dart:async';
import 'dart:convert';

main() {
  Result r = new Result(0, 100);
  List<int> v = Base64.encode(ASCII.encode("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"), 0, r);
  print(ASCII.decode(v));
  print("${r.index} ${r.length}");

  List<int> inputValue = ASCII.encode("QUJDREVGR0hJSktMTU5PUFFSU1RVVldYWVphYmNkZWZnaGlqa2xtbm9wcXJzdHV2d3h5ejAxMjM0NTY3ODkrLw==");
  List<int> w = Base64.decode(inputValue, 0, inputValue.length, r);
  print("${r.index} ${r.length}");
  print(ASCII.decode(w.sublist(0, r.length), allowInvalid: true));
}
