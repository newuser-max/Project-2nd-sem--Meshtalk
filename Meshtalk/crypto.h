#ifndef CRYPTO_H
#define CRYPTO_H

#include <QByteArray>
#include <QString>

class Crypto
{
public:
    // The shared key — everyone in the mesh uses this same key
    // In a real app this would be exchanged via QR code or verbally
    // 32 bytes = 256 bits = AES-256
    static const QByteArray SHARED_KEY;

    // Encrypts raw plain data (may be arbitrary binary, e.g. compressed bytes)
    // Returns encrypted bytes, and fills iv and tag
    static QByteArray encrypt(const QByteArray &plainData,
                              QByteArray &iv,
                              QByteArray &tag);

    // Decrypts encrypted bytes using iv and tag
    // Returns raw plain data, or an empty array if decryption fails
    static QByteArray decrypt(const QByteArray &cipherText,
                              const QByteArray &iv,
                              const QByteArray &tag);
};

#endif // CRYPTO_H