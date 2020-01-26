#!/bin/sh
# --------------------------------------
# name: farend
# desc: a simple todo system in shell
# main: jaidyn ann <jadedctrl@teknik.io>
# --------------------------------------

# Take in everything in stdin, then print
# (Useful for piping something into a variable)
#
# local distance=0
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

# Multiply two numbers
function multiply {
    local a="$1"; local b="$2"
    echo "$a * $b" \
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


# Return whether or not a number is negative
function is_negative {
    local a="$!"
    echo "$a" \
    | grep "^-" \
    > /dev/null
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
		else echo "$number";
	fi
}



# --------------------------------------
# DATE PRIMITIVES

# Return today's date, YYYY-MM-DD
function today {
    date +"%Y-%m-%d"
}

# Return current time, HH:MM
function now {
    date +"%H:%M"
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


# Return the hour of a given time
function time_hour {
    local time="$1"
    echo "$time" \
    | awk -F ":" '{print $1}'
}

# Return the minute of a given time
function time_minute {
    local time="$1"
    echo "$time" \
    | awk -F ":" '{print $2}'
}


# Return current year
function this_year {
    date_year "$(today)"
}

# Return current month
function this_month {
    date_month "$(today)"
}

# Return current day
function this_day {
    date_day "$(today)"
}


# Return current hour
function this_hour {
    time_hour "$(now)"
}

# Return current minute
function this_minute  {
    time_minute "$(now)"
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
    local date_day="$(date_day "$date")"

    carry_date "$date" "$(add "$date_day" "$days_added")"
}

# Return the amount of days between two dates
function date_distance {
    local date_a="$1"; local date_b="$2"

    local year_a="$(date_year "$date_a")"; local year_b="$(date_year "$date_b")"
    local month_a="$(date_month "$date_a")"
    local month_b="$(date_month "$date_b")"
    local day_a="$(date_day "$date_a")"; local day_b="$(date_day "$date_b")"

    if test "$month_a" -eq "$month_b" -a "$year_a" -eq "$year_a"; then
     	same_year_month_distance "$month_a" "$day_a" "$day_b"
    elif test "$year_a" -eq "$year_b"; then
        same_year_distance "$month_a" "$day_a" "$month_b" "$day_b"
    else different_year_distance "$year_a" "$month_a" "$day_a" \
                                 "$year_b" "$month_b" "$day_b"
    fi
}


# Return whether or not a given date is valid
# (I.E., not too month months or days)
function is_balanced_date {
	local date="$1"
	local month="$(date_month "$date")"
	local day="$(date_day "$date")"
	local month_max="$(month_days "$month")"

	if test "$month" -gt 12; then
		echo "1"
	elif test "$day" -gt "$month_max" ; then
    		echo "1";
    	else echo "0"
        fi
}

# Correct an unbalanced date
function carry_date {
    local date="$1"

	while test "$(is_balanced_date "$date")" -eq 1; do
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
        local new_days="$(subtract "$days" "$(month_days "$month")" | digits 2)"
        local new_month="$(add "$month" "1")"
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


# Return the distance between two dates of different years
# (Helper function to date_distance)
function different_year_distance {
    local year_a="$1"; local month_a="$2"; local day_a="$3"
    local year_b="$4"; local month_b="$5"; local day_b="$6"

    add "$(multiply 365 $(subtract $year_b $year_a))" \
   	 "$(same_year_distance "$month_a" "$day_a" "$month_b" "$day_b")"
}

# Return the distance between two dates of the same year and month
# (Helper function to date_distance)
function same_year_month_distance {
    local month="$1"
    local day_a="$2"; local day_b="$3"
    subtract "$day_b" "$day_a"
}

# Return the distance between two dates of the same year
# (Helper function to date_distance)
function same_year_distance {
    local month_a="$1"; local day_a="$2"
    local month_b="$3"; local day_b="$4"

    local month_days_a="$(month_days "$month_a")"
    local distance=0

    if test "$month_a" -gt "$month_b"; then
        echo "-$(same_year_distance "$month_b" "$day_b" "$month_a" "$day_a")"
    else
	distance="$(subtract "$month_days_a" "$day_a")"
	month_a="$(inc "$month_a")"

	while test "$month_a" -lt "$month_b"; do
    		month_a="$(inc "$month_a")"
    		distance="$(add "$distance" "$(month_days "$month_a")")"
	done
	add "$distance" "$day_b"
	fi
}



# --------------------------------------
# TODO HANDLING

# Replace piped todo's vague dates with current dates
function demystify_todo_times {
    sed 's%^\*-%'"$(this_year)"'-%g' \
    | sed 's%-\*-%-'"$(this_month)"'-%g' \
    | sed 's%-\*%-'"$(this_day)"'%g' \
    | sed 's%\*:%'"$(this_hour)"':%g' \
    | sed 's%:\*%:'"$(this_minute)"'%g'
}

# Filter out comments and blank lines from piped todo
function ignore_todo_blanks {
    grep -v "^#" \
    | grep -v "^$"
}

function preprocess_todo {
    ignore_todo_blanks \
    | demystify_todo_times
}


function todo_line_date {
    awk '{print $1}'
}

function todo_line_time {
    awk '{print $2}'
}

function todo_line_desc {
    awk '{print $2}'
}

function todo_line_distance {
    local line_date="$(todo_line_date)"
    date_distance "$(today)" "$line_date"
}

function todo_line_is_trash {
    if is_negative "$(todo_line_distance)"; then
        return 0
	else
    	return 1
    	fi
}

function upcoming_todo_lines {
    local limit="$1"
    preprocess_todo \
    | while IFS= read -r line; do
        if test "$limit" -gt "$(echo "$line" | todo_line_distance)"; then
        echo "$line"
        fi
      done
}

function today_todo_lines {
    grep "$(today)"
}

function generate_report {
    local todo_file="$1"
    local limit="$2"
    local today_lines="$(cat "$todo_file" | preprocess_todo | today_todo_lines)"

    echo "$TODAY_MSG"
    echo "$DIVIDER"
    echo "$today_lines"
    echo
    echo "$LATER_MSG"
    echo "$DIVIDER"
    grep -v "$(today)" $todo_file \
    | upcoming_todo_lines $limit \
    | sort -n
}



# --------------------------------------
# INVOCATION

TODO_FILE="$HOME/.todo"
LIMIT=7
DIVIDER="----------------------------------------"
TODAY_MSG="TODAY"
LATER_MSG="NEXT EPISODE..."
PAST_MSG="FROM THE GRAVE"
QUIET_MODE=1

while getopts 'l:D:T:L:P:qh' c; do
	case "$c" in
    		l) LIMIT="$OPTARG" ;;
    		D) DIVIDER="$OPTARG" ;;
    		T) TODAY_MSG="$OPTARG" ;;
    		L) LATER_MSG="$OPTARG" ;;
    		P) PAST_MSG="$OPTARG" ;;
    		q) QUIET_MODE=0 ;;
    		h) echo "$HELP"; exit 2 ;;
	esac
done

if test $QUIET_MODE -eq 1; then
	generate_report "$TODO_FILE" "$LIMIT"
else
	cat "$TODO_FILE" \
	| preprocess_todo \
	| upcoming_todo_lines "$LIMIT" \
	| sort -n
fi
