#!/bin/bash

# Twitter Musicology Bot -- RETWEET
# Required dependency: twurl
# Written by: Hubert Léveillé Gauvin
# Date: 18 April 2018
# Last Update: 20 April 2018


# I set up a crontab job to automatically run this script everyday at noon. 
# The crontab job is as follow:
# 00 12 * * *  ~/.profile; "/Users/Hubert/Google Drive/Scripting/twitterAPI/musicologybot.sh"
# It can be modified using the crontab -e command (Vim editor. Press "i" to enter "insert" mode, press "esc" to quit "insert" mode; press "shift + zz" to save and quit."
# The PATH below is needed for crontab to work properly.

PATH="/usr/local/opt/gettext/bin:/Library/Frameworks/Python.framework/Versions/3.5/bin:/opt/local/bin:/opt/local/sbin:/Users/Hubert/humdrum-tools/humextra/bin:/Users/Hubert/humdrum-tools/humdrum/bin:/usr/local/humdrum-tools/humdrum/bin:/Users/Hubert/Todo/todo.sh:/usr/local/humdrum-tools/humextra/bin:/usr/local/bin/humdrum/bin:/usr/local/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Library/TeX/texbin:/usr/local/weather-tool:/usr/local/weather-tool"

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


# ##### RETWEET HASHTAGS #########################
# 
# ### Retweet musicScience ###################
# # Get list of musicscience tweets in last 7 days
# twurl '/1.1/search/tweets.json?q=#musicscience' |  jq '.statuses[].id_str' | sed 's/"//g' > musicscience.txt
# 
# # Retweet
# while IFS= read -r line; do
# 	twurl -X POST "/1.1/statuses/retweet/$line.json"
# done < musicscience.txt
# 
# rm musicscience.txt
# 
# ### Retweet digitalmusicology ###################
# # Get list of digitalmusicology tweets in last 7 days
# twurl '/1.1/search/tweets.json?q=#digitalmusicology' |  jq '.statuses[].id_str' | sed 's/"//g' > digitalmusicology.txt
# 
# # Retweet 
# while IFS= read -r line; do
# 	twurl -X POST "/1.1/statuses/retweet/$line.json"
# done < digitalmusicology.txt
# 
# rm digitalmusicology.txt
# 
# ### Retweet musiccognition ###################
# # Get list of musiccognition tweets in last 7 days
# twurl '/1.1/search/tweets.json?q=#musiccognition' |  jq '.statuses[].id_str' | sed 's/"//g' > musiccognition.txt
# 
# # Retweet 
# while IFS= read -r line; do
# 	twurl -X POST "/1.1/statuses/retweet/$line.json"
# done < musiccognition.txt
# 
# rm musiccognition.txt
# 
# ### Retweet computationalmusicology  ###################
# # Get list of computationalmusicology  tweets in last 7 days
# twurl '/1.1/search/tweets.json?q=#computationalmusicology' |  jq '.statuses[].id_str' | sed 's/"//g' > computationalmusicology.txt
# 
# # Retweet 
# while IFS= read -r line; do
# 	twurl -X POST "/1.1/statuses/retweet/$line.json"
# done < computationalmusicology.txt
# 
# rm computationalmusicology.txt
# 
# ### Retweet musicpsych  ###################
# # Get list of musicpsych  tweets in last 7 days
# twurl '/1.1/search/tweets.json?q=#musicpsych' |  jq '.statuses[].id_str' | sed 's/"//g' > musicpsych.txt
# 
# # Retweet 
# while IFS= read -r line; do
# 	twurl -X POST "/1.1/statuses/retweet/$line.json"
# done < musicpsych.txt
# 
# rm musicpsych.txt
# 
# ### Retweet musicpsychology  ###################
# # Get list of musicpsychology  tweets in last 7 days
# twurl '/1.1/search/tweets.json?q=#musicpsychology' |  jq '.statuses[].id_str' | sed 's/"//g' > musicpsychology.txt
# 
# # Retweet 
# while IFS= read -r line; do
# 	twurl -X POST "/1.1/statuses/retweet/$line.json"
# done < musicpsychology.txt
# 
# rm musicpsychology.txt
# 
# ### Retweet icmpc  ###################
# # Get list of icmpc  tweets in last 7 days
# twurl '/1.1/search/tweets.json?q=#icmpc' |  jq '.statuses[].id_str' | sed 's/"//g' > icmpc.txt
# 
# # Retweet 
# while IFS= read -r line; do
# 	twurl -X POST "/1.1/statuses/retweet/$line.json"
# done < icmpc.txt
# 
# rm icmpc.txt
# 
# ### Retweet icmpc15  ###################
# # Get list of icmpc15  tweets in last 7 days
# twurl '/1.1/search/tweets.json?q=#icmpc15' |  jq '.statuses[].id_str' | sed 's/"//g' > icmpc15.txt
# 
# # Retweet 
# while IFS= read -r line; do
# 	twurl -X POST "/1.1/statuses/retweet/$line.json"
# done < icmpc15.txt
# 
# rm icmpc15.txt
# 
# ### Retweet icmpc2018  ###################
# # Get list of icmpc2018  tweets in last 7 days
# twurl '/1.1/search/tweets.json?q=#icmpc2018' |  jq '.statuses[].id_str' | sed 's/"//g' > icmpc2018.txt
# 
# # Retweet 
# while IFS= read -r line; do
# 	twurl -X POST "/1.1/statuses/retweet/$line.json"
# done < icmpc2018.txt
# 
# rm icmpc2018.txt





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







