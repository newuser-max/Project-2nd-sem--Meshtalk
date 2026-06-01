#ifndef BACKEND_H
#define BACKEND_H

#include <QObject>
#include <QStringList>
#include "peermanager.h"


class Backend : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QStringList messages READ messages NOTIFY messagesChanged)
    Q_PROPERTY(QStringList peers    READ peers    NOTIFY peersChanged)
    Q_PROPERTY(QString myNickname   READ myNickname NOTIFY myNicknameChanged)

public:
    explicit Backend(QObject *parent = nullptr);

    QStringList messages() const;
    QStringList peers()    const;
    QString     myNickname() const;

    Q_INVOKABLE void setNickname(const QString &name);
    Q_INVOKABLE void sendMessage(const QString &recipient, const QString &text);
    Q_INVOKABLE void checkInbox();
    Q_INVOKABLE void addSimulatedPeer(const QString &peerId, const QString &nick);
    Q_INVOKABLE void connectPeers(const QString &idA, const QString &idB);

signals:
    void messagesChanged();
    void peersChanged();
    void myNicknameChanged();

private slots:
    void onPacketReceived(const Packet &packet);

private:
    PeerManager  m_manager;
    QStringList  m_messages;
    QStringList  m_peers;
    QString      m_myId;
    QString      m_myNickname;

    void addMessage(const QString &line);
    void announcePresence();
    void discoverPeer(const QString &nickname);
};

#endif
