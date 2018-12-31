﻿/*
*  Copyright 2018  Michail Vourlakos <mvourlakos@gmail.com>
*
*  This file is part of Latte-Dock
*
*  Latte-Dock is free software; you can redistribute it and/or
*  modify it under the terms of the GNU General Public License as
*  published by the Free Software Foundation; either version 2 of
*  the License, or (at your option) any later version.
*
*  Latte-Dock is distributed in the hope that it will be useful,
*  but WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*  GNU General Public License for more details.
*
*  You should have received a copy of the GNU General Public License
*  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import QtQuick.Dialogs 1.2

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.plasmoid 2.0

import QtQuick.Controls.Styles.Plasma 2.0 as Styles

import org.kde.latte 0.2 as Latte

import "../../controls" as LatteExtraControls

PlasmaComponents.Page {
    Layout.maximumWidth: content.width + content.Layout.leftMargin * 2
    Layout.maximumHeight: content.height + units.smallSpacing * 2

    ColumnLayout {
        id: content

        width: (dialog.appliedWidth - units.smallSpacing * 2) - Layout.leftMargin * 2
        spacing: dialog.subGroupSpacing
        anchors.horizontalCenter: parent.horizontalCenter
        Layout.leftMargin: units.smallSpacing * 2

        //! BEGIN: Shadows
        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: units.smallSpacing
            spacing: units.smallSpacing

            LatteExtraControls.HeaderSwitch {
                id: showAppletShadow
                Layout.fillWidth: true
                Layout.minimumHeight: implicitHeight
                Layout.rightMargin: units.smallSpacing * 2

                checked: plasmoid.configuration.shadows !== Latte.Types.NoneShadow
                text: i18n("Shadows")
                tooltip: i18n("Enable/disable applet shadows")

                onPressed: {
                    if(plasmoid.configuration.shadows !== Latte.Types.AllAppletsShadow){
                        plasmoid.configuration.shadows = Latte.Types.AllAppletsShadow;
                    } else {
                        plasmoid.configuration.shadows = Latte.Types.NoneShadow;
                    }
                }
            }

            ColumnLayout {
                Layout.leftMargin: units.smallSpacing * 2
                Layout.rightMargin: units.smallSpacing * 2

                RowLayout{
                    enabled: showAppletShadow.checked

                    PlasmaComponents.Label {
                        enabled: showAppletShadow.checked
                        text: i18n("Size")
                        horizontalAlignment: Text.AlignLeft
                    }

                    LatteExtraControls.Slider {
                        id: shadowSizeSlider
                        Layout.fillWidth: true
                        enabled: showAppletShadow.checked

                        value: plasmoid.configuration.shadowSize
                        from: 0
                        to: 100
                        stepSize: 5
                        wheelEnabled: false

                        function updateShadowSize() {
                            if (!pressed)
                                plasmoid.configuration.shadowSize = value;
                        }

                        onPressedChanged: {
                            updateShadowSize();
                        }

                        Component.onCompleted: {
                            valueChanged.connect(updateShadowSize);
                        }

                        Component.onDestruction: {
                            valueChanged.disconnect(updateShadowSize);
                        }
                    }

                    PlasmaComponents.Label {
                        enabled: showAppletShadow.checked
                        text: shadowSizeSlider.value + " %"
                        horizontalAlignment: Text.AlignRight
                        Layout.minimumWidth: theme.mSize(theme.defaultFont).width * 4
                        Layout.maximumWidth: theme.mSize(theme.defaultFont).width * 4
                    }
                }


                RowLayout{
                    enabled: showAppletShadow.checked

                    PlasmaComponents.Label {
                        enabled: showAppletShadow.checked
                        text: i18n("Opacity")
                        horizontalAlignment: Text.AlignLeft
                    }

                    LatteExtraControls.Slider {
                        id: shadowOpacitySlider
                        Layout.fillWidth: true

                        value: plasmoid.configuration.shadowOpacity
                        from: 0
                        to: 100
                        stepSize: 5
                        wheelEnabled: false

                        function updateShadowOpacity() {
                            if (!pressed)
                                plasmoid.configuration.shadowOpacity = value;
                        }

                        onPressedChanged: {
                            updateShadowOpacity();
                        }

                        Component.onCompleted: {
                            valueChanged.connect(updateShadowOpacity);
                        }

                        Component.onDestruction: {
                            valueChanged.disconnect(updateShadowOpacity);
                        }
                    }

                    PlasmaComponents.Label {
                        enabled: showAppletShadow.checked
                        text: shadowOpacitySlider.value + " %"
                        horizontalAlignment: Text.AlignRight
                        Layout.minimumWidth: theme.mSize(theme.defaultFont).width * 4
                        Layout.maximumWidth: theme.mSize(theme.defaultFont).width * 4
                    }
                }
            }

            RowLayout {
                id: shadowColorRow
                Layout.fillWidth: true
                Layout.leftMargin: units.smallSpacing * 2
                Layout.rightMargin: units.smallSpacing * 2
                spacing: 2
                enabled: showAppletShadow.checked

                PlasmaComponents.Label {
                    text: i18n("Color")

                    Layout.rightMargin: units.smallSpacing
                }

                readonly property string defaultShadow: "080808"
                readonly property string themeShadow: {
                    var strC = String(theme.textColor);

                    return strC.indexOf("#") === 0 ? strC.substr(1) : strC;
                }

                ExclusiveGroup {
                    id: shadowColorGroup

                    property bool inStartup: true

                    onCurrentChanged: {
                        if (inStartup) {
                            return;
                        }

                        if (current === defaultShadowBtn) {
                            plasmoid.configuration.shadowColorType = Latte.Types.DefaultColorShadow;
                        } else if (current === themeShadowBtn) {
                            plasmoid.configuration.shadowColorType = Latte.Types.ThemeColorShadow;
                        } else if (current === userShadowBtn) {
                            plasmoid.configuration.shadowColorType = Latte.Types.UserColorShadow;
                        }
                    }

                    Component.onCompleted: inStartup = false;
                }

                PlasmaComponents.Button {
                    id: defaultShadowBtn
                    Layout.fillWidth: true

                    text: i18nc("default shadow", "Default")
                    checked: plasmoid.configuration.shadowColorType === Latte.Types.DefaultColorShadow
                    checkable: true
                    exclusiveGroup: shadowColorGroup
                    tooltip: i18n("Default shadow for applets")
                }

                PlasmaComponents.Button {
                    id: themeShadowBtn
                    Layout.fillWidth: true

                    text: i18nc("theme shadow", "Theme")
                    checked: plasmoid.configuration.shadowColorType === Latte.Types.ThemeColorShadow
                    checkable: true
                    exclusiveGroup: shadowColorGroup
                    tooltip: i18n("Shadow from theme color pallete")
                }

                //overlayed button
                PlasmaComponents.Button {
                    id: userShadowBtn
                    Layout.fillWidth: true
                    height: parent.height
                    text: " "

                    checkable: true
                    checked: plasmoid.configuration.shadowColorType === Latte.Types.UserColorShadow
                    tooltip: i18n("Use set shadow color")
                    exclusiveGroup: shadowColorGroup

                    Rectangle{
                        anchors.fill: parent
                        anchors.margins: 1.5*units.smallSpacing

                        color: "#" + plasmoid.configuration.shadowColor;

                        opacity: shadowColorRow.enabled ? 1 : 0.6

                        Rectangle{
                            anchors.fill: parent
                            color: "transparent"
                            border.width: 1
                            border.color: theme.textColor
                            opacity: parent.opacity - 0.4
                        }

                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                shadowColorGroup.current = userShadowBtn;
                                viewConfig.setSticker(true);
                                colorDialogLoader.showDialog = true;
                            }
                        }
                    }

                    Loader{
                        id:colorDialogLoader
                        property bool showDialog: false
                        active: showDialog

                        sourceComponent: ColorDialog {
                            title: i18n("Please choose shadow color")
                            showAlphaChannel: false

                            onAccepted: {
                                //console.log("You chose: " + String(color));
                                var strC = String(color);
                                if (strC.indexOf("#") === 0) {
                                    plasmoid.configuration.shadowColor = strC.substr(1);
                                }

                                colorDialogLoader.showDialog = false;
                                viewConfig.setSticker(false);
                            }
                            onRejected: {
                                colorDialogLoader.showDialog = false;
                                viewConfig.setSticker(false);
                            }
                            Component.onCompleted: {
                                color = String("#" + plasmoid.configuration.shadowColor);
                                visible = true;
                            }
                        }
                    }
                }
            }
        }
        //! END: Shadows

        //! BEGIN: Active Indicator
        ColumnLayout{
            spacing: units.smallSpacing
            Layout.rightMargin: units.smallSpacing * 2

            LatteExtraControls.Header {
                text: i18n("Indicators")
            }

            GridLayout {
                Layout.fillWidth: true
                Layout.leftMargin: units.smallSpacing * 2
                rowSpacing: units.smallSpacing * 2
                columnSpacing: 2

                columns: 5

                property int indicatorType: plasmoid.configuration.activeIndicatorType
                property int activeIndicator: plasmoid.configuration.activeIndicator

                ExclusiveGroup {
                    id: activeIndicatorTypeGroup
                    onCurrentChanged: {
                        if (current.checked)
                            plasmoid.configuration.activeIndicatorType = current.indicatorType;
                    }
                }

                ExclusiveGroup {
                    id: activeIndicatorGroup
                    onCurrentChanged: {
                        if (current.checked)
                            plasmoid.configuration.activeIndicator = current.activeIndicator
                    }
                }

                PlasmaComponents.Label {
                    text: i18nc("active indicator style","Active") + " "
                    horizontalAlignment: Text.AlignLeft
                    visible: dialog.highLevel
                }

                PlasmaComponents.Button {
                    Layout.fillWidth: true

                    text: i18nc("line indicator","Line")
                    checked: parent.indicatorType === indicatorType
                    checkable: true
                    exclusiveGroup: activeIndicatorTypeGroup
                    tooltip: i18n("Show a line indicator for active tasks/applets")

                    readonly property int indicatorType: Latte.Types.LineIndicator
                }

                PlasmaComponents.Button {
                    Layout.fillWidth: true

                    text: i18nc("dot indicator", "Dot")
                    checked: parent.indicatorType === indicatorType
                    checkable: true
                    exclusiveGroup: activeIndicatorTypeGroup
                    tooltip: i18n("Show a dot indicator for active tasks/applets")

                    readonly property int indicatorType: Latte.Types.DotIndicator
                }

                PlasmaComponents.Label{
                    text:"  |  "
                }

                PlasmaComponents.Button {
                    Layout.fillWidth: true

                    text: i18nc("reverse the position of the active indicator e.g. from bottom to top", "Reverse")
                    checked: plasmoid.configuration.reverseLinesPosition
                    checkable: true
                    tooltip: i18n("Reverse the position of the active indicator e.g. from bottom to top")

                    onClicked: {
                        plasmoid.configuration.reverseLinesPosition = checked;
                    }
                }

                PlasmaComponents.Label {
                    text: i18n("Applets") + " "
                    horizontalAlignment: Text.AlignLeft
                    //visible: dialog.expertLevel
                    visible: false
                }

                PlasmaComponents.Button {
                    Layout.fillWidth: true

                    text: i18nc("active indicator to no applets", "None")
                    checked: parent.activeIndicator === activeIndicator
                    checkable: true
                    exclusiveGroup: activeIndicatorGroup
                    //visible: dialog.expertLevel
                    visible: false

                    tooltip: i18n("Latte will not show any active applet indicator on its own except those the plasma theme provides")

                    readonly property int activeIndicator: Latte.Types.NoneIndicator
                }
                PlasmaComponents.Button {
                    Layout.columnSpan: 2
                    Layout.fillWidth: true

                    text: i18nc("active indicator only to in-house latte applets", "Internals")
                    checked: parent.activeIndicator === activeIndicator
                    checkable: true
                    exclusiveGroup: activeIndicatorGroup
                    //visible: dialog.expertLevel
                    visible: false

                    tooltip: i18n("Latte will show active applet indicators only for applets that have been adjusted by it for hovering capabilities e.g. folderview")

                    readonly property int activeIndicator: Latte.Types.InternalsIndicator
                }

                PlasmaComponents.Button {
                    Layout.fillWidth: true

                    text: i18nc("active indicator to all applets", "All")
                    checked: parent.activeIndicator === activeIndicator
                    checkable: true
                    exclusiveGroup: activeIndicatorGroup
                    //visible: dialog.expertLevel
                    visible: false

                    tooltip: i18n("Latte will show active applet indicators for all applets")

                    readonly property int activeIndicator: Latte.Types.AllIndicator
                }

                PlasmaComponents.Label {
                    text: i18n("Glow") + " "
                    horizontalAlignment: Text.AlignLeft
                    visible: dialog.expertLevel
                    enabled: plasmoid.configuration.glowOption!==Latte.Types.GlowNone
                }

                property int option: plasmoid.configuration.glowOption

                ExclusiveGroup {
                    id: glowGroup
                    onCurrentChanged: {
                        if (current.checked)
                            plasmoid.configuration.glowOption = current.option
                    }
                }

                PlasmaComponents.Button {
                    Layout.fillWidth: true
                    text: i18nc("none glow", "None")
                    checked: parent.option === option
                    checkable: true
                    exclusiveGroup:  glowGroup
                    tooltip: i18n("Do not show any glow for task/applet indicators")

                    readonly property int option: Latte.Types.GlowNone
                }

                PlasmaComponents.Button {
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    text: i18nc("glow only to active task/applet indicators","Only On Active")
                    checked: parent.option === option
                    checkable: true
                    exclusiveGroup:  glowGroup
                    tooltip: i18n("Add glow only to active task/applet indicator")

                    readonly property int option: Latte.Types.GlowOnlyOnActive
                }

                PlasmaComponents.Button {
                    Layout.fillWidth: true
                    text: i18nc("glow to all task/applet indicators","All")
                    checked: parent.option === option
                    checkable: true
                    exclusiveGroup: glowGroup
                    tooltip: i18n("Add glow to all task/applet indicators")

                    readonly property int option: Latte.Types.GlowAll
                }

                ColumnLayout{
                    Layout.columnSpan: 5
                    enabled: plasmoid.configuration.glowOption!==Latte.Types.GlowNone

                    RowLayout {
                        PlasmaComponents.Label {
                            text: i18n("Glow Opacity")
                            horizontalAlignment: Text.AlignLeft
                        }

                        LatteExtraControls.Slider {
                            id: glowOpacitySlider
                            Layout.fillWidth: true

                            value: plasmoid.configuration.glowOpacity
                            from: 0
                            to: 100
                            stepSize: 5
                            wheelEnabled: false

                            function updateGlowOpacity() {
                                if (!pressed)
                                    plasmoid.configuration.glowOpacity = value;
                            }

                            onPressedChanged: {
                                updateGlowOpacity();
                            }

                            Component.onCompleted: {
                                valueChanged.connect(updateGlowOpacity);
                            }

                            Component.onDestruction: {
                                valueChanged.disconnect(updateGlowOpacity);
                            }
                        }

                        PlasmaComponents.Label {
                            text: glowOpacitySlider.value + " %"
                            horizontalAlignment: Text.AlignRight
                            Layout.minimumWidth: theme.mSize(theme.defaultFont).width * 4
                            Layout.maximumWidth: theme.mSize(theme.defaultFont).width * 4
                        }
                    }

                    PlasmaComponents.CheckBox {
                        id: showGlow3D
                        text: i18n("Use a 3D style glow")
                        checked: plasmoid.configuration.glow3D
                        visible: false

                        onClicked: {
                            plasmoid.configuration.glow3D = checked;
                        }
                    }
                }
            }
        }
        //! END: Active Indicator

        //! BEGIN: Animations
        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: units.smallSpacing
            spacing: units.smallSpacing

            LatteExtraControls.Header {
                text: i18n("Animations")
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: units.smallSpacing * 2
                Layout.rightMargin: units.smallSpacing * 2
                spacing: 2

                property int duration: plasmoid.configuration.durationTime

                ExclusiveGroup {
                    id: animationsGroup
                    onCurrentChanged: {
                        if (current.checked)
                            plasmoid.configuration.durationTime = current.duration
                    }
                }

                PlasmaComponents.Button {
                    Layout.fillWidth: true
                    text: i18n("Instant")
                    checked: parent.duration === duration
                    checkable: true
                    exclusiveGroup: animationsGroup

                    readonly property int duration: 0
                }
                PlasmaComponents.Button {
                    Layout.fillWidth: true
                    text: i18n("x1")
                    checked: parent.duration === duration
                    checkable: true
                    exclusiveGroup: animationsGroup

                    readonly property int duration: 1
                }
                PlasmaComponents.Button {
                    Layout.fillWidth: true
                    text: i18n("x2")
                    checked: parent.duration === duration
                    checkable: true
                    exclusiveGroup: animationsGroup

                    readonly property int duration: 2
                }
                PlasmaComponents.Button {
                    Layout.fillWidth: true
                    text: i18n("x3")
                    checked: parent.duration === duration
                    checkable: true
                    exclusiveGroup: animationsGroup

                    readonly property int duration: 3
                }
            }
        }
        //! END: Animations
    }
}