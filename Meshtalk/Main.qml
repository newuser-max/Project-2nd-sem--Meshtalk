import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Window {
    id: root
    width: 400
    height: 700
    visible: true
    title: "MeshTalk"
    color: "#F5F0EB"

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
            color: "#F5F0EB"

            Column {
                anchors.centerIn: parent
                spacing: 0
                width: 300

               Rectangle {
    width: 80
    height: 80
    radius: 40
    color: "#E8E0D8"
    anchors.horizontalCenter: parent.horizontalCenter

   
    Item {
        anchors.centerIn: parent
        width: 44
        height: 40

        Rectangle {
            width: 44
            height: 32
            radius: 10
            color: "#C4956A"
            anchors.top: parent.top
        }

        
        Rectangle {
            width: 12
            height: 12
            radius: 3
            color: "#C4956A"
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
                    color: "#FFFFFF"
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
                    color: "#2C2420"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

            

                Item { height: 40; width: 1 }

                Text {
                    text: "What should we call you?"
                    font.pixelSize: 14
                    font.family: "Georgia"
                    color: "#5C4C42"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Item { height: 10; width: 1 }

                TextField {
                    id: nickInput
                    width: 300
                    height: 52
                    font.pixelSize: 16
                    font.family: "Georgia"
                    color: "#2C2420"
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
                        radius: 14
                        color: "#FFFFFF"
                        border.color: nickInput.activeFocus ? "#C4956A" : "#DDD5CC"
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
                    radius: 14
                    color: nickInput.text.trim() !== "" ? "#C4956A" : "#E8E0D8"

                    Behavior on color { ColorAnimation { duration: 200 } }

                    Text {
                        anchors.centerIn: parent
                        text: "Let's go →"
                        font.pixelSize: 16
                        font.bold: true
                        font.family: "Georgia"
                        color: nickInput.text.trim() !== "" ? "#FFFFFF" : "#BBA898"
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
                    color: "#BBA898"
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
            color: "#F5F0EB"

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
                    color: "#FFFFFF"

                    // Bottom border
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 1
                        color: "#EDE6DF"
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 18
                        anchors.rightMargin: 18

                        // Avatar circle
                        Rectangle {
                            width: 36
                            height: 36
                            radius: 18
                            color: "#F0E6D8"

                            Text {
                                anchors.centerIn: parent
                                text: backend.myNickname.charAt(0).toUpperCase()
                                font.pixelSize: 16
                                font.bold: true
                                font.family: "Georgia"
                                color: "#C4956A"
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
                                color: "#2C2420"
                            }

                            Text {
                                text: backend.peers.length === 0
                                      ? "No one nearby yet"
                                      : backend.peers.length === 1
                                        ? "1 person nearby"
                                        : backend.peers.length + " people nearby"
                                font.pixelSize: 11
                                font.family: "Georgia"
                                color: backend.peers.length > 0 ? "#7BAF7A" : "#BBA898"
                            }
                        }

                        Rectangle {
                            width: 72
                            height: 32
                            radius: 10
                            color: "#F5F0EB"
                            border.color: "#DDD5CC"
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "People"
                                font.pixelSize: 12
                                font.family: "Georgia"
                                color: "#7A6A60"
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
                                radius: isMine ? 18 : 18
                                color: isMine ? "#C4956A" : "#FFFFFF"
                                anchors.right: isMine ? parent.right : undefined

                                // Subtle shadow
                                layer.enabled: true
                                layer.effect: null

                                Text {
                                    id: msgText
                                    text: {
                                        // Strip "You → Name: " prefix for cleaner look
                                        var t = modelData
                                        if (t.indexOf(": ") !== -1) {
                                            return t.substring(t.indexOf(": ") + 2)
                                        }
                                        return t
                                    }
                                    font.pixelSize: 14
                                    font.family: "Georgia"
                                    color: isMine ? "#FFFFFF" : "#2C2420"
                                    wrapMode: Text.Wrap
                                    width: Math.min(implicitWidth, messageList.width - 108)
                                    anchors.centerIn: parent
                                }
                            }

                            // Sender label
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
                                color: "#BBA898"
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
                        text: "Say hello to someone nearby ✨"
                        font.pixelSize: 13
                        font.family: "Georgia"
                        color: "#C4B5A8"
                    }
                }

                // Input bar
                Rectangle {
                    Layout.fillWidth: true
                    color: "#FFFFFF"
                    height: Math.min(Math.max(msgInput.implicitHeight + 32, 72), 160)

                    Behavior on height { NumberAnimation { duration: 100 } }

                    // Top border
                    Rectangle {
                        anchors.top: parent.top
                        width: parent.width
                        height: 1
                        color: "#EDE6DF"
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
                            radius: 12
                            color: toInput.text !== "" ? "#FEF5EC" : "#F5F0EB"
                            border.color: toInput.text !== "" ? "#C4956A" : "#DDD5CC"
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
                                    color: toInput.text !== "" ? "#C4956A" : "#9C8C80"
                                    elide: Text.ElideRight
                                    width: 80
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "▾"
                                    font.pixelSize: 9
                                    color: toInput.text !== "" ? "#C4956A" : "#BBA898"
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
                                    color: "#FFFFFF"
                                    border.color: "#EDE6DF"
                                    border.width: 1
                                    radius: 14

                                    // Drop shadow effect via layered rectangle
                                    Rectangle {
                                        anchors.fill: parent
                                        radius: 14
                                        color: "transparent"
                                        border.color: "#00000010"
                                        border.width: 3
                                        z: -1
                                    }
                                }

                                contentItem: Column {
                                    spacing: 2

                                    Text {
                                        text: "Send to…"
                                        font.pixelSize: 11
                                        font.family: "Georgia"
                                        color: "#BBA898"
                                        leftPadding: 10
                                        topPadding: 4
                                        bottomPadding: 2
                                    }

                                    // All option
                                    Rectangle {
                                        width: 168
                                        height: 42
                                        radius: 10
                                        color: allArea.containsMouse ? "#FEF5EC" : "transparent"

                                        Behavior on color { ColorAnimation { duration: 80 } }

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.margins: 10
                                            spacing: 10

                                            Rectangle {
                                                width: 28; height: 28; radius: 14
                                                color: "#F0E6D8"

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
                                                    color: "#2C2420"
                                                }

                                                Text {
                                                    text: "broadcast"
                                                    font.pixelSize: 10
                                                    font.family: "Georgia"
                                                    color: "#BBA898"
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
                                        width: 150; height: 1; color: "#EDE6DF"; x: 9
                                        visible: backend.peers.length > 0
                                    }

                                    Repeater {
                                        model: backend.peers

                                        Rectangle {
                                            width: 168
                                            height: 42
                                            radius: 10
                                            color: peerItemArea.containsMouse ? "#FEF5EC" : "transparent"

                                            Behavior on color { ColorAnimation { duration: 80 } }

                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.margins: 10
                                                spacing: 10

                                                Rectangle {
                                                    width: 28; height: 28; radius: 14
                                                    color: "#E8F5E8"

                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: modelData.charAt(0).toUpperCase()
                                                        font.pixelSize: 13
                                                        font.bold: true
                                                        font.family: "Georgia"
                                                        color: "#5A9A5A"
                                                    }
                                                }

                                                Text {
                                                    text: modelData
                                                    font.pixelSize: 13
                                                    font.family: "Georgia"
                                                    color: "#2C2420"
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
                                            color: "#C4B5A8"
                                        }
                                    }
                                }
                            }
                        }

                        // Message input
                        Rectangle {
                            Layout.fillWidth: true
                            height: Math.min(Math.max(msgInput.implicitHeight + 16, 46), 130)
                            radius: 12
                            color: "#F5F0EB"
                            border.color: msgInput.activeFocus ? "#C4956A" : "#DDD5CC"
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
                                    color: "#2C2420"
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
                            radius: 12
                            color: (toInput.text !== "" && msgInput.text !== "") ? "#C4956A" : "#EDE6DF"

                            Behavior on color { ColorAnimation { duration: 150 } }

                            Text {
                                anchors.centerIn: parent
                                text: "↑"
                                font.pixelSize: 20
                                font.bold: true
                                color: (toInput.text !== "" && msgInput.text !== "") ? "#FFFFFF" : "#C4B5A8"
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
            color: "#F5F0EB"

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                Rectangle {
                    Layout.fillWidth: true
                    height: 62
                    color: "#FFFFFF"

                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 1
                        color: "#EDE6DF"
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 18

                        Rectangle {
                            width: 36; height: 36; radius: 10
                            color: "#F5F0EB"
                            border.color: "#DDD5CC"; border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "←"
                                font.pixelSize: 16
                                color: "#7A6A60"
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
                            color: "#2C2420"
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            width: 28; height: 28; radius: 14
                            color: backend.peers.length > 0 ? "#E8F5E8" : "#F0EBE6"

                            Text {
                                anchors.centerIn: parent
                                text: backend.peers.length
                                font.pixelSize: 12
                                font.bold: true
                                font.family: "Georgia"
                                color: backend.peers.length > 0 ? "#5A9A5A" : "#BBA898"
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
                            color: "#5C4C42"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                            text: "When someone else opens MeshTalk\non the same network, they'll show up here."
                            font.pixelSize: 13
                            font.family: "Georgia"
                            color: "#9C8C80"
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
                    spacing: 1
                    topMargin: 10
                    model: backend.peers

                    delegate: Rectangle {
                        width: parent.width - 24
                        x: 12
                        height: 70
                        radius: 14
                        color: peerArea.containsMouse ? "#FFFFFF" : "#FDFAF7"
                        border.color: "#EDE6DF"
                        border.width: 1

                        Behavior on color { ColorAnimation { duration: 100 } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 14
                            spacing: 12

                            // Avatar
                            Rectangle {
                                width: 42; height: 42; radius: 21
                                color: "#F0E6D8"

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.charAt(0).toUpperCase()
                                    font.pixelSize: 18
                                    font.bold: true
                                    font.family: "Georgia"
                                    color: "#C4956A"
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
                                    color: "#2C2420"
                                }

                                Row {
                                    spacing: 5

                                    Rectangle {
                                        width: 7; height: 7; radius: 4
                                        color: "#7BAF7A"
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Text {
                                        text: "Online nearby"
                                        font.pixelSize: 11
                                        font.family: "Georgia"
                                        color: "#9C8C80"
                                    }
                                }
                            }

                            Rectangle {
                                width: 68; height: 34; radius: 10
                                color: "#C4956A"

                                Text {
                                    anchors.centerIn: parent
                                    text: "Chat"
                                    font.pixelSize: 13
                                    font.bold: true
                                    font.family: "Georgia"
                                    color: "#FFFFFF"
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
