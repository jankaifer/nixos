pkill -x .polybar-wrappe
pkill -x polybar

if type "xrandr"; then
    NONPRIMARY_MONITORS=`xrandr --query | grep -G " connected [^(primary)]" | cut -d" " -f1`
    PRIMARY_MONITORS=`xrandr --query | grep " connected primary" | cut -d" " -f1`

    echo primary monitors $PRIMARY_MONITORS
    echo non primary monitors $NONPRIMARY_MONITORS

    for m in $NONPRIMARY_MONITORS; do
        MONITOR=$m polybar --reload top &
        MONITOR=$m polybar --reload bottom &
    done

    for m in $PRIMARY_MONITORS; do
        MONITOR=$m polybar --reload primary-top &
        MONITOR=$m polybar --reload primary-bottom &
    done
else
    polybar --reload top &
    polybar --reload bottom &
fi