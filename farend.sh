#!/bin/sh
# --------------------------------------
# name: farend
# desc: a simple todo system in shell
# main: jaidyn ann <jadedctrl@posteo.at>
# --------------------------------------

# Take in everything in stdin, then print
# (Useful for piping something into a variable)
function reade {
	local stack=""
	while read input; do
		stack="$(printf '%s\n%s' "$stack" "$input")"
	done
	echo "$stack"
}



# --------------------------------------
# BASIC MATH

# Add together two numbers
function add {
	local a="$1"; local b="$2"
	echo "$a + $b" \
	| bc
}

# Subtract two numbers
function subtract {
	local a="$1"; local b="$2"
	echo "$a - $b" \
	| bc 
}

# Increment a number by one
function inc {
	local a="$1"
	add 1 "$a"
}

# Decrement a number by one
function dec {
	local a="$1"
	subtract "$a" 1
}


# Format a number to be a certain amount of digits long
# (done by prepending zeroes)
function digits {
	local number="$(reade)"
	local digits="$1"

	if test "$(dec "$(echo "$number" | wc -c )")" -lt "$(inc "$digits")"
	then
		local i=1;
		while test $i -lt "$digits"; do
			printf "0";
			i="$(inc "$i")"
		done
		printf %s $number
	else
		printf %s $number;
	fi
}



# --------------------------------------
# DATE PRIMITIVES

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

# Return the month of a given date
function date_month {
	local date="$1"
	echo "$date" \
	| awk -F "-" '{print $2}'
}

 # Return the year of a given date
function date_year {
	local date="$1"
	echo "$date" \
	| awk -F "-" '{print $1}'
}


# Return how many days ought to be in the given month
function month_days {
	local month="$1"
	case "$month" in
		09) echo 30;;
		04) echo 30;;
		06) echo 30;;
		11) echo 30;;
		*)  echo 31;;
	esac
}



# --------------------------------------
# DATE ARITHMETIC

# Add an amount of days to a given date
function add_days {
	local date="$1"
	local days_added="$2"
	local day="$(date_day "$date")"; local month="$(date_month "$date")"
	local year="$(date_year "$date")"

	local new_day="$(add "$day" "$days_added" | digits 2)"

	carry_date "${year}-${month}-$new_day"
}

# Return whether or not a given date is valid
# (I.E., not too month months or days)
function is_balanced_date {
	local date="$1"
	local month="$(date_month "$date")"
	local day="$(date_day "$date")"
	local month_max="$(month_days "$month")"

	if test "$month" -gt 12; then
		return 1
	elif test "$day" -gt "$month_max" ; then
		return 1
	else
		return 0
	fi
}

# Correct an unbalanced date
function carry_date {
	local date="$1"

	is_balanced_date "$date"
	while test "$?" -eq 1; do
		date="$(carry_months "$(carry_days "$date")")"
	done
	echo "$date"
}

# If too many days in a given month, carry them over
function carry_days {
	local date="$1"
	local year="$(date_year "$date")"
	local month="$(date_month "$date")"
	local days="$(date_day "$date")"

	if test "$days" -gt "$(month_days "$month")"; then
		local new_days="$(subtract "$days" "$(month_days "$month")")"
		local new_month="$(add "$month" "1")"
		new_days="$(echo "$new_days" | digits 2)"
		new_month="$(echo "$new_month" | digits 2)"
		echo "${year}-${new_month}-${new_days}"
	else
		echo "$date"
	fi
}

# If too many months in a year, carry them over
function carry_months {
	local date="$1"
	local year="$(date_year "$date")"
	local day="$(date_day "$date")"
	local month="$(date_month "$date")"

	if test "$month" -gt 12; then
		month="$(subtract "$month" 12 | digits 2)"
		year="$(inc "$year")"
	fi
	echo "${year}-${month}-${day}"
}



# --------------------------------------
# TODO HANDLING

# Clean up a todo file for use with the program
function preprocess_todo {
	ignore_todo_blanks \
	| demystify_todo_times
}


# Replace piped todo's vague dates with current dates
function demystify_todo_times {
	local year="$(date_year "$(today)")"
	local month="$(date_month "$(today)")"
	local day="$(date_day "$(today)")"
	sed 's%^\*-%'"$year"'-%g' \
	| sed 's%-\*-%-'"$month"'-%g' \
	| sed 's%-\*%-'"$day"'%g'
}

# Filter out comments and blank lines from piped todo
function ignore_todo_blanks {
	grep -v "^#" \
	| grep -v "^$"
}


# Return all todo lines of the given date
function date_todo_lines {
	local date="$1"
	grep "$date"
}

# Print all todo lines during the giving days following the start-date
function upcoming_todo_lines {
	local todo_file="$1"
	local start_date="$2"
	local limit="$3"

	if test "$limit" -eq 0; then limit="$(inc "$limit")"; fi

	local i="0"
	while test "$i" -lt "$limit"; do
		cat "$todo_file" \
		| preprocess_todo \
		| date_todo_lines "$(add_days "$start_date" "$i")"

		if test "$?" -eq 0 \
			-a "$i" -ne "$(dec "$limit")" \
			-a "$QUIET_MODE" -ne 0
		then	echo "---"; fi

		i="$(inc "$i")"
	done
}


# Print a user-friendly report of upcoming events <3
function generate_report {
	local todo_file="$1"
	local limit="$2"

	local tomorrow="$(add_days "$(today)" 1)"
	local today_lines="$(upcoming_todo_lines "$todo_file" "$(today)" 0)"
	local later_lines="$(upcoming_todo_lines "$todo_file" "$tomorrow" "$limit")"

	if test -n "$today_lines"; then
		echo "$TODAY_MSG"
		echo "$DIVIDER"
		echo "$today_lines"
		if test -n "$later_lines"; then echo ''; fi
	fi

	if test -n "$later_lines"; then
		echo "$LATER_MSG"
		echo "$DIVIDER"
		echo "$later_lines"
	fi
}



# --------------------------------------
# INVOCATION

BIN="$(echo "$0" | sed 's%.*/%%')"
function print_help {
	echo "usage: $BIN [-hq] [-l \$LIMIT] [-L | -D \$MSG] [\$TODO_PATH]"
	exit 2
}


# ------------------
# OPTIONS

DIVIDER="----------------------------------------"
TODO_FILE="$HOME/.todo"
LIMIT=7
TODAY_MSG="TODAY"
LATER_MSG="NEXT EPISODE..."
PAST_MSG="FROM THE GRAVE"
QUIET_MODE=1

while getopts 'l:D:T:L:qh' c; do
	case "$c" in
			l) LIMIT="$OPTARG" ;;
			D) DIVIDER="$OPTARG" ;;
			T) TODAY_MSG="$OPTARG" ;;
			L) LATER_MSG="$OPTARG" ;;
			q) QUIET_MODE=0 ;;
			h) print_help ;;
	esac
done
shift "$(dec "$OPTIND" 1)"

FREE_ARG="$1"
if test -n "$FREE_ARG"; then
	TODO_FILE="$FREE_ARG"
fi


# ------------------
# PROGRAM TYME

if test ! -e "$TODO_FILE"; then
	echo "$TODO_FILE: No such file exists"
	exit 3
fi

if test $QUIET_MODE -eq 1; then
	generate_report "$TODO_FILE" "$LIMIT"
else
	upcoming_todo_lines "$TODO_FILE" "$(today)" "$LIMIT"
fi
