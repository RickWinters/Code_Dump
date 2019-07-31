
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
/*
    this class keeps track of the current score of the player.
    next to that it should check to which score field the dice can be applied to.
    I.e. If the dice are [1, 1, 3, 4, 6] they can be applied to either the Ones, Threes, Fours, Sixes, Change
    This can perhaps be done by defining a seperate class for each type of score with fields like 'score' and 'taken'
     */

class Scoreboard {
    int totalscore;
    private boolean gotbonus;
    private final List<String> options = new ArrayList<>();

    private final Ones ones = new Ones();
    private final Twos twos = new Twos();
    private final Threes threes = new Threes();
    private final Fours fours = new Fours();
    private final Fives fives = new Fives();
    private final Sixes sixes = new Sixes();
    private final ThreeOfaKind threeOfaKind = new ThreeOfaKind();
    private final FourOfaKind fourOfaKind = new FourOfaKind();
    private final SmallStraight smallStraight = new SmallStraight();
    private final LargeStraight largeStraight = new LargeStraight();
    private final FullHouse fullHouse = new FullHouse();
    private final Change change = new Change();
    private final Yathzee yathzee = new Yathzee();

    List<String> getOptions(Dice[] dices) {
        //counters to count how often a certain value is thrown. This can be used to see if threeofakind / fourofakind / fullhous or yathzee is possible
        int one = 0;
        int two = 0;
        int three = 0;
        int four = 0;
        int five = 0;
        int six = 0;

        for (Dice dice : dices){ //loop over each dice
            switch (dice.value){
                case 1:
                    one++;
                    if (!ones.possible && !ones.taken) {
                        ones.possible = true;
                        options.add(ones.option);
                    }
                    break;
                case 2:
                    two++;
                    if (!twos.possible && !twos.taken) {
                        twos.possible = true;
                        options.add(twos.option);
                    }
                    break;
                case 3:
                    three++;
                    if (!threes.possible && !threes.taken) {
                        threes.possible = true;
                        options.add(threes.option);
                    }
                    break;
                case 4:
                    four++;
                    if (!fours.possible && !fours.taken) {
                        fours.possible = true;
                        options.add(fours.option);
                    }
                    break;
                case 5:
                    five++;
                    if (!fives.possible && !fives.taken) {
                        fives.possible = true;
                        options.add(fives.option);
                    }
                    break;
                case 6:
                    six++;
                    if (!sixes.possible && !sixes.taken) {
                        sixes.possible = true;
                        options.add(sixes.option);
                    }
                    break;
            } //check if ones, twos etc is possible and if so add it to the options. Also
        }
        if(threeOfaKind.isPossible(new int[]{one, two, three, four, five, six}) && !threeOfaKind.taken){
            options.add(threeOfaKind.option);
        }
        if(fourOfaKind.isPossible(new int[]{one,two,three,four,five,six}) && !fourOfaKind.taken){
            options.add(fourOfaKind.option);
        }
        if(fullHouse.isPossible(new int[]{one,two,three,four,five,six})&& !fullHouse.taken){
            options.add(fullHouse.option);
        }
        if(smallStraight.isPossible(dices,new int[]{one,two,three,four,five,six}) && !smallStraight.taken){
            options.add(smallStraight.option);
        }
        if(largeStraight.isPossible(dices,new int[]{one,two,three,four,five,six}) && !largeStraight.taken){
            options.add(largeStraight.option);
        }
        if(yathzee.isPossible(new int[]{one,two,three,four,five,six}) && !yathzee.taken){
            options.add(yathzee.option);
        }
        if(change.possible){
            options.add(change.option);
        }
        return options;
    }

    void resetPossibles(){
        ones.possible = false;
        twos.possible = false;
        threes.possible = false;
        fours.possible = false;
        fives.possible = false;
        sixes.possible = false;
        threeOfaKind.possible = false;
        fourOfaKind.possible = false;
        smallStraight.possible = false;
        largeStraight.possible = false;
        fullHouse.possible = false;
        yathzee.possible = false;
        while(options.size()>0){
            options.remove(0);
        }
    }

    void applyScore(String chosen, Dice[] dices) throws WrongScoreOptionException{
        if(options.contains(chosen)){
            // check all score classes
            if(chosen.equals(ones.option)) {
                totalscore += ones.applyScore(dices);
            } else if(chosen.equals(twos.option)) {
                totalscore += twos.applyScore(dices);
            } else if(chosen.equals(threes.option)) {
                totalscore += threes.applyScore(dices);
            } else if(chosen.equals(fours.option)) {
                totalscore += fours.applyScore(dices);
            } else if(chosen.equals(fives.option)) {
                totalscore += fives.applyScore(dices);
            } else if(chosen.equals(sixes.option)) {
                totalscore += sixes.applyScore(dices);
            } else if(chosen.equals(threeOfaKind.option)){
                totalscore += threeOfaKind.applyScore(dices);
            } else if(chosen.equals(fourOfaKind.option)){
                totalscore += fourOfaKind.applyScore(dices);
            } else if(chosen.equals(fullHouse.option)){
                totalscore += fullHouse.applyScore();
            } else if(chosen.equals(smallStraight.option)){
                totalscore += smallStraight.applyScore();
            } else if(chosen.equals(largeStraight.option)){
                totalscore += largeStraight.applyScore();
            } else if(chosen.equals(yathzee.option)){
                totalscore += yathzee.applyScore();
            } else if(chosen.equals(change.option)){
                totalscore += change.applyScore(dices);
            }
            if(!gotbonus){
                totalscore += checkBonusPoints(new int[]{ones.score, twos.score, threes.score, fours.score, fives.score, sixes.score});
            }
        } else {
            throw new WrongScoreOptionException();
        }
    }

    boolean checkEndGame(){
        return (ones.taken && twos.taken && threes.taken && fours.taken &&
                fives.taken && sixes.taken && threeOfaKind.taken &&
                fourOfaKind.taken && yathzee.taken && fullHouse.taken &&
                smallStraight.taken && largeStraight.taken && change.taken);
    }

    private int checkBonusPoints(int[] scores){
        int total = 0;
        for(int score : scores){
            total += score;
        }
        if (total > 63){
            gotbonus = true;
            return 35;
        } else {
            return 0;
        }
    }

    List<String> getScratchables(){
        if (!ones.taken){
            options.add(ones.option);
        } if (!twos.taken){
            options.add(twos.option);
        } if (!threes.taken){
            options.add(threes.option);
        } if (!fours.taken){
            options.add(fours.option);
        } if (!fives.taken){
            options.add(fives.option);
        } if (!sixes.taken){
            options.add(sixes.option);
        } if (!threeOfaKind.taken){
            options.add(threeOfaKind.option);
        } if (!fourOfaKind.taken){
            options.add(fourOfaKind.option);
        } if (!fullHouse.taken){
            options.add(fullHouse.option);
        } if (!smallStraight.taken){
            options.add(smallStraight.option);
        } if (!largeStraight.taken){
            options.add(largeStraight.option);
        } if (!change.taken){
            options.add(change.option);
        } if (!yathzee.taken){
            options.add(yathzee.option);
        }
        return options;
    }

    void scratchItem(String option) throws WrongScoreOptionException{
        if(options.contains(option)){
            if (ones.option.equals(option)){
                ones.scratch();
            } else if (twos.option.equals(option)){
                twos.scratch();
            } else if (threes.option.equals(option)){
                threes.scratch();
            } else if (fours.option.equals(option)){
                fours.scratch();
            } else if (fives.option.equals(option)){
                fives.scratch();
            } else if (sixes.option.equals(option)){
                sixes.scratch();
            } else if (threeOfaKind.option.equals(option)){
                threeOfaKind.scratch();
            } else if (fourOfaKind.option.equals(option)){
                fourOfaKind.scratch();
            } else if (fullHouse.option.equals(option)){
                fullHouse.scratch();
            } else if (smallStraight.option.equals(option)){
                smallStraight.scratch();
            } else if (largeStraight.option.equals(option)){
                largeStraight.scratch();
            } else if (change.option.equals(option)){
                change.scratch();
            } else if (yathzee.option.equals(option)){
                yathzee.scratch();
            }
        } else {
            throw new WrongScoreOptionException();
        }
    }

    @Override
    public String toString() {
        int bonus = 0;
        if(gotbonus){
            bonus = 35;
        }
        return "Scoreboard: " +
                "\n totale score = " + totalscore +
                "\n [1] -------------- " + ones +
                "\n [2] -------------- " + twos +
                "\n [3] -------------- " + threes +
                "\n [4] -------------- " + fours +
                "\n [5] -------------- " + fives +
                "\n [6] -------------- " + sixes +
                "\n [bonus] ---------- " + bonus +
                "\n [drie hetzelfde] - " + threeOfaKind +
                "\n [vier hetzelfde] - " + fourOfaKind +
                "\n [kleine straat] -- " + smallStraight +
                "\n [grote straat] --- " + largeStraight +
                "\n [fullhouse] ------ " + fullHouse +
                "\n [wissel] --------- " + change +
                "\n [yatzee] --------- " + yathzee;
    }
}

class Score_option{
    boolean taken;
    boolean possible;
    int score = 0;

    public void scratch(){
        taken = true;
        score = 0;
    }

    public String toString(){
        if (!taken){
            return "x";
        } else {
            return "[" + score + "]";
        }
    }
}

class Ones extends Score_option{
    final String option = "een";

    int applyScore(Dice[] dices){
        taken = true;
        for (Dice dice: dices){
            if (dice.value==1){
                score+=1;
            }
        }
        return score;
    }

}

class Twos extends Score_option{
    final String option = "twee";

    int applyScore(Dice[] dices){
        taken = true;
        for (Dice dice: dices){
            if (dice.value==2){
                score+=2;
            }
        }
        return score;
    }
}

class Threes extends Score_option{
    final String option = "drie";

    int applyScore(Dice[] dices){
        taken = true;
        for (Dice dice: dices){
            if (dice.value==3){
                score+=3;
            }
        }
        return score;
    }
}

class Fours extends Score_option{
    final String option = "vier";

    int applyScore(Dice[] dices){
        taken = true;
        for (Dice dice: dices){
            if (dice.value==4){
                score+=4;
            }
        }
        return score;
    }
}

class Fives extends Score_option{
    final String option = "vijf";

    int applyScore(Dice[] dices){
        taken = true;
        for (Dice dice: dices){
            if (dice.value==5){
                score+=5;
            }
        }
        return score;
    }
}

class Sixes extends Score_option{
    final String option = "zes";

    int applyScore(Dice[] dices){
        taken = true;
        for (Dice dice: dices){
            if (dice.value==6){
                score+=6;
            }
        }
        return score;
    }
}

class ThreeOfaKind extends Score_option{
    final String option = "drie_hetzelfde";

    boolean isPossible(int[] counts){
        for(int count :counts){
            if (count == 3){
                possible = true;
                return true;
            }
        }
        return false;
    }

    int applyScore(Dice[] dices){
        taken = true;
        for (Dice dice: dices){
            score += dice.value;
        }
        return score;
    }
}

class FourOfaKind extends Score_option{
    final String option = "vier_hetzelfde";

    boolean isPossible(int[] counts){
        for(int count :counts){
            if (count == 4){
                possible = true;
                return true;
            }
        }
        return false;
    }

    int applyScore(Dice[] dices){
        taken = true;
        for(Dice dice: dices){
            score += dice.value;
        }
        return score;
    }
}

class FullHouse extends Score_option{
    final String option = "fullhouse";

    boolean isPossible(int[] counts){
        boolean twocounts = false;
        boolean threecounts = false;
        for(int count :counts){
            if (count == 2){
                twocounts = true;
            } else if (count == 3){
                threecounts = true;
            }
        }
        if (twocounts && threecounts){
            possible = true;
            return true;
        } else {
            return false;
        }
    }

    int applyScore(){
        taken = true;
        score = 25;
        return score;
    }
}

class SmallStraight extends Score_option{
    final String option = "kleine_straat";

    boolean isPossible(Dice[] dices, int[] counts) {
        boolean maybe = true;
        int maxSeriesLength = 0;
        int seriesLength = 1;
        for (int count : counts) {
            if (count > 2) { // to get four in a row, the remaining dice can have the same value as the row. But if there are three dice with the same value it is impossible to have four in a row.
                maybe = false;
                break;
            }
        }
        if (maybe) {
            int[] values = new int[]{dices[0].value, dices[1].value, dices[2].value, dices[3].value, dices[4].value};
            Arrays.sort(values);
            for (int i = 0; i < values.length - 1; i++) {
                if (values[i] == values[i + 1] - 1) {
                    seriesLength++;
                } else if (values[i] != values[i+1]) {
                    if (seriesLength > maxSeriesLength){
                        maxSeriesLength = seriesLength;
                    }
                    seriesLength = 1;
                }
            }
            if (seriesLength>=4){
                maxSeriesLength=4;
            }
        }
        return (maxSeriesLength == 4);
    }

    int applyScore(){
        taken = true;
        score = 30;
        return score;
    }
}

class LargeStraight extends Score_option{
    final String option = "grote_straat";

    boolean isPossible(Dice[] dices, int[] counts) {
        boolean maybe = true;
        int maxSeriesLength = 0;
        int seriesLength = 1;
        for (int count : counts) {
            if (count > 2) { // to get four in a row, the remaining dice can have the same value as the row. But if there are three dice with the same value it is impossible to have four in a row.
                maybe = false;
                break;
            }
        }
        if (maybe) {
            int[] values = new int[]{dices[0].value, dices[1].value, dices[2].value, dices[3].value, dices[4].value};
            Arrays.sort(values);
            for (int i = 0; i < values.length - 1; i++) {
                if (values[i] == values[i + 1] - 1) {
                    seriesLength++;
                } else {
                    if (seriesLength > maxSeriesLength) {
                        maxSeriesLength = seriesLength;
                    }
                    seriesLength = 1;
                }
            }
            if (seriesLength == 5) {
                maxSeriesLength = 5;
            }
        }
        return (maxSeriesLength == 5);
    }

    int applyScore(){
        taken = true;
        score = 40;
        return score;
    }
}

class Change extends Score_option{
    final String option = "wissel";
    boolean possible = true;

    int applyScore(Dice[] dices){
        possible = false;
        taken = true;
        for(Dice dice: dices){
            score += dice.value;
        }
        return score;
    }
}

class Yathzee extends Score_option{
    final String option = "yathzee";

    boolean isPossible(int[] counts){
        for(int count :counts){
            if (count == 5){
                possible = true;
                return true;
            }
        }
        return false;
    }

    int applyScore(){
        taken = true;
        score = 50;
        return score;
    }
}

class WrongScoreOptionException extends Exception{

}