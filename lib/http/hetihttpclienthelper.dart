part of hetimanet_http;

class HttpClientHelper {
  TetSocketBuilder socketBuilder;
  HttpClientHelper(this.socketBuilder){}
  Future<HttpClientResponse> get(String address, int port, String pathAndOption,
    {List<int> redirectStatusCode: const [301, 302, 303, 304, 305, 307, 308],
       Map<String, String> header, int redirect: 5,
       bool reuseQuery: true}) async {
      return await base(address, port, "GET", pathAndOption, null,
      redirectStatusCode: redirectStatusCode, header: header, redirect: redirect, reuseQuery: reuseQuery);
  }

  Future<HttpClientResponse> post(String address, int port, String pathAndOption, List<int> data,
    {List<int> redirectStatusCode: const [301, 302, 303, 304, 305, 307, 308],
       Map<String, String> header, int redirect: 5,
       bool reuseQuery: true}) async {
      return await base(address, port, "POST", pathAndOption, data,
      redirectStatusCode: redirectStatusCode, header: header, redirect: redirect, reuseQuery: reuseQuery);
  }

  Future<HttpClientResponse> base(String address, int port, String action, String pathAndOption, List<int> data, {List<int> redirectStatusCode: const [301, 302, 303, 304, 305, 307, 308], Map<String, String> header, int redirect: 5, bool reuseQuery: true}) async {
    print("${pathAndOption}");
    HttpClient client = new HttpClient(socketBuilder);
    await client.connect(address, port);
    HttpClientResponse res = await client.base(action,pathAndOption, data, header:header);
    client.close();
    //
    if (redirectStatusCode.contains(res.message.line.statusCode)) {
      HetiHttpResponseHeaderField locationField = res.message.find("Location");
      HttpUrl hurl = HttpUrlDecoder.decodeUrl(locationField.fieldValue, "http://${address}:${port}");
      int optionIndex = pathAndOption.indexOf("?");
      String option = "";
      if(optionIndex > 0) {
        option = pathAndOption.substring(optionIndex);
      }
      pathAndOption = "${hurl.path}${option}";
      return base(address, port, action, pathAndOption, data,
        redirectStatusCode: redirectStatusCode, header: header, redirect: (redirect - 1), reuseQuery: reuseQuery);
    } else {
      return res;
    }
  }
}
