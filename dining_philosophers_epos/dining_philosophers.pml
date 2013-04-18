/* Author: mateuskl - Mateus Krepsky Ludwich */
#define iterations 100
#define NUM_SEMAPHORES 5
#define NUM_PHILOSOPHERS 5
#define MAX_SEMAPHORE_CAPACITY 5
#define WAITING_QUEUE_SIZE 2 /* At most two philosophers can compete by the same chopstick, so the queue_size is 2. */

/* Semaphore */
typedef Semaphore_Channel
{
    chan proc = [0] of { int, int }
};

Semaphore_Chanell sem[NUM_SEMAPHORES];

#define p 16
#define v 22
#define go 1

/*
 * This semaphore allows having a count bigger than the initial value
*/ 
proctype Semaphore(int id, int queue_size, int initial_value) 
{
    assert(inital_value >= 0);
    
    int waiting_queue[queue_size];
    int queue_index = 0;
    int count = initial_value;
    int process_id;

    do
        if
            ::(sem[id].proc?p(process_id)) ->
             if
                 ::(count > 0) ->
                  count --;
                  sem[id].proc!go(process_id);
                 ::(count <= 0) ->
                  count --;
                  if
                      ::(queue_index < queue_size)
                       waiting_queue[queue_index] = process_id;
                       queue_index ++;
                      ::(queue_index >= queue_size)
                       printf("/nSemaphore waiting queue overflow!/n");
                  fi
             fi
             
            :: (sem[id].proc?v(process_id)) ->
             if
                 ::(count < 0) ->
                  count ++;
                  if
                      ::(queue_index > 0)
                       sem[id].proc!go(waiting_queue[queue_index-1])
                       queue_index --;
                      ::(queue_index <= 0)
                       printf("/nSemaphore underflow/n");
                  fi
                 ::(count >= 0) ->
                  count ++;
             fi
        fi
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

        first = (n < NUM_PHILOSOPHERS - 1)? n : 0;
        second = (n < NUM_PHILOSOPHERS - 1)? n + 1 : 4; 
        
        sem[first].proc!p(n);
        sem[first].proc?go(n);
        sem[second].proc!p(n);
        sem[second].proc?go(n);        

        printf("eating");

        sem[first].proc!v(n);
        sem[second].proc!v(n);
    }
    
    printf("\ndone\n");
}

/*
ltl { eventually(full_slot == BUF_SIZE) }
*/

proctype Monitor()
{
    assert(empty_slot >= 0 && empty_slot <= BUF_SIZE);
    assert(full_slot >= 0 && full_slot <= BUF_SIZE);
    /*
    assert(empty_slot + full_slot == BUF_SIZE);
    assert(empty_slot == BUF_SIZE - full_slot);
    assert(full_slot == BUF_SIZE - empty_slot);
    */
}

init
{
    atomic
    {
        sem[0] = Semaphore(0, WAITING_QUEUE_SIZE, 1);
        sem[1] = Semaphore(1, WAITING_QUEUE_SIZE, 1);
        sem[2] = Semaphore(2, WAITING_QUEUE_SIZE, 1);
        sem[3] = Semaphore(3, WAITING_QUEUE_SIZE, 1);
        sem[4] = Semaphore(4, WAITING_QUEUE_SIZE, 1);
        
        run Philosopher(0);
        run Philosopher(1);
        run Philosopher(2);
        run Philosopher(3);
        run Philosopher(4);
        
        run Monitor();
    }
}

