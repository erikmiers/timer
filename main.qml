import QtQuick 2.15
import QtQml 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.settings 1.0
import QtGraphicalEffects 1.15
import QtMultimedia 5.12


Window {
	id      : mainWindow
	width   : 640
	height  : 480
	visible : true
	title   : qsTr("Timer")

    property bool running            : false
    property alias repeat            : swtchRepeat.checked
    property alias countdown         : swtchCountdown.checked
    property alias hideControls      : btnHideCntrls.checked
    property string datastore        : ""
    property int savedSettingsHeight : 1

	Settings {
		id: settings
        property alias x                   : mainWindow.x
        property alias y                   : mainWindow.y
        property alias width               : mainWindow.width
        property alias height              : mainWindow.height
        property alias repeat              : mainWindow.repeat
        property alias countdown           : mainWindow.countdown
        property alias hideControls        : mainWindow.hideControls
        property alias datastore           : mainWindow.datastore
        property alias savedSettingsHeight : mainWindow.savedSettingsHeight
    } // Settings

	Component.onCompleted: {
		if ( datastore ) {
            intervallData.clear()
			var datamodel = JSON.parse(datastore)
            for ( var i = 0; i < datamodel.length; ++i) intervallData.append(datamodel[i])
		}
        intervallData.updateRoundTime()
	}

	onClosing: {
		var datamodel = []
        for (var i = 0; i < intervallData.count; ++i) datamodel.push(intervallData.get(i))
		datastore = JSON.stringify(datamodel)
	}

	SoundEffect {
		id     : ssTap
		source : "qrc:/tap.wav"
	}
	SoundEffect {
		id     : ssBing
		source : "qrc:/bing.wav"
	}
	SoundEffect {
		id     : ssHorn
		source : "qrc:/horn.wav"
	}
	SoundEffect {
		id     : ssBingBong
		source : "qrc:/bing-bong.wav"
	}

	Timer {
		id        : timer

		property int interv : 0
		property int time   : 0
        property int round  : 0

		Component.onCompleted: reset()

		running     : mainWindow.running
		interval    : 1000
		repeat      : true
		onTriggered : {
			time -= 1
			if ( mainWindow.countdown && time <= 3 ) ssTap.play()
            if ( time == 0 && intervallData.get(interv).tone !== 0 )
                switch ( intervallData.get(interv).tone ) {
				case 1: ssBing.play()
					break
				case 2: ssHorn.play()
					break
				case 3: ssBingBong.play()
					break
				}
            if ( time == 0 ) {
                interv += 1
                if ( interv >= intervallData.count ) {
                    interv = 0
                    if ( !mainWindow.repeat ) mainWindow.running = false
                    else round++
                }
                time = intervallData.get(interv).time
            }

			updateDisplay()
		}

		function reset() {
			interv = 0
            round = 0
            time = intervallData.get(0).time
			updateDisplay()
		}

		function updateDisplay() {
			var minutes = Math.floor(time / 60)
			var seconds = time % 60
            mainWindow.display = ('00'+minutes).substr(-2) + ":" +
                    ('00'+seconds).substr(-2) // + "[" + (interv + 1)  + "]"
            mainWindow.rounddp = round //('00' + round).substr(-2)
		}
	} // Timer

    property string display: "00:00"
    property string rounddp: "0"

    Rectangle {
        id     : display
        width  : parent.width
        height : lblTimer.contentHeight

        Label {
            id               : lblTimer
            width            : parent.width
            rightPadding     : lblRound.width * 1.5
            height           : implicitHeight
            text             : mainWindow.display
            color            : "black"
            minimumPointSize : 10
            fontSizeMode     : Text.Fit
            font.weight      : Font.DemiBold
            font.pointSize   : 640
        } // Label Timer
        
        Label {
            id               : lblRound
            anchors.right    : parent.right
            width            : parent.width * .15
            height           : implicitHeight
            text             : mainWindow.rounddp
            color            : "dimgrey"
            anchors.baseline : lblTimer.baseline
            minimumPointSize : 10
            fontSizeMode     : Text.Fit
            font.weight      : Font.DemiBold
            font.pointSize   : 640
        } // Label Timer

        ListView {
            id                 : lvProgress
            orientation        : Qt.Horizontal
            anchors.bottom     : parent.bottom
            height             : parent.height * .05
            width              : parent.width
            model              : intervallData
            delegate           : Rectangle {
                height                : lvProgress.height
                width                 : (lvProgress.width / intervallData.roundTime) * time
                Rectangle             {
                    anchors.fill : parent
                    color        : "steelblue"
                    opacity      : index % 2 == 0 ? .5 : .7
                } // Rectangle Background
                Rectangle {
                    height                : parent.height
                    width                 : parent.width * progress
                    property real progress : {
                        if ( timer.interv === index )
                            return (time - timer.time) / time
                        if ( timer.interv >= index ) return 100
                        return 0
                    }
                    color        : "red"
                    opacity      : .4
                } // Rectangle Progress
            }
        } // Repeater Progress

        Button {
            id               : btnHideCntrls
            anchors.right    : parent.right
            anchors.top      : parent.top
            anchors.margins  : 4
            width            : 32
            height           : 32
            opacity          : .5
            checkable        : true
            checked          : false
            icon.source      : checked ? "qrc:/fullscreen_exit.svg" : "qrc:/fullscreen.svg"
            onClicked        : {
               if ( checked ) {
                   savedSettingsHeight = mainWindow.height - display.height
                   mainWindow.height = display.height
               } else {
                   mainWindow.height = display.height + savedSettingsHeight
               }
           }

        } // Buttont Hide Controls

    } // Rectangle Display

	Rectangle {
        id             : rectSettings
        visible        : !mainWindow.hideControls
        anchors.top    : display.bottom
		width          : parent.width
        anchors.bottom : parent.bottom

        Rectangle {
            anchors.fill   : parent
            color          : "steelblue"
            opacity        : .9
        } // Rectangle Background



        RowLayout {
            id                : layoutSettings
            anchors.top       : parent.top
            width             : parent.width
            height            : 42
            Rectangle { Layout.fillWidth: true }
            Image {
                source           : "qrc:/loop.svg"
                width            :  42
                height           :  42
            }
            Switch {
                id                    : swtchRepeat
                checked               : true
                Layout.preferredWidth : implicitWidth
            }
            Rectangle { Layout.fillWidth: true }
            Image {
                source           : "qrc:/volume.svg"
                width            :  42
                height           :  42
            }
            Switch {
                id                    : swtchCountdown
                Layout.preferredWidth : implicitWidth
                checked               : true
            }
            Rectangle { Layout.fillWidth: true }
        }

        ListModel {
            id : intervallData
            ListElement {
                time: 30
                tone: 2
            }
            onDataChanged: updateRoundTime()
            property int roundTime
            function updateRoundTime() {
                var time = 0
                for (var i = 0; i < intervallData.count; ++i) time += intervallData.get(i).time
                roundTime = time
                lvProgress.update()
            }
        } // ListModel Intervall data

        ListView {
            id                : listView
            anchors.top       : layoutSettings.bottom
            width             : parent.width
            anchors.bottom    : layoutButtons.top
            model             : intervallData
            delegate          : Rectangle {
                id       : rectDelegate
                width    : listView.width
                height   : 48
                property var idx: index
                property var tim: time
                property var ton: tone
                Rectangle {
                    anchors.fill : parent;
                    property bool active: mainWindow.running &&
                                          timer.interv === rectDelegate.idx
                    color   : active ? "slateblue" : "steelblue" // lightslategrey
                    opacity : active ? 1 : index % 2 == 0 ? 1 : .8
                }

                RowLayout {
                    anchors.fill : parent
                    spacing      : 4
                    Label {
                        Layout.leftMargin  : 8
                        Layout.rightMargin : 4
                        text              : qsTr("Intervall #%1").arg(rectDelegate.idx+1)
                    }
                    TextField {
                        Layout.preferredWidth : implicitWidth
                        placeholderText       : qsTr("Seconds")
                        text                  : rectDelegate.tim
                        validator             : IntValidator{bottom: 0; top: 999;}
                        onTextChanged         : {
                            var parsed = parseInt(text)
                            if ( parsed ) intervallData.get(rectDelegate.idx).time = parsed
    //						if ( !mainWindow.running ) timer.reset()
                        }
                    }
                    ComboBox {
                        Layout.preferredWidth : implicitWidth
                        model                 : [qsTr("None"), qsTr("Bing"), qsTr("Horn"), qsTr("Bing-Bong")]
                        currentIndex          : rectDelegate.ton
                        onCurrentIndexChanged : intervallData.get(rectDelegate.idx).tone = currentIndex
                    }
                    Rectangle {
                        Layout.fillWidth: true
                    }
                    Button {
                        Layout.preferredWidth : implicitWidth
                        Layout.rightMargin    : 8
                        icon.source           : "qrc:/delete.svg"
                        icon.width            : 24
                        icon.height           : 24
                        onClicked             : {
                            intervallData.remove(rectDelegate.idx)
                            intervallData.updateRoundTime()
                        }
                    } // Button Remove

                } // RowLayout
            } // delegate Rectangle
        } // ListView


        RoundButton {
            id              : btnAddRow
            anchors.bottom  : layoutButtons.top
            anchors.right   : parent.right
            anchors.margins : 16
            width           : 48
            height          : 48
            icon.source     : "qrc:/plus.svg"
            icon.height     : 36
            icon.width      : 36
            font.weight     : Font.Normal
            font.pointSize  : 32
            layer.enabled   : true
            layer.effect    : DropShadow {
                color            : "#FF555555"
                radius           : 6 // btnAddRow.down ? 6 : 10
                samples          : (radius * 2) + 1
                spread           : .0
                horizontalOffset : 0
                verticalOffset   : btnAddRow.down ? 2 : 4
            }
            onClicked            : {
                intervallData.append({"time": 90, "tone": 0})
                intervallData.updateRoundTime()
            }
        } // Button AddRow

        RowLayout {
            id             : layoutButtons
            anchors.bottom : parent.bottom
            width          : parent.width
            height         : implicitHeight

            Button {
                Layout.fillWidth : true
                text             : qsTr("Reset")
                onClicked        : timer.reset()
            }
            Button {
                Layout.fillWidth : true
                text             : mainWindow.running? qsTr("Stop") : qsTr("Start")
                onClicked        : mainWindow.running = !mainWindow.running
            }
        } // RowLayout
    } // Rectangle Setting

} // Window
