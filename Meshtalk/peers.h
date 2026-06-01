#ifndef PEERS_H
#define PEERS_H

#include <QString>
#include <QList>
#include <QSet>
#include <QStringList>
#include "packetqueue.h"

class Peer {
public:
    Peer(const QString &peerId, const QString &nick = "");

    QString id;
    QString nickname;

    void addNeighbour(Peer *peer);
    void sendPacket(Peer &recipient, const QString &message);
    void forward(Packet p);
    void receive();

    QStringList drainInbox();

private:
    PacketQueue  m_inbox;
    QList<Peer*> m_neighbours;
    QSet<int>    m_seenPackets;

    static int s_nextPacketId;
};

#endif
