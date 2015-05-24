import QtQuick 2.0

Item {
    id: root
    property string name
    width: 300
    height: 300
    property var mPos: null
    property int borderSize: 2
    property int moveAreaSize: 10
    property int originalX
    property int originalY

    property int minimumWidth: 200
    property int minimumHeight: 200
    property var container: null    

    property int percentWidth;
    property int percentHeight;

    property int index: -1;
    property bool isFirst: index === 0;
    property bool isLast: false;

    property var innerObject: null;
    property alias color: panel.color

    Rectangle {
        anchors.fill: parent
        id: panel

        color: "#ffcc00"

        x: parent.borderSize
        y: parent.borderSize
        width: parent.width - (parent.borderSize * 2)
        height: parent.height - (parent.borderSize * 2)

        MouseArea {
            id: mouseMoveArea
            x: borderSize
            y: borderSize

            width: parent.width - moveAreaSize
            height: moveAreaSize
            drag.target: (container.movable)?root:null

            function percentInRect(thisPanel, rect) {

                console.assert(thisPanel.end && thisPanel.ini && rect.ini && rect.end);

                if (thisPanel.end.x < rect.ini.x || thisPanel.end.y < rect.ini.y || thisPanel.ini.x > rect.end.x || thisPanel.ini.y > rect.end.y)
                    return 0;

                var thisWidth = thisPanel.end.x - thisPanel.ini.x;
                var thisHeight = thisPanel.end.y - thisPanel.ini.y;

                var distX = 0;
                if (thisPanel.ini.x > rect.ini.x && thisPanel.end.x < rect.end.x)
                    distX = thisWidth;
                if (thisPanel.ini.x > rect.ini.x)
                    distX = rect.end.x - thisPanel.ini.x;
                else if (thisPanel.end.x < rect.end.x)
                    distX = thisPanel.end.x - rect.ini.x;

                var percX = distX / thisWidth * 100;

                var distY = 0;
                if (thisPanel.ini.y > rect.ini.y && thisPanel.end.y < rect.end.y)
                    distX = thisHeight;
                if (thisPanel.ini.y > rect.ini.y)
                    distX = rect.end.y - thisPanel.ini.y;
                else if (thisPanel.end.y < rect.end.y)
                    distX = thisPanel.end.y - rect.ini.y;

                return distX + distY;

            }

            function whichPosition(panel, parent) {

                var percents = {};
                var thisPanel = {ini: Qt.point(root.x, root.y), end: Qt.point(root.x + root.width, root.y + root.height)};

                console.log("whichPosition -> thisPanel: " + thisPanel.end)
                console.log("whichPosition -> thisPanel: " + container.edgeTop.end)

                percents["TOP"] = percentInRect(thisPanel, container.edgeTop);
                percents["BOTTOM"] = percentInRect(thisPanel, container.edgeBottom);
                percents["LEFT"] = percentInRect(thisPanel, container.edgeLeft);
                percents["RIGHT"] = percentInRect(thisPanel, container.edgeRight);

                console.log("Percent in top: " + percents.TOP);
                console.log("Percent in bottom: " + percents.BOTTOM);
                console.log("Percent in left: " + percents.LEFT);
                console.log("Percent in right: " + percents.RIGHT);

                var percentMax = { val: null, pos: null, rect: null};
                for (var property in percents) {
                    if (!percentMax.val || percentMax.val < percents[property]) {
                        percentMax.pos = property;
                        percentMax.val = percents[property];

                        if (property === "TOP")
                            percentMax.rect = top;
                        else if (property === "BOTTOM")
                            percentMax.rect = bottom;
                        else if (property === "LEFT")
                            percentMax.rect = left;
                        else if (property === "RIGHT")
                            percentMax.rect = right;
                    }
                }

                if (percentMax.val)
                    return {pos: percentMax.pos, rect: percentMax.rect};
                else
                    return null;
            }

            onPositionChanged: {
                if (!container.movable) return;

                container.curPosition = Qt.point(root.x, root.y);
                var position = whichPosition(root, container);

                for (var property in container.highlightEdges) {
                    container.highlightEdges[property].visible = false;
                }

                if (position)
                    container.highlightEdges[position.pos].visible = true;

                console.log("POSITION: " + position);
            }

            onReleased: {
                console.log("panel Released")
                container.curPanel = root
                container.curPosition = Qt.point(root.x, root.y);
                container.edgePosition = whichPosition(root, container)
                moveArea.Drag.drop()
            }

            Rectangle {
                id: moveArea
                anchors.fill: parent

                color: "lightgrey"

                Drag.active: mouseMoveArea.drag.active

            }

        }

        MouseArea {
            id: leftBorderMouseArea

            anchors.left: parent.left
            width: root.borderSize
            height: parent.height
            cursorShape: "SizeHorCursor"

            onPressed: {
                if ((container.layout === "row" && isFirst) || container.layout === "column")
                {
                    console.log("left - Set originalX to 0, isFirst: " + isFirst + ", isLast: " + isLast)
                    originalX = 0;
                }
                else
                {
                    console.log("Set originalX to mouseX")
                    originalX = mouseX;
                }
            }

            onMouseXChanged: {
                if (!originalX) return;

                var xMove = (mouseX - originalX);
                if (root.width - xMove > minimumWidth && container.adjustSidePanel(root, "prev", xMove, 0)) {
                    root.x += xMove;
                    root.width -= xMove;
                    innerObject.width = root.width - (borderSize * 2);
                }
            }
        }

        MouseArea {
            id: rightBorderMouseArea

            anchors.right: parent.right
            width: root.borderSize
            height: parent.height
            cursorShape: "SizeHorCursor"

            onPressed: {
                if ((container.layout === "row" && isLast) || container.layout === "column")
                {
                    originalX = 0;
                    console.log("right - Set originalX to 0, isFirst: " + isFirst + ", isLast: " + isLast)
                }
                else
                {
                    originalX = mouseX;
                    console.log("Set originalX to mouseX")
                }
            }

            onMouseXChanged: {
                if (!originalX) return;

                var xMove = (mouseX - originalX);
                console.log("XMOVE: " + xMove);
                if (root.width + xMove > minimumWidth && container.adjustSidePanel(root, "next", xMove, 0)) {
                    root.width += xMove;
                    innerObject.width = root.width - (borderSize * 2);
                }
            }
        }

        MouseArea {
            id: topBorderMouseArea

            anchors.top: parent.top
            width: parent.width
            height: root.borderSize
            cursorShape: "SizeVerCursor"

            onPressed: {
                if ((container.layout === "column" && isFirst) || container.layout === "row")
                    originalY = 0;
                else
                    originalY = mouseY;
            }

            onMouseXChanged: {
                if (!originalY)
                    return;

                var yMove = (mouseY - originalY);
                if (root.height - yMove > minimumHeight && container.adjustSidePanel(root, "prev", 0, yMove)) {
                    root.y += yMove;
                    root.height -= yMove;

                    innerObject.height = root.height - (borderSize * 2);
                }
            }
        }

        MouseArea {
            id: bottomBorderMouseArea

            anchors.bottom: parent.bottom
            width: parent.width
            height: root.borderSize
            cursorShape: "SizeVerCursor"

            onPressed: {
                if ((container.layout === "column" && root.isLast) || container.layout === "row")
                    originalY = 0;
                else
                    originalY = mouseY;
            }

            onMouseXChanged: {
                if (!originalY) return;

                var yMove = (mouseY - originalY);
                if (root.height + yMove > minimumHeight && container.adjustSidePanel(root, "next", 0, yMove)) {
                    root.height += yMove;
                    innerObject.height = root.height - (borderSize * 2);
                }
            }
        }

    }

}
