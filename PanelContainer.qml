import QtQuick 2.0

DropArea {
    id: panelContainer

    property var curPanel: null;
    property point curPosition;
    property var edgePosition;
    property string layout: "row";
    property var panels: [];

    property var edgeTop;
    property var edgeBottom;
    property var edgeLeft;
    property var edgeRight;

    property var highlightEdges;

    Component.onCompleted: {
        edgeTop = {ini: Qt.point(0, 0), end: Qt.point(width, height/3)};
        edgeBottom = {ini: Qt.point(0, height/3 * 2), end: Qt.point(width, height)};
        edgeLeft = {ini: Qt.point(0, 0), end: Qt.point(width/3, height)};
        edgeRight = {ini: Qt.point(width/3*2, 0), end: Qt.point(width, height)};

        highlightEdges = {};

        var component = Qt.createComponent("HighlightEdge.qml");
        highlightEdges["TOP"] = component.createObject(panelContainer, {"x": edgeTop.ini.x, "y": edgeTop.ini.y, "width": edgeTop.end.x - edgeTop.ini.x, "height": edgeTop.end.y - edgeTop.ini.y, z: 1000});
        highlightEdges["BOTTOM"] = component.createObject(panelContainer, {"x": edgeBottom.ini.x, "y": edgeBottom.ini.y, "width": edgeBottom.end.x - edgeBottom.ini.x, "height": edgeBottom.end.y - edgeBottom.ini.y, z: 1000});
        highlightEdges["LEFT"] = component.createObject(panelContainer, {"x": edgeLeft.ini.x, "y": edgeLeft.ini.y, "width": edgeLeft.end.x - edgeLeft.ini.x, "height": edgeLeft.end.y - edgeLeft.ini.y, z: 1000});
        highlightEdges["RIGHT"] = component.createObject(panelContainer, {"x": edgeRight.ini.x, "y": edgeRight.ini.y, "width": edgeRight.end.x - edgeRight.ini.x, "height": edgeRight.end.y - edgeRight.ini.y, z: 1000});

        calculatePositions();
    }

    function finishCreation(component, params) {
        if (component.status === Component.Ready) {
            var panel = component.createObject(panelContainer, params);
            if (panel === null) {
                // Error Handling
                console.log("Error creating object");
            }
        } else if (component.status === Component.Error) {
            // Error Handling
            console.log("Error loading component:", component.errorString());
        }
    }

    function calculatePositions() {

        if (!panels)return;

        var lastPanel = panels.length - 1;
        var sumWidth = 0;
        var sumHeight = 0;

        console.log("calculatePositions - begin")

        for (var i=0; i < panels.length; i++) {
            console.log("Creating panel: " + i)
            var component;

            if ( !panels[i].object )
            {
                component = Qt.createComponent("Panel.qml");
                if (component.status === Component.Ready) {
                    panels[i].object = component.createObject(panelContainer, {"name": panels[i].name});
                    if (panels[i].object) {
                        console.log("Object created: " + panels[i].object.name);
                    }
                    else {
                        console.log("Error creating object");
                    }
                }
                else {
                    console.log("Error creating component: " + component.errorString())
                }
            }

            if (panels[i].object) {

                var params = panels[i];
                var panel = panels[i].object;
                panel.index = i;

                if (i == 0)
                    panel.isFirst = true;
                else
                    panel.isFirst = false;

                panel.container = params["container"];
                panel.percentWidth = params["percentWidth"];
                panel.percentHeight = params["percentHeight"];

                if (panelContainer.layout === "row") {
                    panel.x = sumWidth;
                    panel.y = 0;
                    console.log("sumWidth: " + sumWidth)
                    panel.height = panel.container.height;
                    if (i === lastPanel) {
                        panel.isLast = true;
                        panel.width = panel.container.width - sumWidth;
                    }
                    else if (panel.percentWidth) {
                        panel.width = (panel.container.width * panel.percentWidth)/100;
                        sumWidth += panel.width;
                        panel.isLast = false;
                    }
                }
                else {
                    panel.y = sumHeight;
                    panel.x = 0;
                    panel.width = panel.container.width;
                    if (i == lastPanel) {
                        panel.height = panel.container.height - sumHeight;
                    }
                    else if (panel.percentHeight) {
                        panel.height = (panel.container.height * panel.percentHeight)/100;
                        sumHeight += panel.height;
                    }
                }

                if (!panels[i].innerObject && panels[i].qml) {
                    var innerComponent = Qt.createComponent(panels[i].qml);
                    if (innerComponent.status === Component.Ready) {
                        panels[i].innerObject = innerComponent.createObject(panels[i].object);
                        if (panels[i]) {
                            console.log("InnerObject created to: " + panels[i].object.name);
                        }
                        else {
                            console.log("Error creating innerObject");
                        }
                    }
                    else {
                        console.log("Error creating innerObject component: " + innerComponent.errorString())
                    }
                }

                panels[i].innerObject.x = panels[i].object.borderSize;
                panels[i].innerObject.y = panels[i].object.borderSize;
                panels[i].innerObject.width = panels[i].object.width - (panels[i].object.borderSize * 2);
                panels[i].innerObject.height = panels[i].object.height - (panels[i].object.borderSize * 2);

                panels[i].object.innerObject = panels[i].innerObject;
            }
        }
    }

    function adjustSidePanel(panel, side, moveX, moveY) {
        if (side === "prev") {
            var prevPanel = panels[panel.index - 1];

            if (prevPanel.object.width + moveX < prevPanel.object.minimumWidth)
                return false;

            if (prevPanel.object.height + moveY < prevPanel.object.minimumHeight)
                return false;

            prevPanel.object.width += moveX;
            prevPanel.object.height += moveY;

            prevPanel.innerObject.width = prevPanel.object.width - prevPanel.object.borderSize * 2;
            prevPanel.innerObject.height = prevPanel.object.height - prevPanel.object.borderSize * 2;

            console.log("Prev inner Object width: " + prevPanel.innerObject.width);

        }
        else if (side === "next"){
            var nextPanel = panels[panel.index + 1];

            if (nextPanel.object.width - moveX < nextPanel.object.minimumWidth)
                return false;

            if (nextPanel.object.height - moveY < nextPanel.object.minimumHeight)
                return false;

            nextPanel.object.x += moveX;
            nextPanel.object.y += moveY;
            nextPanel.object.width -= moveX;
            nextPanel.object.height -= moveY;

            nextPanel.innerObject.width = nextPanel.object.width - nextPanel.object.borderSize * 2;
            nextPanel.innerObject.height = nextPanel.object.height - nextPanel.object.borderSize * 2;

            console.log("Next Object width: " + nextPanel.object.width);
            console.log("Next borderSize: " + nextPanel.object.borderSize);
            console.log("Next Inner Object width: " + nextPanel.innerObject.width);

        }

        return true;
    }

    onWidthChanged: {
        calculatePositions();
    }

    onHeightChanged: {
        calculatePositions();
    }

    onDropped: {
        console.log("Dropped: " + curPanel.name)
        var position = edgePosition;
        console.log("Position: " + position.pos)

        if (position.pos === "TOP" || position.pos === "BOTTOM")
            layout = "column";
        if (position.pos === "LEFT" || position.pos === "RIGHT")
            layout = "row";

        var index = -1;
        var metaPanel;
        for (var i=0; i<panels.length; i++){
            console.log("Panel name at " + i + ": " + panels[i].name)
            console.log("Cur Panel: " + curPanel.name)
            if (panels[i].name === curPanel.name) {
                index = i;
                metaPanel = panels[i];
                break;
            }
        }

        console.log("Index at: " + index)

        if (position.pos === "TOP" || position.pos === "LEFT") {
            if (index > -1) {
                panels.splice(index, 1);
                panels.splice(0, 0, metaPanel);
            }
        }
        else {
            if (index > -1) {
                panels.splice(index, 1);
                panels.push(metaPanel);
            }
        }

        for (var key in highlightEdges) {
            highlightEdges[key].visible = false;
        }

        calculatePositions();
    }

    Rectangle {
        id: dropRectangle
        width: parent.width
        height: parent.height
        color: "#3188e3";
    }

}

