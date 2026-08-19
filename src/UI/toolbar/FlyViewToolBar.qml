import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

import QGroundControl
import QGroundControl.Controls
import QGroundControl.FlyView

Item {
    required property var guidedValueSlider

    id:     control
    width:  parent.width
    height: ScreenTools.toolbarHeight

    property var    _activeVehicle:     QGroundControl.multiVehicleManager.activeVehicle
    property bool   _communicationLost: _activeVehicle ? _activeVehicle.vehicleLinkManager.communicationLost : false
    property color  _mainStatusBGColor: "#ff3b30"
    property real   _leftRightMargin:   ScreenTools.defaultFontPixelWidth * 0.75
    property var    _guidedController:  globals.guidedControllerFlyView

    function dropMainStatusIndicatorTool() {
        mainStatusIndicator.dropMainStatusIndicator()
    }

    QGCPalette { id: qgcPal }

    QGCFlickable {
        anchors.fill:       parent
        contentWidth:       toolBarLayout.width
        flickableDirection: Flickable.HorizontalFlick

        Row {
            id:         toolBarLayout
            height:     parent.height
            spacing:    0

            Item {
                id:     leftPanel
                width:  leftPanelLayout.implicitWidth
                height: parent.height

                Rectangle {
                    id:         gradientBackground
                    height:     parent.height
                    width:      mainStatusLayout.width
                    opacity:    qgcPal.windowTransparent.a

                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: _mainStatusBGColor }
                        GradientStop { position: 0.5; color: _activeVehicle ? _mainStatusBGColor : "#ff8a80" }
                        GradientStop { position: 1.0; color: qgcPal.window }
                    }
                }

                Rectangle {
                    anchors.left:   gradientBackground.right
                    anchors.right:  parent.right
                    height:         parent.height
                    color:          qgcPal.windowTransparent
                }

                RowLayout {
                    id:         leftPanelLayout
                    height:     parent.height
                    spacing:    ScreenTools.defaultFontPixelWidth * 2

                    RowLayout {
                        id:         mainStatusLayout
                        height:     parent.height
                        spacing:    ScreenTools.defaultFontPixelWidth * 0.75

                        QGCToolBarButton {
                            id:                 qgcButton
                            Layout.fillHeight:  true
                            Layout.leftMargin:  ScreenTools.defaultFontPixelWidth * 1
                            icon.source:        qgcPal.globalTheme === QGCPalette.Dark
                                                ? "qrc:/res/QGCLogoBlack.png"
                                                : "qrc:/res/QGCLogoFull.png"
                            logo:               true
                            onClicked:          mainWindow.showToolSelectDialog()
                        }

                        QGCLabel {
                            id:                     appTitleLabel
                            Layout.alignment:       Qt.AlignVCenter
                            text:                   qsTr("KapYah GCS  ")
                            font.pointSize:         ScreenTools.largeFontPointSize
                            font.bold:              true
                            color:                  qgcPal.text
                            visible:                _activeVehicle === null
                        }

                        MainStatusIndicator {
                            id:                 mainStatusIndicator
                            Layout.fillHeight:  true
                        }
                    }

                    QGCButton {
                        id:         disconnectButton
                        text:       qsTr("Disconnect")
                        onClicked:  _activeVehicle.closeVehicle()
                        visible:    _activeVehicle && _communicationLost
                    }

                    FlightModeIndicator {
                        Layout.fillHeight:  true
                        visible:            _activeVehicle
                    }
                }
            }

            Item {
                id:     centerPanel
                width:  Math.max(
                            guidedActionConfirm.visible ? guidedActionConfirm.width : 0,
                            control.width - (leftPanel.width + rightPanel.width)
                        )
                height: parent.height

                Rectangle {
                    anchors.fill:   parent
                    color:          qgcPal.windowTransparent
                }

                GuidedActionConfirm {
                    id:                         guidedActionConfirm
                    height:                     parent.height
                    anchors.horizontalCenter:   parent.horizontalCenter
                    guidedController:           control._guidedController
                    guidedValueSlider:          control.guidedValueSlider
                    messageDisplay:             guidedActionMessageDisplay
                }
            }

            Item {
                id:      rightPanel
                width:   _activeVehicle !== null
                         ? (flyViewIndicators.width + ScreenTools.defaultFontPixelWidth * (ScreenTools.isMobile ? 30 : 58))
                         : 0
                height:  parent.height
                visible: _activeVehicle !== null

                Rectangle {
                    anchors.fill:   parent
                    color:          qgcPal.windowTransparent
                }

                FlyViewToolBarIndicators {
                    id:                     flyViewIndicators
                    height:                 parent.height
                    anchors.left:           parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }

                Item {
                    id:                     logoContainer
                    anchors.right:          parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width:                  ScreenTools.isMobile
                                            ? ScreenTools.defaultFontPixelWidth * 26
                                            : ScreenTools.defaultFontPixelWidth * 32
                    height:                 parent.height

                    Image {
                        id: kapyahGCSLogo
                        anchors.fill: parent
                        source: "qrc:/res/KapYahGCS.png"
                        visible: _activeVehicle !== null
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        mipmap: true
                        cache: true
                    }
                }
            }
        }
    }

    Rectangle {
        id:                         guidedActionMessageDisplay
        anchors.top:                control.bottom
        anchors.topMargin:          _margins
        x:                          control.mapFromItem(guidedActionConfirm.parent, guidedActionConfirm.x, 0).x
                                    + (guidedActionConfirm.width - guidedActionMessageDisplay.width) / 2
        width:                      messageLabel.contentWidth + (_margins * 2)
        height:                     messageLabel.contentHeight + (_margins * 2)
        color:                      qgcPal.windowTransparent
        radius:                     ScreenTools.defaultBorderRadius
        visible:                    guidedActionConfirm.visible

        QGCLabel {
            id:         messageLabel
            x:          _margins
            y:          _margins
            width:      ScreenTools.defaultFontPixelWidth * 30
            wrapMode:   Text.WordWrap
            text:       guidedActionConfirm.message
        }

        PropertyAnimation {
            id:         messageOpacityAnimation
            target:     guidedActionMessageDisplay
            property:   "opacity"
            from:       1
            to:         0
            duration:   500
        }

        Timer {
            id:             messageFadeTimer
            interval:       4000
            onTriggered:    messageOpacityAnimation.start()
        }
    }

    ParameterDownloadProgress {
        anchors.fill: parent
    }
}