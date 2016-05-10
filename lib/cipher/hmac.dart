import 'dart:typed_data' show Uint8List;
import './sha1.dart' show SHA1;

typedef Uint8List hmacHash(List<Uint8List> source, {Uint8List output});

//
// https://www.ietf.org/rfc/rfc2104.txt
//
class HMAC {
  static const int digestBlockSize = 64;
  static const int inputBlockSize = 56;

  Uint8List key;
  hmacHash hashFunc;
  int digestSize;

  HMAC(this.hashFunc, this.digestSize, this.key) {}

  factory HMAC.SHA1(Uint8List key) {
    SHA1 hashFunc = new SHA1();
    return new HMAC((List<Uint8List> source, {Uint8List output}) {
      hashFunc.sha1Reset();
      source.forEach((Uint8List v) {
        hashFunc.sha1Input(v, v.length);
      });
      return hashFunc.sha1Result(output: output);
    }, 20, key);
  }

  Uint8List calcHMAC(Uint8List text, {Uint8List tmp, Uint8List output}) {
    Uint8List ipad = new Uint8List(digestBlockSize);
    Uint8List opad = new Uint8List(digestBlockSize);
    ipad.fillRange(0, digestBlockSize, 0x36);
    opad.fillRange(0, digestBlockSize, 0x5c);
    if (output == null) {
      output = new Uint8List(digestSize);
    }
    if (tmp == null) {
      tmp = new Uint8List(digestSize);
    }
    for (int i = 0, len = key.lengthInBytes; i < len; i++) {
      ipad[i] ^= key[i];
      opad[i] ^= key[i];
    }
    //
    // HMAC_k(m) = h((opad ^ K) || h(K^ipad || m ))
    hashFunc([ipad, text], output: tmp);
    hashFunc([opad, tmp], output: output);
    return output;
  }
}
