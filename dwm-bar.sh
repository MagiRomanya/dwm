output=""
SCRIPTS_DIR="/home/magi/.config/scripts/"

battery="$(/home/magi/.config/scripts/battery/battery | head -n1)"

time="$(date '+%Y-%m-%d %H:%M:%S')"

audio="$(/home/magi/.config/scripts/volume-pulseaudio | head -n1)"

wifi=" $(/home/magi/.config/scripts/wifi | head -n1)"

output="$audio | $wifi | $battery | $time"

echo $output
