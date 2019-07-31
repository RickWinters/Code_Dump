import random
import itertools
import time

class Card:
    def __init__(self,Suit,Value): #Create a card with all the properties
        self.Suit = Suit
        self.Value = Value
        self.Score = Value
        self.Name = str(Value)
        self.Power = 0   #0 = no power, 1 is look at own card, 2 look at others card, 3 exchange card blind, 4 look and exchange
        self.SeenBy = [];

        #Setup the names
        if self.Value == 11:
            self.Name = 'Jack'
        elif self.Value == 12:
            self.Name = 'Queen'
        elif self.Value == 13:
            self.Name = 'King'
        elif self.Value == 1:
            self.Name = 'Ace'
        if self.Suit == 'joker':
            self.Name = 'joker'

        #Setup the scores
        if Value == 1:
            self.Score = -1
        if Suit == 'joker':
            self.Score = -2
        if (Suit == 'Hearts' and Value == 13) or (Suit == 'Diamonds' and Value == 13):
            self.Score = 0

        #Setup the powers
        if Value == 6 or Value == 7:
            self.Power = 1
        if Value == 8 or Value == 9:
            self.Power = 2
        if Value == 10:
            self.Power = 3
        if Value == 11:
            self.Power = 4

    def HasSeen(self,ID):
        self.SeenBy.append(ID)

class Deck:
    def __init__(self): #Create deck of cards
        self.suits = ['Spades', 'Hearts', 'Diamonds', 'Clubs']
        self.values = range(1,14)
        self.ActualCards = []
        for Suit, Value in itertools.product(self.suits,self.values):
            self.ActualCards.append(Card(Suit,Value))
        self.ActualCards.append(Card('joker',1))
        self.ActualCards.append(Card('joker',1))

    def Shuffle(self): #Shuffle cards
        random.seed(time.time())
        random.shuffle(self.ActualCards)

    def GetCard(self): #Draw card form deck and remove from deck
        CurrentCard = self.ActualCards[0]
        self.ActualCards.pop(0)
        return CurrentCard

class Player:
    def __init__(self,ID):
        self.ID = ID
        self.cards = []
        self.knownscore = 0
        self.totalscore = 0
        self.PlayCard = []
        self.covered = 0
        for i in range(0,4):
            self.cards.append(MainDeck.GetCard())
        for i in range(0,2):
            self.cards[i].HasSeen(self.ID)

    def getownscores(self):
        self.totalscore = 0
        self.knownscore = 0
        for card in self.cards:
            if self.ID in card.SeenBy:
                self.knownscore += card.Score
            self.totalscore += card.Score

    def givescores(self,ID):
        score = 0
        for card in self.cards:
            if ID in card.SeenBy:
                score += card.Score
        return score

    def PullCard(self):
        self.PlayCard = MainDeck.GetCard()
        self.PlayCard.HasSeen(self.ID)

    def TrashPulledCard(self,players):
        for player in players:
            self.PlayCard.HasSeen(player.ID)
        TrashDeck.append(self.PlayCard)
        self.PlayCard = []

    def getplayernumber(self,players,selfallowed):
        found = 0
        while True:
            playerID = input('Which player? --> ')
            playernumber = 0
            for player in players:
                if (player.ID == playerID and not player.ID == self.ID) or (player.ID == playerID and selfallowed == 1):
                    found = 1
                    break
                else:
                    playernumber += 1
            if found == 0:
                print('player not found')
            else:
                break
        return playernumber

    def PlayTurn(self,players):
        while True:
            action = input('Pull card, get trashed card, cover or double card? --> ')
            if action == 'pull card':
                self.PullCard()
                if self.PlayCard.Name == 'joker':
                    print('You pulled ' + self.PlayCard.Name)
                else:
                    print('You pulled ' + self.PlayCard.Name + ' of ' + self.PlayCard.Suit)

                if self.PlayCard.Power == 1:
                    action = input('You can look at your own cards, do you want to? --> ')
                    if action == 'yes':
                        number = int(input('Which card do you want to look at? --> '))
                        self.cards[number-1].HasSeen(self.ID)
                        self.TrashPulledCard(players)
                        break

                elif self.PlayCard.Power == 2:
                    action = input('You can look at another players card, do you want to? --> ')
                    if action == 'yes':
                        playernumber = self.getplayernumber(players,0)
                        cardnumber = int(input('Which Card? --> '))
                        players[playernumber].cards[cardnumber-1].HasSeen(self.ID)
                        validcardaction = 0
                        self.TrashPulledCard(players)
                        break

                elif self.PlayCard.Power == 3:
                    action = input('You can switch your card with another players card, do you want to --> ')
                    if action == 'yes':
                        playernumber = self.getplayernumber(players,0)
                        owncardnumber = int(input('Own card number --> '))
                        opponentcardnumber = int(input('Oponnents card number? --> '))
                        cardone = players[playernumber].cards[opponentcardnumber-1]
                        cardtwo = self.cards[owncardnumber-1]
                        players[playernumber].cards[opponentcardnumber-1] = cardtwo
                        self.cards[owncardnumber-1] = cardone
                        self.TrashPulledCard(players)
                        break

                elif self.PlayCard.Power == 4:
                    action = input('You can look and switch your card with an opponent\'s card, do you want to? --> ')
                    if action == 'yes':
                        playernumber = self.getplayernumber(players,0)
                        cardnumber = int(input('Opponents card number? --> '))
                        players[playernumber].cards[cardnumber-1].HasSeen(self.ID)
                        print('Card is ' + players[playernumber].cards[cardnumber-1].Name + ' of ' + players[playernumber].cards[cardnumber-1].Suit)
                        action = input('Do you want to switch? --> ')
                        if action == 'yes':
                            owncardnumber = int(input('With which card number? --> '))
                            cardone = players[playernumber].cards[cardnumber-1]
                            cardtwo = self.cards[owncardnumber-1]
                            players[playernumber].cards[cardnumber-1] = cardtwo
                            self.cards[owncardnumber-1] = cardone
                        self.TrashPulledCard(players)
                        break

                while True:
                    self.action = input('What do you want to do? [trash card, replace] --> ')

                    if self.action == 'trash card':
                        self.TrashPulledCard(players)
                        break

                    elif self.action == 'replace':
                        number = int(input('With which card do you want to replace? --> '))
                        self.cards[number-1], self.PlayCard = self.PlayCard, self.cards[number-1]
                        self.TrashPulledCard(players)
                        break
                    else:
                        print('invalid card action')
                break

            elif action == 'get trashed card':
                cardnumber = int(input('Which which card do you want to replace trashed card? --> '))-1
                self.PlayCard = self.cards[cardnumber]
                self.cards[cardnumber] = TrashDeck[-1]
                TrashDeck.pop(-1)
                self.TrashPulledCard(players)
                break

            elif action == 'cover':
                self.covered = 1
                break

            elif action == 'double card':
                false = 0
                while True:
                    playernumber = self.getplayernumber(players,1)
                    cardnumber = int(input('What card number is a double? --> '))-1
                    if cardnumber <= len(players[playernumber].cards):
                        if players[playernumber].cards[cardnumber].Name == TrashDeck[-1].Name:
                            self.PlayCard = players[playernumber].cards[cardnumber]
                            self.TrashPulledCard(players)
                            if players[playernumber].ID != self.ID:
                                owncardnumber = int(input('Which of your own card do you want to replace? --> ')) - 1
                                players[playernumber].cards[cardnumber], self.cards[owncardnumber] = self.cards[owncardnumber], players[playernumber].cards[cardnumber]
                                self.cards.pop(owncardnumber)
                            else:
                                players[playernumber].cards.pop(cardnumber)
                        else:
                            print('Cards arent double')
                            self.cards.append(MainDeck.GetCard())
                            false = 1
                        break
                    else:
                        print('invalid card number')
                print('Trashed card is ' + TrashDeck[-1].Name + ' of ' + TrashDeck[-1].Suit)
                outputgamestate(players,CurrentID,TrashDeck,1)
                if false == 1:
                    break

            elif action == 'quit':
                for player in players:
                    player.covered = True
                break

            else:
                'Invalid command, try again'

def outputgamestate(players,CurrentID,TrashDeck,result):
    if result == 0:
        print('-----------------------------------------------------------------------------------------------------------')
        print('-----------------------------------------------------------------------------------------------------------')
        if TrashDeck[-1].Name == 'joker':
            print('Trashed card is ' + TrashDeck[-1].Name)
        else:
            print('Trashed card is ' + TrashDeck[-1].Name + ' of ' + TrashDeck[-1].Suit)
        print(CurrentID + 's turn')
    elif result == 1:
        print('Result of '+ CurrentID + 's turn')

    for player in players:
        strings = []
        for card in player.cards:
            string = 'XXXXXXXXX'
            if CurrentID in card.SeenBy:
                string = card.Name + ' of ' + card.Suit
                if card.Name == 'joker':
                    string = 'joker'
            strings.append(string)

        knownscore = player.givescores(CurrentID)
        print(str(player.ID) + ' Cards: ' + str(strings) + ' Score = ' + str(knownscore))


if __name__ == "__main__":
    MainDeck = Deck()
    TrashDeck = []
    MainDeck.Shuffle()
    MainDeck.Shuffle()
    playernames = []
    nplayers = int(input('Number of players? --> '))
    for i in range(nplayers):
        playernames.append(input('Name of player ' + str(i+1) + '? --> '))

    players = []
    for ID in playernames:
        players.append(Player(ID))

    ind = 0
    TrashDeck.append(MainDeck.GetCard())
    for player in players:
        TrashDeck[-1].HasSeen(player.ID)

    while True:
        players[ind].getownscores()
        CurrentID = players[ind].ID
        if players[ind].covered == 1:
            print('----------------------------------------------------------------------------------------------------')
            print('----------------------------------------------------------------------------------------------------')
            print('covered player, game ended')
            break

        outputgamestate(players,CurrentID,TrashDeck,0)
        players[ind].PlayTurn(players)
        outputgamestate(players,CurrentID,TrashDeck,1)

        ind += 1
        if ind == nplayers:
            ind = 0

        if len(MainDeck.ActualCards) == 0:
            print('----------------------------------------------------------------------------------------------------')
            print('----------------------------------------------------------------------------------------------------')
            print('out of cards on main deck')
            break

    scores = [] #all scores list
    for player in players:
        player.getownscores()
        scores.append(player.totalscore)

    for player in players: #append 10 points if falsely covered
        if player.covered == 1 and player.totalscore > min(scores):
            player.totalscore += 10

    scores = []  # all scores list
    for player in players:
        scores.append(player.totalscore)

    for player in players:
        if player.totalscore == min(scores):
            winner = player.ID
            winningscore = player.totalscore
            break

    print('Winner = ' + winner + ' with a score of ' + str(winningscore))

    for player in players:
        if player.covered == 1:
            print(player.ID + ' had a total score of ' + str(player.totalscore) + ' and covered ')
        else:
            print(player.ID + ' had a total score of ' + str(player.totalscore))
