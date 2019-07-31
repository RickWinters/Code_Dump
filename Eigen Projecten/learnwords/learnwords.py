import os
import random

def createfile(filename):
    l1 = input("language one?: ")
    l2 = input("language two?:  ")
    print("input words, type 'done' when you're done:  ")
    i = 1
    with open(filename+'.txt', 'a') as file:
        while True:
            w1 = input("Word in " + l1 + ":  ")
            if w1 == 'done':
                break
            w2 = input("Word in " + l2 + ":  ")
            line = [l1, w1, l2, w2]
            file.write(str(line))
            file.write('\n')
            i += 1
    pass

def createlist():
    pass
    folder = input("In which folder should the list be saved?:  ")

    filename = input("What is the filename?:  ")
    if os.path.isfile(folder+filename):
        action = input("file already exists, you want to append words? [yes, no]")
        if action == 'yes':
            filename = 'temp'
            createfile(filename)
            #create a temporary new file, then load the entries and append it
        if action == 'no':
            done = True
    else:
        pass
        createfile(filename)
        #immediately create list

def txttodict(file):
    wordlist = []
    for line in file:
        line = line.replace("\\","")
        line = line.replace("\n","")
        line = line.replace('[','')
        line = line.replace(']','')
        line = line.replace('\'','')
        line = line.split(',')
        wordlist.append(line)
    l1 = wordlist[0][0]
    l2 = wordlist[0][2]
    while True:
        direction = input("learning direction? 1) " + l1 + " --> " + l2 + " or 2) " + l2 + " --> " + l1 + " [1, 2]:  ")
        if direction == '1':
            break
        elif direction == '2':
            l2, l1 = l1, l2
            break
        else:
            print("invalid answer")
    learnlist = []
    for i in range(len(wordlist)):
        if direction == '1':
            word1 = wordlist[i][1]
            word2 = wordlist[i][3]
        else:
            word1 = wordlist[i][3]
            word2 = wordlist[i][1]
        worddict = {'id':i, 'done':False, 'correct':False, 'word1':word1, 'word2':word2, 'l1':l1, 'l2':l2}
        learnlist.append(worddict)
    return learnlist

def learnwordlist(filename):
    file = open(filename + '.txt','r').readlines()
    learnlist = txttodict(file)
    ncorrect = 0
    while ncorrect < len(learnlist):
        number = random.randint(0,len(learnlist)-1)
        if learnlist[number]['correct'] == False:
            answer = input(learnlist[number]['word1'] + '--> :')
            answer = ' ' + answer
            if answer == learnlist[number]['word2'] :
                print('answer is correct')
                learnlist[number]['correct'] = True
                ncorrect += 1
            else:
                print('Answer incorrect, correct answer = ' + learnlist[number]['word2'])
    print('all answers correct')

    action = input("do you want to test / learn this list or are you done? [test, learn, done]")
    if action == 'test':
        testlist(filename)
    elif action == 'learn':
        learnwordlist(filename)
    else:
        pass

def testlist(filename):
    file = open(filename + '.txt', 'r').readlines()
    learnlist = txttodict(file)
    done = 0
    while done < len(learnlist):
        number = random.randint(0,len(learnlist)-1)
        if learnlist[number]['done'] == False:
            learnlist[number]['done'] = True
            done += 1
            answer = input(learnlist[number]['word1'] + '--> :')
            answer = ' '+answer
            if answer == learnlist[number]['word2']:
                learnlist[number]['correct'] = True
    print('test finished, calculating results')
    ncorrect = 0
    nwords = 0
    for word in learnlist:
        nwords += 1
        if word['correct'] == True:
            ncorrect += 1

    score = round(ncorrect/nwords,1)*9+1
    print("you had " + str(ncorrect) + " out of a total of " + str(nwords) + " which gives a score of " + str(score))
    action = input("do you want to test / learn this list or are you done? [test, learn, done]")
    if action == 'test':
        testlist(filename)
    elif action == 'learn':
        learnwordlist(filename)
    else:
        pass

done = False
finished = False
while not finished:
    while not done:
        action = input("Create a list, learn a word list or test your knowledge? [create, learn, test]:  ")
        if action == 'create':
            createlist()
            done = True
        elif action == 'learn':
            filename = input("What is the filename of the list?:  ")
            learnwordlist(filename)
            done = True
        elif action == 'test':
            filename = input("What is the filename of the list?:  ")
            testlist(filename)
            done = True
        else:
            print("Invalid action")

    action = print("Do you want to switch to another file? [yes, no]:  ")
    if action == 'no':
        finished = True
    else:
        pass


