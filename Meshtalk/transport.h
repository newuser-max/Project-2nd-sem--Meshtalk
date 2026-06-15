#ifndef TRANSPORT_H
#define TRANSPORT_H

#include <QObject>
#include <QUdpSocket>
#include <QJsonObject>
#include "packet.h"

class UdpTransport : public QObject
{
    Q_OBJECT                                //necessary to make slots and signals functionable

public:
    explicit UdpTransport(QObject *parent = nullptr);

    void startListening(quint16 port);      //to listen to packets in the network
    void sendPacket(const Packet &packet);  //to send its own packets in the network

signals:
    void packetReceived(const Packet &packet);

private slots:
    void onDataReceived();

private:
    QUdpSocket m_socket;                      //necessary for receving and sending datagrams

    QByteArray serializePacket(const Packet &packet, const QByteArray &cipherText);
    Packet deserializePacket(const QJsonObject &json);
};

#endif
