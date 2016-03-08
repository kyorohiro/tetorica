part of hetimanet;

class IPAddr {
  List<int> rawvalue;
  IPAddr.fromString(String ip) {
    rawvalue = IPConv.toRawIP(ip);
  }
  IPAddr.fromBytes(this.rawvalue) {}

  String toStrng() {
    return IPConv.toIPString(rawvalue);
  }

  bool isLocalHost() {
    return IPConv.isLocalHost(rawvalue);
  }

  bool isLinkLocal() {
    return IPConv.isLinkLocal(rawvalue);
  }

  bool isPrivate() {
    return IPConv.isPrivate(rawvalue);
  }

  bool isMulticast() {
    return IPConv.isMulticast(rawvalue);
  }

  bool isBroadcast() {
    return IPConv.isBroadcast(rawvalue);
  }
}

class IPConv {
  static List<int> toRawIP(String ip, {List<int> output}) {
    List rawIP = null;
    if (ip.contains(".")) {
      // ip v4
      if (output == null || output.length >= 4) {
        rawIP = new List(4);
      } else {
        rawIP = output;
      }
      List<String> v = ip.split(".");
      if (v.length < 4) {
        throw new Exception();
      }
      rawIP[0] = int.parse(v[0]);
      rawIP[1] = int.parse(v[1]);
      rawIP[2] = int.parse(v[2]);
      rawIP[3] = int.parse(v[3]);
    } else if (ip.contains(":")) {
      // ip v6
      if (output == null || output.length >= 16) {
        rawIP = new List(16);
      } else {
        rawIP = output;
      }
      int i = 0;
      List<String> vv = ip.split(":");
      for (String v in vv) {
        if (v.length == 0) {
          int r = 8 - vv.length + 1;
          for (int o = 0; o < r; o++) {
            rawIP[i++] = 0;
            rawIP[i++] = 0;
          }
        } else {
          int s = int.parse(v, radix: 16);
          rawIP[i++] = (0xff & (s >> 8));
          rawIP[i++] = (0xff & s);
        }
      }
    } else {
      throw new Exception();
    }
    return rawIP;
  }

  static String toIPString(List<int> rawIP) {
    if (rawIP.length == 4) {
      return "${rawIP[0].toUnsigned(8)}" + "." + "${rawIP[1].toUnsigned(8)}" + "." + "${rawIP[2].toUnsigned(8)}" + "." + "${rawIP[3].toUnsigned(8)}";
    } else if (rawIP.length == 16) {
      return "${_toIP6Part(rawIP[0],rawIP[1])}" + ":" + "${_toIP6Part(rawIP[2],rawIP[3])}" + ":" + "${_toIP6Part(rawIP[4],rawIP[5])}" + ":" + "${_toIP6Part(rawIP[6],rawIP[7])}" + ":" + "${_toIP6Part(rawIP[8],rawIP[9])}" + ":" + "${_toIP6Part(rawIP[10],rawIP[11])}" + ":" + "${_toIP6Part(rawIP[12],rawIP[13])}" + ":" + "${_toIP6Part(rawIP[14],rawIP[15])}";
    } else {
      throw new Exception();
    }
  }

  static String toIPv4String(List<int> rawIP, {int start: 0}) {
    return "${rawIP[start+0].toUnsigned(8)}" + "." + "${rawIP[start+1].toUnsigned(8)}" + "." + "${rawIP[start+2].toUnsigned(8)}" + "." + "${rawIP[start+3].toUnsigned(8)}";
  }

  static String toIPv6String(List<int> rawIP, {int start: 0}) {
    return "${_toIP6Part(rawIP[start+0],rawIP[start+1])}" + ":" + "${_toIP6Part(rawIP[start+2],rawIP[start+3])}" + ":" + "${_toIP6Part(rawIP[start+4],rawIP[start+5])}" + ":" + "${_toIP6Part(rawIP[start+6],rawIP[start+7])}" + ":" + "${_toIP6Part(rawIP[start+8],rawIP[start+9])}" + ":" + "${_toIP6Part(rawIP[start+10],rawIP[start+11])}" + ":" + "${_toIP6Part(rawIP[start+12],rawIP[start+13])}" + ":" + "${_toIP6Part(rawIP[start+14],rawIP[start+15])}";
  }

  static String _toIP6Part(int a, int b) {
    String aa = a.toUnsigned(8).toRadixString(16);
    if (aa == "0") {
      aa = "";
    }
    String bb = b.toUnsigned(8).toRadixString(16);
    if (bb.length == 1 && aa.length != 0) {
      bb = "0" + bb;
    }
    return "${aa}${bb}";
  }

  static bool isIpV4(List<int> ip) {
    if (ip.length == 4) {
      return true;
    } else {
      return false;
    }
  }

  static bool isLocalNetwork(List<int> ip) {
    if (ip.length == 4) {
      if (ip[0] == 127 || ip[0] == 10 || ip[0] == 192) {
        return true;
      } else {
        return false;
      }
    } else {
      if (ip[0] == 0xfe && ip[1] == 0x80) {
        return true;
      } else {
        return false;
      }
    }
  }

  static bool isLocalHost(List<int> ip) {
    if (ip.length == 4) {
      return (ip[0] == 127);
    } else {
      //::1
      if(0xff&ip[15]==1) {
        for(int i=0;i<15;i++) {
          if(0xff&ip[i] != 0) {
            return false;
          }
        }
        return true;
      } else {
        return false;
      }
    }
  }

  static bool isLinkLocal(List<int> ip) {
    if (ip.length == 4) {
      return (0xff & ip[0] == 0xff & 169) && (0xff & ip[1] == 0xff & 254);
    } else {
      return (0xff & ip[0] == 0xfe) && (0xC0 & ip[1] == 0x80);
    }
  }

  static bool isPrivate(List<int> ip) {
    if (ip.length == 4) {
      return (0xff & ip[0] == 10) || ((0xff & ip[0] == 172) && (0xf0 & ip[1] == 16)) || ((0xff & ip[0] == 192) && (0xf0 & ip[1] == 168));
    } else {
      //fec0::/10
      return (0xff & ip[0] == 0xfe) && (0xC0 & ip[1] == 0xc0);
    }
  }

  static bool isMulticast(List<int> ip) {
    if (ip.length == 4) {
      return (0xf0 & ip[0] == 224);
    } else {
      return (0xff & ip[0] == 0xff);
    }
  }

  static bool isBroadcast(List<int> ip) {
    if (ip.length == 4) {
      return (0xff & ip[0] == 255) && (0xff & ip[1] == 255) && (0xff & ip[2] == 255) && (0xff & ip[3] == 255);
    } else {
      //ff02::1
      if(0xff&ip[0] == 0xff && 0xff&ip[1] == 0x02 && 0xff&ip[15]==1) {
        for(int i=2;i<15;i++) {
          if(0xff&ip[i] != 0) {
            return false;
          }
        }
        return true;
      } else {
        return false;
      }
    }
  }
}
