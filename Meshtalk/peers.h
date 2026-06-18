#ifndef PEERS_H
#define PEERS_H

#include <QString>
#include <QList>
#include <QSet>
#include <QStringList>
#include "packetqueue.h"

// One node in the mesh network. Each peer can be linked to other peers
// as "neighbours", and messages are flooded across those links until
// they reach the intended receiver or run out of hops.
class Peer {
private:
    QString id;
    QString nickname;
    PacketQueue inbox;
    QList<Peer*> neighbours;
    QSet<int> seenPackets;
    static int nextPacketId;

public:
    Peer(const QString &peerId, const QString &nickname = "");

    QString getId() const;
    QString getNickname() const;

    void addNeighbour(Peer* peer);
    void sendPacket(Peer &receiver, const QString &message);
    void forward(Packet p);
    void receive();
    QStringList drainInbox();
};

#endif 