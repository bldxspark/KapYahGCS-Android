import QtQuick
import QtQuick.Controls

import QGroundControl
import QGroundControl.Controls

// Important Note: Toolbar buttons must manage their checked state manually in order to support
// view switch prevention. This means they can't be checkable or autoExclusive.

Button {
    id:                 button
    height:             ScreenTools.defaultFontPixelHeight * 3
    leftPadding:        logo ? 0 : _horizontalMargin
    rightPadding:       logo ? 0 : _horizontalMargin
    checkable:          false

    property bool logo: false

    property real _horizontalMargin: ScreenTools.defaultFontPixelWidth

    onCheckedChanged: checkable = false

    background: Rectangle {
        anchors.fill:   parent
        color:          button.checked ? qgcPal.buttonHighlight : Qt.rgba(0, 0, 0, 0)
        border.color:   "red"
        border.width:   QGroundControl.corePlugin.showTouchAreas ? 3 : 0
    }

    contentItem: Row {
        spacing:                logo ? 0 : ScreenTools.defaultFontPixelWidth
        anchors.verticalCenter: button.verticalCenter

        Item {
            height: ScreenTools.defaultFontPixelHeight * 2
            width:  height
            anchors.verticalCenter: parent.verticalCenter

            Image {
                visible: logo
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                source: button.icon.source
                smooth: true
                mipmap: true
            }

            QGCColoredImage {
                visible: !logo
                anchors.fill: parent
                sourceSize.height: parent.height
                fillMode: Image.PreserveAspectFit
                color: button.checked ? qgcPal.buttonHighlightText : qgcPal.buttonText
                source: button.icon.source
            }
        }

        Label {
            id:                     _label
            visible:                text !== ""
            text:                   button.text
            color:                  button.checked ? qgcPal.buttonHighlightText : qgcPal.buttonText
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}