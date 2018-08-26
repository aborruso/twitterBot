#!/bin/bash

# Twitter Musicology Bot -- REPLY
# Required dependency: jimbo.py,jq,twurl,wiki
# Written by: Hubert Léveillé Gauvin
# Date: 18 April 2018
# Last Update: 22 April 2018


# I set up a crontab job to automatically run this script everyday at noon. 
# The crontab job is as follow:
# 00 12 * * *  ~/.profile; "/Users/Hubert/Google Drive/Scripting/twitterAPI/musicologybot.sh"
# It can be modified using the crontab -e command (Vim editor. Press "i" to enter "insert" mode, press "esc" to quit "insert" mode; press "shift + zz" to save and quit."
# The PATH below is needed for crontab to work properly.

PATH="/usr/local/opt/gettext/bin:/Library/Frameworks/Python.framework/Versions/3.5/bin:/opt/local/bin:/opt/local/sbin:/Users/Hubert/humdrum-tools/humextra/bin:/Users/Hubert/humdrum-tools/humdrum/bin:/usr/local/humdrum-tools/humdrum/bin:/Users/Hubert/Todo/todo.sh:/usr/local/humdrum-tools/humextra/bin:/usr/local/opt/gettext/bin:/Library/Frameworks/Python.framework/Versions/3.5/bin:/opt/local/bin:/opt/local/sbin:/Users/Hubert/humdrum-tools/humextra/bin:/Users/Hubert/humdrum-tools/humdrum/bin:/usr/local/humdrum-tools/humdrum/bin:/Users/Hubert/Todo/todo.sh:/usr/local/humdrum-tools/humextra/bin:/usr/local/bin/humdrum/bin:/usr/local/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Library/TeX/texbin:/Users/Hubert/weather-tool:/Users/Hubert/weather-tool"





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