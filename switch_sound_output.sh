set -a
MIXER=${MIXER:-""}
SCONTROL=${SCONTROL:-""}

if [[ -z "$MIXER" ]] ; then
    MIXER="default"
    if amixer -D pulse info >/dev/null 2>&1 ; then
        MIXER="pulse"
    fi
fi

if [[ -z "$SCONTROL" ]] ; then
    SCONTROL=$(amixer -D "$MIXER" scontrols | sed -n "s/Simple mixer control '\([^']*\)',0/\1/p" | head -n1)
fi


CAPABILITY=$(amixer -D $MIXER get $SCONTROL | sed -n "s/  Capabilities:.*cvolume.*/Capture/p")


function move_sinks_to_new_default {
    DEFAULT_SINK=$1
    pacmd list-sink-inputs | grep index: | grep -o '[0-9]\+' | while read SINK
    do
        pacmd move-sink-input $SINK $DEFAULT_SINK
    done
}

function set_default_playback_device_next {
    inc=${1:-1}
    num_devices=$(pacmd list-sinks | grep -c index:)
    sink_arr=($(pacmd list-sinks | grep index: | grep -o '[0-9]\+'))
    default_sink_index=$(( $(pacmd list-sinks | grep index: | grep -no '*' | grep -o '^[0-9]\+') - 1 ))
    default_sink_index=$(( ($default_sink_index + $num_devices + $inc) % $num_devices ))
    default_sink=${sink_arr[$default_sink_index]}
    pacmd set-default-sink $default_sink
    move_sinks_to_new_default $default_sink
}

BLOCK_BUTTON=1
case "$BLOCK_BUTTON" in
    1) set_default_playback_device_next ;;
    2) amixer -q -D $MIXER sset $SCONTROL $CAPABILITY toggle ;;
    3) set_default_playback_device_next -1 ;;
    4) amixer -q -D $MIXER sset $SCONTROL $CAPABILITY $AUDIO_DELTA%+ ;;
    5) amixer -q -D $MIXER sset $SCONTROL $CAPABILITY $AUDIO_DELTA%- ;;
esac

