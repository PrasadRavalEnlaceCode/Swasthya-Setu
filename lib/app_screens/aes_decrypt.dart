import 'package:flutter/material.dart';
/*import 'package:encrypt/encrypt.dart';
import 'package:encrypt/encrypt.dart' as encrypt;*/

class AESDecrypt extends StatelessWidget {
  /*String decodeBase64(String text) {
    var bytes = base64.decode(text);
    return String.fromCharCodes(bytes);
  }

  decodeTheStringByAESDecrypt(String encoded) {
    String decodedBase64 = decodeBase64(encoded);
    var bytes = utf8.encode("EASYNOW");
    var digest = sha256.convert(bytes);
    String hashedKey = digest.toString();
    String hashedIV = digest.toString().substring(0, 16);
    debugPrint("hashedKey - " + hashedKey);
    debugPrint("hashedIV - " + hashedIV);
    var key = encrypt.Key.fromUtf8(hashedKey);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: "PKCS7"));
    String decryptedFinal = encrypter.decrypt(Encrypted.fromBase64(encoded),
        iv: IV.fromUtf8(hashedIV));
    debugPrint("Decrypted final - " + decryptedFinal);
  }*/

  @override
  Widget build(BuildContext context) {
    //decodeTheStringByAESDecrypt("SEx0L2pKUE1VUDlJS0w3aUkvbVZuZz09");
    return Container();
  }
}
