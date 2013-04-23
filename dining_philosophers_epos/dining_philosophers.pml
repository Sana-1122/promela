/* Author: mateuskl - Mateus Krepsky Ludwich */
#define iterations 1
#define NUM_PHILOSOPHERS 5
#define NUM_SEMAPHORES_IN_EACH_ARRAY NUM_PHILOSOPHERS
#define NUM_SEMAPHORES_ARRAYS 1
#define WAITING_QUEUE_SIZE 2 /* At most two philosophers can compete by the same chopstick, so the queue_size is 2. */

#include "semaphore.pml"

#define chopstick 0

/* Philosopher */
#define THINKING 0
#define EATING 1
#define DONE 2

int ate_times[NUM_PHILOSOPHERS];
chan phil_done[NUM_PHILOSOPHERS] = [0] of { int };

int phil_state[NUM_PHILOSOPHERS];

proctype Philosopher(int n) 
{
    int first;
    int second;

    int i;
    for (i : 0 .. iterations - 1)
    {
        atomic
        {
            phil_state[n] = THINKING;
            printf("P%dT, ", n); /* thinking */
        }

        if
            :: (n < NUM_PHILOSOPHERS - 1) ->
             first = n;
             second = n + 1;
            :: else ->
             first = 0;
             second = NUM_PHILOSOPHERS - 1;
        fi;

        sem[chopstick].elem[first].proc!p(n);
        sem[chopstick].elem[first].proc?go(n);
        sem[chopstick].elem[second].proc!p(n);
        sem[chopstick].elem[second].proc?go(n);        

        atomic
        {
            phil_state[n] = EATING;
            printf("P%dE, ", n); /* eating */
        }

        sem[chopstick].elem[first].proc!v(n);
        sem[chopstick].elem[second].proc!v(n);
    }

    atomic
    {
        phil_state[n] = DONE;
        /* printf("\ndone\n"); */
        ate_times[n] = i;
        phil_done[n]!DONE;
    }
}

/* ---- */


/* Verification properties regarding Philosophers and the application */
ltl safety_p01 { always !( (phil_state[0] == EATING) && (phil_state[1] == EATING) ) }
ltl safety_p02 { always !( (phil_state[1] == EATING) && (phil_state[2] == EATING) ) }
ltl safety_p03 { always !( (phil_state[2] == EATING) && (phil_state[3] == EATING) ) }
ltl safety_p04 { always !( (phil_state[3] == EATING) && (phil_state[4] == EATING) ) }
ltl safety_p05 { always !( (phil_state[4] == EATING) && (phil_state[0] == EATING) ) }

ltl fairness_p01 { (phil_state[0] == DONE) -> (ate_times[0] == iterations) }
ltl fairness_p02 { (phil_state[1] == DONE) -> (ate_times[1] == iterations) }
ltl fairness_p03 { (phil_state[2] == DONE) -> (ate_times[2] == iterations) }
ltl fairness_p04 { (phil_state[3] == DONE) -> (ate_times[3] == iterations) }
ltl fairness_p05 { (phil_state[4] == DONE) -> (ate_times[4] == iterations) }

ltl concurrency_p01 { eventually ( (phil_state[0] == EATING) && (phil_state[2] == EATING) ) }
ltl concurrency_p02 { eventually ( (phil_state[0] == EATING) && (phil_state[3] == EATING) ) }
ltl concurrency_p03 { eventually ( (phil_state[1] == EATING) && (phil_state[3] == EATING) ) }
ltl concurrency_p04 { eventually ( (phil_state[1] == EATING) && (phil_state[4] == EATING) ) }
ltl concurrency_p05 { eventually ( (phil_state[2] == EATING) && (phil_state[4] == EATING) ) }

ltl termination { eventually ( (phil_state[0] == DONE) &&
                   (phil_state[1] == DONE) &&
                   (phil_state[2] == DONE) &&
                   (phil_state[3] == DONE) &&
                   (phil_state[4] == DONE) )}

/* ---- */

proctype Monitor()
{
    skip;
}

init
{
    atomic
    {
        int i;

        for (i : 0 .. NUM_PHILOSOPHERS - 1)
        {
            phil_state[i] = THINKING;
        }
        
        run Semaphore(chopstick, 0, 1);
        run Semaphore(chopstick, 1, 1);
        run Semaphore(chopstick, 2, 1);
        run Semaphore(chopstick, 3, 1);
        run Semaphore(chopstick, 4, 1);
        
        run Philosopher(0);
        run Philosopher(1);
        run Philosopher(2);
        run Philosopher(3);
        run Philosopher(4);
        
        run Monitor();

        
        
        for (i : 0 .. NUM_PHILOSOPHERS - 1)
        {
            phil_done[i]?DONE;
            atomic
            {
                printf("\nPhilosopher %d ate %d times\n", i, ate_times[i]);
            }
        }

        for (i : 0 .. NUM_PHILOSOPHERS - 1)
        {
            /*
            atomic
            {
                printf("");
            }
            */
            
        }
       
    }
}

