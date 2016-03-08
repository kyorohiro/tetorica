part of hetimacore_cl;


class HetimaDataFSBuilder extends HetimaDataBuilder {
  Future<HetimaData> createHetimaData(String path) async {
    return new HetimaDataFS(path);
  }
}

class HetimaDataFS extends HetimaData {
  String _fileName = "";
  String get fileName => _fileName;
  html.FileEntry _fileEntry = null;

  bool get writable => true;
  bool get readable => true;

  bool _erace = false;
  bool _persistent = false;
  HetimaDataFS(String name, {erace: false, persistent: false}) {
    _fileName = name;
    _erace = erace;
    _persistent = persistent;
  }

  HetimaDataFS.fromFile(html.FileEntry fileEntry) {
    _fileEntry = fileEntry;
    _fileName = fileEntry.name;
  }

  Future<html.Entry> getEntry() async {
    return init();
  }

  Future<html.Entry> init() async {
    if (_fileEntry != null) {
      return _fileEntry;
    }
    html.FileSystem f = await html.window.requestFileSystem(1024, persistent: _persistent);
    html.Entry e = await f.root.createFile(_fileName);
    _fileEntry = (e as html.FileEntry);
    if (_erace == true) {
      await truncate(0);
      return _fileEntry;
    } else {
      return _fileEntry;
    }
  }

  Future<int> getLength() async {
    await init();
    html.File f = await _fileEntry.file();
    return f.size;
  }

  Future<WriteResult> write(Object buffer, int start, [int length=null]) async {
    if (buffer is List<int> && !(buffer is Uint8List)) {
      buffer = new Uint8List.fromList(buffer);
    }

    Completer<WriteResult> completer = new Completer();
    await init();
    html.FileWriter writer = await _fileEntry.createWriter();
    writer.onWrite.listen((html.ProgressEvent e) {
      completer.complete(new WriteResult());
      writer.abort();
    });
    writer.onError.listen((e) {
      completer.completeError({});
      writer.abort();
    });
    int len = await getLength();
    if (len < start) {
      Uint8List dummy = null;
      dummy = new Uint8List.fromList(new List.filled(start - len, 0));
      writer.seek(len);
      writer.write(new html.Blob([dummy, buffer]).slice(0, length+dummy.length));
    } else {
      writer.seek(start);
      writer.write(new html.Blob([buffer]).slice(0, length));
    }

    return completer.future;
  }

  Future<int> truncate(int fileSize) async {
    await init();
    html.FileWriter writer = await _fileEntry.createWriter();
    writer.truncate(fileSize);
    return fileSize;
  }

  Future<ReadResult> read(int offset, int length, {List<int> tmp: null}) async {
    Completer<ReadResult> c_ompleter = new Completer();
    await init();
    html.FileReader reader = new html.FileReader();
    html.File f = await _fileEntry.file();
    reader.onLoad.listen((_) {
      c_ompleter.complete(new ReadResult(reader.result));
    });
    reader.onError.listen((_) {
      c_ompleter.completeError(_);
    });
    reader.readAsArrayBuffer(f.slice(offset, offset + length));
    return c_ompleter.future;
  }

  void beToReadOnly() {}

  static Future<List<String>> getFiles({persistent: false}) async {
    html.FileSystem e = await html.window.requestFileSystem(1024, persistent: persistent);
    List<html.Entry> files = await e.root.createReader().readEntries();
    List<String> ret = [];
    for (html.Entry e in files) {
      if (e.isFile) {
        ret.add(e.name);
      }
    }
    return ret;
  }

  static Future removeFile(String filename, {persistent: false}) async {
    html.FileSystem e = await html.window.requestFileSystem(1024, persistent: persistent);
    html.Entry f = await e.root.getFile(filename);
    return f.remove();
  }
}
