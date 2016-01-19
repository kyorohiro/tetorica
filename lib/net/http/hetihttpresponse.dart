library hetimanet.http.response;

import 'dart:convert' as convert;
import 'dart:async' as async;
import 'package:tetorica/core.dart';
import '../util/hetiutil.dart';

//rfc2616 rfc7230
class HetiHttpResponse {
  static List<int> PATH = convert.UTF8.encode(RfcTable.RFC3986_PCHAR_AS_STRING + "/");
  static List<int> QUERY = convert.UTF8.encode(RfcTable.RFC3986_RESERVED_AS_STRING + RfcTable.RFC3986_UNRESERVED_AS_STRING);


  static async.Future<HetiHttpMessageWithoutBody> decodeHttpMessage(EasyParser parser) {
    async.Completer<HetiHttpMessageWithoutBody> completer = new async.Completer();
    HetiHttpMessageWithoutBody result = new HetiHttpMessageWithoutBody();
    decodeStatusline(parser).then((HetiHttpResponseStatusLine line) {
      result.line = line;
      return decodeHeaderFields(parser);
    }).then((List<HetiHttpResponseHeaderField> httpfields) {
      result.headerField = httpfields;
      result.index = parser.index;
      completer.complete(result);
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }

  static async.Future<List<HetiHttpResponseHeaderField>> decodeHeaderFields(EasyParser parser) {
    async.Completer<List<HetiHttpResponseHeaderField>> completer = new async.Completer();
    List<HetiHttpResponseHeaderField> result = new List();
    async.Future p() {
      return decodeHeaderField(parser).then((HetiHttpResponseHeaderField v) {
        result.add(v);
        return p();
      });
    }

    p().catchError((e) {
      return decodeCrlf(parser);
    }).then((e) {
      completer.complete(result);
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }


  static async.Future<HetiHttpResponseHeaderField> decodeHeaderField(EasyParser parser) {
    HetiHttpResponseHeaderField result = new HetiHttpResponseHeaderField();
    async.Completer<HetiHttpResponseHeaderField> completer = new async.Completer();
    decodeFieldName(parser).then((String v) {
      result.fieldName = v;
      return parser.nextString(":");
    }).then((String v) {
      return decodeOWS(parser);
    }).then((String v) {
      return decodeFieldValue(parser);
    }).then((String v) {
      result.fieldValue = v;
      return decodeCrlf(parser);
    }).then((String v) {
      completer.complete(result);
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }

  static async.Future<String> decodeFieldName(EasyParser parser) {
    async.Completer<String> completer = new async.Completer();
    parser.nextBytePatternByUnmatch(new EasyParserIncludeMatcher(RfcTable.TCHAR)).then((List<int> v) {
      completer.complete(convert.UTF8.decode(v));
    });
    return completer.future;
  }

  static async.Future<String> decodeFieldValue(EasyParser parser) {
    async.Completer<String> completer = new async.Completer();
    parser.nextBytePatternByUnmatch(new FieldValueMatcher()).then((List<int> v) {
      completer.complete(convert.UTF8.decode(v));
    });
    return completer.future;
  }

  //
  // Http-version
  static async.Future<String> decodeHttpVersion(EasyParser parser) {
    async.Completer completer = new async.Completer();
    int major = 0;
    int minor = 0;
    try {
      parser.nextString("HTTP" + "/").then((String v) {
      }).then((e) {
        return parser.nextBytePattern(new EasyParserIncludeMatcher(RfcTable.DIGIT));
      }).then((int v) {
        major = v - 48;
        return parser.nextString(".");
      }).then((e) {
        return parser.nextBytePattern(new EasyParserIncludeMatcher(RfcTable.DIGIT));
      }).then((int v) {
        minor = v - 48;
        return completer.complete("HTTP/" + major.toString() + "." + minor.toString());
      });
    } catch (e) {
      throw new EasyParseError();
    }
    return completer.future;
  }


  //
  // Status Code
  // DIGIT DIGIT DIGIT
  static async.Future<String> decodeStatusCode(EasyParser parser) {
    async.Completer<String> completer = new async.Completer();
    int ret = 0;
    try {
      parser.nextBytePatternWithLength(new EasyParserIncludeMatcher(RfcTable.DIGIT), 3).then((List<int> v) {
        ret = 100 * (v[0] - 48) + 10 * (v[1] - 48) + (v[2] - 48);
        completer.complete(ret.toString());
      });
    } catch (e) {
      throw new EasyParseError();
    }
    return completer.future;
  }


  static async.Future<String> decodeReasonPhrase(EasyParser parser) {
    async.Completer<String> completer = new async.Completer();
    parser.nextBytePatternByUnmatch(new TextMatcher()).then((List<int> vv) {
      String v = convert.UTF8.decode(vv);
      completer.complete(v);
    });
    return completer.future;
  }

  //Status-Line = HTTP-Version SP Status-Code SP Reason-Phrase CRLF
  static async.Future<HetiHttpResponseStatusLine> decodeStatusline(EasyParser parser) {
    HetiHttpResponseStatusLine result = new HetiHttpResponseStatusLine();
    async.Completer<HetiHttpResponseStatusLine> completer = new async.Completer();
    decodeHttpVersion(parser).then((String v) {
      result.version = v;
      return decodeSP(parser);
    }).then((String v) {
      return decodeStatusCode(parser);
    }).then((String v) {
      result.statusCode = int.parse(v);
      return decodeSP(parser);
    }).then((onValue) {
      return decodeReasonPhrase(parser);
    }).then((String v) {
      result.statusPhrase = v;
      return decodeCrlf(parser);
    }).then((String v) {
      completer.complete(result);
    });
    return completer.future;
  }

  static async.Future<String> decodeOWS(EasyParser parser) {
    async.Completer completer = new async.Completer();
    parser.nextBytePatternByUnmatch(new EasyParserIncludeMatcher(RfcTable.OWS)).then((List<int> v) {
      completer.complete(convert.UTF8.decode(v));
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }

  static async.Future<String> decodeSP(EasyParser parser) {
    async.Completer completer = new async.Completer();
    parser.nextBytePatternByUnmatch(new EasyParserIncludeMatcher(RfcTable.SP)).then((List<int> v) {
      completer.complete(convert.UTF8.decode(v));
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }

  //
  static async.Future<String> decodeCrlf(EasyParser parser) {
    async.Completer completer = new async.Completer();
    //bool lf = true;
    bool crlf = true;
    parser.push();
    parser.nextString("\r\n").catchError((e) {
      parser.back();
      parser.pop();
      parser.push();
      crlf = false;
      return parser.nextString("\n");
    }).then((e) {
      if (crlf == true) {
        completer.complete("\r\n");
      } else {
        completer.complete("\n");
      }
    }).catchError((e) {
      completer.completeError(e);
    }).whenComplete(() {
      parser.pop();
    });
    return completer.future;
  }

  //
  static async.Future<int> decodeChunkedSize(EasyParser parser) {
    async.Completer<int> completer = new async.Completer();
    int v = 0;
    parser.nextBytePatternByUnmatch(new EasyParserIncludeMatcher(RfcTable.HEXDIG)).then((List<int> n) {
      if (n.length == 0) {
        throw new EasyParseError();
      } else {
        String nn = convert.UTF8.decode(n);
        //  print("nn=" + nn);
        v = int.parse(nn, radix: 16);
        return HetiHttpResponse.decodeCrlf(parser);
      }
    }).then((d) {
      completer.complete(v);
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }

  //  request-line   = method SP request-target SP HTTP-version CRLF
  static async.Future<HetiRequestLine> decodeRequestLine(EasyParser parser) {
    async.Completer<HetiRequestLine> completer = new async.Completer();
    HetiRequestLine result = new HetiRequestLine();
    decodeMethod(parser).then((String method) {
      result.method = method;
      return decodeSP(parser);
    }).then((t) {
      return decodeRequestTarget(parser);
    }).then((String requestTarget) {
      result.requestTarget = requestTarget;
      return decodeSP(parser);
    }).then((t) {
      return decodeHttpVersion(parser);
    }).then((String httpVersion) {
      result.httpVersion = httpVersion;
      return decodeCrlf(parser);
    }).then((String crlf) {
      completer.complete(result);
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }

  static async.Future<HetiHttpRequestMessageWithoutBody> decodeRequestMessage(EasyParser parser) {
    async.Completer<HetiHttpRequestMessageWithoutBody> completer = new async.Completer();
    HetiHttpRequestMessageWithoutBody result = new HetiHttpRequestMessageWithoutBody();
    decodeRequestLine(parser).then((HetiRequestLine line) {
      result.line = line;
      return decodeHeaderFields(parser);
    }).then((List<HetiHttpResponseHeaderField> httpfields) {
      result.headerField = httpfields;
      result.index = parser.index;
      completer.complete(result);
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }
  // metod = token = 1*tchar
  static async.Future<String> decodeMethod(EasyParser parser) {
    async.Completer<String> completer = new async.Completer();
    parser.nextBytePatternByUnmatch(new EasyParserIncludeMatcher(RfcTable.TCHAR)).then((List<int> v) {
      completer.complete(convert.UTF8.decode(v));
    });
    return completer.future;
  }

  // CHAR_STRING
  static async.Future<String> decodeRequestTarget(EasyParser parser) {
    async.Completer<String> completer = new async.Completer();
    parser.nextBytePatternByUnmatch(new EasyParserIncludeMatcher(RfcTable.VCHAR)).then((List<int> v) {
      completer.complete(convert.UTF8.decode(v));
    });
    return completer.future;
  }

  // request-target = origin-form / absolute-form / authority-form / asterisk-form
  // absolute-URI  = scheme ":" hier-part [ "?" query ]

  //rfc2616
  static async.Future<HetiHttpRequestRange> decodeRequestRangeValue(EasyParser parser) {
    //HetiHttpResponseStatusLine result = new HetiHttpResponseStatusLine();
    HetiHttpRequestRange ret = new HetiHttpRequestRange();
    async.Completer<HetiHttpRequestRange> completer = new async.Completer();
    parser.nextString("bytes=").then((String v) {
      return parser.nextBytePatternByUnmatch(new EasyParserIncludeMatcher(RfcTable.DIGIT));
    }).then((List<int> startAsList) {
      ret.start = 0;
      for (int d in startAsList) {
        ret.start = (d - 48) + ret.start * 10;
      }
      return parser.nextString("-");
    }).then((String v) {
      return parser.nextBytePatternByUnmatch(new EasyParserIncludeMatcher(RfcTable.DIGIT));
    }).then((List<int> endAsList) {
      if (endAsList.length == 0) {
        ret.end = -1;
      } else {
        ret.end = 0;
        for (int d in endAsList) {
          ret.end = (d - 48) + ret.end * 10;
        }
      }
      completer.complete(ret);
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }
}

// Range: bytes=0-499
class HetiHttpRequestRange {
  int start = 0;
  int end = 0;
}
// reason-phrase  = *( HTAB / SP / VCHAR / obs-text )
class TextMatcher extends EasyParserMatcher {
  @override
  bool match(int target) {
    //  VCHAR = 0x21-0x7E
    //  obs-text = %x80-FF
    //  SP = 0x30
    //  HTAB = 0x09
    if (0x21 <= target && target <= 0x7E) {
      return true;
    }
    if (0x80 <= target && target <= 0xFF) {
      return true;
    }
    if (target == 0x20 || target == 0x09) {
      return true;
    }
    return false;
  }
}

class FieldValueMatcher extends EasyParserMatcher {
  @override
  bool match(int target) {
    if (target == 0x0D || target == 0x0A) {
      return false;
    } else {
      return true;
    }
  }
}

// reason-phrase  = *( HTAB / SP / VCHAR / obs-text )
class HetiHttpResponseStatusLine {
  String version = "";
  int statusCode = -1;
  String statusPhrase = "";
}

class HetiHttpResponseHeaderField {
  String fieldName = "";
  String fieldValue = "";
}

class HetiRequestLine {
  String method = "";
  String requestTarget = "";
  String httpVersion = "";
}

class HetiHttpRequestMessageWithoutBody {
  int index = 0;
  HetiRequestLine line = new HetiRequestLine();
  List<HetiHttpResponseHeaderField> headerField = new List();

  HetiHttpResponseHeaderField find(String fieldName) {
    for (HetiHttpResponseHeaderField field in headerField) {
      //  print(""+field.fieldName.toLowerCase() +"== "+fieldName.toLowerCase());
      if (field != null && field.fieldName.toLowerCase() == fieldName.toLowerCase()) {
        return field;
      }
    }
    return null;
  }
}

// HTTP-message   = start-line
// *( header-field CRLF )
// CRLF
// [ message-body ]
class HetiHttpMessageWithoutBody {
  int index = 0;
  HetiHttpResponseStatusLine line = new HetiHttpResponseStatusLine();
  List<HetiHttpResponseHeaderField> headerField = new List();

  HetiHttpResponseHeaderField find(String fieldName) {
    for (HetiHttpResponseHeaderField field in headerField) {
      //  print(""+field.fieldName.toLowerCase() +"== "+fieldName.toLowerCase());
      if (field != null && field.fieldName.toLowerCase() == fieldName.toLowerCase()) {
        return field;
      }
    }
    return null;
  }
  int get contentLength {
    HetiHttpResponseHeaderField field = find(RfcTable.HEADER_FIELD_CONTENT_LENGTH);
    if (field == null) {
      return -1;
    }
    try {
      return int.parse(field.fieldValue.replaceAll(" |\r|\n|\t", ""));
    } catch (e) {
      return -1;
    }

  }
}
