#ifndef PACKET_H
#define PACKET_H

#include <QString>
#include <QDateTime>
#include <QByteArray>

class Packet
{
public:
    //constructor
    Packet();

    // //packet basic structure have: -
    // 1) id
    // 2) who is sending the mssage
    // 3) who will be recieving it
    // 4) what is the content of the message
    // 4) what is the type of packet
    // 5) how many hops did it pass or maintain the hopping of 7 devices
    // 6) timestamps hold the time when the packet was created
    // 7) is the msg encrypted or not

    int id;
    QString sender;
    QString receiver;
    QString message;
    QString type;
    int hopCount;
    QDateTime timestamp;
    QByteArray iv;
    QByteArray tag;
    bool encrypted;
};

#endif // PACKET_H