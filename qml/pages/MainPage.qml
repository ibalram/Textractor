import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.textractor.settingsmanager 1.0

Page {

    id: mainPage
    property bool cropReady: false;
    property bool selectReady: false;
    property bool idle: true;

    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        contentHeight: childrenRect.height

        PullDownMenu {
            id: menu
            enabled: idle

            MenuItem {
                text: "About"
                onClicked: {
                    pageStack.push("About.qml");
                }
            }

            MenuItem {
                text: qsTr("Usage Hints");
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("HintsPage.qml"))
                }
            }

            MenuItem {
                text: "Settings"
                onClicked: {
                    pageStack.push("Settings.qml");
                }
            }

        }

        Column {
            id: headerContainer
            width: parent.width

            PageHeader {
                title: qsTr("Textractor")
            }
        }

        SectionHeader {
            id: generalsection
            text: qsTr("OCR Language")
            font.pixelSize: Theme.fontSizeMedium
            anchors.top: headerContainer.bottom
            height: 50;
        }

        ValueButton {
            id: lang
            label: "Language"
            anchors.top: generalsection.bottom
            value: tesseractAPI.settings.getLanguage();
            enabled: idle

            onClicked: {
                var dialog = pageStack.push("LanguageDialog.qml")

                dialog.accepted.connect(function() {
                    value = tesseractAPI.settings.getLanguage();
                })
            }
        }


        BackgroundItem {
            id: button1
            anchors.top: lang.bottom
            anchors.topMargin: 25;
            anchors.left: parent.left
            width: parent.width - 4 * Theme.paddingMedium
            anchors.leftMargin: 2 * Theme.paddingMedium
            height: 200
            z: -1
            enabled: idle

            Image {
                anchors.fill: parent
                fillMode: Image.Pad
                horizontalAlignment: Image.AlignHCenter
                verticalAlignment: Image.AlignVCenter
                source: "image://theme/graphics-cover-camera"
                z: 30
            }

            Label {
                anchors.topMargin: 10;
                anchors.top: parent.top
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: "Take a picture"
            }

            onClicked: {
                pageStack.push("CameraPage.qml")
            }
        }

        BackgroundItem {
            id: button2
            anchors.top: button1.bottom
            anchors.left: parent.left
            anchors.topMargin: 25;
            width: parent.width - 4 * Theme.paddingMedium
            anchors.leftMargin: 2 * Theme.paddingMedium
            height: 200
            z: -1
            enabled: idle

            Image {
                anchors.fill: parent
                fillMode: Image.Pad
                horizontalAlignment: Image.AlignHCenter
                verticalAlignment: Image.AlignVCenter
                source: "image://theme/icon-l-image"
                z: 30
            }

            Label {
                anchors.topMargin: 10;
                anchors.top: parent.top
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: "Select an image from the gallery"
            }

            BusyIndicator {
                id: busyind
                anchors.centerIn: parent
                size: BusyIndicatorSize.Large
                running: cropReady || selectReady;
                z: 99
            }

            onClicked: {

                idle = false;
                var imagePicker = pageStack.push("Sailfish.Pickers.ImagePickerPage");

                imagePicker.selectedContentChanged.connect(function() {
                    selectReady = true;
                    tesseractAPI.prepareForCropping(String(imagePicker.selectedContent).replace("file://", ""), 0, true);
                });

                imagePicker.onStatusChanged.connect(function() {
                    if (imagePicker.status === PageStatus.Deactivating) {
                        if (imagePicker._navigation === PageNavigation.Back) {
                            idle = true;
                        }
                    }
                });

            }

        }

        BackgroundItem {
            id: button3
            anchors.top: button2.bottom
            anchors.left: parent.left
            anchors.topMargin: 25;
            width: parent.width - 4 * Theme.paddingMedium
            anchors.leftMargin: 2 * Theme.paddingMedium
            height: 200
            z: -1
            enabled: idle

            Image {
                anchors.fill: parent
                fillMode: Image.Pad
                horizontalAlignment: Image.AlignHCenter
                verticalAlignment: Image.AlignVCenter
                source: "image://theme/icon-l-document"
                z: 30
            }

            Label {
                anchors.topMargin: 10;
                anchors.top: parent.top
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: "Extract text from PDF file"
            }

            onClicked: {

                var dialog = pageStack.push("FilePickerDialog.qml")

                dialog.accepted.connect(function() {
                    console.log(dialog.selectedFile);
                })

            }

        }

        Rectangle {
            anchors.fill: button1
            radius: 10;
            color: Theme.rgba(Theme.highlightBackgroundColor, 0.3)
        }

        Rectangle {
            anchors.fill: button2
            radius: 10;
            color: Theme.rgba(Theme.highlightBackgroundColor, 0.3)
        }

        Rectangle {
            anchors.fill: button3
            radius: 10;
            color: Theme.rgba(Theme.highlightBackgroundColor, 0.3)
        }

    }

    onStatusChanged: {

        if (status === PageStatus.Active && selectReady) {
            selectReady = false;

            var dialog = pageStack.push(Qt.resolvedUrl("CroppingPage.qml"), { loading: true });

            dialog.accepted.connect(function() {
                cropReady = true;
            });

            dialog.onStatusChanged.connect(function() {
                if (dialog.status === PageStatus.Deactivating) {
                    if (dialog._navigation === PageNavigation.Back) {
                        idle = true;
                    }
                }
            });

        }

        if (status === PageStatus.Active && cropReady) {
            cropReady = false;
            idle = true;
            pageStack.push(Qt.resolvedUrl("ResultsPage.qml"), { loading: true });
        }
    }

    Connections {
        target: tesseractAPI

        onFirstUse: {
            var dialog = pageStack.push("LanguageDialog.qml", {firstuse: true});
            dialog.accepted.connect(function() {
                lang.value = tesseractAPI.settings.getLanguage();
            });
        }
    }
}
