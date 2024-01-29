#!/bin/sh
# --------------------------------------
# name: ccal
# desc: portable colourized `cal`
# main: jaidyn ann <jadedctrl@posteo.at>
# --------------------------------------

# On some systems, the `cal` command can't highlight the current day.
# This version does it portably, only assuming you have POSIX `cal`.

# To change the highlight colours, set the $CCAL_HEAD and $CCAL_TAIL
# variables. $CCAL_HEAD should set the colours (ANSI codes etc), _TAIL should
# reset colours, ofc.

# Return today's date, YYYY-MM-DD
function today {
	date +"%Y-%m-%d"
}

# Return the day of a given date
function date_day {
	local date="$1"
	echo "$date" \
	| awk -F "-" '{print $3}'
}

# Concatenate three arguments into one non-delimited string
function join_three {
	a="$1"
	b="$2"
	c="$3"
	echo "${a}${b}${c}"
}

# Color the given text from piped input, using giving head and tail as codes
function colour_text {
	local text="$1"
	local head="$2"
	local tail="$3"

	sed 's%'"$text"'%'"$(join_three "$head" "$text" "$tail")"'%'
}

# Colourized form of `cal`
function colourized_cal {
	cal $@ \
	| colour_text "$(date_day "$(today)")" "$CCAL_HEAD" "$CCAL_TAIL"
}



# Set colours if you haven't
if test -z "$CCAL_HEAD"; then
	white_bg="$(tput setab 7 2>/dev/null)"
	black_fg="$(tput setaf 0 2>/dev/null)"
	bold="$(tput bold 2>/dev/null)"
	reset="$(tput sgr0)"
	CCAL_HEAD="${white_bg}${black_fg}${bold}"
	CCAL_TAIL="${reset}"
fi

colourized_cal $@
