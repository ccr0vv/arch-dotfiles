#!/bin/bash
STATE_FILE="${XDG_RUNTIME_DIR:?}/pomodoro_state"
FOCUS=1500
BREAK=300

init() {
    [ ! -f "$STATE_FILE" ] && echo "stopped:$FOCUS:focus:0" > "$STATE_FILE"
}

read_state() {
    IFS=':' read -r status remaining phase cycles < "$STATE_FILE"
}

write_state() {
    echo "$1:$2:$3:$4" > "$STATE_FILE"
}

init

case "$1" in
    toggle)
        read_state
        if [ "$status" = "running" ]; then
            elapsed=$(( $(date +%s) - remaining ))
            limit=$( [ "$phase" = "focus" ] && echo $FOCUS || echo $BREAK )
            left=$((limit - elapsed))
            write_state "paused" "$left" "$phase" "$cycles"
            notify-send "⏸ Pomodoro" "Pausado — $(( left / 60 ))m restantes"
        elif [ "$status" = "paused" ]; then
            new_start=$(( $(date +%s) - ( $( [ "$phase" = "focus" ] && echo $FOCUS || echo $BREAK ) - remaining ) ))
            write_state "running" "$new_start" "$phase" "$cycles"
            notify-send "▶ Pomodoro" "Continuando!"
        else
            write_state "running" "$(date +%s)" "$phase" "$cycles"
        fi
        ;;
    reset)
        write_state "stopped" "$FOCUS" "focus" "0"
        notify-send "🍅 Pomodoro" "Timer resetado"
        ;;
    *)
        read_state
        current_time=$(date +"%H:%M")
        tooltip="🕐 $current_time"

        if [ "$status" = "running" ]; then
            elapsed=$(( $(date +%s) - remaining ))
            limit=$( [ "$phase" = "focus" ] && echo $FOCUS || echo $BREAK )
            remaining_time=$((limit - elapsed))

            if [ $remaining_time -le 0 ]; then
                if [ "$phase" = "focus" ]; then
                    notify-send -u critical "🍅 Pomodoro" "Foco concluído! Hora do descanso ☕"
                    [ ! -f "$HOME/.local/share/sounds/pomodoro/persona5_jingle.wav" ] || paplay "$HOME/.local/share/sounds/pomodoro/persona5_jingle.wav" &
                    write_state "running" "$(date +%s)" "break" "$cycles"
                    phase="break"
                else
                    cycles=$((cycles + 1))
                    notify-send -u critical "🍅 Pomodoro" "Descansou! Bora focar 💪 (sessão $((cycles + 1)))"
                    write_state "running" "$(date +%s)" "focus" "$cycles"
                    phase="focus"
                fi
                remaining_time=$( [ "$phase" = "focus" ] && echo $FOCUS || echo $BREAK )
            fi

            mins=$((remaining_time / 60))
            secs=$((remaining_time % 60))
            icon=$( [ "$phase" = "focus" ] && echo "🍅" || echo "☕" )
            label=$( [ "$phase" = "focus" ] && echo "foco" || echo "pausa" )
            echo "{\"text\": \"$icon ${mins}:$(printf '%02d' $secs)\", \"tooltip\": \"$tooltip  •  $label  •  sessão $((cycles + 1))\", \"class\": \"$phase\"}"

        elif [ "$status" = "paused" ]; then
            mins=$((remaining / 60))
            secs=$((remaining % 60))
            icon=$( [ "$phase" = "focus" ] && echo "🍅" || echo "☕" )
            echo "{\"text\": \"$icon ${mins}:$(printf '%02d' $secs) ⏸\", \"tooltip\": \"$tooltip  •  pausado\", \"class\": \"paused\"}"

        else
            echo "{\"text\": \"$(date +'%H:%M')\", \"tooltip\": \"$(date +'%A, %d de %B de %Y')\nClique direito para iniciar 🍅\", \"class\": \"clock\"}"
        fi
        ;;
esac
