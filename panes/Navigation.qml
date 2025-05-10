import QtQuick

Item {
    Text {
        anchors {
            top: parent.top
            left: parent.left

            topMargin: 12
            leftMargin: 11
        }

        text: "Favorite Links"
        color: Qt.rgba(0, 0, 0, 0.5)

        Text {
            anchors {
                top: parent.top
                left: parent.left

                topMargin: 25
                leftMargin: 18
            }

            text: "(Empty)"
            color: "#7584cb"
        }
    }
}
