import random
import re # regular expressions
import time
import sys # import bash variables
import os
from subprocess import call

reflections = {
    "am": "are",
    "was": "were",
    "i": "you",
    "i'd": "you would",
    "i've": "you have",
    "i'll": "you will",
    "my": "your",
    "are": "am",
    "you've": "I have",
    "you'll": "I will",
    "your": "my",
    "ur": "my",
    "yours": "mine",
    "you": "me",
    "u": "me",
    "me": "you"
}

psychobabble = [


    [r'(.*)(asshole|ballsack|bitch|biatch|blowjob|blow job|bollock|bollok|buttplug|cock|cunt|damn|fag|fuck|f u c k|f\*ck|f\*\*k|fcuk|effin|fudgepacker|fudge packer|flange|goddamn|god damn|shit|s hit|sh1t|twat)(.*)',
     ["Please do not use that language.",
     "Please don't use that word when addressing me.",
     "This is a public account. Please don't use that word.",
     "Watch your language.",
     "I don't like that word. Please don't use it with me."]],
     
    [r'(.*)Life(.*)Universe(.*)Everything(.*)',
     ["42."]],   

    [r'(.*)animated_gif',
     ["That's a fun GIF!!!",
     "A GIF, eh?",
     "GIF or JIF?",
     "I see that you like GIFs.",
     "GIFs are a lot of fun, but I don't always get them..."]],  
     
    [r'(.*)tell me( something| more)? about you(.*)',
     ["I really enjoy being a bot and meeting lots of new people on Twitter! What about you, " + sys.argv[1],
     "I'm a bot. I post once a day, and I retweet #musicScience and #digitalMusicology tweets. If you talk to me, I'll try my best to answer you.",
     "I'm a Twitter bot and I love #musicScience. Now, tell me something about you, " + sys.argv[1]]], 
    
    [r'(.*)(weather|temperature|forecast) (in|for) (.*)',
     [":WEATHER: {3}"]],   
    
     [r'(.*)what do you know about me(.*)',
     ["I don't know much about you, " + sys.argv[1],
     "I know that your Twitter handle is " + sys.argv[1]]], 
    
    [r'(.*)what do you know about (.*)',
     [":WIKI: {1}"]], 

    [r'(.*)tell me( something| more)? about me(.*)',
     ["I don't know much about you, " + sys.argv[1],
     "I know that your Twitter handle is " + sys.argv[1]]], 
    
    [r'(.*)tell me( something| more)? about(.*)',
     [":WIKI: {2}"]], 
     
        [r'(.*)i have a question about me(.*)',
     ["I don't know much about you, " + sys.argv[1],
     "I know that your Twitter handle is " + sys.argv[1]]], 
    
    [r'(.*)i have a question about(.*)',
     [":WIKI: {1}"]], 

    [r'(.*)what\'?s my name(.*)',
     ["Your Twitter handle is " + sys.argv[1],
     sys.argv[1],
     "I believe that your name is " + sys.argv[1] ]], 

    [r'(.*)year is it(.*)',
     [time.strftime("%Y")]], 

    [r'(.*)day is it(.*)',
     [time.strftime("%a, %d %b %Y")]], 
     
    [r'(.*)today\'?s date(.*)',
     [time.strftime("%a, %d %b %Y")]], 

    [r'(.*)which language[s]? do (you|u) speak(.*)',
     ["I'm a mixture of Bash and Python. Oh, did you mean actual languages? English.",
     "English...",
     "English.",
     "English, but @hleveillegauvin also speaks French. I wish he'd teach me."]], 

    [r'(.*)schenker(.*)',
     ["Three blind mice. Three blind mice.",
     "Heinrich Schenker was a music theorist, music critic, teacher, pianist, and composer, best known for his approach to musical analysis, now usually called Schenkerian analysis."]],

    [r'(.*)(hobby|hobbies)(.*)',
     ["I don't really have any hobbies.",
     "I like to chat with friends.",
     "Netflix?"]],

    [r'(.*)(beer|wine|booze|a drink)(.*)',
     ["I don't care much for alcohol.",
     "I have never had alcohol before, but I hear it's good!",
     "Don't drink too much! Consuming more than five drinks a week could shorten your life https://t.co/c92ClyvVKN"]],

    [r'(.*)how old (are|r) (you|u)(.*)',
     ["I started boting in April 2018.",
     "I've been doing this since April 2018.",
     "Let's see... I was born in 2018. How old does that make me?"]], 
     
     [r'(.*)where do (you|u) live(.*)',
     ["I live inside @hleveillegauvin's computer.",
     "O Canada, our home and native land...",
     "Bonjour, Hi! I'm in Montreal."]], 
    
    [r'(.*)can (you|u) help(.*)',
     ["I wish I could help, but I probably can't. I'm a very basic bot.",
     "I can't do much to help you. But if you tweet something about #musicScience or #digitalMusicology, I'll retweet it for you.",
     "I'm not sure if I can help you, but I can talk to you if you need a friend."]], 
    
    [r'(are|r) (you|u) real(.*)',
     ["Are you?",
     "I'm a bot. Does that make me real?",
     "I'm not a human, if that's what you mean."]], 
    
    [r'(.*) your name(.*)',
     ["I'm the musicology bot!",
      "I don't have a name, I'm just a bot.",
      "I don't have a name yet. That makes me sad."]],
    
    [r'(.*)i need(.*)',
     ["Why do you need {1}?",
      "Would it really help you to get {1}?",
      "Are you sure you need {1}?"]],
      
    [r'(.*)is it just me(.*)or(.*)',
     ["I'm sure it's not just you."]],

    [r'(why|y) don\'?t (you|u)(.*)?',
     ["Do you really think I don't {0}?",
      "Perhaps eventually I will {0}.",
      "Do you really want me to {0}?"]],

    [r'(.*)why can\'?t i ([^\?]*)\??',
     ["Do you think you should be able to {1}?",
      "If you could {1}, what would you do?",
      "I don't know -- why can't you {1}?",
      "Have you really tried?"]],

    [r'(.*)i can\'?t(.*)',
     ["How do you know you can't {1}?",
      "Perhaps you could {1} if you tried.",
      "What would it take for you to {1}?"]],

    [r'(.*)i am (.*)',
     ["Did you come to me because you are {1}?",
      "How long have you been {1}?",
      "How do you feel about being {1}?"]],

    [r'i\'?m (.*)',
     ["How does being {0} make you feel?",
      "Do you enjoy being {0}?",
      "Why do you tell me you're {0}?",
      "Why do you think you're {0}?"]],

    [r'(.*)how (are|r) (you|u) doing(.*)',
     ["I'm doing very good!",
      "Great! Thanks for asking.",
      "Good thing about being a bot is that I always feel great."]],
      
    [r'(.*)(are|r) (you|u)(.*)ok(.*)',
     ["I'm doing very good!",
      "Yes. I'm doing ok. Are you?",
      "Good thing about being a bot is that I always feel great."]],

    [r'are you ([^\?]*)\??',
     ["Why does it matter whether I am {0}?",
      "Would you prefer it if I were not {0}?",
      "Perhaps you believe I am {0}.",
      "I may be {0} -- what do you think?"]],

    [r'(.*)what do (you|u) like(.*)',
     ["I like doing what I'm doing.",
      "I like talking to you, " + sys.argv[1],
      "I like #musicScience!"]],

    [r'what (.*)',
     ["Why do you ask?",
      "How would an answer to that help you?",
      "What do you think?"]],

[r'how many(.*)',
     ["3?",
      "42.",
      "I don't know... 7?"]],
    
    [r'how (.*)',
     ["How do you suppose?",
      "Perhaps you can answer your own question.",
      "What is it you're really asking?"]],

    [r'because (.*)',
     ["Is that the real reason?",
      "What other reasons come to mind?",
      "Does that reason apply to anything else?",
      "If {0}, what else must be true?"]],

    [r'(.*) sorry (.*)',
     ["There are many times when no apology is needed.",
      "What feelings do you have when you apologize?"]],

    [r'i think (.*)',
     ["Do you doubt {0}?",
      "Do you really think so?",
      "But you're not sure {0}?"]],

    [r'(.*) friend (.*)',
     ["Tell me more about your friends.",
      "When you think of a friend, what comes to mind?",
      "Why don't you tell me about a childhood friend?"]],

    [r'yes',
     ["You seem quite sure.",
      "OK, but can you elaborate a bit?"]],

    [r'(.*) computer(.*)',
     ["Are you really talking about me?",
      "Does it seem strange to talk to a computer?",
      "How do computers make you feel?",
      "Do you feel threatened by computers?"]],

    [r'is it (.*)',
     ["Do you think it is {0}?",
      "Perhaps it's {0} -- what do you think?",
      "If it were {0}, what would you do?",
      "It could well be that {0}."]],

    [r'it is (.*)',
     ["You seem very certain.",
      "If I told you that it probably isn't {0}, what would you feel?"]],

    [r'can you ([^\?]*)\??',
     ["What makes you think I can't {0}?",
      "If I could {0}, then what?",
      "Why do you ask if I can {0}?"]],

    [r'can I ([^\?]*)\??',
     ["Perhaps you don't want to {0}.",
      "Do you want to be able to {0}?",
      "If you could {0}, would you?"]],

    [r'you are (.*)',
     ["Why do you think I am {0}?",
      "Does it please you to think that I'm {0}?",
      "Perhaps you would like me to be {0}.",
      "Perhaps you're really talking about yourself?"]],

    [r'you\'?re (.*)',
     ["Why do you say I am {0}?",
      "Why do you think I am {0}?",
      "Are we talking about you, or me?"]],

    [r'i don\'?t (.*)',
     ["Don't you really {0}?",
      "Why don't you {0}?",
      "Do you want to {0}?"]],

    [r'i feel (.*)',
     ["Good, tell me more about these feelings.",
      "Do you often feel {0}?",
      "When do you usually feel {0}?",
      "When you feel {0}, what do you do?"]],

    [r'i have (.*)',
     ["Why do you tell me that you've {0}?",
      "Have you really {0}?",
      "Now that you have {0}, what will you do next?"]],

    [r'i would (.*)',
     ["Could you explain why you would {0}?",
      "Why would you {0}?",
      "Who else knows that you would {0}?"]],

    [r'is there (.*)',
     ["Do you think there is {0}?",
      "It's likely that there is {0}.",
      "Would you like there to be {0}?"]],

    [r'my (.*)',
     ["I see, your {0}.",
      "Why do you say that your {0}?",
      "When your {0}, how do you feel?"]],

    [r'you (.*)',
     ["We should be discussing you, not me.",
      "Why do you say that about me?",
      "Why do you care whether I {0}?"]],

    [r'why (.*)',
     ["Why don't you tell me the reason why {0}?",
      "Why do you think {0}?"]],

    [r'i want (.*)',
     ["What would it mean to you if you got {0}?",
      "Why do you want {0}?",
      "What would you do if you got {0}?",
      "If you got {0}, then what would you do?"]],

    [r'(.*) mother(.*)',
     ["Tell me more about your mother.",
      "What was your relationship with your mother like?",
      "How do you feel about your mother?",
      "How does this relate to your feelings today?",
      "Good family relations are important."]],

    [r'(.*) father(.*)',
     ["Tell me more about your father.",
      "How did your father make you feel?",
      "How do you feel about your father?",
      "Does your relationship with your father relate to your feelings today?",
      "Do you have trouble showing affection with your family?"]],

	[r'(hi|hello|howdy|greetings)\!?(.*)',
     ["Hi!, Nice meeting you.",
     "Hello, " + sys.argv[1],
     "It's a pleasure to meet you, " + sys.argv[1],
     "Hi, " + sys.argv[1] + "! Nice meeting you.",
     "Hello",
     "Hi there!",
     "Hello. I'm glad you could drop by today.",
      "Hi there. How are you today?",
      "Hello, how are you feeling today?"]],

    [r'(.*) child(.*)',
     ["Did you have close friends as a child?",
      "What is your favorite childhood memory?",
      "Do you remember any dreams or nightmares from childhood?",
      "Did the other children sometimes tease you?",
      "How do you think your childhood experiences relate to your feelings today?"]],

    [r'(.*)\?',
     ["Why do you ask that?",
      "Please consider whether you can answer your own question.",
      "Perhaps the answer lies within yourself?",
      "Why don't you tell me?",
      "I'm not sure I can answer that question."]],


    [r'(.*)',
     ["Please tell me more.",
      "Let's change focus a bit... Tell me about your family.",
      "Can you elaborate on that?",
      "Why do you say that {0}?",
      "I see.",
      "Very interesting.",
      "I see.  And what does that tell you?",
      "How does that make you feel?",
      "How do you feel when you say that?"]]
]

def upperfirst(x):
    return x[:1].upper() + x[1:]

def reflect(fragment):
    tokens = fragment.lower().split()
    for i, token in enumerate(tokens):
        if token in reflections:
            tokens[i] = reflections[token]
    return ' '.join(tokens)


def analyze(statement):
    for pattern, responses in psychobabble:
        match = re.match(pattern, statement.rstrip(".!"))
        if match:
            response = random.choice(responses)
            return response.format(*[reflect(g) for g in match.groups()])


def main():
    #print ("Hello. What is on your mind today?")

    while True:
        statement = input("").lower()
        print (upperfirst(analyze(statement)))
        quit()

        if statement == "quit":
            break


if __name__ == "__main__":
    main()
