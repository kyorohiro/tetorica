part of hetimanet_http;

//
// https://tools.ietf.org/html/rfc5849
// http://oauth.net/core/1.0a/
//
// todotodo
class OAuthClient {
  TetSocketBuilder _socketBuilder;
  OAuthToken token;
  math.Random rand;
  OAuthClient(this._socketBuilder, String consumerKey, String consumerSecret, String accessToken, String accessTokenSecret, {String signatureMethod: "HMAC-SHA1"}) {
    math.Random r = new math.Random(new DateTime.now().millisecondsSinceEpoch);
    token = new OAuthToken();
    token.consumerKey = consumerKey;
    token.consumerSecret = consumerSecret;
    token.accessToken = accessToken;
    token.accessTokenSecret = accessTokenSecret;
    token.signatureMethod = signatureMethod;
  }

  data.Uint8List createRandomBytes(int byteSize) {
    data.Uint8List ret = new data.Uint8List(byteSize);
    for(int i=0;i<byteSize;i++) {
      ret[i] = (rand.nextInt(0xff) ^ rand.nextInt(0xff) ) & 0xff;
    }
    return ret;
  }

  Map<String,String> createParamSet(String path) {
    Map<String, String> params = new Map<String, String>();
    String nonce = convert.BASE64.encode(createRandomBytes(8));
    int timestamp = new DateTime.now().millisecondsSinceEpoch ~/ 1000;
    //
    params["oauth_consumer_key"] = this.token.consumerKey;
    if(this.token.accessToken != null) {
      params["oauth_token"] = this.token.consumerKey;
    }
    params["oauth_signature_method"] = this.token.signatureMethod;
    params["oauth_version"] = "1.0";
    params["oauth_nonce"] = nonce;
    params["oauth_timestamp"] = timestamp.toString();
    //
    Map<String,String> queryMap = HttpUrlDecoder.queryMap(path);
    queryMap .keys.map((var k) => queryMap[k]);
    params.keys.map((var k) => params[k]);
    return params;
  }

  Future send(HttpClient client, String path) {

  }
}

class OAuthToken {
  String consumerKey;
  String consumerSecret;
  String accessToken;
  String accessTokenSecret;
  String signatureMethod = "HMAC-SHA1"; //, RSA-SHA1, and PLAINTEXT"
}
