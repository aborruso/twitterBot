# twitterBot
How to create a simple Twitter Bot in BASH 

## Overview

In early 2018, I created The Musicology Bot ([@musicologybot](https://twitter.com/musicologybot)), a simple Twitter Bot for the [#musicScience](https://twitter.com/search?q=%23musicScience&src=typd) and [#digitalmusicology](https://twitter.com/search?q=%23digitalmusicology&src=typd) community. Below I'll describe how to create a similar bot in BASH.

The Musicology Bot can do three (3) main things:

1. Post previously prepared tweets.
2. Retweet tweets containing specific hastags
3. Respond to tweets addressed directly at it through a rudimentary chatbot algorithm.

Each of these functions will be handled by a different script, meaning that our bot will really be three main scripts. 

## Posting

We'll start by creating the posting script. We'll use Twurl to interact with the Twitter API (I'm going to assume that Twurl is already set up with your Twitter credentials). Twurl is pretty easy to use. For example, to post a tweet:

    twurl -d "status=Hello, Wolrd!" /1.1/statuses/update.json
    
We want our bot to randomly select Tweets from stored in a text file. We'll create a text file called FUTURE_POST.txt where we'll store each future tweet on an individual line. We'll then write the core of our posting script:

```
# Post tweet
TODAY=$(date)                                           # Create a variable with today's date (to create a PAST_POST.txt log file)
cp FUTURE_POST.txt temp_post                            # Create a temp file that is a duplicate of FUTURE_POST.txt
TWEET=$(gshuf -n 1 FUTURE_POST.txt)                     # Randomly select one tweet from FUTURE_POST.txt and store it as $TWEET
twurl -d "status=$TWEET" /1.1/statuses/update.json      # Post the tweet stored under $TWEET
echo -e "$TODAY\t$TWEET" >> PAST_POST.txt               # Prepare log file of past posts. Start with today's date, then print $TWEET on a newline
grep -v "$TWEET" temp_post > FUTURE_POST.txt            # Remove the tweet from FUTURE_POST.txt
rm temp_post                                            # Remove the temp file 
```

That's the core of the posting script. Here's the full twitterbot_POST.sh script:

```
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
[ -s FUTURE_POST.txt ] || exit # exit if FUTURE.txt is empty

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
```
