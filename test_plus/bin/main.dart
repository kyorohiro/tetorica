import 'package:tetorica/net_dartio.dart';
import 'package:tetorica/http.dart' as http;
import 'dart:convert';

main() async {
  TetSocketBuilderDartIO builder = new TetSocketBuilderDartIO();
  http.HttpClient client = new http.HttpClient(builder);
  http.HttpClientConnectResult connectResult = await client.connect("httpbin.org", 80);
  http.HttpClientResponse postResult =
    await client.post(
      "post", UTF8.encode(JSON.encode({"message": "hello!!"})),
      header:{"nono": "nano", "Content-Type": "application/json"});
  print("## ${postResult.message.contentLength}");
}
