library hetimacore.parser;

import 'dart:typed_data' as data;
import 'dart:math' as math;
import 'dart:convert' as convert;
import 'dart:async';
import 'dart:core';
import 'hetimareader.dart';
import 'byteorder.dart';

class EasyParser {
  int index = 0;
  List<int> stack = new List();
  HetimaReader _buffer = null;
  HetimaReader get buffer => _buffer;
  bool _logon = false;

  EasyParser(HetimaReader builder,{bool logon:false}) {
    _buffer = builder;
    _logon = logon;
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

  Future<List<int>> nextBuffer(int length, {List<int> buffer: null, List<int> outLength:null}) async {
    List<int> v = await _buffer.getByteFuture(index, length, buffer: buffer, output:outLength);
    if(outLength == null) {
      index += v.length;
    } else {
      index +=outLength[0];
    }
    return v;
  }

  Future<String> nextString(String value, {List<int> buffer:null, List<int> outLength:null}) {
    if(outLength == null) {
      outLength = [0];
    }
    Completer completer = new Completer();
    List<int> encoded = convert.UTF8.encode(value);

    _buffer.getByteFuture(index, encoded.length, buffer:buffer, output:outLength).then((List<int> v) {
      if (outLength[0] != encoded.length) {
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

  Future<String> readSignWithLength(int length, {List<int> buffer:null, List<int> outLength:null}) {
    if(outLength == null) {
      outLength = [0];
    }
    Completer<String> completer = new Completer();
    _buffer.getByteFuture(index, length, buffer:buffer, output:outLength).then((List<int> va) {
      if (outLength[0] < length) {
        completer.completeError(new EasyParseError());
      } else {
        index += length;
        completer.complete(convert.UTF8.decode(va));
      }
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }

  Future<int> readShort(int byteorder, {List<int> buffer:null, List<int> outLength:null}) {
    if(outLength == null) {
      outLength = [0];
    }
    Completer<int> completer = new Completer();
    _buffer.getByteFuture(index, 2, buffer:buffer, output:outLength).then((List<int> va) {
      if (outLength[0] < 2) {
        completer.completeError(new EasyParseError());
      } else {
        index += 2;
        completer.complete(ByteOrder.parseShort(va, 0, byteorder));
      }
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }

  Future<List<int>> readShortArray(int byteorder, int num, {List<int> buffer:null, List<int> outLength:null}) {
    if(outLength == null) {
      outLength = [0];
    }
    Completer<List<int>> completer = new Completer();
    if (num == 0) {
      completer.complete([]);
      return completer.future;
    }
    _buffer.getByteFuture(index, 2 * num,buffer:buffer, output:outLength).then((List<int> va) {
      if (outLength[0] < 2 * num) {
        completer.completeError(new EasyParseError());
      } else {
        index += 2 * num;
        List<int> l = new List();
        for (int i = 0; i < num; i++) {
          l.add(ByteOrder.parseShort(va, i * 2, byteorder));
        }
        completer.complete(l);
      }
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }

  Future<int> readInt(int byteorder, {List<int> buffer:null, List<int> outLength:null}) {
    if(outLength == null) {
      outLength = [0];
    }
    Completer<int> completer = new Completer();
    _buffer.getByteFuture(index, 4, buffer:buffer, output:outLength).then((List<int> va) {
      if (outLength[0] < 4) {
        completer.completeError(new EasyParseError());
      } else {
        index += 4;
        completer.complete(ByteOrder.parseInt(va, 0, byteorder));
      }
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }

  Future<int> readLong(int byteorder, {List<int> buffer:null, List<int> outLength:null}) {
    if(outLength == null) {
      outLength = [0];
    }
    Completer<int> completer = new Completer();
    _buffer.getByteFuture(index, 8, buffer:buffer, output:outLength).then((List<int> va) {
      if (outLength[0] < 8) {
        completer.completeError(new EasyParseError());
      } else {
        index += 8;
        completer.complete(ByteOrder.parseLong(va, 0, byteorder));
      }
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }

  Future<int> readByte({List<int> buffer:null, List<int> outLength:null}) {
    if(outLength == null) {
      outLength = [0];
    }
    Completer<int> completer = new Completer();
    _buffer.getByteFuture(index, 1, buffer:buffer, output:outLength).then((List<int> va) {
      if (outLength[0] < 1) {
        completer.completeError(new EasyParseError());
      } else {
        index += 1;
        completer.complete(va[0]);
      }
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
