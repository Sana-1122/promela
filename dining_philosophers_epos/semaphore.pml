/* Semaphore */
#define SEM_OK 0
#define WAITING_QUEUE_OVERFLOW 1
#define WAITING_QUEUE_UNDERFLOW 2
#define FINISHED 3

typedef Inner_Semaphore_Type
{
    chan proc = [0] of { int, int };
    int state = SEM_OK;
    int finish;
    chan finished = [0] of {int};
};

typedef Semaphore_Type
{
    Inner_Semaphore_Type elem[NUM_SEMAPHORES_IN_EACH_ARRAY];
};

Semaphore_Type sem[NUM_SEMAPHORES_ARRAYS];

#define p 16
#define v 22
#define go 1

/*
 * This semaphore allows having a count bigger than the initial value
*/
proctype Semaphore(int n; int e; int initial_value) 
{
    assert(initial_value >= 0);

    sem[n].elem[e].state = SEM_OK;
    sem[n].elem[e].finish = 0;
    
    int waiting_queue[WAITING_QUEUE_SIZE];
    int queue_index = 0;
    int count = initial_value;
    int process_id;

    do
        :: sem[n].elem[e].finish != 1 ->
         if
             :: sem[n].elem[e].proc?p(process_id) ->                
              if
                  :: (count > 0) ->
                   count --;
                   sem[n].elem[e].proc!go(process_id);
                  :: (count <= 0) ->
                   count --;
                   if
                       :: (queue_index < WAITING_QUEUE_SIZE) ->
                        waiting_queue[queue_index] = process_id;
                        queue_index ++;
                       :: else ->
                        sem[n].elem[e].state = WAITING_QUEUE_OVERFLOW;
                        printf("/nSemaphore waiting queue overflow!/n");
                   fi;
              fi; /* p */
                     
             :: sem[n].elem[e].proc?v(process_id) ->
              if
                  :: (count < 0) ->
                   count ++;
                   if
                       :: (queue_index > 0) ->
                        sem[n].elem[e].proc!go(waiting_queue[queue_index-1]);
                        queue_index --;
                       :: else ->
                        sem[n].elem[e].state = WAITING_QUEUE_UNDERFLOW;
                        printf("/nSemaphore underflow/n");
                   fi;
                  :: (count >= 0) ->
                   count ++;
              fi; /* v */
              
             :: skip; /* continue */                    
         fi; /* p or v or nothing */
        :: else -> break
    od;
end:
    atomic
    {
        printf("destroying semaphore %d,%d\n", n, e);
        sem[n].elem[e].finished!FINISHED;
    }
    skip;
}


/* ---- */

/* Verification properties regarding Semaphores */
/*
ltl sem_safety_p0 { always ( sem[0].state == SEM_OK ) }
ltl sem_safety_p1 { always ( sem[1].state == SEM_OK ) }
ltl sem_safety_p2 { always ( sem[2].state == SEM_OK ) }
ltl sem_safety_p3 { always ( sem[3].state == SEM_OK ) }
ltl sem_safety_p4 { always ( sem[4].state == SEM_OK ) }
*/
/* ---- */
