import java.util.Random;

class Dice {
    static private final Random rand = new Random(); //creating a randomizer which is static for the class, so 'rand' is only saved once on the stack
    int value = 1;

    int roll() {
        this.value = rand.nextInt(6) + 1;
        return this.value;
    }
}


