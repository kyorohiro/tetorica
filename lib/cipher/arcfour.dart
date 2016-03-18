library base64;

import 'cipher.dart';
import 'dart:typed_data';

class ARCFOUR {
  static int makeState(List<int> key, int keyIndex, int keyLength, Uint8List out, int outIndex) {
    for (int i = 0; i < 256; i++) {
      out[i + outIndex] = i;
    }

    for (int i = 0, j = 0, tmp = 0; i < 256; i++) {
      j = (j + out[i + outIndex] + key[i % keyLength + keyIndex]) % 256;
      tmp = out[i + outIndex];
      out[i + outIndex] = out[j + outIndex];
      out[j + outIndex] = tmp;
    }
    return 256;
  }

  static int operate(List<int> value, int valueIndex, int valueLength, List<int> state, int stateIndex, List<int> ij, int ijIndex, Uint8List output, int outputIndex) {
    int i = ij[ijIndex];
    int j = ij[ijIndex + 1];
    //
    //
    int ri = outputIndex;
    for (int v = 0, tmp = 0; v < valueLength; v++) {
      i = (i + 1) % 256;
      j = (j + state[i + stateIndex]) % 256;
      tmp = state[i + stateIndex];
      state[i + stateIndex] = state[j + stateIndex];
      state[j + stateIndex] = tmp;
      output[ri++] = state[((state[i + stateIndex] + state[j + stateIndex]) % 256) + stateIndex] ^ value[v + valueIndex];
    }
    ij[ijIndex] = i;
    ij[ijIndex + 1] = i;
    return ri - outputIndex;
  }
}
