//import 'package:unittest/unittest.dart' as unit;
import 'package:tetorica/core.dart' as hetima;
import 'package:tetorica/hetimanet.dart' as hetima;

/*
void main() {

  hetima.HetiTest test = new hetima.HetiTest("t");

  {
    hetima.HetiTestTicket ticket = test.test("a", 3000);
    Map<String, String> map = hetima.HttpUrlDecoder.queryMap("");
    ticket.assertTrue("", 0==map.length);
    ticket.fin();
  }
  {
    hetima.HetiTestTicket ticket = test.test("aa", 3000);
    Map<String, String> map = hetima.HttpUrlDecoder.queryMap("=");
    ticket.assertTrue("", 1==map.length);
    ticket.assertTrue("", ""==map[""]);
    ticket.fin();
  }
  {
    hetima.HetiTestTicket ticket = test.test("b", 3000);
    Map<String, String> map = hetima.HttpUrlDecoder.queryMap("xxx=ccc");
    ticket.assertTrue("1:"+map.length.toString(), 1==map.length);
    ticket.assertTrue("2:", "ccc"==map["xxx"]);
    ticket.fin();
  }

  {
    hetima.HetiTestTicket ticket = test.test("c", 3000);
    Map<String, String> map = hetima.HttpUrlDecoder.queryMap("xxx=ccc&ddd=xxx");
    ticket.assertTrue("1:"+map.length.toString(), 2==map.length);
    ticket.assertTrue("2:", "ccc"==map["xxx"]);
    ticket.assertTrue("3:", "xxx"==map["ddd"]);
    ticket.fin();
  }

  {
    hetima.HetiTestTicket ticket = test.test("d", 3000);
    Map<String, String> map = hetima.HttpUrlDecoder.queryMap("xxx=ccc&ddd=x?x");
    ticket.assertTrue("1:"+map.length.toString(), 2==map.length);
    ticket.assertTrue("2:", "ccc"==map["xxx"]);
    ticket.assertTrue("3:", "x?x"==map["ddd"]);
    ticket.fin();
  }
  {
    hetima.HetiTestTicket ticket = test.test("e", 3000);
    Map<String, String> map = hetima.HttpUrlDecoder.queryMap("info_hash=%5F%C6%B8%A2%64%63%33%F5%63%9D%4E%95%2B%9B%B8%AD%EE%12%1A%BD&port=6969&peer_id=%2D%2D%74%65%73%74%87%E4%36%2A%55%AB%0C%E2%B5%33%C2%4B%79%84&event=started&uploaded=0&downloaded=0&left=0");
    ticket.assertTrue("2:", "%5F%C6%B8%A2%64%63%33%F5%63%9D%4E%95%2B%9B%B8%AD%EE%12%1A%BD"==map["info_hash"]);
    ticket.fin();
  }
  {
    hetima.HetiTestTicket ticket = test.test("f", 3000);
    Map<String, String> map = hetima.HttpUrlDecoder.queryMap("info_hash=%5F%C6%B8%A2%64%63%33%F5%63%9D%4E%95%2B%9B%B8%AD%EE%12%1A%BD&port=6969&peer_id=%2D%2D%74%65%73%74%87%E4%36%2A%55%AB%0C%E2%B5%33%C2%4B%79%84&event=started&uploaded=0&downloaded=0&left=0");
    ticket.assertTrue("2:", "%5F%C6%B8%A2%64%63%33%F5%63%9D%4E%95%2B%9B%B8%AD%EE%12%1A%BD"==map["info_hash"]);
    ticket.fin();
  }
  {
    hetima.HetiTestTicket ticket = test.test("g", 3000);
    Map<String, String> map = hetima.HttpUrlDecoder.queryMap("info_hash=_%C6%B8%A2dc3%F5c%9DN%95%2B%9B%B8%AD%EE%12%1A%BD&port=6969&peer_id=--test%87%E46%2AU%AB%0C%E2%B53%C2Ky%84&event=started&uploaded=0&downloaded=0&left=0");
    ticket.assertTrue("2:", "_%C6%B8%A2dc3%F5c%9DN%95%2B%9B%B8%AD%EE%12%1A%BD"==map["info_hash"]);
    ticket.fin();
  }
  {
    hetima.HetiTestTicket ticket = test.test("h", 3000);
    Map<String, String> map = hetima.HttpUrlDecoder.queryMap("info_hash=_%C6%B8%A2dc3%F5c%9DN%95%2B%9B%B8%AD%EE%12%1A%BD&port=6969&peer_id=--test%87%E46%2AU%AB%0C%E2%B53%C2Ky%84&event=started&uploaded=0&downloaded=0&left=0");
    ticket.assertTrue("2:", "_%C6%B8%A2dc3%F5c%9DN%95%2B%9B%B8%AD%EE%12%1A%BD"==map["info_hash"]);
    ticket.fin();
  }

   //"/announce?info_hash=_%C6%B8%A2dc3%F5c%9DN%95%2B%9B%B8%AD%EE%12%1A%BD&port=6969&peer_id=--test%87%E46%2AU%AB%0C%E2%B53%C2Ky%84&event=started&uploaded=0&downloaded=0&left=0"



//  TrackerServer#onListen/announce?info_hash=_%C6%B8%A2dc3%F5c%9DN%95%2B%9B%B8%AD%EE%12%1A%BD&port=6969&peer_id=--test%87%E46%2AU%AB%0C%E2%B53%C2Ky%84&event=started&uploaded=0&downloaded=0&left=0

}
*/
