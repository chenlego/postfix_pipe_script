#!/bin/sh

#
# originated from: http://www.postfix.org/FILTER_README.html
#
# Simple shell-based filter. It is meant to be invoked as follows:
#       /path/to/script -f sender recipients...

# Localize these. The -G option does nothing before Postfix 2.3.
FILTER_NAME=smtp_to_non_smtp
INSPECT_DIR=/tmp/spool/$FILTER_NAME
#INSPECT_DIR=/var/spool/filter
#SENDMAIL="/usr/sbin/sendmail -G -i" # NEVER NEVER NEVER use "-t" here.

# Exit codes from <sysexits.h>
EX_TEMPFAIL=75
EX_UNAVAILABLE=69

TS="$(date +%s)"
RAW_MSG_F="in.$TS.$$"

# Clean up when done or when aborting.
#trap "rm -f $RAW_MSG_F" 0 1 2 3 15

# Start processing.
cd $INSPECT_DIR || {
    echo $INSPECT_DIR does not exist; exit $EX_TEMPFAIL; }

cat >"$RAW_MSG_F" || {
    echo Cannot save mail to file; exit $EX_TEMPFAIL; }

# Specify your content filter here.
# filter <in.$$ || {
#   echo Message content rejected; exit $EX_UNAVAILABLE; }

LOG="/var/logs/$FILTER_NAME/$(date +%Y%m%d).log"
CMD="/bin/{email handling}.sh $RAW_MSG_F $@"

# let bulletmail API set the return path
sed -i '/^Return-Path: .*/d' "$RAW_MSG_F"
echo -n "$TS $(date +%Y%m%d:%H:%M:%S:%Z) $CMD" >> "$LOG"

# use the aliased $(_cmd_) instead of $($CMD)),
# otherwise the pipe ("|") in the CMD chain won't work
#alias _cmd_="$CMD"
#ret="$(_cmd_)"
ret="$($CMD 2>&1)"
ret_code=$?

OK_PREFIX="SENT OK"
FAIL_PREFIX="SENT FAILURE"
OK_OR_FAIL="$ret"
OK_OR_FAIL="${OK_OR_FAIL/$FAIL_PREFIX*/$FAIL_PREFIX}"
OK_OR_FAIL="${OK_OR_FAIL/$OK_PREFIX*/$OK_PREFIX}"

echo ", ret: $ret" >> "$LOG"

# err handling according to result of CMD
# treat CMD failure as perm failure so postfix won't retry it
if [ $ret_code -ne 0 ] ; then
  #exit $EX_UNAVAILABLE
  # silently exit without bouncing / retry when CMD not exiting gracefully
  exit 0
elif [ "$OK_OR_FAIL" == "$FAIL_PREFIX" ] ; then
  # if CMD says it is fail, treat it as soft failure so that postifx will retry
  exit $EX_TEMPFAIL
elif [ "$OK_OR_FAIL" == "$OK_PREFIX" ] ; then
  # an explicit OK response, so remove the msg info and exit
  rm -f "$RAW_MSG_F" "$RAW_MSG_F".*
  exit 0
else
  # if CMD says anything else, treat it as done, but keep the msg info
  exit 0
fi

#$SENDMAIL "$@" <in.$$

#exit $?
