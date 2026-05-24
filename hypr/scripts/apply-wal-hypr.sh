#!/bin/bash
# ─────────────────────────────────────────────
#  apply-wal-hypr.sh
#  Lee ~/.cache/wal/colors.sh y escribe
#  ~/.cache/wal/colors-hyprland.conf
#  luego recarga Hyprland
# ─────────────────────────────────────────────

source ~/.cache/wal/colors.sh

# Quitar el # de los colores para hyprctl
c0="${color0//#/}"
c1="${color1//#/}"
c2="${color2//#/}"
c3="${color3//#/}"
c4="${color4//#/}"
c5="${color5//#/}"
c6="${color6//#/}"
c7="${color7//#/}"

cat > ~/.cache/wal/colors-hyprland.conf << EOF
# Generado automáticamente por apply-wal-hypr.sh
# No editar manualmente

\$color0 = rgb($c0)
\$color1 = rgb($c1)
\$color2 = rgb($c2)
\$color3 = rgb($c3)
\$color4 = rgb($c4)
\$color5 = rgb($c5)
\$color6 = rgb($c6)
\$color7 = rgb($c7)

# Bordes de ventanas
\$border_active   = rgb($c5)
\$border_inactive = rgb($c0)
EOF

# Recargar Hyprland sin reiniciar
hyprctl reload 2>/dev/null || true
