library hash_lib;

import 'package:sha3/sha3.dart';
import 'dart:convert';

class Hash {
  static String calc(String input) {
    var sha = SHA3(256, SHA3_PADDING, 256);
    sha.update(utf8.encode(input));
    var hash = sha.digest();
    return base64Encode(hash);
  }
}
