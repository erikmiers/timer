import QtQuick 2.15
import QtQuick.Window 2.12
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

	property bool running     : false
	property alias repeat      : swtchRepeat.checked
	property alias countdown   : swtchCountdown.checked
	property string datastore : ""

	Settings {
		id: settings
		property alias x         : mainWindow.x
		property alias y         : mainWindow.y
		property alias width     : mainWindow.width
		property alias height    : mainWindow.height
		property alias repeat    : mainWindow.repeat
		property alias countdown : mainWindow.countdown
		property alias datastore : mainWindow.datastore
	} // Settings

	Component.onCompleted: {
		if ( datastore ) {
			modelData.clear()
			var datamodel = JSON.parse(datastore)
			for ( var i = 0; i < datamodel.length; ++i) modelData.append(datamodel[i])
		}
	}

	onClosing: {
		var datamodel = []
		for (var i = 0; i < modelData.count; ++i) datamodel.push(modelData.get(i))
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

		Component.onCompleted: reset()

		running     : mainWindow.running
		interval    : 1000
		repeat      : true
		onTriggered : {
			time -= 1
			if ( time < 0 ) {
				interv += 1
				if ( interv >= modelData.count ) {
					interv = 0
					if ( !mainWindow.repeat ) mainWindow.running = false
				}
				time = modelData.get(interv).time
			}
			if ( mainWindow.countdown && time <= 3 ) ssTap.play()
			if ( time == 0 && modelData.get(interv).tone !== 0 )
				switch ( modelData.get(interv).tone ) {
				case 1: ssBing.play()
					break
				case 2: ssHorn.play()
					break
				case 3: ssBingBong.play()
					break
				}

			updateDisplay()
		}

		function reset() {
			interv = 0
			time = modelData.get(0).time
			updateDisplay()
		}

		function updateDisplay() {
			var minutes = Math.floor(time / 60)
			var seconds = time % 60
			display = ('00'+minutes).substr(-2) + ":" +
					('00'+seconds).substr(-2) + "[" + (interv + 1)  + "]"
		}
	} // Timer

	property string display: "00:00 [1]"

	Label {
		id               : lblTimer
		width            : parent.width
		height           : implicitHeight
		text             : mainWindow.display
		color            : "black"
		minimumPointSize : 10
		fontSizeMode     : Text.Fit
		font.weight      : Font.DemiBold
		font.pointSize   : 640
	} // Label

	Rectangle {
		anchors.top    : layoutSettings.top
		width          : parent.width
		anchors.bottom : parent.bottom
		color          : "steelblue"
		opacity        : .9
	}

	RowLayout {
		id                : layoutSettings
		anchors.top       : parent.top
		anchors.topMargin : lblTimer.contentHeight
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
		id : modelData
		ListElement {
			time: 30
			tone: 2
		}
	}

	ListView {
		id                : listView
		anchors.top       : layoutSettings.bottom
		width             : parent.width
		anchors.bottom    : layoutButtons.top
		model             : modelData
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
						if ( parsed ) modelData.get(rectDelegate.idx).time = parsed
//						if ( !mainWindow.running ) timer.reset()
					}
				}
				ComboBox {
					Layout.preferredWidth : implicitWidth
					model                 : [qsTr("None"), qsTr("Bing"), qsTr("Horn"), qsTr("Bing-Bong")]
					currentIndex          : rectDelegate.ton
					onCurrentIndexChanged : modelData.get(rectDelegate.idx).tone = currentIndex
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
					onClicked             : modelData.remove(rectDelegate.idx)
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
		onClicked: modelData.append({"time": 90, "tone": 0})
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
} // Window
