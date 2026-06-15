#include "compression.h"
#include <QDebug>

// Payloads smaller than this go out raw — compression would only make them bigger
static const int THRESHOLD = 64;

QByteArray MessageCompressor::compress(const QByteArray &data)
{

    if (data.size() < THRESHOLD) {                  //checks whether the message size is worth compressing or not
        return QByteArray(1, 0x00) + data;
    }

    QByteArray compressed = qCompress(data, 6);     //qts native compression function usages LZ4 compression method


    if (compressed.size() >= data.size()) {         //checks if the compression helped or not if not then the raw message is sent
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

    bool isCompressed = (data.at(0) == 0x01);      //checks if the compression was done or not
    QByteArray payload = data.mid(1);              //leaves the flag and reads the message

    if (!isCompressed)
        return payload;                             //returns original message

    QByteArray result = qUncompress(payload);       //qts native decompression function
    if (result.isEmpty()) {
        qDebug() << "[COMPRESSOR] Decompression failed";
        if (ok) *ok = false;
        return {};
    }

    return result;
}