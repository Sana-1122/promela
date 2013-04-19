/* Author: mateuskl - Mateus Krepsky Ludwich */
#define iterations 1
#define NUM_SEMAPHORES 5
#define NUM_PHILOSOPHERS 5
#define MAX_SEMAPHORE_CAPACITY 5
#define WAITING_QUEUE_SIZE 2 /* At most two philosophers can compete by the same chopstick, so the queue_size is 2. */

/* Semaphore */
#define SEM_OK 0
#define WAITING_QUEUE_OVERFLOW 1
#define WAITING_QUEUE_UNDERFLOW 2

typedef Semaphore_Type
{
    chan proc = [0] of { int, int };
    int state = SEM_OK;
};

Semaphore_Type sem[NUM_SEMAPHORES];

#define p 16
#define v 22
#define go 1

/*
 * This semaphore allows having a count bigger than the initial value
*/ 
proctype Semaphore(int id; int initial_value) 
{
    assert(initial_value >= 0);

    sem[id].state = SEM_OK;
    
    int waiting_queue[WAITING_QUEUE_SIZE];
    int queue_index = 0;
    int count = initial_value;
    int process_id;

    do
        :: if
               :: sem[id].proc?p(process_id) ->                
                if
                    :: (count > 0) ->
                     count --;
                     sem[id].proc!go(process_id);
                    :: (count <= 0) ->
                     count --;
                     if
                         :: (queue_index < WAITING_QUEUE_SIZE) ->
                          waiting_queue[queue_index] = process_id;
                          queue_index ++;
                         :: else ->
                          sem[id].state = WAITING_QUEUE_OVERFLOW;
                          printf("/nSemaphore waiting queue overflow!/n");
                     fi;
                fi;
             
               :: sem[id].proc?v(process_id) ->
                if
                    :: (count < 0) ->
                     count ++;
                     if
                         :: (queue_index > 0) ->
                          sem[id].proc!go(waiting_queue[queue_index-1]);
                          queue_index --;
                         :: else ->
                          sem[id].state = WAITING_QUEUE_UNDERFLOW;
                          printf("/nSemaphore underflow/n");
                     fi;
                    :: (count >= 0) ->
                     count ++;
                fi;
         fi;
    od
}


/* ---- */

/* Verification properties regarding Semaphores */
ltl sem_safety_p0 { always ( sem[0].state == SEM_OK ) }
ltl sem_safety_p1 { always ( sem[1].state == SEM_OK ) }
ltl sem_safety_p2 { always ( sem[2].state == SEM_OK ) }
ltl sem_safety_p3 { always ( sem[3].state == SEM_OK ) }
ltl sem_safety_p4 { always ( sem[4].state == SEM_OK ) }

/* ---- */

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

        sem[first].proc!p(n);
        sem[first].proc?go(n);
        sem[second].proc!p(n);
        sem[second].proc?go(n);        

        atomic
        {
            phil_state[n] = EATING;
            printf("P%dE, ", n); /* eating */
        }

        sem[first].proc!v(n);
        sem[second].proc!v(n);
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
        
        run Semaphore(0, 1);
        run Semaphore(1, 1);
        run Semaphore(2, 1);
        run Semaphore(3, 1);
        run Semaphore(4, 1);
        
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
       
    }
}

