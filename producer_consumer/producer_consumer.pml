#define iterations 100
#define BUF_SIZE 16

int buffer[BUF_SIZE];
int empty_slot = BUF_SIZE;
int full_slot = 0;

 
proctype Producer() 
{
    int input = 0;

    int i;
    for (i : 0 .. iterations)
    {
        d_step
        {
            if
                :: empty_slot > 0 -> empty_slot = empty_slot - 1;
            fi
        }
        printf("P");
        buffer[input] = 900 + input;
        input = (input + 1) % BUF_SIZE;
        d_step {full_slot = full_slot + 1;}
    }
    printf("\nProducer terminating...\n");
}


proctype Consumer() 
{
    int output = 0;

    int i;
    for (i : 0 .. iterations)
    {
        d_step
        {
            if
                :: full_slot > 0 -> full_slot = full_slot - 1;
            fi
        }
        printf("%d", buffer[output]);
        output = (output + 1) % BUF_SIZE;
        d_step {empty_slot = empty_slot + 1;}
    }
    printf("\nConsumer terminating...\n");
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
        run Producer();
        run Consumer();
        run Monitor();
    }
}

