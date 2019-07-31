import wordlist
import numpy as np
from threading import Thread

def decode(textlist, codelist, threadnumber):
    i = 0
    message = []
    for word in textlist:
        i += 1
        print(str(np.round((i / len(textlist)) * 100)) + 'of thread ' + str(threadnumber))
        sum = 0
        for letter in word:
            index = word.index(letter)
            sum += numberlist[index]

        sum = str(sum)
        if len(sum) > 6:
            sum = sum[len(sum) - 6:]

        sum = int(sum)

        if sum in codelist:
            message.append([word, codelist.index(sum)])
    return message


letterlist = 'abdeghilnostu'
numberlist = [188461, 565383, 969149, 88447, 265341,796023, 388069, 164207, 492621, 477863, 433589, 300767, 902301]
generator = wordlist.Generator(letterlist)
wordslist = generator.generate(2,5)
codelist = [696318, 994738, 186634, 937474, 818450, 387210, 184029, 377231, 999091, 293830, 725605, 893049, 394922]

textlist = [5]
print('generating list of letters')
for word in wordslist:
    textlist.append(word)

lenlist = int(np.ceil(len(textlist)/4))

print('dividing list')
textlist1 = textlist[:lenlist]
textlist2 = textlist[lenlist+1:2*lenlist]
textlist3 = textlist[2*lenlist+1:3*lenlist]
textlist4 = textlist[3*lenlist+1:]

print('starting threads')
thread1 = Thread(target = decode, args= (textlist1,codelist,1))
thread2 = Thread(target = decode, args= (textlist2,codelist,2))
thread3 = Thread(target = decode, args= (textlist3,codelist,3))
thread4 = Thread(target = decode, args= (textlist4,codelist,4))

thread1.start()
thread2.start()
thread3.start()
thread4.start()

message1 = thread1.join()
message2 = thread2.join()
message3 = thread3.join()
message4 = thread4.join()

print('message consists of ' + str(message1) + str(message2) + str(message3) + str(message4))
