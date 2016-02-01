part of hetimacore;

class EasyParser {
  int index = 0;
  List<int> stack = new List();
  HetimaReader _buffer = null;
  HetimaReader get buffer => _buffer;

  EasyParser(HetimaReader builder,{bool logon:false}) {
    _buffer = builder;
  }

  EasyParser toClone() {
    EasyParser parser = new EasyParser(new HetimaReaderAdapter(_buffer, 0));
    parser.index = index;
    parser.stack = new List.from(stack);
    return parser;
  }

  void push() {
    stack.add(index);
  }

  void back() {
    index = stack.last;
  }

  int pop() {
    int ret = stack.last;
    stack.remove(ret);
    return ret;
  }

  int last() {
    return stack.last;
  }

  //
  // [TODO]
  void resetIndex(int _index) {
    index = _index;
  }
  //
  // [TODO]
  int getInedx() {
    return index;
  }
  Future<List<int>> getPeek(int length) {
    return _buffer.getByteFuture(index, length);
  }

  Future<List<int>> nextBuffer(int length) async {
    List<int> v = await _buffer.getByteFuture(index, length);
      index += v.length;
    return v;
  }

  Future<String> nextString(String value) {
    Completer completer = new Completer();
    List<int> encoded = convert.UTF8.encode(value);

    _buffer.getByteFuture(index, encoded.length).then((List<int> v) {
      if(v.length < encoded.length) {
        completer.completeError(new EasyParseError());
        return;
      }
      int i = 0;
      for (int e in encoded) {
        if (e != v[i]) {
          completer.completeError(new EasyParseError());
          return;
        }
        i++;
        index++;
      }
      completer.complete(value);
    });
    return completer.future;
  }

  Future<String> readSignWithLength(int length) {
    Completer<String> completer = new Completer();
    _buffer.getByteFuture(index, length).then((List<int> va) {
        index += length;
        completer.complete(convert.UTF8.decode(va));
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }

  Future<int> readShort(int byteorder) {
    Completer<int> completer = new Completer();
    _buffer.getByteFuture(index, 2).then((List<int> va) {
        index += 2;
        completer.complete(ByteOrder.parseShort(va, 0, byteorder));
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }

  Future<List<int>> readShortArray(int byteorder, int num) {
    Completer<List<int>> completer = new Completer();
    if (num == 0) {
      completer.complete([]);
      return completer.future;
    }
    _buffer.getByteFuture(index, 2 * num).then((List<int> va) {
        index += 2 * num;
        List<int> l = new List();
        for (int i = 0; i < num; i++) {
          l.add(ByteOrder.parseShort(va, i * 2, byteorder));
        }
        completer.complete(l);
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }

  Future<int> readInt(int byteorder) {
    Completer<int> completer = new Completer();
    _buffer.getByteFuture(index, 4).then((List<int> va) {
        index += 4;
        completer.complete(ByteOrder.parseInt(va, 0, byteorder));
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }

  Future<int> readLong(int byteorder) {
    Completer<int> completer = new Completer();
    _buffer.getByteFuture(index, 8).then((List<int> va) {
        index += 8;
        completer.complete(ByteOrder.parseLong(va, 0, byteorder));
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }

  Future<int> readByte() {
    Completer<int> completer = new Completer();
    _buffer.getByteFuture(index, 1).then((List<int> va) {
      index += 1;
      completer.complete(va[0]);
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }

  Future<int> nextBytePattern(EasyParserMatcher matcher) {
    Completer completer = new Completer();
    matcher.init();
    _buffer.getByteFuture(index, 1).then((List<int> v) {
      if (v.length < 1) {
        throw new EasyParseError();
      }
      if (matcher.match(v[0])) {
        index++;
        completer.complete(v[0]);
      } else {
        throw new EasyParseError();
      }
    });
    return completer.future;
  }

  Future<List<int>> nextBytePatternWithLength(EasyParserMatcher matcher, int length) {
    Completer completer = new Completer();
    matcher.init();
    _buffer.getByteFuture(index, length).then((List<int> va) {
      if (va.length < length) {
        completer.completeError(new EasyParseError());
      }
      for (int v in va) {
        bool find = false;
        find = matcher.match(v);
        if (find == false) {
          completer.completeError(new EasyParseError());
        }
        index++;
      }
      completer.complete(va);
    });
    return completer.future;
  }

  Future<List<int>> nextBytePatternByUnmatch(EasyParserMatcher matcher, [bool keepWhenMatchIsTrue = true]) {
    Completer completer = new Completer();
    matcher.init();
    List<int> ret = new List<int>();
    Future<Object> p() {
      return _buffer.getByteFuture(index, 1).then((List<int> va) {
        if (va.length < 1) {
          completer.complete(ret);
        } else if (keepWhenMatchIsTrue == matcher.match(va[0])) {
          ret.add(va[0]);
          index++;
          return p();
        } else if (_buffer.immutable) {
          completer.complete(ret);
        } else {
          completer.complete(ret);
        }
      });
    }
    p();
    return completer.future;
  }
}

abstract class EasyParserMatcher {
  void init() {
    ;
  }
  bool match(int target);
  bool matchAll() {
    return true;
  }
}

//
// http response
//
class EasyParserIncludeMatcher extends EasyParserMatcher {
  List<int> include = null;
  EasyParserIncludeMatcher(List<int> i) {
    include = i;
  }

  bool match(int target) {
    return include.contains(target);
  }
}

class EasyParserStringMatcher extends EasyParserMatcher {
  List<int> include = null;
  int index = 0;
  EasyParserIncludeMatcher(String v) {
    include = convert.UTF8.encode(v);
  }

  void init() {
    index = 0;
  }

  bool match(int target) {
    return include.contains(target);
  }
}

class EasyParseError extends Error {
  EasyParseError();
}
