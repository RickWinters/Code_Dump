import java.util.Scanner;

class YatzeeSpel {
    private final Scanner input = new Scanner(System.in);
    private final Player[] players;
    private int turn;
    private boolean run = true;
    private int nplayers;


    YatzeeSpel() {
        System.out.println("Hoeveel spelers?");
        try {
            nplayers = Integer.parseInt(input.nextLine());
        } catch (NumberFormatException nfe) {
            System.out.println("voer een getal in");
        }
        players = new Player[nplayers];

        for (int i = 0; i < nplayers; i++) {
            System.out.println("naam van speler " + (i + 1) + "? -->: ");
            players[i] = new Player(input.nextLine());
            System.out.println();
        }

        for (Player player : players) {
            System.out.println("naam = " + player.naam);
        }

    }

    void spelen() {
        while (run) {
            System.out.println("\nHet is " + players[turn].naam + "'s " + players[turn].nturns + "e beurt, druk op Enter om te beginnen, of druk op q om te stoppen");
            System.out.println(players[turn].score);
            String text = input.nextLine();
            if (text.equals("'") || text.equals("q")) {
                run = false;
            } else {
                players[turn].newturn(); //resets the blocked array to all dice can rollue
                players[turn].roll(false);
                players[turn].vasthouden();
                players[turn].roll(true);
                players[turn].vasthouden();
                players[turn].roll(false);
                System.out.println("Laatse dobbelstenen die gerold zijn " + players[turn].printDice());
                players[turn].Score();
                System.out.println("Score na deze beurt = " + players[turn].score.totalscore);

                /*
                something to ask the player where to 'put' the dice and add to the overall score.
                 */
            }

            turn++;
            if (turn == players.length) {
                turn = 0;
                if (players[turn].checkEndGame()) {
                    run = false;
                }
            }
        }


    }
}
