library test_plus.http;

import 'package:tetorica/net.dart';
import 'package:tetorica/http.dart' as http;
import 'dart:convert' as conv;
import 'package:test/test.dart' as test;

doTest(TetSocketBuilder builder) async {

  test.test("put", () async {
    http.HttpClient client = new http.HttpClient(builder);
    await client.connect("httpbin.org", 80);
    http.HttpClientResponse postResult = await client.put("/put", conv.UTF8.encode(conv.JSON.encode({"message": "hello!!"})), header: {"nono": "nano", "Content-Type": "application/json"});
    print("## ${postResult.message.contentLength}");
    print("## ${await postResult.body.getString()}");
    Map<String, Object> ret = conv.JSON.decode(await postResult.body.getString());
    test.expect("application/json", (ret["headers"] as Map)["Content-Type"]);
    test.expect("nano", (ret["headers"] as Map)["Nono"]);
    test.expect("hello!!", (ret["json"] as Map)["message"]);
  });
  test.test("patch", () async {
    http.HttpClient client = new http.HttpClient(builder);
    await client.connect("httpbin.org", 80);
    http.HttpClientResponse postResult = await client.patch("/patch", conv.UTF8.encode(conv.JSON.encode({"message": "hello!!"})), header: {"nono": "nano", "Content-Type": "application/json"});
    print("## ${postResult.message.contentLength}");
    print("## ${await postResult.body.getString()}");
    Map<String, Object> ret = conv.JSON.decode(await postResult.body.getString());
    test.expect("application/json", (ret["headers"] as Map)["Content-Type"]);
    test.expect("nano", (ret["headers"] as Map)["Nono"]);
    test.expect("hello!!", (ret["json"] as Map)["message"]);
  });
  test.test("post", () async {
    http.HttpClient client = new http.HttpClient(builder);
    await client.connect("httpbin.org", 80);
    http.HttpClientResponse postResult = await client.post("/post", conv.UTF8.encode(conv.JSON.encode({"message": "hello!!"})), header: {"nono": "nano", "Content-Type": "application/json"});
    print("## ${postResult.message.contentLength}");
    print("## ${await postResult.body.getString()}");
    Map<String, Object> ret = conv.JSON.decode(await postResult.body.getString());
    test.expect("application/json", (ret["headers"] as Map)["Content-Type"]);
    test.expect("nano", (ret["headers"] as Map)["Nono"]);
    test.expect("hello!!", (ret["json"] as Map)["message"]);
  });

  test.test("get", () async {
    http.HttpClient client = new http.HttpClient(builder);
    await client.connect("httpbin.org", 80);
    http.HttpClientResponse postResult = await client.get("/get", header: {"nono": "nano", "Content-Type": "application/json"});
    print("## ${postResult.message.contentLength}");
    print("## ${await postResult.body.getString()}");
    Map<String, Object> ret = conv.JSON.decode(await postResult.body.getString());
    test.expect("application/json", (ret["headers"] as Map)["Content-Type"]);
    test.expect("nano", (ret["headers"] as Map)["Nono"]);
    //test.expect("hello!!", (ret["json"] as Map)["message"]);
  });

  test.test("delete", () async {
    http.HttpClient client = new http.HttpClient(builder);
    await client.connect("httpbin.org", 80);
    http.HttpClientResponse postResult = await client.delete("/delete", header: {"nono": "nano", "Content-Type": "application/json"});
    print("## ${postResult.message.contentLength}");
    print("## ${await postResult.body.getString()}");
    Map<String, Object> ret = conv.JSON.decode(await postResult.body.getString());
    test.expect("application/json", (ret["headers"] as Map)["Content-Type"]);
    test.expect("nano", (ret["headers"] as Map)["Nono"]);
    //test.expect("hello!!", (ret["json"] as Map)["message"]);
  });

  test.test("head", () async {
    http.HttpClient client = new http.HttpClient(builder);
    await client.connect("httpbin.org", 80);
    http.HttpClientResponse postResult = await client.head("/get");//, header: {"nono": "nano", "Content-Type": "application/json"});
    print("## ${postResult.message.headerField}");
    print("## ${await postResult.body.getString()}");
    //Map<String, Object> ret = conv.JSON.decode(await postResult.body.getString());
    //test.expect("application/json", (ret["headers"] as Map)["Content-Type"]);
    //test.expect("nano", (ret["headers"] as Map)["Nono"]);
    //test.expect("hello!!", (ret["json"] as Map)["message"]);
  });

  test.test("put", () async {
    http.HttpClient client = new http.HttpClient(builder);
    await client.connect("httpbin.org", 80);
    http.HttpClientResponse postResult = await client.put("/put", conv.UTF8.encode(conv.JSON.encode({"message": "hello!!"})), header: {"nono": "nano", "Content-Type": "application/json"});
    print("## ${postResult.message.contentLength}");
    print("## ${await postResult.body.getString()}");
    Map<String, Object> ret = conv.JSON.decode(await postResult.body.getString());
    test.expect("application/json", (ret["headers"] as Map)["Content-Type"]);
    test.expect("nano", (ret["headers"] as Map)["Nono"]);
    test.expect("hello!!", (ret["json"] as Map)["message"]);
  });
  ///redirect-to?url=foo
  ///
  test.test("helper get", () async {
    http.HttpClientHelper client = new http.HttpClientHelper(builder);
    http.HttpClientResponse postResult = await client.get("httpbin.org", 80,"/get",header: {"nono": "nano", "Content-Type": "application/json"});
    print("## ${postResult.message.contentLength}");
    print("## ${await postResult.body.getString()}");
    Map<String, Object> ret = conv.JSON.decode(await postResult.body.getString());
    test.expect("application/json", (ret["headers"] as Map)["Content-Type"]);
    test.expect("nano", (ret["headers"] as Map)["Nono"]);
  });
  ///redirect-to?url=foo
  ///
  test.test("helper get relative-redirect 3", () async {
    http.HttpClientHelper client = new http.HttpClientHelper(builder);
    http.HttpClientResponse postResult = await client.get("httpbin.org", 80,"/relative-redirect/3",header: {"nono": "nano", "Content-Type": "application/json"});
    print("## ${postResult.message.contentLength}");
    print("## ${await postResult.body.getString()}");
    Map<String, Object> ret = conv.JSON.decode(await postResult.body.getString());
    test.expect("application/json", (ret["headers"] as Map)["Content-Type"]);
    test.expect("nano", (ret["headers"] as Map)["Nono"]);
  });

  test.test("helper get absolute-redirect 3", () async {
    http.HttpClientHelper client = new http.HttpClientHelper(builder);
    http.HttpClientResponse postResult =
    await client.get("httpbin.org", 80,"/absolute-redirect/3?asdf=aas",header: {"nono": "nano", "Content-Type": "application/json"});
    print("## ${postResult.message.contentLength}");
    print("## ${await postResult.body.getString()}");
    Map<String, Object> ret = conv.JSON.decode(await postResult.body.getString());
    test.expect("application/json", (ret["headers"] as Map)["Content-Type"]);
    test.expect("nano", (ret["headers"] as Map)["Nono"]);
  });

  test.test("helper post", () async {
    http.HttpClientHelper client = new http.HttpClientHelper(builder);
    http.HttpClientResponse postResult =
    await client.post("httpbin.org", 80, "/post",//"/absolute-redirect/3?asdf=aas",
    conv.UTF8.encode(conv.JSON.encode({"message": "hello!!"})),
    header: {"nono": "nano", "Content-Type": "application/json"});
    print("## ${postResult.message.contentLength}");
    print("## ${await postResult.body.getString()}");
    Map<String, Object> ret = conv.JSON.decode(await postResult.body.getString());
    test.expect("application/json", (ret["headers"] as Map)["Content-Type"]);
    test.expect("nano", (ret["headers"] as Map)["Nono"]);
  });

  test.test("get : https", () async {
    http.HttpClient client = new http.HttpClient(builder);
    await client.connect("httpbin.org", 443, useSecure: true);
    http.HttpClientResponse postResult = await client.get("/get", header: {"nono": "nano", "Content-Type": "application/json"});
    print("## ${postResult.message.contentLength}");
    print("## ${await postResult.body.getString()}");
//    Map<String, Object> ret = conv.JSON.decode(await postResult.body.getString());
//    test.expect("application/json", (ret["headers"] as Map)["Content-Type"]);
//    test.expect("nano", (ret["headers"] as Map)["Nono"]);
  });
}
