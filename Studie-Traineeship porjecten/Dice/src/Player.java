import java.util.Arrays;
import java.util.List;
import java.util.Scanner;

class Player {
    String naam;
    int nturns = 1;
    final Scoreboard score = new Scoreboard();
    //variables
    private final Dice[] dices = new Dice[5];//creates a Dice array where every dice has the value of 0
    private final int[] blocked = new int[5];
    private final Scanner input = new Scanner(System.in);

    Player(String naam) {
        this.naam = naam;
        dices[0] = new Dice();
        dices[1] = new Dice();
        dices[2] = new Dice();
        dices[3] = new Dice();
        dices[4] = new Dice();
    }

    /*
    Methods used by other methods in this class to 'help';
     */
    private boolean checkskip() { //should be 'false' if we want to continue, should be 'true' if we want to skip to the end of the turn because all the dice ase blocked from rolling
        boolean skip = true;
        for (int block : blocked) {
            if (block == 0) {
                skip = false;
                break;
            }
        }
        return !skip;
    }

    /*
    Methods that no interact with the player
     */
    String printDice() {
        return "[" + dices[0].value + " " + dices[1].value + " " + dices[2].value + " " + dices[3].value + " " + dices[4].value + "]";
    }

    /*
    Methods that control the player actions
     */

    void newturn() { //reset// s the blocked array so all dice can be thrown
        nturns++;
        for (int i = 0; i < blocked.length; i++) {
            blocked[i] = 0;
        }
        score.resetPossibles();
    }

    void roll(boolean printblocked) {
        if (checkskip()) {
            int[] result = new int[5];
            for (int i = 0; i < dices.length; i++) {
                if (blocked[i] == 0) {
                    result[i] = dices[i].roll();
                } else {
                    result[i] = dices[i].value;
                }
            }
            System.out.println(Arrays.toString(result) + " <-- dice waarden");
            if (printblocked) {
                System.out.println(Arrays.toString(blocked) + " <-- vastgezette dobbelstenen");
            }
        }
    }

    void vasthouden() {
        if (checkskip()) {
            System.out.println("Welke wil je vasthouden");
            int answer;
            while (true) {
                try {
                    answer = Integer.parseInt(input.nextLine());
                    break;
                } catch (NumberFormatException nfe) {
                    System.out.println("voer een getal in");
                }
            }
            if (answer / 100_000 >= 1) { //checks if the entered value is bigger than 5 digits, if so --> saves last 5 digits
                System.out.println("answer entered was too big, using last 5 digits");
                answer = answer % 100_000;
            }
            if (answer / 10_000 >= 1) { // if there are 5 digits, get the 5th digit and use that as an index for the blocked array, than save only the last 4 digits
                int temp = answer / 10_000;
                blocked[temp - 1] = 1;
                answer = answer % 10_000;
            }
            if (answer / 1_000 >= 1) {
                int temp = answer / 1_000;
                blocked[temp - 1] = 1;
                answer = answer % 1_000;
            }
            if (answer / 100 >= 1) { // 321
                int temp = answer / 100; //3
                blocked[temp - 1] = 1;
                answer = answer % 100; //21
            }
            if (answer / 10 >= 1) {
                int temp = answer / 10;
                blocked[temp - 1] = 1;
                answer = answer % 10;
            }
            if (answer > 0) {
                blocked[answer - 1] = 1;
            }
        }
    }

    void Score() {
        List options = score.getOptions(dices);
        if (!options.isEmpty()) {
            System.out.println("Opties zijn " + options.toString());
            System.out.println("Waar wil je een score invullen?");

            while (true) {
                try {
                    String chosen = input.nextLine();
                    score.applyScore(chosen, dices);
                    break;
                } catch (WrongScoreOptionException e) {
                    System.out.println("Input niet herkend, kies uit de opties");
                }
            }
        } else {
            options = score.getScratchables();
            if (!options.isEmpty()) {
                System.out.println("Er zijn geen opties open, welke open veld wil je weg-schrijven");
                System.out.println("de mogelijkheden zijn : " + options.toString());

                while (true) {
                    try {
                        String option = input.nextLine();
                        score.scratchItem(option);
                        break;
                    } catch (WrongScoreOptionException e) {
                        System.out.println("Input niet herkend, kies uit de opties");
                    }
                }
            }
        }
    }

    boolean checkEndGame() {
        return score.checkEndGame();
    }


    /*
    Other methods (setters and getters if needed)
     */
}
