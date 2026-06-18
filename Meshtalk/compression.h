#ifndef COMPRESSION_H
#define COMPRESSION_H

#include <QByteArray>

// Compresses/decompresses is done using Qt's built-in zlib wrapper.
// Small payloads are skipped automatically.
class MessageCompressor
{
public:
    static QByteArray compress(const QByteArray &data);
    static QByteArray decompress(const QByteArray &data, bool *ok = nullptr);
};

#endif
