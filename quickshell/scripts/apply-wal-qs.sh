#!/bin/bash
python3 << PYEOF
import json, os

with open(os.path.expanduser("~/.cache/wal/colors.json")) as f:
    d = json.load(f)
c = d["colors"]

def blend(h1,h2,t):
    r=lambda s,i:int(s[i:i+2],16)
    return "#{:02x}{:02x}{:02x}".format(
        int(r(h1[1:],0)*(1-t)+r(h2[1:],0)*t),
        int(r(h1[1:],2)*(1-t)+r(h2[1:],2)*t),
        int(r(h1[1:],4)*(1-t)+r(h2[1:],4)*t))

qml = f"""// Auto-generado
import QtQuick
QtObject {{
    readonly property string bg:      "{c['color0']}"
    readonly property string bg2:     "{c['color8']}"
    readonly property string surface: "{blend(c['color0'],c['color8'],0.6)}"
    readonly property string overlay: "{blend(c['color0'],c['color7'],0.3)}"
    readonly property string subtext: "{c['color7']}"
    readonly property string blue:    "{c['color4']}"
    readonly property string mauve:   "{c['color5']}"
    readonly property string pink:    "{c['color9']}"
    readonly property string green:   "{c['color2']}"
    readonly property string yellow:  "{c['color3']}"
    readonly property string peach:   "{c['color11']}"
    readonly property string red:     "{c['color1']}"
    readonly property string text:    "{c['color15']}"
}}
"""
with open(os.path.expanduser("~/.config/quickshell/colors.qml"),"w") as f:
    f.write(qml)
print("✓ colors.qml actualizado")
PYEOF
