import QtQuick
import QtQuick.Controls
import QtLocation
import QtPositioning
import QtQuick.Dialogs
import Qt.labs.animation

import QGroundControl
import QGroundControl.Controls
import QGroundControl.FlightMap

Map {
id: _map

plugin:     Plugin { name: "QGroundControl" }
opacity:    0.99

property string mapName:                        "defaultMap"
property bool   isSatelliteMap:                 activeMapType.name.indexOf("Satellite") > -1 || activeMapType.name.indexOf("Hybrid") > -1
property var    gcsPosition:                    QGroundControl.qgcPositionManger.gcsPosition
property real   gcsHeading:                     QGroundControl.qgcPositionManger.gcsHeading
property bool   allowGCSLocationCenter:         false
property bool   allowVehicleLocationCenter:     false
property bool   firstGCSPositionReceived:       false
property bool   firstVehiclePositionReceived:   false
property bool   planView:                       false

property var    _activeVehicle:                 QGroundControl.multiVehicleManager.activeVehicle
property var    _activeVehicleCoordinate:       _activeVehicle ? _activeVehicle.coordinate : QtPositioning.coordinate()

function setVisibleRegion(region) {
    let maxZoomLevel = 20
    _map.visibleRegion = QtPositioning.rectangle(QtPositioning.coordinate(0, 0), QtPositioning.coordinate(0, 0))
    _map.visibleRegion = region
    if (_map.zoomLevel > maxZoomLevel) {
        _map.zoomLevel = maxZoomLevel
    }
}

function _possiblyCenterToVehiclePosition() {
    if (!firstVehiclePositionReceived && allowVehicleLocationCenter && _activeVehicleCoordinate.isValid) {
        firstVehiclePositionReceived = true
        center = _activeVehicleCoordinate
        zoomLevel = QGroundControl.flightMapInitialZoom
    }
}

function centerToSpecifiedLocation() {
    specifyMapPositionDialogFactory.open()
}

QGCPopupDialogFactory {
    id: specifyMapPositionDialogFactory
    dialogComponent: specifyMapPositionDialog
}

Component {
    id: specifyMapPositionDialog
    EditPositionDialog {
        title:                  qsTr("Specify Position")
        coordinate:             center
        onCoordinateChanged:    center = coordinate
    }
}

onGcsPositionChanged: {
    if (gcsPosition.isValid && allowGCSLocationCenter && !firstGCSPositionReceived && !firstVehiclePositionReceived) {
        firstGCSPositionReceived = true
        var _activeVehicleCoordinate = _activeVehicle ? _activeVehicle.coordinate : QtPositioning.coordinate()
        if (QGroundControl.settingsManager.flyViewSettings.keepMapCenteredOnVehicle.rawValue || !_activeVehicleCoordinate.isValid) {
            center = gcsPosition
        }
    }
}

function updateActiveMapType() {
    var settings = QGroundControl.settingsManager.flightMapSettings
    var fullMapName = settings.mapProvider.value + " " + settings.mapType.value

    for (var i = 0; i < _map.supportedMapTypes.length; i++) {
        if (fullMapName === _map.supportedMapTypes[i].name) {
            _map.activeMapType = _map.supportedMapTypes[i]
            return
        }
    }
}

on_ActiveVehicleCoordinateChanged: _possiblyCenterToVehiclePosition()

onMapReadyChanged: {
    if (_map.mapReady) {
        updateActiveMapType()
        _possiblyCenterToVehiclePosition()
    }
}

Connections {
    target: QGroundControl.settingsManager.flightMapSettings.mapType
    function onRawValueChanged() { updateActiveMapType() }
}

Connections {
    target: QGroundControl.settingsManager.flightMapSettings.mapProvider
    function onRawValueChanged() { updateActiveMapType() }
}

signal mapPanStart
signal mapPanStop
signal mapClicked(var position)
signal mapRightClicked(var position)
signal mapPressAndHold(var position)

PinchHandler {
    id: pinchHandler
    target: null
    property var pinchStartCentroid

    onActiveChanged: {
        if (active) {
            pinchStartCentroid = _map.toCoordinate(pinchHandler.centroid.position, false)
        }
    }

    onScaleChanged: (delta) => {
        let newZoomLevel = Math.max(_map.zoomLevel + Math.log2(delta), 0)
        _map.zoomLevel = newZoomLevel
        _map.alignCoordinateToPoint(pinchStartCentroid, pinchHandler.centroid.position)
    }
}

WheelHandler {
    acceptedDevices: Qt.platform.pluginName === "cocoa" || Qt.platform.pluginName === "wayland"
                     ? PointerDevice.Mouse | PointerDevice.TouchPad
                     : PointerDevice.Mouse
    rotationScale: 1 / 120
    property: "zoomLevel"
}

MultiPointTouchArea {
    id: multiTouchArea
    anchors.fill: parent
    maximumTouchPoints: 1
    mouseEnabled: true

    property bool dragActive: false
    property real lastMouseX
    property real lastMouseY
    property bool isPressed: false
    property bool pressAndHold: false

    onPressed: (touchPoints) => {
        lastMouseX = touchPoints[0].x
        lastMouseY = touchPoints[0].y
        isPressed = true
        pressAndHold = false
        pressAndHoldTimer.start()
    }

    onGestureStarted: (gesture) => {
        dragActive = true
        gesture.grab()
        mapPanStart()
    }

    onUpdated: (touchPoints) => {
        if (dragActive) {
            let deltaX = touchPoints[0].x - lastMouseX
            let deltaY = touchPoints[0].y - lastMouseY
            if (Math.abs(deltaX) >= 1.0 || Math.abs(deltaY) >= 1.0) {
                _map.pan(lastMouseX - touchPoints[0].x, lastMouseY - touchPoints[0].y)
                lastMouseX = touchPoints[0].x
                lastMouseY = touchPoints[0].y
            }
        }
    }

    onReleased: (touchPoints) => {
        isPressed = false
        pressAndHoldTimer.stop()
        if (dragActive) {
            _map.pan(lastMouseX - touchPoints[0].x, lastMouseY - touchPoints[0].y)
            dragActive = false
            mapPanStop()
        } else if (!pressAndHold) {
            mapClicked(Qt.point(touchPoints[0].x, touchPoints[0].y))
        }
        pressAndHold = false
    }

    Timer {
        id: pressAndHoldTimer
        interval: 600
        repeat: false

        onTriggered: {
            if (multiTouchArea.isPressed && !multiTouchArea.dragActive) {
                multiTouchArea.pressAndHold = true
                mapPressAndHold(Qt.point(multiTouchArea.lastMouseX, multiTouchArea.lastMouseY))
            }
        }
    }
}

MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.RightButton
    propagateComposedEvents: true

    onPressed: (mouseEvent) => {
        if (mouseEvent.button === Qt.RightButton) {
            mapRightClicked(Qt.point(mouseEvent.x, mouseEvent.y))
        }
    }
}

MapQuickItem {
    anchorPoint.x:  sourceItem.width / 2
    anchorPoint.y:  sourceItem.height / 2
    visible:        gcsPosition.isValid && !planView
    coordinate:     gcsPosition

    sourceItem: Image {
        id:                 mapItemImage
        source:             "/res/QGCLogoFull.svg"
        mipmap:             true
        antialiasing:       true
        fillMode:           Image.PreserveAspectFit
        height:             ScreenTools.defaultFontPixelHeight * 2
        sourceSize.height:  height
    }
}

}