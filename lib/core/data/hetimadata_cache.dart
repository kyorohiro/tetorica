library hetimacore.cache;

import 'dart:async' as async;
import 'dart:core';
import 'hetimadata.dart';
import 'hetimadata_mem.dart';

class CashInfo {
  int index = 0;
  int length = 0;
  HetimaDataMemory dataBuffer = null;
  bool _isWrite = false; //kiyo
  CashInfo(int index, int length) {
    this.index = index;
    this.length = length;
    this.dataBuffer = new HetimaDataMemory();
  }

  _setV(int index, int length) {
    this.index = index;
    this.length = length;
  }
}

class HetimaDataCache extends HetimaData {
  List<CashInfo> _gomiInfoList = [];
  List<CashInfo> _cashInfoList = [];
  HetimaData _cashData = null;
  int cashSize = 1024;
  int cashNum = 3;

  bool get writable => true;
  bool get readable => true;
  int _cashLength = 0;

  static async.Future<HetimaDataCache> createWithReuseCashData(HetimaData cashData, {cacheSize: 1024, cacheNum: 3}) {
    async.Completer<HetimaDataCache> com = new async.Completer();
    HetimaDataCache ret = new HetimaDataCache(cashData, cacheSize: cacheSize, cacheNum: cacheNum);
    ret.getLength().then((int length) {
      ret._cashLength = length;
      com.complete(ret);
    }).catchError((e) {
      com.completeError(e);
    });
    return com.future;
  }

  //
  // if reuse cashData, you must to use HetimaDataCache#create
  //
  HetimaDataCache(HetimaData cashData, {cacheSize: 1024, cacheNum: 3}) {
    this._cashInfoList = [];
    this._cashData = cashData;
    this.cashSize = cacheSize;
    this.cashNum = cacheNum;
  }

  async.Future<int> getLength() {
    async.Completer<int> com = new async.Completer();
    _cashData.getLength().then((int len) {
      if (_cashLength > len) {
        com.complete(_cashLength);
      } else {
        com.complete(len);
      }
    }).catchError(com.completeError);
    return com.future;
  }

  async.Future<CashInfo> getCashInfo(int startA) {
    async.Completer<CashInfo> com = new async.Completer();

    for (CashInfo c in _cashInfoList) {
      //   print("#### ${c.index} <= ${startA} && ${startA} < ${(c.index + c.length)}");
      if (c.index <= startA && startA < (c.index + c.length)) {
        _cashInfoList.remove(c);
        _cashInfoList.add(c);
        com.complete(c);
        return com.future;
      }
    }

    //   print("###############################dd ${_cashInfoList.length} ${cashNum}");
    CashInfo removeInfo = null;
    CashInfo writeInfo = null;
    if (_gomiInfoList.length > 0) {
      writeInfo = _gomiInfoList.removeLast();
      writeInfo._setV(startA - startA % cashSize, cashSize);
    } else {
      writeInfo = new CashInfo(startA - startA % cashSize, cashSize);
    }
    // not found
    if (_cashInfoList.length >= cashNum) {
      removeInfo = _cashInfoList.removeAt(0);
    }

    _writeFunc(removeInfo).then((WriteResult w) {
      return _readFunc(writeInfo).then((WriteResult r) {
        com.complete(writeInfo);
      });
    }).catchError((e) {
      com.completeError(e);
    });
    return com.future;
  }

  async.Future<WriteResult> write(List<int> buffer, int offset,[int length=null]) {
    async.Completer<WriteResult> com = new async.Completer();

    // add 0
    if (offset > _cashLength) {
      List<int> zero = new List.filled(offset - _cashLength, 0);
      offset = _cashLength;
      buffer.insertAll(0, zero);
    }

    if(length == null) {
     length = buffer.length;
    }
    int n = 0;
    List<async.Future> act = [];

    for (int i = offset; i < (offset + length); i = n) {
      int index = i;
      int next = n = i + (cashSize - (i + cashSize) % cashSize);
      act.add(getCashInfo(index).then((CashInfo ret) {
        if (next - offset > buffer.length) {
          next = buffer.length + offset;
        }
        ret._isWrite = true; //kiyo
        return ret.dataBuffer.write(buffer.sublist(index - offset, next - offset), index - ret.index);
      }));
    }

    async.Future.wait(act).then((List<WriteResult> rl) {
      com.complete(new WriteResult());
    });

    return com.future;
  }

  async.Future<ReadResult> read(int offset, int length, {List<int> tmp: null}) {
    List<int> indexList = [];
    List<int> nextList = [];

    //
    // search cache
    {
      int n = 0;
      for (int i = offset; i < (offset + length); i = n) {
        int index = i;
        int next = n = i + (cashSize - (i + cashSize) % cashSize);
        indexList.add(index);
        nextList.add(n);
      }
    }

    //
    // zero
    if (indexList.length == 0) {
      return new async.Future(() {
        return new ReadResult([]);
      });
    }
    //
    // one
    else if (indexList.length == 1) {
      int index = indexList[0];
      int next = nextList[0];
      return getCashInfo(indexList[0]).then((CashInfo info) {
        return info.dataBuffer.read(index - info.index, next - index);
      });
    }

    //
    // other
    else {

      List<async.Future> act = [];
      for (int i = 0; i < indexList.length; i++) {
        int index = indexList[i];
        int next = nextList[i];
        act.add(getCashInfo(index).then((CashInfo ret) {
          return ret.dataBuffer.read(index - ret.index, next - index);
        }));
      }

      return async.Future.wait(act).then((List<ReadResult> rl) {
        //
        // buffer length
        int length = 0;
        for (ReadResult r in rl) {
          length += r.length;
        }
        
        
        //
        // buffer
        List<int> _buffer = null;
        if (_buffer == null || tmp.length < length) {
          _buffer = new List(length);
        } else {
          _buffer = tmp;
        }
        int s = 0;
        int e = 0;
        for (ReadResult r in rl) {
          e = s + r.length;
          _buffer.setAll(s, r.buffer);
          s = e;
        }
        
        // end
        return new ReadResult(_buffer, length);
      });
    }
  }

  void beToReadOnly() {}

  async.Future _writeFunc(CashInfo info) {
    if (info == null || info._isWrite == false) {
      ///kiyo
      async.Completer comp = new async.Completer();
      //
      //
      //
      if (_gomiInfoList.length == 0 && info != null) {
        info._isWrite = false;
        _gomiInfoList.add(info);
      }
      comp.complete(null);
      return comp.future;
    }
    return info.dataBuffer.getLength().then((int len) {
      return info.dataBuffer.read(0, len).then((ReadResult r) {
        return _cashData.write(r.buffer, info.index, r.buffer.length).then((WriteResult r) {
          if (_gomiInfoList.length == 0 && info != null) {
            info._isWrite = false;
            _gomiInfoList.add(info);
          }
          return r;
        });
      });
    });
  }

  async.Future _readFunc(CashInfo ret) {
    // kiyokiyo
    return new async.Future(() {
      return _cashData.read(ret.index, cashSize).then((ReadResult r) {
        return ret.dataBuffer.write(r.buffer, 0).then((WriteResult r) {
          _cashInfoList.add(ret);          
        });
      });
    });
  }

  async.Future<dynamic> flush() {
//   print("###############################ff");
    List<async.Future> act = [];
    for (CashInfo c in _cashInfoList) {
      act.add(_writeFunc(c));
    }
    return async.Future.wait(act);
  }
}
