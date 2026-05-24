#!/bin/bash

THEME="$HOME/.config/rofi/hypr-menu.rasi"
ROFI_CMD="rofi -dmenu -i -theme $THEME"

show_main() {
    echo -e "󰣆  Aplicaciones\n󰑓  Aprender\n󱐋  Disparadores\n󰏘  Estilo\n󰒓  Configuración\n󰮝  Instalar\n󰮘  Eliminar\n󰑓  Actualizar\n󰋼  Acerca de\n󰐥  Sistema" | \
    $ROFI_CMD -p "Ir a..."
}

show_aprender() {
    echo -e "󰌌  Atajos de teclado\n󰂿  Omarchy\n  Hyprland\n  Arch\n  Neovim\n  Bash" | \
    $ROFI_CMD -p "Aprender..."
}

show_configuracion() {
    echo -e "󰕾  Audio\n󰖩  WiFi\n󰂯  Bluetooth\n󱐋  Perfil de energía\n󰒲  Suspender\n󰍹  Monitores\n󰌌  Atajos de teclado\n󰍽  Entrada\n󰖟  DNS\n󰌆  Seguridad\n󰒓  Config" | \
    $ROFI_CMD -p "Configuración..."
}

show_sistema() {
    echo -e "󰍃  Cerrar sesión\n󰜉  Reiniciar\n󰐥  Apagar\n󰌾  Bloquear" | \
    $ROFI_CMD -p "Sistema..."
}

show_estilo() {
    echo -e "󰸉  Fondo de pantalla\n󰐱  Tema\n󰏘  Colores\n󰛖  Fuentes" | \
    $ROFI_CMD -p "Estilo..."
}

# ── Visor de keybindings estilo imagen (dos columnas: atajo → acción) ──────
show_keybindings() {
    local CONF="$HOME/.config/hypr/hyprland.conf"
    
    # Parsea bind = MOD, KEY, ACTION, DESCRIPTION
    # Formatea como:  "SUPER + F    →  Toggle float"
    awk '
    /^[[:space:]]*bind[el]?[[:space:]]*=/ {
        # Quita el "bind = " del inicio
        sub(/^[[:space:]]*bind[el]?[[:space:]]*=[[:space:]]*/, "")
        
        n = split($0, parts, ",")
        if (n < 3) next
        
        # Construir mod+key
        mods = parts[1]
        key  = parts[2]
        desc = parts[3]
        if (n >= 4) desc = desc " " parts[4]
        
        # Limpiar espacios
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", mods)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", key)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", desc)
        
        # Traducir modificadores comunes
        gsub(/SUPER/, "SUPER", mods)
        gsub(/SHIFT/, "SHIFT", mods)
        gsub(/ALT/,   "ALT",   mods)
        gsub(/CTRL/,  "CTRL",  mods)
        
        combo = mods
        if (key != "") combo = combo " + " key
        
        # Columna izquierda (30 chars) + flecha + columna derecha
        printf "%-32s → %s\n", combo, desc
    }
    ' "$CONF" | \
    rofi -dmenu -i \
         -theme "$THEME" \
         -theme-str 'window { width: 700px; } listview { lines: 18; }' \
         -p "Keybindings" \
         -no-custom
    # No ejecutamos nada con la selección, solo es visor
}

# ─────────────────────────────────────────────────────────────────────────────

CHOICE=$(show_main)
[ -z "$CHOICE" ] && exit 0

case "$CHOICE" in
    *"Aplicaciones"*) rofi -show drun -theme "$THEME" ;;

    *"Aprender"*)
        SUB=$(show_aprender)
        [ -z "$SUB" ] && exit 0
        case "$SUB" in
            *"Atajos"*)   show_keybindings ;;   # ← usa el visor bonito
            *"Hyprland"*) xdg-open "https://wiki.hyprland.org" ;;
            *"Arch"*)     xdg-open "https://wiki.archlinux.org" ;;
            *"Neovim"*)   xdg-open "https://neovim.io/doc/" ;;
            *"Bash"*)     xdg-open "https://www.gnu.org/software/bash/manual/" ;;
        esac ;;

    *"Configuración"*)
        SUB=$(show_configuracion)
        [ -z "$SUB" ] && exit 0
        case "$SUB" in
            *"Audio"*)     pavucontrol ;;
            *"WiFi"*)      nm-connection-editor ;;
            *"Bluetooth"*) blueman-manager ;;
            *"Monitores"*) nwg-displays 2>/dev/null || wdisplays ;;
            *"Atajos"*)    show_keybindings ;;   # ← también desde Configuración
            *"Config"*)    kitty -e nvim ~/.config/hypr/hyprland.conf ;;
        esac ;;

    *"Sistema"*)
        SUB=$(show_sistema)
        [ -z "$SUB" ] && exit 0
        case "$SUB" in
            *"Cerrar"*)    hyprctl dispatch exit ;;
            *"Reiniciar"*) systemctl reboot ;;
            *"Apagar"*)    systemctl poweroff ;;
            *"Bloquear"*)  hyprlock 2>/dev/null || swaylock ;;
        esac ;;

    *"Estilo"*)
        SUB=$(show_estilo)
        [ -z "$SUB" ] && exit 0
        case "$SUB" in
            *"Colores"*) kitty -e nvim ~/.config/wal/ ;;
        esac ;;
esac
