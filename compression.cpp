#include "compression.h"
#include <QDebug>

// Payloads smaller than this go out raw — compression would only make them bigger
static const int THRESHOLD = 64;

QByteArray MessageCompressor::compress(const QByteArray &data)
{

    if (data.size() < THRESHOLD) {
        return QByteArray(1, 0x00) + data;
    }

    QByteArray compressed = qCompress(data, 6);


    if (compressed.size() >= data.size()) {
        qDebug() << "[COMPRESSOR] Skipped — compression didn't help";
        return QByteArray(1, 0x00) + data;
    }

    qDebug() << "[COMPRESSOR]" << data.size() << "→" << compressed.size() << "bytes";
    return QByteArray(1, 0x01) + compressed;
}

QByteArray MessageCompressor::decompress(const QByteArray &data, bool *ok)
{
    if (ok) *ok = true;

    if (data.isEmpty()) {
        if (ok) *ok = false;
        return {};
    }

    bool isCompressed = (data.at(0) == 0x01);
    QByteArray payload = data.mid(1);

    if (!isCompressed)
        return payload;

    QByteArray result = qUncompress(payload);
    if (result.isEmpty()) {
        qDebug() << "[COMPRESSOR] Decompression failed";
        if (ok) *ok = false;
        return {};
    }

    return result;
}