#!/bin/bash

BAT="/sys/class/power_supply/BAT0"
MAX_CHARGE=80

status=$(cat "$BAT/status")
capacity=$(cat "$BAT/capacity")

if [ -f "$BAT/power_now" ]; then
    power_now=$(cat "$BAT/power_now")
    energy_now=$(cat "$BAT/energy_now")
    energy_full=$(cat "$BAT/energy_full")
    energy_max=$(( energy_full * MAX_CHARGE / 100 ))

    if [ "$status" = "Charging" ] && [ "$power_now" -gt 0 ]; then
        seconds=$(( (energy_max - energy_now) * 3600 / power_now ))
        if [ "$seconds" -gt 0 ]; then
            h=$(( seconds / 3600 ))
            m=$(( (seconds % 3600) / 60 ))
            time_str="${h}h${m}m"
        else
            time_str="completo"
        fi
    fi
elif [ -f "$BAT/current_now" ]; then
    current_now=$(cat "$BAT/current_now")
    charge_now=$(cat "$BAT/charge_now")
    charge_full=$(cat "$BAT/charge_full")
    charge_max=$(( charge_full * MAX_CHARGE / 100 ))

    if [ "$status" = "Charging" ] && [ "$current_now" -gt 0 ]; then
        seconds=$(( (charge_max - charge_now) * 3600 / current_now ))
        if [ "$seconds" -gt 0 ]; then
            h=$(( seconds / 3600 ))
            m=$(( (seconds % 3600) / 60 ))
            time_str="${h}h${m}m"
        else
            time_str="completo"
        fi
    fi
fi

if [ "$capacity" -ge 90 ]; then icon=""
elif [ "$capacity" -ge 70 ]; then icon=""
elif [ "$capacity" -ge 50 ]; then icon=""
elif [ "$capacity" -ge 30 ]; then icon=""
else icon=""; fi

if [ "$status" = "Charging" ]; then
    if [ -n "$time_str" ] && [ "$capacity" -lt "$MAX_CHARGE" ]; then
        echo "{\"text\": \" $capacity% ($time_str)\", \"class\": \"charging\", \"tooltip\": \"Carregando até ${MAX_CHARGE}%\"}"
    else
        echo "{\"text\": \" $capacity%\", \"class\": \"charging\", \"tooltip\": \"Carregando\"}"
    fi
elif [ "$status" = "Discharging" ]; then
    echo "{\"text\": \"$icon $capacity%\", \"class\": \"discharging\"}"
else
    echo "{\"text\": \" $capacity%\", \"class\": \"full\"}"
fi
