library hetimacore.file.serialize;

import 'dart:async';
import 'dart:core';
import '../../hetimacore.dart';

class HetimaDataSerialize extends HetimaData {
  bool get writable => false;
  bool get readable => false;
  HetimaData _base = null;

  List<HetimaDataSerializeTask> _action = [];
  HetimaDataSerialize(HetimaData base) {
    _base = base;
  }

  Future<int> getLength() {
    HetimaDataSerializeTaskLength t = new HetimaDataSerializeTaskLength();
    t.c = new Completer();
    _action.add(t);
    _update();
    return t.c.future;
  }

  Future<WriteResult> write(Object buffer, int start, [int length=null]) {
    HetimaDataSerializeTaskWrite t = new HetimaDataSerializeTaskWrite();
    t.buffer = buffer;
    t.start = start;
    t.length = length;
    t.c = new Completer();
    _action.add(t);
    _update();
    return t.c.future;
  }

  Future<ReadResult> read(int offset, int length, {List<int> tmp: null}) {
    HetimaDataSerializeTaskRead t = new HetimaDataSerializeTaskRead();
    t.offset = offset;
    t.length = length;
    t.tmp = tmp;
    t.c = new Completer();
    _action.add(t);
    _update();
    return t.c.future;
  }

  void beToReadOnly() {
    _base.beToReadOnly();
  }

  bool _updating = false;
  _update() async {
    if (_updating == true) {
      return;
    }
    _updating = true;
    while (0 < _action.length) {
      HetimaDataSerializeTask t = _action.removeAt(0);
      if (t is HetimaDataSerializeTaskLength) {
        int l = await _base.getLength();
        t.c.complete(l);
      } else if (t is HetimaDataSerializeTaskRead) {
        ReadResult r = await _base.read(t.offset, t.length);
        t.c.complete(r);
      } else if (t is HetimaDataSerializeTaskWrite) {
        WriteResult w = await _base.write(t.buffer, t.start, t.length);
        t.c.complete(w);
      }
    }
    _updating = false;
  }
}

class HetimaDataSerializeTask {
  int id = 0;
  Completer c;
}

class HetimaDataSerializeTaskWrite implements HetimaDataSerializeTask {
  int id = 0;
  Object buffer;
  int start;
  int length;
  Completer c;
}

class HetimaDataSerializeTaskRead implements HetimaDataSerializeTask {
  int id = 0;
  int offset;
  int length;
  List<int> tmp = null;
  Completer c;
}

class HetimaDataSerializeTaskLength implements HetimaDataSerializeTask {
  int id = 0;
  Completer c;
}
