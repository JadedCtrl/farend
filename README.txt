===============================================================================
FAREND(.SH)
===============================================================================

Farend is a very simple todo-list program in shell.
It doesn't manage your todo-list; it can't delete, add, or edit events.
All it does is *display* them in a friendly way, ordered by earliest to latest.

By default, it will print a report listing “TODAY”'s events, followed by the
events of the following seven days. Anything not happening today— or in 7 days—
is ignored.

The idea is that it'll just take your todo-list text file, which you may fill
up with as many events as you want, and only print the immediately relevant
ones.


————————————————————————————————————————
TODO FILE
————————————————————————————————————————
TODO files are formatted like this:

	YYYY-MM-DD HH:MM Event description goes here.

You can use wildcard in any of the date slots; if you don't know the specific
date, to signfify it happens all day (*:*), to signify it's yearly (*-MM-DD),
etc etc.


————————————————————————————————————————
USAGE
————————————————————————————————————————
-l $LIMIT      | The amount of days you'd like to print events in advance (7)
-d $DIVIDER    | Set the divider string under headers (default is 40 "-" chars)
-T $TODAY_MSG  | Set the header title for today's events ("TODAY")
-L $LATER_MSG  | Set the header title to non-today upcoming events  ("NEXT")
-q             | Print upcoming events without dividers or headers ($*_MSG)
-h             | Print the help message

$ farend -l 100 -q /tmp/todo
# Will print upcoming events for the next 100 days, without headers or anything
# … usage goes on along those lines.


————————————————————————————————————————
BORING STUFF
————————————————————————————————————————
License is GPLv3-- check COPYING.txt.
Author is Jaidyn Ann <jadedctrl@teknik.io>
Sauce is at https://git.xwx.moe/farend.git
