import socket
import threading
import random
import itertools
import time
import os
from requests import get

englishstrings = ["card is ",  # 0
                  " of ",  # 1
                  " \'s turn",
                  "\'s Cards: ",
                  " Score = ",
                  "Pull card, get trashed card, cover or double card",
                  "pull card",
                  "get trashed card",
                  "Trashed",
                  "cover",
                  "double card",  # 10
                  "pulled card ",
                  "You pulled ",
                  "You can look at your own cards, do you want to?",
                  "yes",
                  "Which card do you want to look at? [input number]",
                  "looked at own card number",
                  "You can look at another players card, do you want to?",
                  "has looked at ",
                  "\'s card number ",
                  "You can switch your card with another players card, do you want to?",  # 20
                  "Own card number [input number]",
                  "Opponents card number? [input number]",
                  "has switched",
                  "with own card number ",
                  "You can look and switch your card with an opponent\'s card, do you want to?",
                  "Do you want to switch",
                  "With which card number? [input number]",
                  "and switched with own card number",
                  "What do you want to do? [trash card, replace]",
                  "trash card",  # 30
                  "replace",
                  "trashed pulled card",
                  "With which card do you want to replace? [input number]",
                  "replaced pulled card with own card number ",
                  "invalid card action",
                  "grabbed trashed card",
                  "With which card do you want to replace trashed card? [input number]",
                  "switched trashed card with own card number ",
                  "covered",
                  "thrown double card of ",  # 40
                  "What card number is a double?",
                  "Which of your own cards do you want to replace? [input number]",
                  "and switched own card number",
                  "Cards arent double, you get an extra card!",
                  "invalid card number",
                  "quit",
                  "invalid command, try again",
                  "Which player?",
                  "player not found",
                  "Player name?",  # 50
                  "Set player name to ",
                  " has ",
                  "is ",
                  "Game over: these are the results",
                  "Is there a double card?",
                  "Current cards are:"]  # 56

dutchstrings = ["kaart is ",  # 0
                  " van ",  # 1
                  " \'s beurt",
                  "\'s kaarten: ",
                  " Score = ",
                  "trek kaart, pak opgegooide kaart, cover of dubbele kaart",
                  "trek kaart",
                  "pak opgegooide kaart",
                  "opgegooid",
                  "cover",
                  "dubbele kaart",  # 10
                  "getrokken kaart ",
                  "je hebt getrokken ",
                  "Je kan je eigen kaarten bekijken, wil je dat doen?",
                  "ja",
                  "Welke kaart wil je bekijken? [nummer]",
                  "bekeek eigen kaart",
                  "Je kan een andermans kaart bekijken, wil je dat doen?",
                  "Heeft gekeken bij ",
                  "\'s kaartnummer ",
                  "Je kan wisselen met iemand anders zijn kaart, wil je dat doen?",  # 20
                  "Eigen kaart nummer? [nummer]",
                  "Tegenstander's kaart nummer? [nummer]",
                  "Heeft gewisseld",
                  "Met eigen kaart nummer ",
                  "Je kan kijken en evt. wisselen met iemand anders kaart, wil je dat doen?",
                  "Wil je wisselen?",
                  "Met welke kaart nummer? [nummer?]",
                  "en heeft gewisseld met eigen kaart nummer",
                  "Wat wil je doen? [gooi weg, vervang]",
                  "gooi weg",  # 30
                  "vervang",
                  "gooide getrokken kaart weg",
                  "Met welke kaart wil je vervangen? [nummer]",
                  "Verving getrokken kaart met eigen kaart nummer ",
                  "ongeldige actie",
                  "heeft weggegooide kaart getrokken",
                  "Met welke kaart wil je vervangen? [input number]",
                  "Heeft weggegooide kaart vervangen met eigen kaart nummer ",
                  "covered",
                  "Heeft dubbele kaart weggegooid van ",  # 40
                  "Met welke kaart nummer is het een dubbele?",
                  "Welke van je eigen kaarten wens je te vervangen? [nummer]",
                  "en heeft met eigen kaartnummer gewisseld",
                  "Kaarten zijn niet dubbel, je krijgt een extra kaart nummer",
                  "ongeldige kaart nummer",
                  "stop",
                  "ongeldige commando, probeer opnieuw",
                  "Welke speler",
                  "speler's naam bestaad niet",
                  "Je naam is?",  # 50
                  "Speler's naam opgeslagen als ",
                  " heeft ",
                  "is ",
                  "Spel is voorbij, dit zijn de resultaten",
                  "Is er een dubbele kaart?",
                  "Huidige kaarten zijn?"]

languagestrings = [englishstrings, dutchstrings]


def get_interface_ip(ifname):
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    return socket.inet_ntoa(fcntl.ioctl(s.fileno(), 0x8915, struct.pack('256s',
                                                                        ifname[:15]))[20:24])


def get_lan_ip():
    ip = socket.gethostbyname(socket.gethostname())
    if ip.startswith("127.") and os.name != "nt":
        interfaces = [
            "eth0",
            "eth1",
            "eth2",
            "wlan0",
            "wlan1",
            "wifi0",
            "ath0",
            "ath1",
            "ppp0",
        ]
        for ifname in interfaces:
            try:
                ip = get_interface_ip(ifname)
                break
            except IOError:
                pass
    return ip


def get_external_ip():
    ip = get('https://api.ipify.org').text
    return ip


class Card:
    def __init__(self, Suit, Value):  # Create a card with all the properties
        self.Suit = Suit
        self.Value = Value
        self.Score = Value
        self.Name = str(Value)
        self.Power = 0  # 0 = no power, 1 is look at own card, 2 look at others card, 3 exchange card blind, 4 look and exchange
        self.SeenBy = [];

        # Setup the names
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

        # Setup the scores
        if Value == 1:
            self.Score = -1
        if Suit == 'joker':
            self.Score = -2
        if (Suit == 'Hearts' and Value == 13) or (Suit == 'Diamonds' and Value == 13):
            self.Score = 0

        # Setup the powers
        if Value == 6 or Value == 7:
            self.Power = 1
        if Value == 8 or Value == 9:
            self.Power = 2
        if Value == 10:
            self.Power = 3
        if Value == 11:
            self.Power = 4

    def HasSeen(self, ID):
        self.SeenBy.append(ID)


class Deck:
    def __init__(self):  # Create deck of cards
        self.suits = ['Spades', 'Hearts', 'Diamonds', 'Clubs']
        self.values = range(1, 14)
        self.ActualCards = []
        for Suit, Value in itertools.product(self.suits, self.values):
            self.ActualCards.append(Card(Suit, Value))
        self.ActualCards.append(Card('joker', 1))
        self.ActualCards.append(Card('joker', 1))

    def Shuffle(self):  # Shuffle cards
        random.seed(time.time())
        random.shuffle(self.ActualCards)

    def GetCard(self):  # Draw card form deck and remove from deck
        CurrentCard = self.ActualCards[0]
        self.ActualCards.pop(0)
        return CurrentCard


class player:
    def __init__(self, connection, ID, portnum):
        self.connection = connection
        self.ID = ID
        self.number = ID
        self.closeconnection = False
        self.lastmessage = []
        self.status = []
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        server_address = (get_lan_ip(), portnum)
        sock.bind(server_address)
        sock.listen(1)
        self.connection.sendall(bytes('newport = ' + str(portnum),'utf-8'))
        connection, client_address = sock.accept()
        self.connection = connection

    def reset(self):
        self.CurrentID = 0
        self.cards = []
        self.knownscore = 0
        self.restarting = False
        self.totalscore = 0
        self.PlayCard = []
        self.covered = 0
        self.ncards = 4
        self.startgame = False
        self.sendwait = False
        self.Turn = False
        self.admin = False
        self.sendgamestate = False
        self.whosTurn = self.ID
        self.stopgame = False
        self.sendendstate = False
        self.throwingdouble = False
        for i in range(0, 4):
            self.cards.append(MainDeck.GetCard())
        for i in range(0, 2):
            self.cards[i].HasSeen(self.ID)
        if self.number == 0:
            self.admin = True

    def seecards(self):  # this function gets called after ID is set to a string
        for i in range(0, 2):
            self.cards[i].HasSeen(self.ID)

    def outputgamestate(self, players, TrashDeck, result):
        if result == 1:
            send_msg('--------------------------------------------------------------------------------------------', self,
                     self.ID)
            send_msg('--------------------------------------------------------------------------------------------', self,
                     self.ID)
            send_msg(str(self.whosTurn) + languagestrings[self.language][2], self, self.ID)
        elif result == 0:
            send_msg(languagestrings[self.language][56], self, self.ID)
        elif result == 2:
            send_msg('--------------------------------------------------------------------------------------------', self,
                     self.ID)
            send_msg('--------------------------------------------------------------------------------------------', self,
                     self.ID)
            send_msg('--------------------------------------------------------------------------------------------', self,
                     self.ID)
            send_msg('--------------------------------------------------------------------------------------------', self,
                     self.ID)
            send_msg(languagestrings[self.language][54], self, self.ID)

        if TrashDeck[-1].Name == 'joker':
            send_msg(
                languagestrings[self.language][8] + ' ' + languagestrings[self.language][0] + TrashDeck[-1].Name,
                self, self.ID)
        else:
            send_msg(
                languagestrings[self.language][8] + ' ' + languagestrings[self.language][0] + TrashDeck[-1].Name +
                languagestrings[self.language][1] + TrashDeck[-1].Suit, self, self.ID)
        for player in players:
            strings = []
            for card in player.cards:
                string = 'XXXXXXXXX'
                if self.ID in card.SeenBy:
                    string = card.Name + languagestrings[self.language][1] + card.Suit
                    if card.Name == 'joker':
                        string = 'joker'
                strings.append(string)

            knownscore = player.givescores(self.ID)
            # players cards: [card1, card2, card3, card4], score = 'knownscore'
            send_msg(str(player.ID) + languagestrings[self.language][3] + str(strings) + languagestrings[self.language][
                4] + str(knownscore), self, self.ID)

    def askinfo(self):
        send_msg('select language, selecteer taal', self, self.number)
        send_msg('For english type: en', self, self.number)
        send_msg('Voor Nederelands type: nl', self, self.number)
        send_msg('request: ', self, self.number)
        language = tostr(self.connection.recv(1024))
        if language == 'nl':
            self.language = 1
        else:
            self.language = 0
        print('player number ' + str(self.number) + ' set language to ' + language)
        send_msg('request: ' + languagestrings[self.language][50], self, self.number)
        self.ID = tostr(self.connection.recv(1024))
        print('player number ' + str(self.number) + ' has set name to ' + self.ID)
        send_msg(languagestrings[self.language][51], self, self.ID)
        TrashDeck[-1].HasSeen(self.ID)

    def getownscores(self):
        self.totalscore = 0
        self.knownscore = 0
        for card in self.cards:
            if self.ID in card.SeenBy:
                self.knownscore += card.Score
            self.totalscore += card.Score

    def givescores(self, ID):
        score = 0
        for card in self.cards:
            if ID in card.SeenBy:
                score += card.Score
        return score

    def PullCard(self):
        self.PlayCard = MainDeck.GetCard()
        self.PlayCard.HasSeen(self.ID)

    def TrashPulledCard(self, players):
        for player in players:
            self.PlayCard.HasSeen(player.ID)
        TrashDeck.append(self.PlayCard)
        self.PlayCard = []

    def getplayernumber(self, players, selfallowed):
        found = 0
        while True:
            send_msg('request: ' + languagestrings[self.language][48], self, self.ID)
            playerID = tostr(self.connection.recv(1024))
            playernumber = 0
            for player in players:
                if (player.ID == playerID and not player.ID == self.ID) or (player.ID == playerID and selfallowed == 1):
                    found = 1
                    break
                else:
                    playernumber += 1
            if found == 0:
                send_msg(languagestrings[self.language][49], self, self.ID)
            else:
                break
        return playernumber

    def sendaction(self, players, action):
        for player in players:
            string = player.whosTurn + str(languagestrings[player.language][52])
            if player.ID != self.ID:
                for i in range(len(action)):
                    if type(action[i]) == int:
                        string = string + languagestrings[player.language][action[i]]
                    else:
                        string = string + ' ' + action[i]
                send_msg(string, player, player.ID)

    def doublecard(self, players):
        didaction = [40]
        false = 0
        while True:
            playernumber = self.getplayernumber(players, 1)
            # What card number is a double?
            while True:
                send_msg('request: ' + languagestrings[self.language][41], self, self.ID)
                cardnumber = int(tostr(self.connection.recv(1024))) - 1
                if cardnumber <= players[playernumber].ncards:
                    break
                else:
                    send_msg(languagestrings[self.language][45], self, self.ID)

            if cardnumber <= len(players[playernumber].cards):
                if players[playernumber].cards[cardnumber].Name == TrashDeck[-1].Name:
                    # didacion = 'playerID', 's card number, 'cardnumber'
                    didaction.append(str(players[playernumber].ID))
                    didaction.append(19)
                    didaction.append(str(cardnumber + 1))
                    self.PlayCard = players[playernumber].cards[cardnumber]
                    self.TrashPulledCard(players)
                    if players[playernumber].ID != self.ID:
                        # Which of your own cards do you want to replace
                        send_msg('request: ' + languagestrings[self.language][42], self, self.ID)
                        owncardnumber = int(tostr(self.connection.recv(1024))) - 1
                        players[playernumber].cards[cardnumber], self.cards[owncardnumber] = self.cards[
                                                                                                 owncardnumber], \
                                                                                             players[
                                                                                                 playernumber].cards[
                                                                                                 cardnumber]
                        self.cards.pop(owncardnumber)
                        # didaction + and switched own card number, 'owncardnumber'
                        didaction.append(43)
                        didaction.append(str(owncardnumber + 1))
                    else:
                        players[playernumber].cards.pop(cardnumber)
                    self.ncards -= 1
                    self.sendaction(players, didaction)
                else:
                    # Cards arent double
                    send_msg(languagestrings[self.language][44], self, self.ID)
                    self.cards.append(MainDeck.GetCard())
                    false = 1
                break
            else:
                # invalid card number
                send_msg(languagestrings[self.language][45], self, self.ID)
            self.outputgamestate(players, TrashDeck, 1)
            # Trashed, card is, 'cardname', of, 'cardsuit
            send_msg(
                languagestrings[self.language][8] + ' ' + languagestrings[self.language][0] + TrashDeck[-1].Name +
                languagestrings[self.language][1] + TrashDeck[-1].Suit, self, self.ID)
            if false == 1:
                break

    def PlayTurn(self, players):
        while True:
            # Pull card, get trashed card, cover, or double card
            send_msg('request: ' + languagestrings[self.language][5], self, self.ID)
            action = tostr(self.connection.recv(1024))
            # if action == pull card
            if action == languagestrings[self.language][6]:
                # player pulled card
                self.sendaction(players, [11])
                self.PullCard()
                if self.PlayCard.Name == 'joker':
                    # pulled card is 'cardname'
                    send_msg(languagestrings[self.language][11] + self.PlayCard.Name, self, self.ID)
                else:
                    # pulled card is 'cardname' of 'cardsuit'
                    send_msg(
                        languagestrings[self.language][11] + languagestrings[self.language][53] + self.PlayCard.Name +
                        languagestrings[self.language][1] + self.PlayCard.Suit, self, self.ID)

                if self.PlayCard.Power == 1:
                    # you can look at your own cards, do you want to
                    send_msg('request: ' + languagestrings[self.language][13], self, self.ID)

                    action = tostr(self.connection.recv(1024))
                    # if action == yes
                    if action == languagestrings[self.language][14]:
                        # Which card do you want to look at
                        while True:
                            send_msg('request: ' + languagestrings[self.language][15], self, self.ID)
                            number = int(tostr(self.connection.recv(1024))) - 1
                            if number <= self.ncards:
                                self.cards[number].HasSeen(self.ID)
                                self.TrashPulledCard(players)
                                # player looked at own card number
                                self.sendaction(players, [16, str(number)])
                                break
                            else:
                                send_msg(languagestrings[self.language][45], self, self.ID)

                        break

                elif self.PlayCard.Power == 2:
                    # You can look at another players card, do you want to?
                    send_msg('request: ' + languagestrings[self.language][17], self, self.ID)
                    action = tostr(self.connection.recv(1024))
                    # if action == yes
                    if action == languagestrings[self.language][14]:
                        playernumber = self.getplayernumber(players, 0)
                        # Which card do you want to look at
                        while True:
                            send_msg('request: ' + languagestrings[self.language][15], self, self.ID)
                            cardnumber = int(tostr(self.connection.recv(1024)))-1
                            if cardnumber <= players[playernumber].ncards:
                                players[playernumber].cards[cardnumber].HasSeen(self.ID)
                                self.TrashPulledCard(players)
                                # player has looked at 'playernumber' 's card number 'cardnumber'
                                self.sendaction(players, [18, str(players[playernumber].ID), 19, str(cardnumber)])
                                break
                            else:
                                send_msg(languagestrings[self.language][45], self, self.ID)
                        break

                elif self.PlayCard.Power == 3:
                    # you can switch your card with anothers player's card, do you want to?
                    send_msg('request: ' + languagestrings[self.language][20], self, self.ID)
                    action = tostr(self.connection.recv(1024))
                    # if action == yes
                    if action == languagestrings[self.language][14]:
                        playernumber = self.getplayernumber(players, 0)
                        # Opponents card number?
                        while True:
                            send_msg('request: ' + languagestrings[self.language][22], self, self.ID)
                            opponentcardnumber = int(tostr(self.connection.recv(1024)))-1
                            if opponentcardnumber <= players[playernumber].ncards:
                                break
                            else:
                                send_msg(languagestrings[self.language][45], self, self.ID)
                        # Own card number?
                        while True:
                            send_msg('request: ' + languagestrings[self.language][21], self, self.ID)
                            owncardnumber = int(tostr(self.connection.recv(1024)))-1
                            if owncardnumber <= self.ncards:
                                break
                            else:
                                send_msg(languagestrings[self.language][45], self, self.ID)
                        cardone = players[playernumber].cards[opponentcardnumber]
                        cardtwo = self.cards[owncardnumber]
                        players[playernumber].cards[opponentcardnumber] = cardtwo
                        self.cards[owncardnumber] = cardone
                        self.TrashPulledCard(players)
                        # has switched 'playernumbers' 's card number 'oppnentcardnumber' with own card number 'owncardnumber'
                        self.sendaction(players, [23, str(players[playernumber].ID), 19, str(opponentcardnumber-1), 24,
                                                  str(owncardnumber+1)])
                        break

                elif self.PlayCard.Power == 4:
                    # You can look and switch your card with an opponent\'s card, do you want to?
                    send_msg('request: ' + languagestrings[self.language][25], self, self.ID)
                    action = tostr(self.connection.recv(1024))
                    # if action == yes
                    if action == languagestrings[self.language][14]:
                        playernumber = self.getplayernumber(players, 0)
                        # oppenents card number
                        while True:
                            send_msg('request: ' + languagestrings[self.language][22], self, self.ID)
                            cardnumber = int(tostr(self.connection.recv(1024)))-1
                            if cardnumber <= players[playernumber].ncards:
                                break
                            else:
                                send_msg(languagestrings[self.language][45], self, self.ID)
                        players[playernumber].cards[cardnumber].HasSeen(self.ID)
                        # card is 'playernumber's card 'cardnumber'' of 'cardsuit'
                        send_msg(languagestrings[self.language][0] + players[playernumber].cards[cardnumber].Name +
                                 languagestrings[self.language][1] + self.PlayCard.Suit, self, self.ID)
                        # do you want to switch.
                        send_msg('request: ' + languagestrings[self.language][26], self, self.ID)
                        action = tostr(self.connection.recv(1024))
                        # didaction = (has looked at, 'playernumber.id', 's card number, 'cardnumber')
                        didaction = [18, str(players[playernumber].ID), 19, str(cardnumber + 1)]
                        # if action == yes
                        if action == languagestrings[self.language][14]:
                            # Wich which card number
                            while True:
                                send_msg('request: ' + languagestrings[self.language][27], self, self.ID)
                                owncardnumber = int(tostr(self.connection.recv(1024))) - 1
                                if owncardnumber <= self.ncards:
                                    break
                                else:
                                    send_msg(languagestrings[self.language][45], self, self.ID)
                            cardone = players[playernumber].cards[cardnumber]
                            cardtwo = self.cards[owncardnumber]
                            players[playernumber].cards[cardnumber] = cardtwo
                            self.cards[owncardnumber] = cardone
                            # didaction  = append(and switched with own card number, str(owncardnumber))
                            didaction.append(28)
                            didaction.append(str(owncardnumber + 1))
                        self.TrashPulledCard(players)
                        self.sendaction(players, didaction)
                        break

                while True:
                    # what do you want to do? [trash card, replace]
                    send_msg('request: ' + languagestrings[self.language][29], self, self.ID)
                    self.action = tostr(self.connection.recv(1024))

                    # if action == trash card
                    if self.action == languagestrings[self.language][30]:
                        self.TrashPulledCard(players)
                        # thrashed pulled card
                        self.sendaction(players, [32])
                        break

                    # if action == replace
                    elif self.action == languagestrings[self.language][31]:
                        # With which card do you want to replace?
                        while True:
                            send_msg('request: ' + languagestrings[self.language][33], self, self.ID)
                            number = int(tostr(self.connection.recv(1024)))
                            if number <= self.ncards:
                                self.cards[number - 1], self.PlayCard = self.PlayCard, self.cards[number - 1]
                                self.TrashPulledCard(players)
                                # player has replaced pulled card with own card number, 'card number'
                                self.sendaction(players, [34, str(number)])
                                break
                            else:
                                send_msg(languagestrings[self.language][45], self, self.ID)
                        break
                    else:
                        # invalid card action
                        send_msg(languagestrings[self.language][35], self, self.ID)
                break

            # if action == get trashed card
            elif action == languagestrings[self.language][7]:
                # player grabbed trashed card
                self.sendaction(players, [36])
                # With which card do you want to replace trashed card?
                while True:
                    send_msg('request: ' + languagestrings[self.language][37], self, self.ID)
                    cardnumber = int(tostr(self.connection.recv(1024))) - 1
                    if cardnumber <= self.ncards:
                        self.PlayCard = self.cards[cardnumber]
                        self.cards[cardnumber] = TrashDeck[-1]
                        TrashDeck.pop(-1)
                        self.TrashPulledCard(players)
                        # player switched trashed card with own card number, 'cardnumber'
                        self.sendaction(players, [38, str(cardnumber + 1)])
                        break
                    else:
                        send_msg(languagestrings[self.language][45], self, self.ID)
                break

            # if action == cover
            elif action == languagestrings[self.language][9]:
                # player has covered
                self.sendaction(players, [39])
                self.covered = 1
                break

            # if action == double card
            elif action == languagestrings[self.language][10]:
                # didaction = thrown double card of
                self.doublecard(players)
                self.outputgamestate(players, TrashDeck, 0)

            # if action == quit
            elif action == languagestrings[self.language][46]:
                for player in players:
                    player.covered = True
                break

            elif action == 'R120795w%':
                admin_output(players,self)

            # invalid command, try again
            else:
                send_msg(languagestrings[self.language][47], self, self.ID)

        while True and not self.covered:
            self.outputgamestate(players, TrashDeck, 0)
            send_msg("request: " + languagestrings[self.language][55], self, self.ID)
            action = tostr(self.connection.recv(1024))
            if action == languagestrings[self.language][14]:
                self.doublecard(players)
            else:
                break


def tostr(data):
    data = str(data)
    data = data[2:]
    data = data[:-1]

    return data


# Main chatloop of the thread when a client connects
def chatloop(player):
    global players, CurrentID, MainDeck, TrashDeck, startgame, stopgame, languagestrings
    player.askinfo()
    player.seecards()
    while True:  # main game loop on player thread
        # Closes all connections and pops players from the list in order to reset
        if player.closeconnection and player.admin:
            while len(players) > 0:
                send_msg('stop', players[0], players[0].ID)
                players[0].connection.close()
                players.pop(0)
            break

        # if the game has started and it is the players turn
        if player.startgame and player.Turn:
            # If covered, the players thread sets variables in each player in order to have the admin stop/restart the game
            if player.covered:
                for x in players:
                    x.stopgame = True
                    x.restarting = True
                    x.startgame = False
            # Else, output the game state and have the player do a turn
            else:
                player.outputgamestate(players, TrashDeck, 1)
                player.PlayTurn(players)
                # player.outputgamestate(players, TrashDeck, 1)

                # loop over all players changing the turn and resetting variables
                for x in players:
                    x.Turn = False
                    x.sendgamestate = False
                    x.throwingdouble = False
                    x.CurrentID += 1
                    if x.CurrentID == len(players):
                        x.CurrentID = 0
                players[player.CurrentID].Turn = True
                whosTurn = players[player.CurrentID].ID
                for x in players:
                    x.whosTurn = whosTurn

        # if its not the players turn, send game state once
        elif player.startgame and not player.Turn and not player.sendgamestate:
            player.outputgamestate(players, TrashDeck, 1)
            # Wait for players turn
            send_msg('Wait for ' + player.whosTurn + '\'s turn', player, player.ID)
            player.sendgamestate = True

        # Send the end state of the game when a game has ended, showing all the cards
        elif not player.startgame and not player.sendendstate and player.restarting:
            # game over, these are the results
            for x in players:
                for y in x.cards:
                    y.HasSeen(player.ID)
            player.outputgamestate(players, TrashDeck, 2)
            player.sendendstate = True
            if not player.admin:
                send_msg('Wait for admin to restart game', player, player.ID)

        # if the game has ended and waiting for restart, ask admin
        elif not player.startgame and player.admin and player.restarting:
            send_msg('request: send \'yes\' to restart the game, or \'stop\' to stop the game', player,
                     player.ID)
            # do the handling of stopping the threads or restarting the game
            answer = tostr(player.connection.recv(1024))
            if answer == 'yes':
                MainDeck = Deck()
                MainDeck.Shuffle()
                MainDeck.Shuffle()
                TrashDeck.append(MainDeck.GetCard())
                for x in players:
                    x.reset()
                    if x.number == 0:
                        x.admin = True
            elif answer == 'stop':
                for x in players:
                    x.closeconnection = True
            else:
                send_msg('invalid answer', player, player.ID)

        # if the game has not started yet, and player is admin. ask for 'start'
        elif not player.startgame and player.admin and not player.restarting:
            send_msg('request: send \'start\' to start game', player, player.ID)
            answer = tostr(player.connection.recv(1024))
            if answer == 'start':
                random.shuffle(players)
                players[0].Turn = True
                for x in players:
                    x.startgame = True
                    x.whosTurn = players[0].ID
            else:
                pass

        # if player is not the admin, send wait once and wait for admin to start
        elif not player.startgame and not player.admin and not player.sendwait and not player.restarting:
            send_msg('Pleas wait for admin to start game', player, player.ID)
            player.sendwait = True

        time.sleep(0.1)


def send_msg(message, player, ID):
    player.lastmessage = message
    player.status = 'sending'
    while True:
        starttime = time.time()
        player.connection.sendall(bytes(message, 'utf-8'))
        player.status = 'send message'
        print("send: " + message + ' to ' + str(ID))
        returnmessage = ''
        while returnmessage == '':
            returnmessage = tostr(player.connection.recv(1024))
        if returnmessage == message:
            player.connection.sendall(bytes('ok', 'utf-8'))
            intertime = round((time.time() - starttime)*1000)
            print('waitng for confirmation form ' + str(ID) +' took: ' + str(intertime) + 'ms')
            player.status = 'send ok'
            stoptime = round((time.time() - starttime)*1000)
            print('message arrived at ' + str(ID) + ' ok, confirmation took: ' + str(stoptime) + 'ms')
            returnmessage = tostr(player.connection.recv(1024))
            if returnmessage == 'ok':
                break
        else:
            print('message not returned correctly from ' + str(ID) + ', returned message is ' + returnmessage)
            player.status = 'not received ok'
        time.sleep(0.01)


def admin_output(players,admin):
    for player in players:
        send_msg('last send message to ' + player.ID + ' = ' + player.lastmessage,admin,admin.ID)
        send_msg('message status: ' + player.status,admin,admin.ID)
        send_msg('Turn = ' + str(player.Turn),admin,admin.ID)
        string = []
        for card in player.cards:
            string.append(card.Name + ' of ' + card.Suit)
        send_msg('Cards: ' + str(string), admin, admin.ID)



if __name__ == "__main__":
    get_external_ip()
    # for i in range(len(dutchstrings)):
    #    print('dutch = '+dutchstrings[i] + '   english = '+englishstrings[i])

    stopgame = False
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    # sock.settimeout(2)
    server_address = (get_lan_ip(), 10000)
    portnum = 10001
    print('starting up server on ' + server_address[0] + ' on port ' + str(server_address[1]))
    print('External adress is ' + get_external_ip())
    sock.bind(server_address)
    sock.listen(4)
    players = []
    print('waiting for connection')

    MainDeck = Deck()
    TrashDeck = []
    MainDeck.Shuffle()
    MainDeck.Shuffle()
    TrashDeck.append(MainDeck.GetCard())

    startgame = False

    while True:
        connection, client_address = sock.accept()
        players.append(player(connection, len(players), portnum))
        portnum += 1
        players[-1].reset()
        print('connection received form ' + client_address[0] + ' on port ' + str(client_address[1]))
        CurrentID = 0
        cThread = threading.Thread(target=chatloop, args=(players[-1],))
        cThread.daemon = True
        cThread.start()
