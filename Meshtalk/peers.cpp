#include "peers.h"
#include <QDebug>

// Shared counter so every packet gets a unique id across all peers
int Peer::nextPacketId = 1;

Peer::Peer(const QString &peerId, const QString &nick)
{
    id       = peerId;
    nickname = nick.isEmpty() ? peerId : nick; // fall back to id if no nickname given
}

QString Peer::getId() const { return id; }
QString Peer::getNickname() const { return nickname; }

void Peer::addNeighbour(Peer* peer)
{
    neighbours.append(peer);
    qDebug() << id << "added neighbour:" << peer->getId();
}

void Peer::sendPacket(Peer &receiver, const QString &message)
{
    Packet p;
    p.id       = nextPacketId++;
    p.sender   = id;
    p.receiver = receiver.getId();
    p.message  = message;
    // hopCount starts at 7 from the Packet constructor

    qDebug() << "[SEND] Packet" << p.id
             << "from" << id << "to" << receiver.getId()
             << "| msg:" << message;

    if (neighbours.isEmpty()) {
        qDebug() << id << "has no neighbours — cannot send!";
        return;
    }

    for (Peer* neighbour : neighbours)
        neighbour->forward(p);
}

void Peer::forward(Packet p)
{
    if (seenPackets.contains(p.id)) {
        qDebug() << "[DROP]" << id << "already seen packet" << p.id;
        return;
    }
    seenPackets.insert(p.id);

    if (--p.hopCount <= 0) {
        qDebug() << "[DROP]" << id << "hop limit reached for packet" << p.id;
        return;
    }

    if (p.receiver == id) {
        inbox.addPacket(p);
        qDebug() << "[DELIVERED] Packet" << p.id
                 << "arrived at" << id
                 << "| from:" << p.sender
                 << "| msg:" << p.message;
        return;
    }

    // Not for me — pass it along to everyone I'm connected to
    qDebug() << "[RELAY]" << id << "forwarding packet" << p.id;
    for (Peer* neighbour : neighbours)
        neighbour->forward(p);
}

void Peer::receive()
{
    Packet p;
    while (inbox.processPacket(p)) {
        qDebug() << "[INBOX]" << id
                 << "reading message from" << p.sender
                 << ":" << p.message;
    }
}

QStringList Peer::drainInbox()
{
    QStringList result;
    Packet p;
    while (inbox.processPacket(p))
        result.append(p.sender + " → " + id + ": " + p.message);
    return result;
}