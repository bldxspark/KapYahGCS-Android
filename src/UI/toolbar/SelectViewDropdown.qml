import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls

ToolIndicatorPage {
    id: root

    property real _toolButtonHeight: ScreenTools.defaultFontPixelHeight * 3

    contentComponent: Component {
        GridLayout {
            columns: 2
            columnSpacing: ScreenTools.defaultFontPixelWidth
            rowSpacing: columnSpacing

            SubMenuButton {
                implicitHeight: root._toolButtonHeight
                Layout.fillWidth: true
                text: qsTr("Fly")
                imageResource: "/res/FlyingPaperPlane.svg"
                onClicked: {
                    if (mainWindow.allowViewSwitch()) {
                        mainWindow.closeIndicatorDrawer()
                        mainWindow.showFlyView()
                    }
                }
            }

            SubMenuButton {
                implicitHeight: root._toolButtonHeight
                Layout.fillWidth: true
                text: qsTr("Plan")
                imageResource: "/qmlimages/Plan.svg"
                onClicked: {
                    if (mainWindow.allowViewSwitch()) {
                        mainWindow.closeIndicatorDrawer()
                        mainWindow.showPlanView()
                    }
                }
            }

            SubMenuButton {
                implicitHeight: root._toolButtonHeight
                Layout.fillWidth: true
                text: qsTr("Analyze")
                imageResource: "/qmlimages/Analyze.svg"
                visible: QGroundControl.corePlugin.showAdvancedUI
                onClicked: {
                    if (mainWindow.allowViewSwitch()) {
                        mainWindow.closeIndicatorDrawer()
                        mainWindow.showAnalyzeTool()
                    }
                }
            }

            SubMenuButton {
                id: setupButton
                implicitHeight: root._toolButtonHeight
                Layout.fillWidth: true
                text: qsTr("Configure")
                imageResource: "/res/GearWithPaperPlane.svg"
                onClicked: {
                    if (mainWindow.allowViewSwitch()) {
                        mainWindow.requestVehicleConfig()
                    }
                }
            }

            SubMenuButton {
                id: settingsButton
                implicitHeight: root._toolButtonHeight
                Layout.fillWidth: true
                text: qsTr("Settings")
                imageResource: "/res/gear-black.svg"
                visible: !QGroundControl.corePlugin.options.combineSettingsAndSetup
                onClicked: {
                    if (mainWindow.allowViewSwitch()) {
                        mainWindow.closeIndicatorDrawer()
                        mainWindow.showSettingsTool()
                    }
                }
            }

            SubMenuButton {
                id: closeButton
                implicitHeight: root._toolButtonHeight
                Layout.fillWidth: true
                text: qsTr("Close")
                imageResource: "/res/OpenDoor.svg"
                onClicked: {
                    if (mainWindow.allowViewSwitch()) {
                        mainWindow.finishCloseProcess()
                    }
                }
            }

            // 🔥 KapYah Branding (Replaces Version Block)
            ColumnLayout {
                Layout.fillWidth: true
                Layout.columnSpan: 2
                spacing: 2

                QGCLabel {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: "KapYah Ground Control Station"
                    font.bold: true
                    wrapMode: Text.NoWrap
                }

                QGCLabel {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: "A product by KapYah Industries Pvt. Ltd."
                    wrapMode: Text.NoWrap
                    elide: Text.ElideRight
                    font.pointSize: ScreenTools.smallFontPointSize - 1
                    opacity: 0.8
                }
                QGCLabel {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: "v1.0.0"
                    wrapMode: Text.NoWrap
                    font.pointSize: ScreenTools.smallFontPointSize - 1
                    opacity: 0.8
                }
            }
        }
    }
}
