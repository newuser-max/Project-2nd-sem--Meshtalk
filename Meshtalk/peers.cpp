#include "peers.h"
#include <QDebug>

int Peer::s_nextPacketId = 1;

Peer::Peer(const QString &peerId, const QString &nick)
    : id(peerId)
    , nickname(nick.isEmpty() ? peerId : nick)
{}

void Peer::addNeighbour(Peer *peer)
{
    m_neighbours.append(peer);
    qDebug() << id << "→ neighbour added:" << peer->id;
}

void Peer::sendPacket(Peer &recipient, const QString &message)
{
    if (m_neighbours.isEmpty()) {
        qDebug() << id << "has no neighbours — can't send";
        return;
    }

    Packet p;
    p.id       = s_nextPacketId++;
    p.sender   = id;
    p.receiver = recipient.id;
    p.message  = message;

    qDebug() << "[Send]" << id << "→" << recipient.id << ":" << message;

    for (Peer *neighbour : m_neighbours)
        neighbour->forward(p);
}

void Peer::forward(Packet p)
{
    if (m_seenPackets.contains(p.id)) {
        qDebug() << "[Drop]" << id << "already seen packet" << p.id;
        return;
    }
    m_seenPackets.insert(p.id);

    if (--p.hopCount <= 0) {
        qDebug() << "[Drop]" << id << "hop limit reached for packet" << p.id;
        return;
    }

    if (p.receiver == id) {
        m_inbox.addPacket(p);
        qDebug() << "[Delivered] packet" << p.id << "from" << p.sender << ":" << p.message;
        return;
    }

    qDebug() << "[Relay]" << id << "forwarding packet" << p.id;
    for (Peer *neighbour : m_neighbours)
        neighbour->forward(p);
}

void Peer::receive()
{
    Packet p;
    while (m_inbox.processPacket(p))
        qDebug() << "[Inbox]" << id << "← from" << p.sender << ":" << p.message;
}

QStringList Peer::drainInbox()
{
    QStringList messages;
    Packet p;
    while (m_inbox.processPacket(p))
        messages.append(p.sender + " → " + id + ": " + p.message);
    return messages;
}
