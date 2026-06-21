#include "backend.h"
#include <QDebug>

Backend::Backend(QObject *parent) : QObject(parent)
{

    connect(&m_transport, &UdpTransport::packetReceived,
            this, &Backend::onPacketReceived);

    m_transport.startListening(45454);
}

void Backend::broadcastPresence()
{
    Packet p;
    p.type     = "presence";
    p.sender   = m_myNickname;
    p.receiver = "all";
    p.message  = m_myNickname;
    p.hopCount = 7;

    m_transport.sendPacket(p);

    qDebug() << "[BACKEND] Broadcasted presence:" << m_myNickname;
}

bool Backend::addPeerIfNew(const QString &nickname)
{
    if (m_peers.contains(nickname))
        return false;

    m_peers.append(nickname);
    emit peersChanged();
    qDebug() << "[BACKEND] Discovered peer:" << nickname;
    return true;
}



QStringList Backend::messages() const { return m_messages; }
QStringList Backend::peers()    const { return m_peers; }
QString Backend::myNickname()   const { return m_myNickname; }



void Backend::setNickname(const QString &name)
{
    if (name.trimmed().isEmpty())
        return;

    m_myNickname = name.trimmed();
    m_myId       = "local";

    Peer me(m_myId, m_myNickname);
    m_manager.addPeer(me);

    emit myNicknameChanged();
    qDebug() << "[BACKEND] Local peer created:" << m_myId << "/" << m_myNickname;


    broadcastPresence();
}

void Backend::sendMessage(const QString &toNickname, const QString &text)
{
    if (m_myNickname.isEmpty()) {
        qDebug() << "[BACKEND] Cannot send — nickname not set yet";
        return;
    }

    Packet p;
    p.id       = 0;
    p.sender   = m_myNickname;
    p.receiver = toNickname;
    p.message  = text;
    p.hopCount = 7;

    m_transport.sendPacket(p);

    if (toNickname.toLower() == "all")
        appendMessage("You → All: " + text);
    else
        appendMessage("You → " + toNickname + ": " + text);

    qDebug() << "[BACKEND] Sending to:" << toNickname << "msg:" << text;
}

void Backend::checkInbox()
{
    Peer* me = m_manager.getPeer(m_myId);
    if (!me) return;

    for (const QString &line : me->drainInbox())
        appendMessage(line);
}

void Backend::addSimulatedPeer(const QString &peerId, const QString &nick)
{
    Peer newPeer(peerId, nick);
    m_manager.addPeer(newPeer);
    addPeerIfNew(peerId);

    qDebug() << "[BACKEND] Peer added:" << peerId << "/" << nick;
}

void Backend::connectPeers(const QString &idA, const QString &idB)
{
    Peer* a = m_manager.getPeer(idA);
    Peer* b = m_manager.getPeer(idB);

    if (!a || !b) {
        qDebug() << "[BACKEND] connectPeers failed";
        return;
    }

    a->addNeighbour(b);
    b->addNeighbour(a);

    qDebug() << "[BACKEND] Connected:" << idA << "<-->" << idB;
}

void Backend::onPacketReceived(const Packet &packet)
{
    qDebug() << "[BACKEND] UDP packet arrived from"
             << packet.sender << "to" << packet.receiver
             << "| type:" << packet.type;


    if (packet.sender == m_myNickname)
        return;

    bool isNewPeer = addPeerIfNew(packet.sender);

    if (packet.type == "presence") {

        if (isNewPeer)
            broadcastPresence();
        return;
    }

    if (packet.receiver == m_myNickname)
        appendMessage(packet.sender + " → You: " + packet.message);
    else if (packet.receiver.toLower() == "all")
        appendMessage(packet.sender + " → All: " + packet.message);
    else
        qDebug() << "[BACKEND] Packet not for me — ignoring";
}



void Backend::appendMessage(const QString &line)
{
    m_messages.append(line);
    emit messagesChanged();
}