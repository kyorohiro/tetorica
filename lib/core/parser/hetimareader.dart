part of hetimacore;

abstract class HetimaReader {

  Future<List<int>> getByteFuture(int index, int length, {List<int> buffer:null, List<int> output:null}) ;

  Future<int> getLength();

  void fin() {
    immutable = true;
  }

  Completer<bool> _completerFin = new Completer();

  Completer<bool> get rawcompleterFin => _completerFin;
  //
  // maybe dart bug when use with dart:io:
  // must to use rawcompleterFin.future...
  //
  Future<bool> get onFin => _completerFin.future;

  bool _immutable = false;

  bool get immutable => _immutable;

  void set immutable(bool v) {
    bool prev = _immutable;
    _immutable = v;
    if(prev == false && v== true) {
      _completerFin.complete(v);
    }
  }

  void clearInnerBuffer(int len) {
    ;
  }

}

class HetimaReaderAdapter extends HetimaReader {
  HetimaReader _base = null;
  int _startIndex = 0;

  HetimaReaderAdapter(HetimaReader builder, int startIndex) {
    _base = builder;
    _startIndex = startIndex;
  }

  Future<int> getLength() {
    Completer<int> completer = new Completer();
    _base.getLength().then((int v){
      completer.complete(v - _startIndex);
    }).catchError((e){
      completer.completeError(e);
    });
    return completer.future;
  }

  Completer<bool> get rawcompleterFin => _base.rawcompleterFin;
  //
  Future<bool> get onFin => _base.onFin;

  Future<List<int>> getByteFuture(int index, int length, {List<int> buffer:null,List<int> output:null}) {
    Completer<List<int>> completer = new Completer();

    _base.getByteFuture(index + _startIndex, length, buffer:buffer, output:output).then((List<int> d) {
      completer.complete(d);
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }

  void fin() {
    _base.fin();
  }

  bool get immutable => _base.immutable;

  void set immutable(bool v) {
    _base.immutable = v;
  }
}
