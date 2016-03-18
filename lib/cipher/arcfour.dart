library base64;

import 'cipher.dart';
import 'dart:typed_data';

class ARCFOUR {
  static List<int> operate(List<int> value, List<int> key, BBuffer result) {
    Uint8List state = new Uint8List(256);

    //
    // make state
    {
      for (int i = 0; i < 256; i++) {
        state[i] = i;
      }
      for (int i = 0, j = 0, tmp = 0; i < 256; i++) {
        j = (j + state[i] + key[i % key.length]) % 256;
        state[i] = i;
        tmp = state[i];
        state[i] = state[j];
        state[j] = tmp;
      }
    }
    //
    //
    {
      List<int> buffer = result.buffer;
      int ri = result.index;
      for (int i = 0, j = 0, v = 0, len = value.length, tmp = 0; v < len; v++) {
        i = (i + 1) % 256;
        j = (j + state[i]) % 256;
        tmp = state[i];
        state[i] = state[j];
        state[j] = tmp;
        buffer[ri++] = state[(state[i] + state[j]) % 256] ^ value[v];
      }
      result.length = ri;
    }
  }
}
