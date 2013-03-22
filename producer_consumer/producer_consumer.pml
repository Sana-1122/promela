#define iteractions 100
#define BUF_SIZE 16

int buffer[BUF_SIZE];
int empty_slot = BUF_SIZE;
int full_slot = 0;

 
proctype Producer() 
{
    int input = 0;

    int i;
    for (i : 0 .. iteractions)
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
    for (i : 0 .. iteractions)
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

init
{
    run Producer();
    run Consumer();
}

