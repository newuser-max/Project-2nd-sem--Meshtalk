#include "transport.h"
#include "crypto.h"

#include <QJsonDocument>
#include <QJsonObject>
#include <QHostAddress>
#include <QNetworkDatagram>
#include <QDebug>

// Every device in the mesh uses this same UDP port
const quint16 UDP_PORT = 65432;

UdpTransport::UdpTransport(QObject *parent)
    : QObject(parent)
{
    // When the socket gets data, run onDataReceived
    connect(&m_socket, &QUdpSocket::readyRead,this, &UdpTransport::onDataReceived);

    // Listen on all network interfaces
    bool bindOk = m_socket.bind(QHostAddress::AnyIPv4, UDP_PORT,QUdpSocket::ShareAddress | QUdpSocket::ReuseAddressHint);

    if (bindOk) {
        qDebug() << "[UDP] Socket bound on port" << UDP_PORT;
    } else {
        qDebug() << "[UDP] Bind failed:" << m_socket.errorString();
    }
}

void UdpTransport::startListening(quint16 port)
{
    Q_UNUSED(port)
    // Binding already happens in the constructor
}

void UdpTransport::sendPacket(const Packet &packet)
{
    // encrypt the message
    QByteArray iv;
    QByteArray tag;
    QByteArray cipherText = Crypto::encrypt(packet.message, iv, tag);

    if (cipherText.isEmpty()) {
        qDebug() << "[UDP] Encryption failed";
        return;
    }

    // fill in encryption fields on a copy of the packet
    Packet toSend = packet;
    toSend.iv = iv;
    toSend.tag = tag;
    toSend.encrypted = true;

    //  convert to JSON bytes ready to send
    QByteArray data = serializePacket(toSend, cipherText);

    // send to this machine and to the local network
    qint64 sentToLocal = m_socket.writeDatagram(data, QHostAddress::LocalHost, UDP_PORT);
    qint64 sentToBroadcast = m_socket.writeDatagram(data, QHostAddress::Broadcast, UDP_PORT);

    qDebug() << "[UDP] Sent packet" << packet.id << "localhost:" << sentToLocal << "broadcast:" << sentToBroadcast;
}

void UdpTransport::onDataReceived()
{
    while (m_socket.hasPendingDatagrams()) {

        QByteArray rawData = m_socket.receiveDatagram().data();

        QJsonParseError parseError;
        QJsonDocument doc = QJsonDocument::fromJson(rawData, &parseError);

        bool jsonIsValid = (parseError.error == QJsonParseError::NoError);
        bool jsonIsObject = doc.isObject();

        if (!jsonIsValid || !jsonIsObject)
        {
            qDebug() << "[UDP] Invalid packet ignored:" << parseError.errorString();
            continue;
        }

        QJsonObject obj = doc.object();

        // Encrypted parts are stored as Base64 text inside the JSON
        QByteArray cipherText = QByteArray::fromBase64(obj["cipherText"].toString().toUtf8());
        QByteArray iv         = QByteArray::fromBase64(obj["iv"].toString().toUtf8());
        QByteArray tag        = QByteArray::fromBase64(obj["tag"].toString().toUtf8());

        QString plainMessage = Crypto::decrypt(cipherText, iv, tag);
        if (plainMessage.isEmpty())
        {
            qDebug() << "[UDP] Dropped packet — decryption failed";
            continue;
        }

        // Rebuild the packet from JSON + decrypted message
        Packet packet;
        packet.id        = obj["id"].toInt();
        packet.sender    = obj["sender"].toString();
        packet.receiver  = obj["receiver"].toString();
        packet.message   = plainMessage;
        packet.hopCount  = obj["hopCount"].toInt();
        packet.type      = obj["type"].toString("message");
        packet.timestamp = QDateTime::fromString(obj["timestamp"].toString(), Qt::ISODate);
        packet.encrypted = true;

        qDebug() << "[UDP] Received and decrypted packet from" << packet.sender << "to" << packet.receiver;

        emit packetReceived(packet);
    }
}

QByteArray UdpTransport::serializePacket(const Packet &packet, const QByteArray &cipherText)
{
    QJsonObject obj;

    obj["id"]        = packet.id;
    obj["sender"]    = packet.sender;
    obj["receiver"]  = packet.receiver;
    obj["hopCount"]  = packet.hopCount;
    obj["type"]      = packet.type;
    obj["timestamp"] = packet.timestamp.toString(Qt::ISODate);

    // Binary data must be Base64 so it can live inside JSON text
    obj["cipherText"] = QString::fromUtf8(cipherText.toBase64());
    obj["iv"]         = QString::fromUtf8(packet.iv.toBase64());
    obj["tag"]        = QString::fromUtf8(packet.tag.toBase64());

    QJsonDocument doc(obj);
    return doc.toJson(QJsonDocument::Compact);
}

Packet UdpTransport::deserializePacket(const QJsonObject &json)
{
    Q_UNUSED(json)

    // Not used — parsing happens in onDataReceived.
    // Kept so the class interface stays unchanged.
    return Packet();
}
