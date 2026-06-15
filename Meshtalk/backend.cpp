#include "backend.h"
#include <QDebug>




QStringList Backend::messages()   const { return m_messages; }
QStringList Backend::peers()      const { return m_peers; }
QString     Backend::myNickname() const { return m_myNickname; }

void Backend::setNickname(const QString &name)
{
    if (name.trimmed().isEmpty())
        return;

    m_myNickname = name.trimmed();
    m_myId       = "local";

    m_manager.addPeer(Peer(m_myId, m_myNickname));

    emit myNicknameChanged();
    qDebug() << "[Backend] I am:" << m_myNickname;

    announcePresence();
}

void Backend::sendMessage(const QString &recipient, const QString &text)
{
    if (m_myNickname.isEmpty()) {
        qDebug() << "[Backend] Set a nickname before sending messages";
        return;
    }

    Packet p;
    p.sender   = m_myNickname;
    p.receiver = recipient;
    p.message  = text;
    p.hopCount = 7;

    bool isBroadcast = (recipient.toLower() == "all");
    addMessage(isBroadcast ? "You → All: " + text
                           : "You → " + recipient + ": " + text);
}

void Backend::checkInbox()
{
    Peer *me = m_manager.getPeer(m_myId);
    if (!me) return;

    for (const QString &line : me->drainInbox())
        addMessage(line);
}

void Backend::addSimulatedPeer(const QString &peerId, const QString &nick)
{
    m_manager.addPeer(Peer(peerId, nick));
    discoverPeer(peerId);
    qDebug() << "[Backend] Simulated peer added:" << nick;
}

void Backend::connectPeers(const QString &idA, const QString &idB)
{
    Peer *a = m_manager.getPeer(idA);
    Peer *b = m_manager.getPeer(idB);

    if (!a || !b) {
        qDebug() << "[Backend] Peer not found — can't connect" << idA << idB;
        return;
    }

    a->addNeighbour(b);
    b->addNeighbour(a);
    qDebug() << "[Backend] Connected:" << idA << "<->" << idB;
}

// ── Incoming packet handler ───────────────────────────────────────────────────

void Backend::onPacketReceived(const Packet &packet)
{
    // Ignore our own packets
    if (packet.sender == m_myNickname)
        return;

    qDebug() << "[Backend] Received" << packet.type
             << "from" << packet.sender << "to" << packet.receiver;

    if (packet.type == "presence") {
        discoverPeer(packet.sender);
        announcePresence(); // let them know we're here too
        return;
    }

    // Auto-discover whoever messaged us
    discoverPeer(packet.sender);

    bool toMe        = (packet.receiver == m_myNickname);
    bool toBroadcast = (packet.receiver.toLower() == "all");

    if (toMe)
        addMessage(packet.sender + " → You: " + packet.message);
    else if (toBroadcast)
        addMessage(packet.sender + " → All: " + packet.message);
    else
        qDebug() << "[Backend] Packet not addressed to me — ignoring";
}

// ── Private helpers ───────────────────────────────────────────────────────────

void Backend::addMessage(const QString &line)
{
    m_messages.append(line);
    emit messagesChanged();
}

void Backend::announcePresence()
{
    Packet p;
    p.type     = "presence";
    p.sender   = m_myNickname;
    p.receiver = "all";
    p.message  = m_myNickname;
    p.hopCount = 7;
}

void Backend::discoverPeer(const QString &nickname)
{
    if (m_peers.contains(nickname))
        return;

    m_peers.append(nickname);
    emit peersChanged();
    qDebug() << "[Backend] New peer discovered:" << nickname;
}
