#!/bin/bash

# My Twitter Bot -- POST
# Required dependency: twurl
# Written by: Hubert Léveillé Gauvin
# Date: 18 April 2018
# Last Update: 20 April 2018


# I set up a crontab job to automatically run this script everyday at noon. 
# The crontab job is as follow:

# 00 12 * * *  cd "/Users/Hubert/myTwitterBot" && ./twitterbot_POST.sh

# It can be modified using the crontab -e command (Vim editor. Press "i" to enter "insert" mode, press "esc" to quit "insert" mode; press "shift + zz" to save and quit."

# The PATH below is needed for crontab to work properly.

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin   # Change with your own PATH


### Post new tweet ###################
# Check if FUTURE_POST.txt is empty
[ -s FUTURE_POST.txt ] || exit # exit if FUTURE_POST.txt is empty

# Send DM if FUTURE.txt > 10
TWEETSLEFT=$(wc -l < FUTURE_POST.txt)

if [ $TWEETSLEFT -lt 10 ]
then
twurl -A 'Content-type: application/json' -X POST /1.1/direct_messages/events/new.json -d '{"event": {"type": "message_create", "message_create": {"target": {"recipient_id": "2309053927"}, "message_data": {"text": "> 10 tweets left"}}}}' # DM @hleveillegauvin if future tweets > 10       # Change 2309053927 with your own ID
fi

# Post tweet
TODAY=$(date)
cp FUTURE_POST.txt temp_post
TWEET=$(gshuf -n 1 FUTURE_POST.txt)
twurl -d "status=$TWEET" /1.1/statuses/update.json
echo -e "$TODAY\t$TWEET" >> PAST_POST.txt
grep -v "$TWEET" temp_post > FUTURE_POST.txt
rm temp_post
