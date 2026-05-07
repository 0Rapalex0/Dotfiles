import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

ShellRoot {

    QtObject {
        id: colors
        readonly property string bg:      "#1a1b26"
        readonly property string bg2:     "#16161e"
        readonly property string surface: "#2f3549"
        readonly property string overlay: "#414868"
        readonly property string subtext: "#a9b1d6"
        readonly property string blue:    "#7aa2f7"
        readonly property string mauve:   "#bb9af7"
        readonly property string pink:    "#f7768e"
        readonly property string green:   "#9ece6a"
        readonly property string yellow:  "#e0af68"
        readonly property string peach:   "#ff9e64"
        readonly property string red:     "#f7768e"
        readonly property string text:    "#c0caf5"
    }

    property string cpuVal: "0"
    property string ramVal: "0"
    property string volVal: "50"
    property string brightVal: "80"
    property string weatherVal: "?"
    property string musicTitle: ""
    property string musicStatus: "Stopped"
    property string netVal: "󰤨"
    property bool calendarVisible: false
    property bool musicVisible: false
    property bool sysVisible: false
    property bool dashVisible: false
    property bool btVisible: false
    property bool volVisible: false
    property bool brightVisible: false
    property string btDevice: ""
    property string btBattery: ""
    property string weatherFull: ""
    property string weatherHours: ""
    property string musicArtist: ""
    property string musicAlbum: ""
    property string musicPos: "0"
    property string musicLen: "1"
    property string cpuTemp: "?"
    property string ramUsed: "0"
    property string ramTotal: "1"
    property string diskVal: "0"
    property var notifications: []

    Process { id: cpuProc; command: ["bash", "-c", "top -bn1 | grep 'Cpu' | awk '{print int($2)}'"]
        stdout: SplitParser { onRead: (l) => cpuVal = l.trim() } }
    Process { id: ramProc; command: ["bash", "-c", "free -m | awk '/Mem:/{printf \"%.0f\", $3/$2*100}'"]
        stdout: SplitParser { onRead: (l) => ramVal = l.trim() } }
    Process { id: volProc; command: ["bash", "-c", "pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | tr -d '%'"]
        stdout: SplitParser { onRead: (l) => volVal = l.trim() } }
    Process { id: brightProc; command: ["bash", "-c", "brightnessctl -m | awk -F, '{print $4}' | tr -d '%'"]
        stdout: SplitParser { onRead: (l) => brightVal = l.trim() } }
    Process { id: weatherProc; command: ["bash", "-c", "curl -s 'wttr.in/Puebla?format=%c+%t' 2>/dev/null | tr -d '+' || echo '?'"]
        stdout: SplitParser { onRead: (l) => weatherVal = l.trim() } }
    Process { id: musicTitleProc; command: ["bash", "-c", "playerctl metadata title 2>/dev/null | head -c 16 || echo ''"]
        stdout: SplitParser { onRead: (l) => musicTitle = l.trim() } }
    Process { id: musicStatusProc; command: ["bash", "-c", "playerctl status 2>/dev/null || echo 'Stopped'"]
        stdout: SplitParser { onRead: (l) => musicStatus = l.trim() } }
    Process { id: musicArtistProc; command: ["bash", "-c", "playerctl metadata artist 2>/dev/null || echo ''"]
        stdout: SplitParser { onRead: (l) => musicArtist = l.trim() } }
    Process { id: musicPosProc; command: ["bash", "-c", "playerctl metadata --format '{{position}}' 2>/dev/null || echo '0'"]
        stdout: SplitParser { onRead: (l) => musicPos = l.trim() } }
    Process { id: musicLenProc; command: ["bash", "-c", "playerctl metadata mpris:length 2>/dev/null || echo '1'"]
        stdout: SplitParser { onRead: (l) => musicLen = l.trim() === "" ? "1" : l.trim() } }
    Process { id: cpuTempProc; command: ["bash", "-c", "cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null | awk '{printf \"%.0f\", $1/1000}' || echo '?'"]
        stdout: SplitParser { onRead: (l) => cpuTemp = l.trim() } }
    Process { id: ramDetailProc; command: ["bash", "-c", "free -m | awk '/Mem:/{print $3\" \"$2}'"]
        stdout: SplitParser { onRead: (l) => { var p = l.trim().split(" "); ramUsed = p[0] || "0"; ramTotal = p[1] || "1" } } }
    Process { id: diskProc; command: ["bash", "-c", "df -h / | awk 'NR==2{print $5}' | tr -d '%'"]
        stdout: SplitParser { onRead: (l) => diskVal = l.trim() } }
    Process { id: netProc; command: ["bash", "-c", "ping -c1 -W1 8.8.8.8 &>/dev/null && echo '󰤨' || echo '󰤭'"]
        stdout: SplitParser { onRead: (l) => netVal = l.trim() } }
    Process { id: btDeviceProc; command: ["bash", "-c", "bluetoothctl info 2>/dev/null | grep -E 'Name|Battery' | awk -F': ' '{print $2}' | tr '\n' '|' || echo ''"]
        stdout: SplitParser { onRead: (l) => { var p = l.trim().split("|"); btDevice = p[0] || ""; btBattery = p[1] || "" } } }
    Process { id: weatherFullProc; command: ["bash", "-c", "curl -s 'wttr.in/Puebla?format=%C|%t|%h|%w|%p' 2>/dev/null || echo '?'"]
        stdout: SplitParser { onRead: (l) => weatherFull = l.trim() } }
    Process { id: weatherHoursProc; command: ["bash", "-c", "curl -s 'wttr.in/Puebla?format=%H:%M+%t+%C' 2>/dev/null || echo ''"]
        stdout: SplitParser { onRead: (l) => weatherHours = l.trim() } }

    Timer { interval: 5000; running: true; repeat: true
        onTriggered: { cpuProc.running = true; ramProc.running = true; cpuTempProc.running = true; ramDetailProc.running = true; diskProc.running = true } }
    Timer { interval: 2000; running: true; repeat: true
        onTriggered: { musicTitleProc.running = true; musicStatusProc.running = true; volProc.running = true; musicArtistProc.running = true; musicPosProc.running = true; musicLenProc.running = true } }
    Timer { interval: 900000; running: true; repeat: true
        onTriggered: weatherProc.running = true }
    Timer { interval: 30000; running: true; repeat: true
        onTriggered: { netProc.running = true; brightProc.running = true; btDeviceProc.running = true } }
    Timer { interval: 600000; running: true; repeat: true
        onTriggered: { weatherFullProc.running = true; weatherHoursProc.running = true } }

    Component.onCompleted: {
        cpuProc.running = true; ramProc.running = true
        volProc.running = true; brightProc.running = true
        weatherProc.running = true; musicTitleProc.running = true
        musicStatusProc.running = true; netProc.running = true
        musicArtistProc.running = true; musicPosProc.running = true
        musicLenProc.running = true; cpuTempProc.running = true
        ramDetailProc.running = true; diskProc.running = true
        btDeviceProc.running = true; weatherFullProc.running = true
        weatherHoursProc.running = true
    }

    // ══════════════════════════════════════
    //  MÚSICA POPUP
    // ══════════════════════════════════════
    PanelWindow {
        id: musicWindow
        anchors.left: true
        anchors.top: true
        implicitWidth: musicVisible ? 390 : 0
        implicitHeight: 200
        exclusiveZone: -1
        color: "transparent"
        visible: musicVisible
        Behavior on implicitWidth { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 6
            anchors.leftMargin: 84
            anchors.rightMargin: 6
            color: colors.bg
            radius: 16
            border.color: Qt.rgba(154/255, 206/255, 106/255, 0.3)
            border.width: 1
            clip: true

            RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 14

                // Portada (placeholder con inicial del artista)
                Rectangle {
                    width: 80; height: 80
                    radius: 12
                    color: colors.surface
                    border.color: Qt.rgba(154/255, 206/255, 106/255, 0.4)
                    border.width: 1
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        anchors.centerIn: parent
                        text: musicArtist.length > 0 ? musicArtist[0].toUpperCase() : "♪"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 32
                        font.bold: true
                        color: colors.green
                    }

                    // Animación de pulso cuando está reproduciendo
                    Rectangle {
                        anchors.fill: parent
                        radius: parent.radius
                        color: "transparent"
                        border.color: colors.green
                        border.width: 2
                        opacity: musicStatus === "Playing" ? 0.6 : 0
                        Behavior on opacity { NumberAnimation { duration: 400 } }
                        SequentialAnimation on scale {
                            running: musicStatus === "Playing"
                            loops: Animation.Infinite
                            NumberAnimation { to: 1.05; duration: 800; easing.type: Easing.InOutSine }
                            NumberAnimation { to: 1.0;  duration: 800; easing.type: Easing.InOutSine }
                        }
                    }
                }

                // Info y controles
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 6

                    // Título
                    Text {
                        Layout.fillWidth: true
                        text: musicTitle !== "" ? musicTitle : "Sin reproducción"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 13
                        font.bold: true
                        color: colors.text
                        elide: Text.ElideRight
                    }

                    // Artista
                    Text {
                        Layout.fillWidth: true
                        text: musicArtist !== "" ? musicArtist : ""
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
                        color: colors.subtext
                        elide: Text.ElideRight
                    }

                    // Barra de progreso
                    Item {
                        Layout.fillWidth: true
                        height: 6

                        Rectangle {
                            anchors.fill: parent
                            radius: 3
                            color: colors.surface
                        }
                        Rectangle {
                            width: {
                                var pos = parseFloat(musicPos) || 0
                                var len = parseFloat(musicLen) || 1
                                return Math.min(1.0, pos / len) * parent.width
                            }
                            height: parent.height
                            radius: 3
                            color: colors.green
                            Behavior on width { NumberAnimation { duration: 500 } }
                        }
                    }

                    // Controles
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 20

                        Repeater {
                            model: [
                                { icon: "󰒮", cmd: "playerctl previous", col: colors.subtext },
                                { icon: musicStatus === "Playing" ? "󰏤" : "󰐊", cmd: "playerctl play-pause", col: colors.green },
                                { icon: "󰒭", cmd: "playerctl next", col: colors.subtext }
                            ]
                            Text {
                                text: modelData.icon
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: modelData.cmd.includes("play-pause") ? 22 : 17
                                color: modelData.col
                                Behavior on scale { NumberAnimation { duration: 100 } }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    onEntered: parent.scale = 1.2
                                    onExited:  parent.scale = 1.0
                                    onClicked: {
                                        var p = Qt.createQmlObject('import Quickshell.Io; Process {}', root)
                                        p.command = ["bash", "-c", modelData.cmd]
                                        p.running = true
                                        Qt.callLater(() => { musicStatusProc.running = true; musicPosProc.running = true })
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ══════════════════════════════════════
    //  SISTEMA POPUP (CPU / RAM / DISCO)
    // ══════════════════════════════════════
    PanelWindow {
        id: sysWindow
        anchors.left: true
        anchors.top: true
        implicitWidth: sysVisible ? 390 : 0
        implicitHeight: 230
        exclusiveZone: -1
        color: "transparent"
        visible: sysVisible
        Behavior on implicitWidth { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 6
            anchors.leftMargin: 84
            anchors.rightMargin: 6
            color: colors.bg
            radius: 16
            border.color: Qt.rgba(255/255, 158/255, 100/255, 0.3)
            border.width: 1
            clip: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                Text {
                    text: "  Sistema"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 13
                    font.bold: true
                    color: colors.peach
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: Qt.rgba(255/255,158/255,100/255,0.2) }

                // Fila CPU
                RowLayout {
                    Layout.fillWidth: true; spacing: 10
                    Text { text: "󰻠  CPU"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11; color: colors.peach; Layout.preferredWidth: 60 }
                    Rectangle {
                        Layout.fillWidth: true; height: 8; radius: 4; color: colors.surface
                        Rectangle {
                            width: Math.min(1.0, (parseFloat(cpuVal)||0)/100) * parent.width
                            height: parent.height; radius: 4
                            color: parseFloat(cpuVal) > 80 ? colors.red : parseFloat(cpuVal) > 50 ? colors.yellow : colors.peach
                            Behavior on width { NumberAnimation { duration: 600 } }
                        }
                    }
                    Text { text: cpuVal + "%"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11; color: colors.subtext; Layout.preferredWidth: 36 }
                }

                // Temp CPU
                RowLayout {
                    Layout.fillWidth: true; spacing: 10
                    Text { text: "󰔏  Temp"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11; color: colors.yellow; Layout.preferredWidth: 60 }
                    Rectangle {
                        Layout.fillWidth: true; height: 8; radius: 4; color: colors.surface
                        Rectangle {
                            width: Math.min(1.0, (parseFloat(cpuTemp)||0)/100) * parent.width
                            height: parent.height; radius: 4
                            color: parseFloat(cpuTemp) > 80 ? colors.red : parseFloat(cpuTemp) > 60 ? colors.yellow : colors.green
                            Behavior on width { NumberAnimation { duration: 600 } }
                        }
                    }
                    Text { text: cpuTemp + "°"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11; color: colors.subtext; Layout.preferredWidth: 36 }
                }

                // RAM
                RowLayout {
                    Layout.fillWidth: true; spacing: 10
                    Text { text: "󰍛  RAM"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11; color: colors.green; Layout.preferredWidth: 60 }
                    Rectangle {
                        Layout.fillWidth: true; height: 8; radius: 4; color: colors.surface
                        Rectangle {
                            width: Math.min(1.0, (parseFloat(ramUsed)||0)/(parseFloat(ramTotal)||1)) * parent.width
                            height: parent.height; radius: 4
                            color: parseFloat(ramVal) > 80 ? colors.red : parseFloat(ramVal) > 60 ? colors.yellow : colors.green
                            Behavior on width { NumberAnimation { duration: 600 } }
                        }
                    }
                    Text { text: ramUsed + "M"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11; color: colors.subtext; Layout.preferredWidth: 36 }
                }

                // Disco
                RowLayout {
                    Layout.fillWidth: true; spacing: 10
                    Text { text: "󰋊  Disco"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11; color: colors.blue; Layout.preferredWidth: 60 }
                    Rectangle {
                        Layout.fillWidth: true; height: 8; radius: 4; color: colors.surface
                        Rectangle {
                            width: Math.min(1.0, (parseFloat(diskVal)||0)/100) * parent.width
                            height: parent.height; radius: 4
                            color: parseFloat(diskVal) > 85 ? colors.red : parseFloat(diskVal) > 60 ? colors.yellow : colors.blue
                            Behavior on width { NumberAnimation { duration: 600 } }
                        }
                    }
                    Text { text: diskVal + "%"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11; color: colors.subtext; Layout.preferredWidth: 36 }
                }

                Item { Layout.fillHeight: true }
            }
        }
    }

    // ══════════════════════════════════════
    //  NOTIFICACIONES FLOTANTES
    // ══════════════════════════════════════
    PanelWindow {
        id: notifWindow
        anchors.right: true
        anchors.top: true
        implicitWidth: 320
        implicitHeight: notifColumn.height + 12
        exclusiveZone: -1
        color: "transparent"
        visible: notifications.length > 0

        Column {
            id: notifColumn
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 6
            spacing: 6
            width: 308

            Repeater {
                model: notifications
                delegate: Rectangle {
                    width: 308
                    height: notifContent.implicitHeight + 20
                    radius: 12
                    color: colors.bg
                    border.color: Qt.rgba(122/255, 162/255, 247/255, 0.35)
                    border.width: 1

                    // Acento lateral
                    Rectangle {
                        width: 3; height: parent.height - 12
                        anchors.left: parent.left; anchors.leftMargin: 0
                        anchors.verticalCenter: parent.verticalCenter
                        radius: 2
                        color: colors.blue
                    }

                    ColumnLayout {
                        id: notifContent
                        anchors.left: parent.left; anchors.right: parent.right
                        anchors.top: parent.top; anchors.margins: 10
                        anchors.leftMargin: 14
                        spacing: 3

                        Text {
                            text: modelData.summary || "Notificación"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 12; font.bold: true
                            color: colors.text
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                        Text {
                            text: modelData.body || ""
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 10
                            color: colors.subtext
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            visible: text !== ""
                        }
                    }

                    // Cerrar
                    Text {
                        anchors.right: parent.right; anchors.top: parent.top
                        anchors.margins: 8
                        text: "✕"; font.pixelSize: 10; color: colors.overlay
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                var arr = notifications.slice()
                                arr.splice(index, 1)
                                notifications = arr
                            }
                        }
                    }

                    // Auto-dismiss en 5 segundos
                    Timer {
                        interval: 5000; running: true; repeat: false
                        onTriggered: {
                            var arr = notifications.slice()
                            var idx = notifications.indexOf(modelData)
                            if (idx >= 0) { arr.splice(idx, 1); notifications = arr }
                        }
                    }

                    // Animación de entrada
                    opacity: 0
                    Component.onCompleted: opacity = 1
                    Behavior on opacity { NumberAnimation { duration: 250 } }
                }
            }
        }
    }

    // ══════════════════════════════════════
    //  DASHBOARD CENTRAL (reloj grande + clima + forecast)
    // ══════════════════════════════════════
    PanelWindow {
        id: dashWindow
        anchors.left: true
        anchors.top: true
        implicitWidth: dashVisible ? 850 : 0
        implicitHeight: 480
        exclusiveZone: -1
        color: "transparent"
        visible: dashVisible
        Behavior on implicitWidth { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 6
            anchors.leftMargin: 84
            anchors.rightMargin: 6
            color: Qt.rgba(26/255, 27/255, 38/255, 0.96)
            radius: 20
            border.color: Qt.rgba(187/255, 154/255, 247/255, 0.2)
            border.width: 1
            clip: true

            RowLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20

                // ── Columna izquierda: calendario mini ──
                ColumnLayout {
                    Layout.preferredWidth: 180
                    Layout.fillHeight: true
                    spacing: 10

                    Text {
                        text: {
                            var m = ["ENE","FEB","MAR","ABR","MAY","JUN","JUL","AGO","SEP","OCT","NOV","DIC"]
                            return m[new Date().getMonth()] + "  " + new Date().getFullYear()
                        }
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
                        font.bold: true
                        color: colors.mauve
                        font.letterSpacing: 2
                    }

                    // Mini grid calendario
                    GridLayout {
                        id: miniCal
                        columns: 7
                        columnSpacing: 2
                        rowSpacing: 2
                        Layout.fillWidth: true

                        property int dm: new Date().getMonth()
                        property int dy: new Date().getFullYear()
                        property int today: new Date().getDate()
                        property int firstDay: { var d = new Date(dy, dm, 1).getDay(); return d === 0 ? 6 : d - 1 }
                        property int daysInMonth: new Date(dy, dm + 1, 0).getDate()

                        Repeater {
                            model: ["L","M","X","J","V","S","D"]
                            Text { text: modelData; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 9
                                color: colors.overlay; width: 22; horizontalAlignment: Text.AlignHCenter }
                        }
                        Repeater {
                            model: 35
                            delegate: Rectangle {
                                width: 22; height: 20; radius: 4
                                property int day: index - miniCal.firstDay + 1
                                property bool valid: day >= 1 && day <= miniCal.daysInMonth
                                property bool isToday: valid && day === miniCal.today
                                color: isToday ? colors.mauve : "transparent"
                                Text {
                                    anchors.centerIn: parent
                                    text: parent.valid ? parent.day.toString() : ""
                                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 9
                                    font.bold: parent.isToday
                                    color: parent.isToday ? colors.bg :
                                           (index % 7) >= 5 && parent.valid ? colors.pink : colors.subtext
                                }
                            }
                        }
                    }

                    Rectangle { Layout.fillWidth: true; height: 1; color: Qt.rgba(255,255,255,0.06) }

                    // Uptime / info extra
                    Column { spacing: 4; Layout.fillWidth: true
                        Text { text: "󰍛  RAM  " + ramUsed + " / " + ramTotal + " MB"
                            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 9; color: colors.subtext }
                        Text { text: "󰻠  CPU  " + cpuVal + "%   " + cpuTemp + "°C"
                            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 9; color: colors.subtext }
                        Text { text: "󰋊  Disco  " + diskVal + "%"
                            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 9; color: colors.subtext }
                    }

                    Item { Layout.fillHeight: true }
                }

                Rectangle { width: 1; Layout.fillHeight: true; color: Qt.rgba(255,255,255,0.06) }

                // ── Columna central: reloj grande ──
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 0

                    Item { Layout.fillHeight: true }

                    // Reloj estilo "23:40 :07"
                    Row {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 0
                        Text {
                            id: dashHour
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 72
                            font.bold: true
                            color: colors.text
                            Component.onCompleted: text = new Date().getHours().toString().padStart(2,'0')
                            Timer { interval: 1000; running: true; repeat: true
                                onTriggered: dashHour.text = new Date().getHours().toString().padStart(2,'0') }
                        }
                        Text {
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 72; font.bold: true; color: colors.mauve
                            text: ":"
                        }
                        Text {
                            id: dashMin
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 72; font.bold: true; color: colors.text
                            Component.onCompleted: text = new Date().getMinutes().toString().padStart(2,'0')
                            Timer { interval: 1000; running: true; repeat: true
                                onTriggered: dashMin.text = new Date().getMinutes().toString().padStart(2,'0') }
                        }
                        Column {
                            anchors.bottom: parent.bottom; anchors.bottomMargin: 14
                            Text {
                                id: dashSec
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 20; color: colors.overlay
                                Component.onCompleted: text = ":" + new Date().getSeconds().toString().padStart(2,'0')
                                Timer { interval: 1000; running: true; repeat: true
                                    onTriggered: dashSec.text = ":" + new Date().getSeconds().toString().padStart(2,'0') }
                            }
                        }
                    }

                    // Fecha
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: {
                            var days = ["Domingo","Lunes","Martes","Miércoles","Jueves","Viernes","Sábado"]
                            var months = ["Enero","Febrero","Marzo","Abril","Mayo","Junio",
                                         "Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre"]
                            var d = new Date()
                            return days[d.getDay()] + ", " + d.getDate() + " de " + months[d.getMonth()]
                        }
                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 13; color: colors.subtext
                    }

                    Item { Layout.preferredHeight: 20 }

                    // Música mini (si hay)
                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        visible: musicTitle !== ""
                        width: 260; height: 44; radius: 12
                        color: colors.surface
                        border.color: Qt.rgba(154/255,206/255,106/255,0.3); border.width: 1

                        RowLayout {
                            anchors.fill: parent; anchors.margins: 10; spacing: 10
                            Rectangle {
                                width: 26; height: 26; radius: 6; color: colors.overlay
                                Text { anchors.centerIn: parent; text: musicArtist.length > 0 ? musicArtist[0].toUpperCase() : "♪"
                                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 14; color: colors.green }
                            }
                            Column {
                                Layout.fillWidth: true; spacing: 1
                                Text { text: musicTitle; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10
                                    font.bold: true; color: colors.text; elide: Text.ElideRight; width: parent.width }
                                Text { text: musicArtist; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 9
                                    color: colors.subtext; elide: Text.ElideRight; width: parent.width }
                            }
                            Text {
                                text: musicStatus === "Playing" ? "󰏤" : "󰐊"
                                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 16; color: colors.green
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: { var p = Qt.createQmlObject('import Quickshell.Io; Process {}', root)
                                        p.command = ["playerctl", "play-pause"]; p.running = true } }
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }
                }

                Rectangle { width: 1; Layout.fillHeight: true; color: Qt.rgba(255,255,255,0.06) }

                // ── Columna derecha: clima ──
                ColumnLayout {
                    Layout.preferredWidth: 160
                    Layout.fillHeight: true
                    spacing: 8

                    // Temperatura grande
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: {
                            var parts = weatherFull.split("|")
                            return (parts[1] || weatherVal.split(" ")[1] || "?").replace("°C","") + "°"
                        }
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 52; font.bold: true
                        color: colors.yellow
                    }

                    // Descripción
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.fillWidth: true
                        text: weatherFull.split("|")[0] || "Cargando..."
                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10
                        color: colors.subtext; wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Rectangle { Layout.fillWidth: true; height: 1; color: Qt.rgba(255,255,255,0.06) }

                    // Stats: humedad, viento, lluvia
                    Grid {
                        columns: 2; spacing: 6; Layout.fillWidth: true
                        Repeater {
                            model: [
                                { icon: "󰖝", label: "Viento",   val: weatherFull.split("|")[3] || "-" },
                                { icon: "󰖎", label: "Humedad",  val: weatherFull.split("|")[2] || "-" },
                                { icon: "󰼦", label: "Lluvia",   val: weatherFull.split("|")[4] || "-" },
                                { icon: "󰸗", label: "Temp",     val: (weatherFull.split("|")[1] || "?") }
                            ]
                            Column {
                                spacing: 1; width: 72
                                Text { text: modelData.icon; font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 14; color: colors.blue; anchors.horizontalCenter: parent.horizontalCenter }
                                Text { text: modelData.val; font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 9; color: colors.text; anchors.horizontalCenter: parent.horizontalCenter }
                                Text { text: modelData.label; font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 8; color: colors.overlay; anchors.horizontalCenter: parent.horizontalCenter }
                            }
                        }
                    }

                    Rectangle { Layout.fillWidth: true; height: 1; color: Qt.rgba(255,255,255,0.06) }

                    // Forecast próximas horas (simulado con offsets de temp)
                    Text {
                        text: "Próximas horas"
                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 9
                        color: colors.overlay; font.bold: true
                    }

                    Row {
                        spacing: 6; Layout.fillWidth: true
                        Repeater {
                            model: [
                                { h: "+1h", icon: "󰖙", t: "" },
                                { h: "+3h", icon: "󰖐", t: "" },
                                { h: "+6h", icon: "󰖔", t: "" },
                            ]
                            Column {
                                spacing: 2; width: 44
                                Text { text: modelData.h; font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 8; color: colors.overlay; anchors.horizontalCenter: parent.horizontalCenter }
                                Text { text: modelData.icon; font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 16; color: colors.yellow; anchors.horizontalCenter: parent.horizontalCenter }
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }

                    // Botón cerrar
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "✕  Cerrar"; font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 10; color: colors.overlay
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: dashVisible = false }
                    }
                }
            }
        }
    }

    // ══════════════════════════════════════
    //  BLUETOOTH POPUP
    // ══════════════════════════════════════
    PanelWindow {
        id: btWindow
        anchors.left: true
        anchors.top: true
        implicitWidth: btVisible ? 390 : 0
        implicitHeight: 300
        exclusiveZone: -1
        color: "transparent"
        visible: btVisible
        Behavior on implicitWidth { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 6
            anchors.leftMargin: 84
            anchors.rightMargin: 6
            color: colors.bg
            radius: 16
            border.color: Qt.rgba(122/255, 162/255, 247/255, 0.3)
            border.width: 1
            clip: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 14

                // Header
                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "󰂯  Bluetooth"; font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 13; font.bold: true; color: colors.blue }
                    Item { Layout.fillWidth: true }
                    // Refresh
                    Text { text: "󰑐"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 14; color: colors.overlay
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: btDeviceProc.running = true } }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: Qt.rgba(122/255,162/255,247/255,0.15) }

                // Dispositivo conectado
                Rectangle {
                    Layout.fillWidth: true; height: 80; radius: 12
                    color: colors.surface
                    border.color: btDevice !== "" ? Qt.rgba(122/255,162/255,247/255,0.4) : Qt.rgba(255,255,255,0.05)
                    border.width: 1
                    visible: btDevice !== ""

                    RowLayout {
                        anchors.fill: parent; anchors.margins: 14; spacing: 14

                        // Icono dispositivo (audífonos)
                        Rectangle {
                            width: 52; height: 52; radius: 26; color: colors.overlay
                            Text { anchors.centerIn: parent; text: "󰋋"
                                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 26; color: colors.blue }
                            // Anillo animado conectado
                            Rectangle {
                                anchors.fill: parent; radius: parent.radius; color: "transparent"
                                border.color: colors.blue; border.width: 2; opacity: 0.5
                                SequentialAnimation on opacity {
                                    running: btDevice !== ""; loops: Animation.Infinite
                                    NumberAnimation { to: 0.8; duration: 1200 }
                                    NumberAnimation { to: 0.2; duration: 1200 }
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true; spacing: 4
                            Text { text: btDevice; font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 12; font.bold: true; color: colors.text; elide: Text.ElideRight; Layout.fillWidth: true }
                            Text { text: "Conectado"; font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 10; color: colors.green }
                        }

                        // Batería
                        Column {
                            spacing: 2; visible: btBattery !== ""
                            Text { anchors.horizontalCenter: parent.horizontalCenter; text: "󰁹"
                                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 16
                                color: parseFloat(btBattery) > 50 ? colors.green : parseFloat(btBattery) > 20 ? colors.yellow : colors.red }
                            Text { anchors.horizontalCenter: parent.horizontalCenter; text: btBattery + "%"
                                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 9; color: colors.subtext }
                        }
                    }
                }

                // Sin dispositivo
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Sin dispositivos conectados"
                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11; color: colors.overlay
                    visible: btDevice === ""
                }

                Item { Layout.fillHeight: true }

                // Toggles WiFi / BT
                RowLayout {
                    Layout.fillWidth: true; spacing: 10

                    Rectangle {
                        Layout.fillWidth: true; height: 38; radius: 10
                        color: netVal === "󰤨" ? Qt.rgba(122/255,162/255,247/255,0.2) : colors.surface
                        border.color: netVal === "󰤨" ? colors.blue : colors.overlay; border.width: 1
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: { var p = Qt.createQmlObject('import Quickshell.Io; Process {}', root)
                                p.command = ["bash", "-c", "nmcli radio wifi toggle"]; p.running = true
                                Qt.callLater(() => netProc.running = true) }
                        }
                        Row { anchors.centerIn: parent; spacing: 6
                            Text { text: "󰤨"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 14
                                color: netVal === "󰤨" ? colors.blue : colors.overlay }
                            Text { text: "Wi-Fi"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
                                color: netVal === "󰤨" ? colors.blue : colors.overlay }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true; height: 38; radius: 10
                        color: btDevice !== "" ? Qt.rgba(187/255,154/255,247/255,0.2) : colors.surface
                        border.color: btDevice !== "" ? colors.mauve : colors.overlay; border.width: 1
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: { var p = Qt.createQmlObject('import Quickshell.Io; Process {}', root)
                                p.command = ["bash", "-c", "bluetoothctl power toggle"]; p.running = true
                                Qt.callLater(() => btDeviceProc.running = true) }
                        }
                        Row { anchors.centerIn: parent; spacing: 6
                            Text { text: "󰂯"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 14
                                color: btDevice !== "" ? colors.mauve : colors.overlay }
                            Text { text: "Bluetooth"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
                                color: btDevice !== "" ? colors.mauve : colors.overlay }
                        }
                    }
                }
            }
        }
    }

    // ══════════════════════════════════════
    //  VOLUMEN POPUP
    // ══════════════════════════════════════
    PanelWindow {
        id: volWindow
        anchors.left: true
        anchors.top: true
        implicitWidth: volVisible ? 340 : 0
        implicitHeight: 160
        exclusiveZone: -1
        color: "transparent"
        visible: volVisible
        Behavior on implicitWidth { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 6
            anchors.leftMargin: 84
            anchors.rightMargin: 6
            color: colors.bg
            radius: 16
            border.color: Qt.rgba(122/255, 162/255, 247/255, 0.3)
            border.width: 1
            clip: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 14

                // Header
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: parseInt(volVal) === 0 ? "󰖁" : parseInt(volVal) < 50 ? "󰕿" : "󰕾"
                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 22
                        color: colors.blue
                    }
                    Text {
                        text: "Volumen"
                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 13
                        font.bold: true; color: colors.text
                        Layout.fillWidth: true; leftPadding: 6
                    }
                    Text {
                        text: volVal + "%"
                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 20
                        font.bold: true; color: colors.blue
                    }
                }

                // Slider volumen
                Item {
                    Layout.fillWidth: true
                    height: 36

                    // Track fondo
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width; height: 8; radius: 4
                        color: colors.surface
                    }
                    // Track relleno
                    Rectangle {
                        id: volFill
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        width: Math.max(8, (parseFloat(volVal) / 100) * parent.width)
                        height: 8; radius: 4
                        color: colors.blue
                        Behavior on width { NumberAnimation { duration: 150 } }
                    }
                    // Thumb
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        x: Math.min(parent.width - 16, Math.max(0, (parseFloat(volVal) / 100) * parent.width - 8))
                        width: 16; height: 16; radius: 8
                        color: colors.text
                        border.color: colors.blue; border.width: 2
                        Behavior on x { NumberAnimation { duration: 150 } }
                    }
                    // MouseArea para drag
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: (mouse) => {
                            var pct = Math.round(Math.max(0, Math.min(100, (mouse.x / width) * 100)))
                            var p = Qt.createQmlObject('import Quickshell.Io; Process {}', root)
                            p.command = ["pactl", "set-sink-volume", "@DEFAULT_SINK@", pct + "%"]
                            p.running = true
                            Qt.callLater(() => volProc.running = true)
                        }
                        onWheel: (wheel) => {
                            var p = Qt.createQmlObject('import Quickshell.Io; Process {}', root)
                            p.command = ["pactl", "set-sink-volume", "@DEFAULT_SINK@",
                                         wheel.angleDelta.y > 0 ? "+5%" : "-5%"]
                            p.running = true
                            Qt.callLater(() => volProc.running = true)
                        }
                    }
                }

                // Botones rápidos
                RowLayout {
                    Layout.fillWidth: true; spacing: 8
                    Repeater {
                        model: [
                            { label: "0%",   val: 0   },
                            { label: "25%",  val: 25  },
                            { label: "50%",  val: 50  },
                            { label: "75%",  val: 75  },
                            { label: "100%", val: 100 }
                        ]
                        Rectangle {
                            Layout.fillWidth: true; height: 26; radius: 6
                            color: Math.abs(parseFloat(volVal) - modelData.val) < 6 ? Qt.rgba(122/255,162/255,247/255,0.25) : colors.surface
                            border.color: Math.abs(parseFloat(volVal) - modelData.val) < 6 ? colors.blue : "transparent"
                            border.width: 1
                            Text {
                                anchors.centerIn: parent; text: modelData.label
                                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 9
                                color: Math.abs(parseFloat(volVal) - modelData.val) < 6 ? colors.blue : colors.subtext
                            }
                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    var p = Qt.createQmlObject('import Quickshell.Io; Process {}', root)
                                    p.command = ["pactl", "set-sink-volume", "@DEFAULT_SINK@", modelData.val + "%"]
                                    p.running = true
                                    Qt.callLater(() => volProc.running = true)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ══════════════════════════════════════
    //  BRILLO POPUP
    // ══════════════════════════════════════
    PanelWindow {
        id: brightWindow
        anchors.left: true
        anchors.top: true
        implicitWidth: brightVisible ? 340 : 0
        implicitHeight: 160
        exclusiveZone: -1
        color: "transparent"
        visible: brightVisible
        Behavior on implicitWidth { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 6
            anchors.leftMargin: 84
            anchors.rightMargin: 6
            color: colors.bg
            radius: 16
            border.color: Qt.rgba(224/255, 175/255, 104/255, 0.3)
            border.width: 1
            clip: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 14

                // Header
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: parseInt(brightVal) < 30 ? "󰃞" : parseInt(brightVal) < 70 ? "󰃟" : "󰃠"
                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 22
                        color: colors.yellow
                    }
                    Text {
                        text: "Brillo"
                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 13
                        font.bold: true; color: colors.text
                        Layout.fillWidth: true; leftPadding: 6
                    }
                    Text {
                        text: brightVal + "%"
                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 20
                        font.bold: true; color: colors.yellow
                    }
                }

                // Slider brillo
                Item {
                    Layout.fillWidth: true
                    height: 36

                    // Track fondo con gradiente de oscuro a brillante
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width; height: 8; radius: 4
                        color: colors.surface
                        Rectangle {
                            anchors.fill: parent; radius: 4
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: Qt.rgba(224/255,175/255,104/255,0.1) }
                                GradientStop { position: 1.0; color: colors.yellow }
                            }
                            opacity: 0.4
                        }
                    }
                    // Track relleno
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        width: Math.max(8, (parseFloat(brightVal) / 100) * parent.width)
                        height: 8; radius: 4
                        color: colors.yellow
                        Behavior on width { NumberAnimation { duration: 150 } }
                    }
                    // Thumb
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        x: Math.min(parent.width - 16, Math.max(0, (parseFloat(brightVal) / 100) * parent.width - 8))
                        width: 16; height: 16; radius: 8
                        color: colors.text
                        border.color: colors.yellow; border.width: 2
                        Behavior on x { NumberAnimation { duration: 150 } }
                    }
                    // MouseArea
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: (mouse) => {
                            var pct = Math.round(Math.max(1, Math.min(100, (mouse.x / width) * 100)))
                            var p = Qt.createQmlObject('import Quickshell.Io; Process {}', root)
                            p.command = ["brightnessctl", "set", pct + "%"]
                            p.running = true
                            Qt.callLater(() => brightProc.running = true)
                        }
                        onWheel: (wheel) => {
                            var p = Qt.createQmlObject('import Quickshell.Io; Process {}', root)
                            p.command = ["brightnessctl", "set",
                                         wheel.angleDelta.y > 0 ? "+5%" : "5%-"]
                            p.running = true
                            Qt.callLater(() => brightProc.running = true)
                        }
                    }
                }

                // Botones rápidos
                RowLayout {
                    Layout.fillWidth: true; spacing: 8
                    Repeater {
                        model: [
                            { label: "10%",  val: 10  },
                            { label: "25%",  val: 25  },
                            { label: "50%",  val: 50  },
                            { label: "75%",  val: 75  },
                            { label: "100%", val: 100 }
                        ]
                        Rectangle {
                            Layout.fillWidth: true; height: 26; radius: 6
                            color: Math.abs(parseFloat(brightVal) - modelData.val) < 6 ? Qt.rgba(224/255,175/255,104/255,0.2) : colors.surface
                            border.color: Math.abs(parseFloat(brightVal) - modelData.val) < 6 ? colors.yellow : "transparent"
                            border.width: 1
                            Text {
                                anchors.centerIn: parent; text: modelData.label
                                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 9
                                color: Math.abs(parseFloat(brightVal) - modelData.val) < 6 ? colors.yellow : colors.subtext
                            }
                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    var p = Qt.createQmlObject('import Quickshell.Io; Process {}', root)
                                    p.command = ["brightnessctl", "set", modelData.val + "%"]
                                    p.running = true
                                    Qt.callLater(() => brightProc.running = true)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ══════════════════════════════════════
    //  CALENDARIO POPUP
    // ══════════════════════════════════════
    PanelWindow {
        id: calendarWindow
        anchors.left: true
        anchors.top: true
        implicitWidth: calendarVisible ? 390 : 0
        implicitHeight: 420
        exclusiveZone: -1
        color: "transparent"
        visible: calendarVisible

        Behavior on implicitWidth { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 6
            anchors.leftMargin: 84
            anchors.rightMargin: 6
            color: colors.bg
            radius: 16
            border.color: Qt.rgba(187/255, 154/255, 247/255, 0.25)
            border.width: 1
            visible: calendarVisible
            clip: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                // Header del calendario
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        id: prevMonthBtn
                        text: "󰍞"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 16
                        color: colors.mauve
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (calGrid.displayMonth === 0) {
                                    calGrid.displayMonth = 11
                                    calGrid.displayYear--
                                } else {
                                    calGrid.displayMonth--
                                }
                            }
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: {
                            var months = ["Enero","Febrero","Marzo","Abril","Mayo","Junio",
                                         "Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre"]
                            return months[calGrid.displayMonth] + " " + calGrid.displayYear
                        }
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 14
                        font.bold: true
                        color: colors.text
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        text: "󰍟"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 16
                        color: colors.mauve
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (calGrid.displayMonth === 11) {
                                    calGrid.displayMonth = 0
                                    calGrid.displayYear++
                                } else {
                                    calGrid.displayMonth++
                                }
                            }
                        }
                    }
                }

                // Días de la semana
                Row {
                    Layout.fillWidth: true
                    spacing: 0
                    Repeater {
                        model: ["Lu","Ma","Mi","Ju","Vi","Sá","Do"]
                        Text {
                            width: 36
                            text: modelData
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                            color: colors.mauve
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: Qt.rgba(187/255,154/255,247/255,0.2) }

                // Grid del calendario
                GridLayout {
                    id: calGrid
                    Layout.fillWidth: true
                    columns: 7
                    columnSpacing: 0
                    rowSpacing: 4

                    property int displayMonth: new Date().getMonth()
                    property int displayYear: new Date().getFullYear()
                    property int today: new Date().getDate()
                    property int currentMonth: new Date().getMonth()
                    property int currentYear: new Date().getFullYear()

                    property int firstDay: {
                        var d = new Date(displayYear, displayMonth, 1).getDay()
                        return d === 0 ? 6 : d - 1
                    }
                    property int daysInMonth: new Date(displayYear, displayMonth + 1, 0).getDate()

                    Repeater {
                        model: 42
                        delegate: Rectangle {
                            width: 36; height: 30
                            radius: 6
                            property int dayNum: index - calGrid.firstDay + 1
                            property bool isValid: dayNum >= 1 && dayNum <= calGrid.daysInMonth
                            property bool isToday: isValid &&
                                dayNum === calGrid.today &&
                                calGrid.displayMonth === calGrid.currentMonth &&
                                calGrid.displayYear === calGrid.currentYear
                            property bool isWeekend: (index % 7) === 5 || (index % 7) === 6

                            color: isToday ? colors.mauve : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: isValid ? dayNum.toString() : ""
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 12
                                font.bold: isToday
                                color: isToday ? colors.bg :
                                       isWeekend && isValid ? colors.pink :
                                       isValid ? colors.text : "transparent"
                            }
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: Qt.rgba(255,255,255,0.05) }

                // Fecha actual
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: {
                        var days = ["Domingo","Lunes","Martes","Miércoles","Jueves","Viernes","Sábado"]
                        var months = ["Enero","Febrero","Marzo","Abril","Mayo","Junio",
                                     "Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre"]
                        var d = new Date()
                        return days[d.getDay()] + ", " + d.getDate() + " de " + months[d.getMonth()]
                    }
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11
                    color: colors.subtext
                }

                // Botón cerrar
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Cerrar"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11
                    color: colors.overlay
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: calendarVisible = false
                    }
                }

                Item { Layout.fillHeight: true }
            }
        }
    }

    // ══════════════════════════════════════
    //  BARRA LATERAL PRINCIPAL
    // ══════════════════════════════════════
    PanelWindow {
        id: root
        anchors.left: true
        anchors.top: true
        anchors.bottom: true
        implicitWidth: 72
        color: "transparent"
        exclusiveZone: 72

        Rectangle {
            anchors.fill: parent
            anchors.margins: 6
            anchors.rightMargin: 0
            color: colors.bg
            radius: 16
            border.color: Qt.rgba(187/255, 154/255, 247/255, 0.2)
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                // Logo
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "󰣇"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 22
                    color: colors.mauve
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var p = Qt.createQmlObject('import Quickshell.Io; Process {}', root)
                            p.command = ["rofi", "-show", "drun"]
                            p.running = true
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: Qt.rgba(187/255,154/255,247/255,0.15) }

                // Workspaces
                Column {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 8
                    Repeater {
                        model: 9
                        delegate: Rectangle {
                            id: wsDot
                            property int wsId: index + 1
                            property bool isActive: {
                                try { return Hyprland.focusedMonitor.activeWorkspace.id === wsId }
                                catch(e) { return false }
                            }
                            width: isActive ? 12 : 7
                            height: isActive ? 12 : 7
                            radius: width / 2
                            color: isActive ? colors.mauve : colors.overlay
                            anchors.horizontalCenter: parent.horizontalCenter
                            Behavior on width { NumberAnimation { duration: 150 } }
                            Behavior on color { ColorAnimation { duration: 150 } }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onEntered: wsDot.color = colors.blue
                                onExited: wsDot.color = wsDot.isActive ? colors.mauve : colors.overlay
                                onClicked: {
                                    var p = Qt.createQmlObject('import Quickshell.Io; Process {}', root)
                                    p.command = ["hyprctl", "dispatch", "workspace", wsId.toString()]
                                    p.running = true
                                }
                            }
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: Qt.rgba(255,255,255,0.05) }
                Item { Layout.fillHeight: true }

                // Música
                Column {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 2
                    visible: musicTitle !== ""
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: musicStatus === "Playing" ? "󰏤" : "󰐊"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 18
                        color: musicVisible ? colors.pink : colors.green
                        Behavior on color { ColorAnimation { duration: 150 } }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                musicVisible = !musicVisible
                                sysVisible = false
                            }
                        }
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: musicTitle
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 8; color: colors.subtext
                        width: 52; elide: Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: Qt.rgba(255,255,255,0.05); visible: musicTitle !== "" }

                // CPU
                Column {
                    Layout.alignment: Qt.AlignHCenter; spacing: 1
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "󰻠"
                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 17
                        color: sysVisible ? colors.pink : colors.peach
                        Behavior on color { ColorAnimation { duration: 150 } }
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: { sysVisible = !sysVisible; musicVisible = false }
                        }
                    }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: cpuVal + "%"
                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 9; color: colors.subtext }
                }

                // RAM
                Column {
                    Layout.alignment: Qt.AlignHCenter; spacing: 1
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "󰍛"
                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 17
                        color: sysVisible ? colors.pink : colors.green
                        Behavior on color { ColorAnimation { duration: 150 } }
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: { sysVisible = !sysVisible; musicVisible = false }
                        }
                    }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: ramVal + "%"
                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 9; color: colors.subtext }
                }

                // Volumen
                Column {
                    Layout.alignment: Qt.AlignHCenter; spacing: 1
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: parseInt(volVal) === 0 ? "󰖁" : parseInt(volVal) < 50 ? "󰕿" : "󰕾"
                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 17
                        color: volVisible ? colors.pink : colors.blue
                        Behavior on color { ColorAnimation { duration: 150 } }
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                volVisible = !volVisible
                                brightVisible = false; musicVisible = false; sysVisible = false; btVisible = false; calendarVisible = false; dashVisible = false
                            }
                            onWheel: (wheel) => {
                                var p = Qt.createQmlObject('import Quickshell.Io; Process {}', root)
                                p.command = ["pactl", "set-sink-volume", "@DEFAULT_SINK@",
                                             wheel.angleDelta.y > 0 ? "+5%" : "-5%"]
                                p.running = true
                                Qt.callLater(() => volProc.running = true)
                            }
                        }
                    }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: volVal + "%"
                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 9; color: colors.subtext }
                }

                // Brillo
                Column {
                    Layout.alignment: Qt.AlignHCenter; spacing: 1
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: parseInt(brightVal) < 30 ? "󰃞" : parseInt(brightVal) < 70 ? "󰃟" : "󰃠"
                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 17
                        color: brightVisible ? colors.pink : colors.yellow
                        Behavior on color { ColorAnimation { duration: 150 } }
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                brightVisible = !brightVisible
                                volVisible = false; musicVisible = false; sysVisible = false; btVisible = false; calendarVisible = false; dashVisible = false
                            }
                            onWheel: (wheel) => {
                                var p = Qt.createQmlObject('import Quickshell.Io; Process {}', root)
                                p.command = ["brightnessctl", "set",
                                             wheel.angleDelta.y > 0 ? "+5%" : "5%-"]
                                p.running = true
                                Qt.callLater(() => brightProc.running = true)
                            }
                        }
                    }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: brightVal + "%"
                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 9; color: colors.subtext }
                }

                // Clima
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: weatherVal.split(" ")[0] || "?"
                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 18; color: colors.yellow
                }

                // Red
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: netVal; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 17
                    color: netVal === "󰤨" ? colors.blue : colors.red
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            btVisible = !btVisible
                            musicVisible = false; sysVisible = false; calendarVisible = false; dashVisible = false
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: Qt.rgba(255,255,255,0.05) }

                // Reloj — click corto: dashboard, click largo: calendario
                Column {
                    Layout.alignment: Qt.AlignHCenter; spacing: 0
                    MouseArea {
                        width: 52; height: 40
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            dashVisible = !dashVisible
                            calendarVisible = false; musicVisible = false; sysVisible = false; btVisible = false
                        }
                        onPressAndHold: {
                            calendarVisible = !calendarVisible
                            dashVisible = false; musicVisible = false; sysVisible = false; btVisible = false
                        }

                        Column {
                            anchors.centerIn: parent
                            spacing: 0
                            Text {
                                id: hourText
                                anchors.horizontalCenter: parent.horizontalCenter
                                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 16
                                font.bold: true; color: (calendarVisible || dashVisible) ? colors.pink : colors.mauve
                                Behavior on color { ColorAnimation { duration: 150 } }
                                Component.onCompleted: text = new Date().getHours().toString().padStart(2,'0')
                                Timer { interval: 1000; running: true; repeat: true
                                    onTriggered: hourText.text = new Date().getHours().toString().padStart(2,'0') }
                            }
                            Text {
                                id: minText
                                anchors.horizontalCenter: parent.horizontalCenter
                                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 16
                                font.bold: true; color: (calendarVisible || dashVisible) ? colors.pink : colors.blue
                                Behavior on color { ColorAnimation { duration: 150 } }
                                Component.onCompleted: text = new Date().getMinutes().toString().padStart(2,'0')
                                Timer { interval: 1000; running: true; repeat: true
                                    onTriggered: minText.text = new Date().getMinutes().toString().padStart(2,'0') }
                            }
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: Qt.rgba(187/255,154/255,247/255,0.15) }

                // Power menu
                Column {
                    Layout.alignment: Qt.AlignHCenter; spacing: 10
                    Repeater {
                        model: [
                            {icon: "󰌾", col: "#7aa2f7", cmd: "hyprlock"},
                            {icon: "󰜉", col: "#e0af68", cmd: "systemctl reboot"},
                            {icon: "⏻",  col: "#f7768e", cmd: "systemctl poweroff"}
                        ]
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.icon; font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 17; color: modelData.col
                            Behavior on scale { NumberAnimation { duration: 150 } }
                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onEntered: parent.scale = 1.2
                                onExited: parent.scale = 1.0
                                onClicked: {
                                    var p = Qt.createQmlObject('import Quickshell.Io; Process {}', root)
                                    p.command = ["bash", "-c", modelData.cmd]
                                    p.running = true
                                }
                            }
                        }
                    }
                }

                Item { Layout.preferredHeight: 4 }
            }
        }
    }
}
