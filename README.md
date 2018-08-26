# twitterBot
How to create a simple Twitter Bot in BASH 

## Overview

In early 2018, I created The Musicology Bot ([@musicologybot](https://twitter.com/musicologybot)), a simple Twitter Bot for the [#musicScience](https://twitter.com/search?q=%23musicScience&src=typd) and [#digitalMusicology](https://twitter.com/search?q=%23digitalmusicology&src=typd) community. Below I'll describe how to create a similar bot in BASH.

The Musicology Bot can do three (3) main things:

1. Post previously prepared tweets.
2. Retweet tweets containing specific hastags
3. Respond to tweets addressed directly at it through a rudimentary chatbot algorithm.

Each of these functions will be handled by a different script, meaning that our bot will really be three main scripts. 

## Posting

We'll start by creating the posting script. We'll use Twurl to interact with the Twitter API (I'm going to assume that Twurl is already set up with your Twitter credentials). Twurl is pretty easy to use. For example, to post a tweet:

    twurl -d "status=Hello, World!" /1.1/statuses/update.json
    
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
```

## Retweeting

Next we want the bot to retweet tweets containing specific hastags and sytematically retweet some accounts. In the example below, we first created an array with all the hastags we want to retweet (i.e. #musicscience, #digitalmusicology, #musiccognition, #computationalmusicology, #musicpsych, #musicpsychology, #icmpc, #icmpc15, #icmpc2018). We'll also retweet everything from the account @ICMPC15_ESCOM10, which is ID 979758985061568514. The script below is saved as musicologybot_RETWEET.sh.

```
#!/bin/bash

# Twitter Musicology Bot -- RETWEET
# Required dependency: twurl
# Written by: Hubert Léveillé Gauvin
# Date: 18 April 2018
# Last Update: 20 April 2018


## RETWEET USING ARRAY ###################

array=( \#musicscience \#digitalmusicology \#musiccognition \#computationalmusicology \#musicpsych \#musicpsychology \#icmpc \#icmpc15 \#icmpc2018 )
for i in "${array[@]}"
do
	# Get list of tweets in last 7 days
 	twurl "/1.1/search/tweets.json?q=$i" |  jq '.statuses[].id_str' | sed 's/"//g' > "$i.txt"
	# Retweet
	while IFS= read -r line; do
	twurl -X POST "/1.1/statuses/retweet/$line.json"
	done < "$i.txt"
	rm "$i.txt"		
done

##### RETWEET ACCOUNTS ##########################

### Retweet @ICMPC15_ESCOM10  ###################
# Get list of last 50 @ICMPC15_ESCOM10 tweets
# User ID for @ICMPC15_ESCOM10 is 979758985061568514
twurl '/1.1/statuses/user_timeline.json?user_id=979758985061568514&count=50' | jq '.[].id_str' | sed 's/"//g' > ICMPC15_ESCOM10.txt

# Retweet 
while IFS= read -r line; do
	twurl -X POST "/1.1/statuses/retweet/$line.json"
done < ICMPC15_ESCOM10.txt

rm ICMPC15_ESCOM10.txt

```

### Responding

The last thing we want to do is to write a simple chat bot that will reply to users who tweet directly at our bot. For this part, I used [@smkand](https://github.com/smkand)'s [command-line-chatbot](https://github.com/smkand/command-line-chatbot/blob/master/jimbo.py), which is written in python. It's simple and easy to modify to your own need. The file below, which I saved as musicologybot_REPLY.sh, uses a modified version of jimbo.py, adapted for musicology purposes. It's also set to use the [wiki](https://formulae.brew.sh/formula/wiki) command-line tool if a users asks a question like "i have a question about". It also uses my own [weather](https://github.com/hleveillegauvin/weather) command-line tool to answer weather-related questions.


```
#!/bin/bash

# Twitter Musicology Bot -- REPLY
# Required dependency: jimbo.py,jq,twurl,wiki
# Written by: Hubert Léveillé Gauvin
# Date: 18 April 2018
# Last Update: 22 April 2018


### Reply ###################
# Get list of tweets starting with @musicologybot in last 7 days
twurl '/1.1/search/tweets.json?q=@musicologybot' |  jq -r '.statuses[] | [.text, .id_str] | @tsv' | grep "^@musicologybot" | awk -F '\t' '{ print $2 }' | sed 's/\"//g'  | sort > temp_reply

# sort PAST_REPLY.txt
cat PAST_REPLY.txt | sort > temp_reply2

# Filter out tweets that have already been replied to https://goo.gl/34aVcm
comm -23 temp_reply temp_reply2 > tweets_to_reply_to

	
# For all the IDs in tweets_to_reply_to...
while IFS= read -r ID; do
	# find tweet, username, generate response, write a tweet (i.e. username + response)	
	username=$(twurl "/1.1/statuses/show.json?id=$ID" | jq '.user.screen_name' | sed 's/\"//g' | sed 's/^/@/')

		if [[ "$username" == "@null" ]] ; then continue ; fi
	
	# fetch prompt	
	prompt_raw=$(twurl "/1.1/statuses/show.json?id=$ID" | jq '.text' | sed 's/@musicologybot //' | sed 's/^[[:space:]]//' | sed s/[”“]/"'"/g | sed s/[’‘]/\'/g | sed 's/\"//g')
	
	media_type=$(twurl "/1.1/statuses/show.json?id=$ID" | jq '.extended_entities.media[]?.type' | sed 's/"//g')

	prompt=$(echo "$prompt_raw $media_type")

	response=$(python3 jimbo.py "$username" <<< "$prompt")
	
	# use external programs if necessary
	case "$response" in
	# wiki search
	*:WIKI:*) 
    wiki=$(sed 's/:WIKI: //g ; s/[\?\!]//g ; s/[[:space:]]$//g ; s/^[[:space:]]//g' <<< "$response")
    response=$(wiki -short "$wiki" | tr -d '\n')	
    	if [[ !  -z  "$response"  ]] 
    	then
    		if [[ "$response" == *"Create it on"* ]]
    		then
    			response=$(echo "I couldn't find any information on $wiki.")
    		fi
    	else	
    		response=$(echo "Mmmm... I'm not sure what you mean by $wiki. Could you be more specific?")
    	fi
    ;;
    # weather search
    *:WEATHER:*) 
    city=$(sed 's/:WEATHER: //g ; s/[\?\!]//g ; s/[[:space:]]$//g ; s/^[[:space:]]//g' <<< "$response")
    	if [[ "$prompt" == *"ahrenheit"* ]]
    		then
    			unit=$(echo "F")
    		else
    			unit=$(echo "C")
    		fi
		response=$(weather -s "$city" -t -u "$unit")
	## BUG: Color Codes are printed if no match found. Needs to be fixed.
	;;
    * ) :
    ;;
	esac
	
	
	reply_tweet=$(echo "$username $response")
	twurl -X POST -H api.twitter.com "/1.1/statuses/update.json?status=$reply_tweet&in_reply_to_status_id=$ID"
	# add ID to the list of replied tweets
	echo "$ID" >> PAST_REPLY.txt
done < tweets_to_reply_to

rm temp_reply temp_reply2 tweets_to_reply_to
```
