import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.settings 1.0
import QtGraphicalEffects 1.15


Window {
	id      : mainWindow
	width   : 640
	height  : 480
	visible : true
	title   : qsTr("Timer")

	property bool running: false

	Settings {
		id: settings
		property alias x      : mainWindow.x
		property alias y      : mainWindow.y
		property alias width  : mainWindow.width
		property alias height : mainWindow.height
	} // Settings

	Component.onDestruction: {
//		settings.state = page.state
	}

	Label {
		id               : lblTimer
		width            : parent.width
		height           : implicitHeight
		text             : "00:00:00 [1]"
		color            : black;
		minimumPointSize : 10
		fontSizeMode     : Text.Fit
		font.weight      : Font.DemiBold
		font.pointSize   : 640
	} // Label

	ListModel {
		id : modelData
		ListElement {
			time: 30
			tone: 2
		}
	}

	ListView {
		id             : listView
		anchors.top    : lblTimer.bottom
		width          : parent.width
		anchors.bottom : layoutButtons.top
		model          : modelData
		delegate       : Rectangle {
			id     : rectDelegate
			width  : parent.width
			height : 48
			RowLayout {
				anchors.fill: parent
				Label {
					text: qsTr("Intervall %1").arg(rectDelegate.index)
				}
				TextField {
					placeholderText : qsTr("Seconds")
					inputMask       : "999"
					validator       : IntValidator{bottom: 0; top: 999;}
				}

			}
		}

	} // ListView


	RoundButton {
		id              : btnAddRow
		anchors.bottom  : layoutButtons.top
		anchors.right   : parent.right
		anchors.margins : 16
		width           : 48
		height          : 48
		text            : "+"
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
		onClicked: {

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
		}
		Button {
			Layout.fillWidth : true
			text             : mainWindow.running? qsTr("Stop") : qsTr("Start")
			onClicked        : mainWindow.running = !mainWindow.running
		}
	} // RowLayout
} // Window
