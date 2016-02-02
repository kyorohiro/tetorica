part of hetimanet_http;




class HetiHttpClientHelper {
  String _address;
  int _port;
  TetSocketBuilder _socketBuilder;
  //HetimaDataBuilder _fileBuilder;
  String get address => _address;
  int get port => _port;

  HetiHttpClientHelper(String address, int port, TetSocketBuilder socketBuilder, HetimaDataBuilder fileBuilder) {
    this._address = address;
    this._port = port;
    this._socketBuilder = socketBuilder;
  //  this._fileBuilder = fileBuilder;
  }

  Future<HetimaData> get(String pathAndOption) {
    HetiHttpClient client  = new HetiHttpClient(_socketBuilder);
    client.connect(_address, _port).then((HetiHttpClientConnectResult b){
      return client.get(pathAndOption);
    }).then((HetiHttpClientResponse res) {
      ;
    });
  }
}
