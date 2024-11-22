import 'package:encrypt/encrypt.dart' as encrypt;

///How to use
///
///
///String encrypted = encryptString(inputString, kSecretKey);
String encryptString(String inputString, String key) {
  // Create an AES key and initialization vector
  final keyBytes = encrypt.Key.fromUtf8(key); // 32 bytes key for AES-256
  final iv = encrypt.IV.fromLength(16); // 16 bytes for AES

  // Create the Encrypter
  final encrypter = encrypt.Encrypter(encrypt.AES(keyBytes));

  // Encrypt the string
  final encrypted = encrypter.encrypt(inputString, iv: iv);
  return encrypted.base64; // Return the encrypted string as base64
}

String decryptString(String encryptedString, String key) {
  // Create the key and IV (Initialization Vector)
  final keyBytes = encrypt.Key.fromUtf8(key); // 32 bytes key for AES-256
  final iv = encrypt.IV.fromLength(16); // 16 bytes for AES

  // Create the Encrypter
  final encrypter = encrypt.Encrypter(encrypt.AES(keyBytes));

  // Decrypt the string
  final decrypted = encrypter.decrypt64(encryptedString, iv: iv);
  return decrypted; // Return the decrypted string
}

const String kSecretKey = "transactRecordByAvishekVerma2024";
