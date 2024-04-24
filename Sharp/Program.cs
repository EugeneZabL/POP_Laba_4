using System;
using System.Threading;
using System.Threading.Tasks;

public enum State
{
    THINKING = 0,
    HUNGRY = 1,
    EATING = 2
}

public class DiningPhilosophers
{
    private const int N = 5;
    private State[] state = new State[N];
    private Semaphore[] bothForksAvailable = new Semaphore[N];
    private Random rnd = new Random();

    public DiningPhilosophers()
    {
        for (int i = 0; i < N; i++)
        {
            state[i] = State.THINKING;
            bothForksAvailable[i] = new Semaphore(0, 1);
        }
    }

    private int Left(int i)
    {
        return (i - 1 + N) % N;
    }

    private int Right(int i)
    {
        return (i + 1) % N;
    }

    private int MyRand(int min, int max)
    {
        lock (rnd)
        {
            return rnd.Next(min, max + 1);
        }
    }

    private void Test(int i)
    {
        if (state[i] == State.HUNGRY &&
            state[Left(i)] != State.EATING &&
            state[Right(i)] != State.EATING)
        {
            state[i] = State.EATING;
            bothForksAvailable[i].Release();
        }
    }

    private void Think(int i)
    {
        int duration = MyRand(400, 800);
        Console.WriteLine($"{i} is thinking for {duration}ms");
        Thread.Sleep(duration);
    }

    private void TakeForks(int i)
    {
        lock (this)
        {
            state[i] = State.HUNGRY;
            Console.WriteLine($"\t\t{i} is HUNGRY");
            Test(i);
        }
        bothForksAvailable[i].WaitOne();
    }

    private void Eat(int i)
    {
        int duration = MyRand(400, 800);
        Console.WriteLine($"\t\t\t\t{i} is eating for {duration}ms");
        Thread.Sleep(duration);
    }

    private void PutForks(int i)
    {
        lock (this)
        {
            state[i] = State.THINKING;
            Test(Left(i));
            Test(Right(i));
        }
    }

    private void Philosopher(object i)
    {
        while (true)
        {
            Think((int)i);
            TakeForks((int)i);
            Eat((int)i);
            PutForks((int)i);
        }
    }

    public void StartDining()
    {
       // Console.WriteLine("dp_14");

        Task[] tasks = new Task[N];
        for (int i = 0; i < N; i++)
        {
            int philosopherNumber = i;
            tasks[i] = Task.Run(() => Philosopher(philosopherNumber));
        }

        Task.WaitAll(tasks);
    }
}

class Program
{
    static void Main()
    {
        DiningPhilosophers diningPhilosophers = new DiningPhilosophers();
        diningPhilosophers.StartDining();
    }
}