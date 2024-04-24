import java.util.Random;
import java.util.concurrent.Semaphore;


class POP4 {
    public static void main(String[] args) {
        DiningPhilosophers diningPhilosophers = new DiningPhilosophers();
        diningPhilosophers.startDining();
    }
}

    enum State {
        THINKING,
        HUNGRY,
        EATING
    }

    class DiningPhilosophers {
        private final int N = 5;
        private State[] state = new State[N];
        private Semaphore[] bothForksAvailable = new Semaphore[N];
        private Random rnd = new Random();
    
        public DiningPhilosophers() {
            for (int i = 0; i < N; i++) {
                state[i] = State.THINKING;
                bothForksAvailable[i] = new Semaphore(0);
            }
        }
    
        private int left(int i) {
            return (i - 1 + N) % N;
        }
    
        private int right(int i) {
            return (i + 1) % N;
        }
    
        private int myRand(int min, int max) {
            synchronized (rnd) {
                return rnd.nextInt(max - min + 1) + min;
            }
        }
    
        private void test(int i) {
            if (state[i] == State.HUNGRY &&
                state[left(i)] != State.EATING &&
                state[right(i)] != State.EATING) {
                state[i] = State.EATING;
                bothForksAvailable[i].release();
            }
        }
        private void think(int i) throws InterruptedException {
            int duration = myRand(400, 800);
            System.out.println(i + " is thinking for " + duration + "ms");
            Thread.sleep(duration);
        }
    
        private void takeForks(int i) throws InterruptedException {
            synchronized (this) {
                state[i] = State.HUNGRY;
                System.out.println("\t\t" + i + " is HUNGRY");
                test(i);
            }
            bothForksAvailable[i].acquire();
        }
    
        private void eat(int i) throws InterruptedException {
            int duration = myRand(400, 800);
            System.out.println("\t\t\t\t" + i + " is eating for " + duration + "ms");
            Thread.sleep(duration);
        }
    
        private void putForks(int i) {
            synchronized (this) {
                state[i] = State.THINKING;
                test(left(i));
                test(right(i));
            }
        }
        private void philosopher(int i) {
            while (true) {
                try {
                    think(i);
                    takeForks(i);
                    eat(i);
                    putForks(i);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        }
    
        public void startDining() {
            Thread[] threads = new Thread[N];
            for (int i = 0; i < N; i++) {
                final int philosopherNumber = i;
                threads[i] = new Thread(() -> philosopher(philosopherNumber));
                threads[i].start();
            }
            for (Thread thread : threads) {
                try {
                    thread.join();
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        }
    }
    