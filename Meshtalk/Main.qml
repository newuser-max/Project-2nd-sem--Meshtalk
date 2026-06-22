import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Window {
    id: root
    width: 400
    height: 700
    visible: true
    title: "MeshTalk"
    color: "#0A0F1E"

    property string selectedPeer: ""

    StackView {
        id: stack
        anchors.fill: parent
        initialItem: nicknameScreen

        pushEnter: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200 }
            NumberAnimation { property: "y"; from: 30; to: 0; duration: 200; easing.type: Easing.OutCubic }
        }
        pushExit: Transition {
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 150 }
        }
        popEnter: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200 }
        }
        popExit: Transition {
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 150 }
            NumberAnimation { property: "y"; from: 0; to: 30; duration: 200; easing.type: Easing.InCubic }
        }
    }

    // 1. Name
    Component {
        id: nicknameScreen

        Rectangle {
            color: "#0A0F1E"

            Column {
                anchors.centerIn: parent
                spacing: 0
                width: 300

                // Logo icon
                Rectangle {
                    width: 80
                    height: 80
                    radius: 20
                    color: "#111827"
                    border.color: "#00D4FF"
                    border.width: 1
                    anchors.horizontalCenter: parent.horizontalCenter

                    Item {
                        anchors.centerIn: parent
                        width: 44
                        height: 40

                        Rectangle {
                            width: 44
                            height: 32
                            radius: 10
                            color: "#00D4FF"
                            anchors.top: parent.top
                        }

                        Rectangle {
                            width: 12
                            height: 12
                            radius: 3
                            color: "#00D4FF"
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.leftMargin: 6
                        }

                        Row {
                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: -4
                            spacing: 5

                            Repeater {
                                model: 3
                                Rectangle {
                                    width: 5
                                    height: 5
                                    radius: 3
                                    color: "#0A0F1E"
                                }
                            }
                        }
                    }
                }

                Item { height: 24; width: 1 }

                Text {
                    text: "MeshTalk"
                    font.pixelSize: 32
                    font.bold: true
                    font.family: "Georgia"
                    color: "#FFFFFF"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Item { height: 6; width: 1 }

                Text {
                    text: "Chat freely.."
                    font.pixelSize: 11
                    font.family: "Georgia"
                    color: "#00D4FF"
                    font.letterSpacing: 2
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Item { height: 40; width: 1 }

                Text {
                    text: "What should we call you?"
                    font.pixelSize: 14
                    font.family: "Georgia"
                    color: "#8892A4"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Item { height: 10; width: 1 }

                TextField {
                    id: nickInput
                    width: 300
                    height: 52
                    font.pixelSize: 16
                    font.family: "Georgia"
                    color: "#FFFFFF"
                    placeholderText: "Your name…"
                    horizontalAlignment: TextInput.AlignHCenter
                    verticalAlignment: TextInput.AlignVCenter

                    onTextChanged: {
                        var pos = cursorPosition
                        var words = text.split(" ")
                        var result = words.map(function(word) {
                            if (word.length === 0) return ""
                            return word.charAt(0).toUpperCase() + word.slice(1)
                        }).join(" ")
                        if (text !== result) {
                            text = result
                            cursorPosition = pos
                        }
                    }

                    onAccepted: {
                        if (nickInput.text.trim() === "") return
                        backend.setNickname(nickInput.text.trim())
                        stack.push(chatScreen)
                    }

                    background: Rectangle {
                        radius: 12
                        color: "#111827"
                        border.color: nickInput.activeFocus ? "#00D4FF" : "#1E2A3A"
                        border.width: nickInput.activeFocus ? 2 : 1
                        anchors.fill: parent

                        Behavior on border.color { ColorAnimation { duration: 150 } }
                        Behavior on border.width { NumberAnimation { duration: 150 } }
                    }
                }

                Item { height: 14; width: 1 }

                Rectangle {
                    width: 300
                    height: 52
                    radius: 12
                    color: nickInput.text.trim() !== "" ? "#00D4FF" : "#111827"
                    border.color: nickInput.text.trim() !== "" ? "transparent" : "#1E2A3A"
                    border.width: 1

                    Behavior on color { ColorAnimation { duration: 200 } }

                    Text {
                        anchors.centerIn: parent
                        text: "Let's go →"
                        font.pixelSize: 16
                        font.bold: true
                        font.family: "Georgia"
                        color: nickInput.text.trim() !== "" ? "#0A0F1E" : "#3D4F66"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: nickInput.text.trim() !== "" ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: {
                            if (nickInput.text.trim() === "") return
                            backend.setNickname(nickInput.text.trim())
                            stack.push(chatScreen)
                        }
                    }
                }

                Item { height: 20; width: 1 }

                Text {
                    text: "Your name is only shared with nearby devices"
                    font.pixelSize: 11
                    font.family: "Georgia"
                    color: "#3D4F66"
                    anchors.horizontalCenter: parent.horizontalCenter
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    width: parent.width
                }
            }
        }
    }

    // 2. Chat
    Component {
        id: chatScreen

        Rectangle {
            color: "#0A0F1E"

            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: backend.checkInbox()
            }

            Connections {
                target: root
                function onSelectedPeerChanged() {
                    if (root.selectedPeer !== "") {
                        toInput.text = root.selectedPeer
                    }
                }
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Top bar
                Rectangle {
                    Layout.fillWidth: true
                    height: 62
                    color: "#0D1421"

                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 1
                        color: "#1E2A3A"
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 18
                        anchors.rightMargin: 18

                        // Avatar circle
                        Rectangle {
                            width: 36
                            height: 36
                            radius: 10
                            color: "#00D4FF"

                            Text {
                                anchors.centerIn: parent
                                text: backend.myNickname.charAt(0).toUpperCase()
                                font.pixelSize: 16
                                font.bold: true
                                font.family: "Georgia"
                                color: "#0A0F1E"
                            }
                        }

                        Item { width: 10; height: 1 }

                        Column {
                            spacing: 2
                            Layout.fillWidth: true

                            Text {
                                text: backend.myNickname
                                font.pixelSize: 15
                                font.bold: true
                                font.family: "Georgia"
                                color: "#FFFFFF"
                            }

                            Text {
                                text: backend.peers.length === 0
                                      ? "No one nearby yet"
                                      : backend.peers.length === 1
                                        ? "1 person nearby"
                                        : backend.peers.length + " people nearby"
                                font.pixelSize: 11
                                font.family: "Georgia"
                                color: backend.peers.length > 0 ? "#00D4FF" : "#3D4F66"
                            }
                        }

                        Rectangle {
                            width: 72
                            height: 32
                            radius: 8
                            color: "#111827"
                            border.color: "#1E2A3A"
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "People"
                                font.pixelSize: 12
                                font.family: "Georgia"
                                color: "#8892A4"
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: stack.push(peersScreen)
                            }
                        }
                    }
                }

                // Message list
                ListView {
                    id: messageList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 10
                    topMargin: 16
                    bottomMargin: 10
                    leftMargin: 0
                    rightMargin: 0
                    model: backend.messages
                    contentY: contentHeight > height ? contentHeight - height : 0

                    delegate: Item {
                        width: messageList.width
                        height: bubbleCol.implicitHeight + 6

                        property bool isMine: modelData.startsWith("You →")

                        Column {
                            id: bubbleCol
                            anchors.right: isMine ? parent.right : undefined
                            anchors.left: isMine ? undefined : parent.left
                            anchors.rightMargin: 16
                            anchors.leftMargin: 16
                            spacing: 3

                            Rectangle {
                                width: Math.min(msgText.implicitWidth + 28, messageList.width - 80)
                                height: msgText.implicitHeight + 20
                                radius: 14
                                color: isMine ? "#00D4FF" : "#111827"
                                border.color: isMine ? "transparent" : "#1E2A3A"
                                border.width: isMine ? 0 : 1
                                anchors.right: isMine ? parent.right : undefined

                                Text {
                                    id: msgText
                                    text: {
                                        var t = modelData
                                        if (t.indexOf(": ") !== -1) {
                                            return t.substring(t.indexOf(": ") + 2)
                                        }
                                        return t
                                    }
                                    font.pixelSize: 14
                                    font.family: "Georgia"
                                    color: isMine ? "#0A0F1E" : "#E2E8F0"
                                    wrapMode: Text.Wrap
                                    width: Math.min(implicitWidth, messageList.width - 108)
                                    anchors.centerIn: parent
                                }
                            }

                            Text {
                                text: {
                                    var t = modelData
                                    if (t.startsWith("You →")) {
                                        var toEnd = t.indexOf(":")
                                        return "You → " + t.substring(6, toEnd)
                                    }
                                    if (t.indexOf(": ") !== -1) return t.substring(0, t.indexOf(":"))
                                    return ""
                                }
                                font.pixelSize: 10
                                font.family: "Georgia"
                                color: "#3D4F66"
                                anchors.right: isMine ? parent.right : undefined
                                visible: text !== ""
                            }
                        }
                    }
                }

                // Empty state
                Item {
                    visible: backend.messages.length === 0
                    Layout.fillWidth: true
                    height: visible ? 60 : 0

                    Text {
                        anchors.centerIn: parent
                        text: "Say hi!"
                        font.pixelSize: 13
                        font.family: "Georgia"
                        color: "#3D4F66"
                    }
                }

                // Input bar
                Rectangle {
                    Layout.fillWidth: true
                    color: "#0D1421"
                    height: Math.min(Math.max(msgInput.implicitHeight + 32, 72), 160)

                    Behavior on height { NumberAnimation { duration: 100 } }

                    Rectangle {
                        anchors.top: parent.top
                        width: parent.width
                        height: 1
                        color: "#1E2A3A"
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        // Peer selector
                        Rectangle {
                            id: peerSelectorBtn
                            width: 96
                            height: 46
                            radius: 10
                            color: toInput.text !== "" ? "#0A1F2E" : "#111827"
                            border.color: toInput.text !== "" ? "#00D4FF" : "#1E2A3A"
                            border.width: 1

                            Behavior on color { ColorAnimation { duration: 150 } }

                            TextField {
                                id: toInput
                                visible: false
                                text: ""
                            }

                            Column {
                                anchors.centerIn: parent
                                spacing: 2

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: toInput.text !== "" ? toInput.text : "To"
                                    font.pixelSize: 13
                                    font.family: "Georgia"
                                    font.bold: toInput.text !== ""
                                    color: toInput.text !== "" ? "#00D4FF" : "#3D4F66"
                                    elide: Text.ElideRight
                                    width: 80
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "▾"
                                    font.pixelSize: 9
                                    color: toInput.text !== "" ? "#00D4FF" : "#3D4F66"
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: peerPopup.open()
                            }

                            Popup {
                                id: peerPopup
                                y: -(implicitHeight + 8)
                                x: 0
                                width: 180
                                padding: 6
                                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

                                background: Rectangle {
                                    color: "#111827"
                                    border.color: "#1E2A3A"
                                    border.width: 1
                                    radius: 12
                                }

                                contentItem: Column {
                                    spacing: 2

                                    Text {
                                        text: "Send to…"
                                        font.pixelSize: 11
                                        font.family: "Georgia"
                                        color: "#3D4F66"
                                        leftPadding: 10
                                        topPadding: 4
                                        bottomPadding: 2
                                    }

                                    // All option
                                    Rectangle {
                                        width: 168
                                        height: 42
                                        radius: 8
                                        color: allArea.containsMouse ? "#0A1F2E" : "transparent"

                                        Behavior on color { ColorAnimation { duration: 80 } }

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.margins: 10
                                            spacing: 10

                                            Rectangle {
                                                width: 28; height: 28; radius: 8
                                                color: "#00D4FF"

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "📢"
                                                    font.pixelSize: 14
                                                }
                                            }

                                            Column {
                                                spacing: 1
                                                Layout.fillWidth: true

                                                Text {
                                                    text: "Everyone"
                                                    font.pixelSize: 13
                                                    font.bold: true
                                                    font.family: "Georgia"
                                                    color: "#FFFFFF"
                                                }

                                                Text {
                                                    text: "broadcast"
                                                    font.pixelSize: 10
                                                    font.family: "Georgia"
                                                    color: "#3D4F66"
                                                }
                                            }
                                        }

                                        MouseArea {
                                            id: allArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                toInput.text = "All"
                                                peerPopup.close()
                                            }
                                        }
                                    }

                                    Rectangle {
                                        width: 150; height: 1; color: "#1E2A3A"; x: 9
                                        visible: backend.peers.length > 0
                                    }

                                    Repeater {
                                        model: backend.peers

                                        Rectangle {
                                            width: 168
                                            height: 42
                                            radius: 8
                                            color: peerItemArea.containsMouse ? "#0A1F2E" : "transparent"

                                            Behavior on color { ColorAnimation { duration: 80 } }

                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.margins: 10
                                                spacing: 10

                                                Rectangle {
                                                    width: 28; height: 28; radius: 8
                                                    color: "#0A2A1A"
                                                    border.color: "#00D4FF"
                                                    border.width: 1

                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: modelData.charAt(0).toUpperCase()
                                                        font.pixelSize: 13
                                                        font.bold: true
                                                        font.family: "Georgia"
                                                        color: "#00D4FF"
                                                    }
                                                }

                                                Text {
                                                    text: modelData
                                                    font.pixelSize: 13
                                                    font.family: "Georgia"
                                                    color: "#E2E8F0"
                                                    Layout.fillWidth: true
                                                    elide: Text.ElideRight
                                                }
                                            }

                                            MouseArea {
                                                id: peerItemArea
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    toInput.text = modelData
                                                    peerPopup.close()
                                                }
                                            }
                                        }
                                    }

                                    Rectangle {
                                        width: 168; height: 36; color: "transparent"
                                        visible: backend.peers.length === 0

                                        Text {
                                            anchors.centerIn: parent
                                            text: "Nobody nearby yet"
                                            font.pixelSize: 12
                                            font.family: "Georgia"
                                            color: "#3D4F66"
                                        }
                                    }
                                }
                            }
                        }

                        // Message input
                        Rectangle {
                            Layout.fillWidth: true
                            height: Math.min(Math.max(msgInput.implicitHeight + 16, 46), 130)
                            radius: 10
                            color: "#111827"
                            border.color: msgInput.activeFocus ? "#00D4FF" : "#1E2A3A"
                            border.width: msgInput.activeFocus ? 2 : 1

                            Behavior on height { NumberAnimation { duration: 100 } }
                            Behavior on border.color { ColorAnimation { duration: 150 } }

                            ScrollView {
                                anchors.fill: parent
                                anchors.margins: 4
                                clip: true
                                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                                ScrollBar.vertical.policy: ScrollBar.AsNeeded

                                TextArea {
                                    id: msgInput
                                    width: parent.width
                                    font.pixelSize: 15
                                    font.family: "Georgia"
                                    color: "#E2E8F0"
                                    leftPadding: 10
                                    rightPadding: 10
                                    topPadding: 8
                                    bottomPadding: 8
                                    wrapMode: TextArea.Wrap
                                    placeholderText: "Write a message…"
                                    background: null
                                    verticalAlignment: Text.AlignVCenter

                                    Keys.onReturnPressed: (event) => {
                                        if (event.modifiers & Qt.ShiftModifier) {
                                            event.accepted = false
                                        } else {
                                            if (toInput.text.trim() === "" || msgInput.text.trim() === "") return
                                            backend.sendMessage(toInput.text.trim(), msgInput.text.trim())
                                            msgInput.text = ""
                                            event.accepted = true
                                        }
                                    }
                                }
                            }
                        }

                        // Send button
                        Rectangle {
                            width: 46
                            height: 46
                            radius: 10
                            color: (toInput.text !== "" && msgInput.text !== "") ? "#00D4FF" : "#111827"
                            border.color: (toInput.text !== "" && msgInput.text !== "") ? "transparent" : "#1E2A3A"
                            border.width: 1

                            Behavior on color { ColorAnimation { duration: 150 } }

                            Text {
                                anchors.centerIn: parent
                                text: "↑"
                                font.pixelSize: 20
                                font.bold: true
                                color: (toInput.text !== "" && msgInput.text !== "") ? "#0A0F1E" : "#3D4F66"
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: (toInput.text !== "" && msgInput.text !== "") ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: {
                                    if (toInput.text.trim() === "" || msgInput.text.trim() === "") return
                                    backend.sendMessage(toInput.text.trim(), msgInput.text.trim())
                                    msgInput.text = ""
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // 3. Peers
    Component {
        id: peersScreen

        Rectangle {
            color: "#0A0F1E"

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                Rectangle {
                    Layout.fillWidth: true
                    height: 62
                    color: "#0D1421"

                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 1
                        color: "#1E2A3A"
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 18

                        Rectangle {
                            width: 36; height: 36; radius: 8
                            color: "#111827"
                            border.color: "#1E2A3A"; border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "←"
                                font.pixelSize: 16
                                color: "#8892A4"
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: stack.pop()
                            }
                        }

                        Item { width: 10; height: 1 }

                        Text {
                            text: "People Nearby"
                            font.pixelSize: 17
                            font.bold: true
                            font.family: "Georgia"
                            color: "#FFFFFF"
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            width: 28; height: 28; radius: 8
                            color: backend.peers.length > 0 ? "#00D4FF" : "#111827"
                            border.color: backend.peers.length > 0 ? "transparent" : "#1E2A3A"
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: backend.peers.length
                                font.pixelSize: 12
                                font.bold: true
                                font.family: "Georgia"
                                color: backend.peers.length > 0 ? "#0A0F1E" : "#3D4F66"
                            }
                        }
                    }
                }

                // Empty state
                Item {
                    visible: backend.peers.length === 0
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Column {
                        anchors.centerIn: parent
                        spacing: 14

                        Text {
                            text: "🔍"
                            font.pixelSize: 48
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                            text: "Nobody nearby yet"
                            font.pixelSize: 18
                            font.bold: true
                            font.family: "Georgia"
                            color: "#FFFFFF"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                            text: "When someone else opens MeshTalk\non the same network, they'll show up here."
                            font.pixelSize: 13
                            font.family: "Georgia"
                            color: "#3D4F66"
                            anchors.horizontalCenter: parent.horizontalCenter
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }

                // Peers list
                ListView {
                    visible: backend.peers.length > 0
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 6
                    topMargin: 10
                    model: backend.peers

                    delegate: Rectangle {
                        width: parent.width - 24
                        x: 12
                        height: 70
                        radius: 12
                        color: peerArea.containsMouse ? "#111827" : "#0D1421"
                        border.color: peerArea.containsMouse ? "#00D4FF" : "#1E2A3A"
                        border.width: 1

                        Behavior on color { ColorAnimation { duration: 100 } }
                        Behavior on border.color { ColorAnimation { duration: 100 } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 14
                            spacing: 12

                            // Avatar
                            Rectangle {
                                width: 42; height: 42; radius: 10
                                color: "#00D4FF"

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.charAt(0).toUpperCase()
                                    font.pixelSize: 18
                                    font.bold: true
                                    font.family: "Georgia"
                                    color: "#0A0F1E"
                                }
                            }

                            Column {
                                Layout.fillWidth: true
                                spacing: 3

                                Text {
                                    text: modelData
                                    font.pixelSize: 15
                                    font.bold: true
                                    font.family: "Georgia"
                                    color: "#FFFFFF"
                                }

                                Row {
                                    spacing: 5

                                    Rectangle {
                                        width: 7; height: 7; radius: 4
                                        color: "#00D4FF"
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Text {
                                        text: "Online nearby"
                                        font.pixelSize: 11
                                        font.family: "Georgia"
                                        color: "#3D4F66"
                                    }
                                }
                            }

                            Rectangle {
                                width: 68; height: 34; radius: 8
                                color: "#00D4FF"

                                Text {
                                    anchors.centerIn: parent
                                    text: "Chat"
                                    font.pixelSize: 13
                                    font.bold: true
                                    font.family: "Georgia"
                                    color: "#0A0F1E"
                                }
                            }
                        }

                        MouseArea {
                            id: peerArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.selectedPeer = modelData
                                stack.pop()
                            }
                        }
                    }
                }
            }
        }
    }
}
