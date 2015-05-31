# QML Panels

## Overview

**Panels** create resizable/movable panels for Qt/QML application in a *easy and quick* way, just like QML.

### Tutorial

Import **Panel.qml**, **PanelContainer.qml** and **HighlightEdge.qml** into your project.

To create a new PanelContainer just add a block similar to this one into your qml file:

	PanelContainer {
 		id: mainContainer
        anchors.fill: parent
        layout: "row"
        movable: true

        panelsMetaData: [
                    { id: "panel1", container: mainContainer, qml: "qrc:/MyPanel1.qml", name: "Panel 1", percentWidth: 70, percentHeight: 50 },
                    { id: "panel2", container: mainContainer, qml: "qrc:/MyPanel2.qml", name: "Panel 2", percentWidth: 30, percentHeight: 50 }
        ]
    }

**PanelContainer** is the main class, where all the panels should be inside.

**layout:** Indicates the layout flow to use, options are: *row* or *column*
It may change when you move a panel to a different position

**movable:** Indicates wether the user can move a panel to a different position or not. (default to **true**)

**panelsMetadata:** Array containing all the metadata regarding the panels inside the panelContainer, the properties will be explained below.

**id:** The id of the panel

**qml:** The qml file to load inside the Panel

**name:** A name to identify the panel object

*percentWidth:* The default percentage of width to use when in *row* layout

**percentHeight:** The default percentage of height to use when in *column* layout

You also can change panel properties through the meta data parameters.
i.e.: 

	{ id: "panel", container: mainContainer, qml: "qrc:/MyPanel1.qml", name: "panel", percentWidth: 80, percentHeight: 70, color: "blue" }


