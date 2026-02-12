import 'dart:convert';

import 'package:crypto/crypto.dart';

class EncryptionService {
  Future<String> makeNewHash(String input) async {
    var bytes = utf8.encode(input);

    var diggest = md5.convert(bytes);

    return "$diggest";
  }
}
