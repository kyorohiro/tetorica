library sha1_cipher;

import 'dart:typed_data' show Uint8List, Uint32List;

enum SHA1State { shaSuccess, shaNull, shaInputTooLong, shaStateError }

class SHA1 {
  static const int H0 = 0x67452301;
  static const int H1 = 0xEFCDAB89;
  static const int H2 = 0x98BADCFE;
  static const int H3 = 0x10325476;
  static const int H4 = 0xC3D2E1F0;
  static const int K0 = 0x5a827999;
  static const int K1 = 0x6ed9eba1;
  static const int K2 = 0x8f1bbcdc;
  static const int K3 = 0xca62c1d6;

  int lengthLow = 0;
  int lengthHigh = 0;
  Uint32List W = new Uint32List(80);
  Uint8List messageBlock = new Uint8List(64);
  int messageBlockIndex = 0;
  SHA1State computed = SHA1State.shaSuccess;
  SHA1State corrupted = SHA1State.shaSuccess;
  Uint32List intermediateHash = new Uint32List(5);

  SHA1() {
    //  messageBlock32 = messageBlock.buffer.asUint32List();
  }

  Uint8List calcSha1(Uint8List input) {
    sha1Reset();
    sha1Input(input, input.length);
    return sha1Result();
  }

  void sha1Reset() {
    this.lengthLow = 0;
    this.lengthHigh = 0;
    this.messageBlockIndex = 0;
    this.intermediateHash[0] = H0;
    this.intermediateHash[1] = H1;
    this.intermediateHash[2] = H2;
    this.intermediateHash[3] = H3;
    this.intermediateHash[4] = H4;
    this.computed = SHA1State.shaSuccess;
    this.corrupted = SHA1State.shaSuccess;
  }

  Uint8List sha1Result({Uint8List output}) {
    if(output == null) {
      output = new Uint8List(20);
    }
    if (this.corrupted != SHA1State.shaSuccess) {
      throw this.corrupted;
    }
    if (this.computed == SHA1State.shaSuccess) {
      sha1PadMessage();
      this.messageBlock.fillRange(0, 64, 0);
      this.lengthLow = 0;
      this.lengthHigh = 0;
      this.computed = SHA1State.shaNull;
    }

    for (int i = 0; i < 20; i++) {
      output[i] = this.intermediateHash[i >> 2] >> (8 * (3 - (i & 0x03)));
    }

    return output;
  }

  SHA1State sha1Input(Uint8List messageArray, int length) {
    if (length == 0) {
      return SHA1State.shaSuccess;
    }
    if (messageArray == null) {
      return SHA1State.shaNull;
    }
    //
    if (this.computed != SHA1State.shaSuccess) {
      this.corrupted = SHA1State.shaStateError;
      return SHA1State.shaStateError;
    }
    //
    if (this.corrupted != SHA1State.shaSuccess) {
      return this.corrupted;
    }
    //
    for (int i = 0; length != 0 && corrupted == SHA1State.shaSuccess; length--, i++) {
      this.messageBlock[this.messageBlockIndex++] = messageArray[i];// & 0xFF;
      this.lengthLow += 8;
      if (this.lengthLow == 0) {
        this.lengthHigh++;
        if (this.lengthHigh == 0) {
          this.corrupted = SHA1State.shaNull;
        }
      }
      //
      if (this.messageBlockIndex == 64) {
        sha1ProccessMessageBlock();
      }
    }
    return SHA1State.shaSuccess;
  }

  void sha1ProccessMessageBlock() {
    //W.fillRange(0, 80,0);
    for (int t = 0; t < 16; t++) {
      W[t] = this.messageBlock[t * 4] << 24;
      W[t] |= this.messageBlock[t * 4 + 1] << 16;
      W[t] |= this.messageBlock[t * 4 + 2] << 8;
      W[t] |= this.messageBlock[t * 4 + 3];
    }
    for (int t = 16; t < 80; t++) {
      W[t] = sha1CirclularShift(W[t - 3] ^ W[t - 8] ^ W[t - 14] ^ W[t - 16], 1);
    }
    int A = this.intermediateHash[0];
    int B = this.intermediateHash[1];
    int C = this.intermediateHash[2];
    int D = this.intermediateHash[3];
    int E = this.intermediateHash[4];
    //
    for (int t = 0, temp = 0; t < 20; t++) {
      temp = sha1CirclularShift(A, 5) + ((B & C) | ((~B) & D)) + E + W[t] + K0;
      E = D;
      D = C;
      C = sha1CirclularShift(B, 30);
      B = A;
      A = temp & 0xFFFFFFFF;
    }

    for (int t = 20, temp = 0; t < 40; t++) {
      temp = sha1CirclularShift(A, 5) + (B ^ C ^ D) + E + W[t] + K1;
      E = D;
      D = C;
      C = sha1CirclularShift(B, 30);
      B = A;
      A = temp & 0xFFFFFFFF;
    }
    //
    for (int t = 40, temp = 0; t < 60; t++) {
      temp = sha1CirclularShift(A, 5) + ((B & C) | (B & D) | (C & D)) + E + W[t] + K2;
      E = D;
      D = C;
      C = sha1CirclularShift(B, 30);
      B = A;
      A = temp & 0xFFFFFFFF;
    }
    //
    for (int t = 60, temp = 0; t < 80; t++) {
      temp = sha1CirclularShift(A, 5) + (B ^ C ^ D) + E + W[t] + K3;
      E = D;
      D = C;
      C = sha1CirclularShift(B, 30);
      B = A;
      A = temp & 0xFFFFFFFF;
    }
    //
    this.intermediateHash[0] = (this.intermediateHash[0] + A) & 0xffffffff;
    this.intermediateHash[1] = (this.intermediateHash[1] + B) & 0xffffffff;
    this.intermediateHash[2] = (this.intermediateHash[2] + C) & 0xffffffff;
    this.intermediateHash[3] = (this.intermediateHash[3] + D) & 0xffffffff;
    this.intermediateHash[4] = (this.intermediateHash[4] + E) & 0xffffffff;
    this.messageBlockIndex = 0;
  }

  void sha1PadMessage() {
    if (this.messageBlockIndex > 55) {
      this.messageBlock[this.messageBlockIndex++] = 0x80;
      while (this.messageBlockIndex < 64) {
        this.messageBlock[this.messageBlockIndex++] = 0;
      }
      sha1ProccessMessageBlock();
      while (this.messageBlockIndex < 56) {
        this.messageBlock[this.messageBlockIndex++] = 0;
      }
    } else {
      this.messageBlock[this.messageBlockIndex++] = 0x80;
      while (this.messageBlockIndex < 56) {
        this.messageBlock[this.messageBlockIndex++] = 0;
      }
    }

    this.messageBlock[56] = this.lengthHigh >> 24;
    this.messageBlock[57] = this.lengthHigh >> 16;
    this.messageBlock[58] = this.lengthHigh >> 8;
    this.messageBlock[59] = this.lengthHigh;
    this.messageBlock[60] = this.lengthLow >> 24;
    this.messageBlock[61] = this.lengthLow >> 16;
    this.messageBlock[62] = this.lengthLow >> 8;
    this.messageBlock[63] = this.lengthLow;

    sha1ProccessMessageBlock();
  }

  static int sha1CirclularShift(int x, int n) => ((x << n) & 0xFFFFFFFF) | (x >> (32 - n));
}
