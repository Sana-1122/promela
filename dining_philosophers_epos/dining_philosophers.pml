/* Author: mateuskl - Mateus Krepsky Ludwich */
#define iterations 100
#define NUM_SEMAPHORES 5
#define NUM_PHILOSOPHERS 5
#define MAX_SEMAPHORE_CAPACITY 5
#define WAITING_QUEUE_SIZE 2 /* At most two philosophers can compete by the same chopstick, so the queue_size is 2. */

/* Semaphore */
typedef Semaphore_Channel
{
    chan proc = [0] of { int, int };
};

Semaphore_Channel sem[NUM_SEMAPHORES];

#define p 16
#define v 22
#define go 1

/*
 * This semaphore allows having a count bigger than the initial value
*/ 
proctype Semaphore(int id; int initial_value) 
{
    assert(initial_value >= 0);
    
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
                          printf("/nSemaphore underflow/n");
                     fi;
                    :: (count >= 0) ->
                     count ++;
                fi;
         fi;
    od
}

/* --- */



proctype Philosopher(int n) 
{
    int first;
    int second;

    int i;
    for (i : 0 .. iterations)
    {
        printf("thinking");

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

        printf("eating");

        sem[first].proc!v(n);
        sem[second].proc!v(n);
    }
    
    printf("\ndone\n");
    printf("Philosopher %n ate %n times\n", n, i);
}

/*
ltl { eventually(full_slot == BUF_SIZE) }
*/

proctype Monitor()
{
    skip;
}

init
{
    atomic
    {
        /*
        sem[0] = run Semaphore(0, 1);
        sem[1] = run Semaphore(1, 1);
        sem[2] = run Semaphore(2, 1);
        sem[3] = run Semaphore(3, 1);
        sem[4] = run Semaphore(4, 1);
        */
        
        run Philosopher(0);
        run Philosopher(1);
        run Philosopher(2);
        run Philosopher(3);
        run Philosopher(4);
        
        run Monitor();
    }
}

