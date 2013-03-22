#define iteractions 1
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
        atomic
        {
            if
                :: empty_slot > 0 -> empty_slot = empty_slot - 1;
            fi
        }
        printf("P\n");
        buffer[input] = 900 + input;
        input = (input + 1) % BUF_SIZE;
        atomic {full_slot = full_slot + 1;}
        i++;
        if
            :: i >= iteractions -> break;
        fi
    }
}


proctype Consumer() 
{
    int output = 0;

    int i;
    for (i : 0 .. iteractions)
    {
        atomic
        {
            if
                :: full_slot > 0 -> full_slot = full_slot - 1;
            fi
        }
        printf("%d\n", buffer[output]);
        output = (output + 1) % BUF_SIZE;
        atomic {empty_slot = empty_slot + 1;}
        i++;
        if
            :: i >= iteractions -> break;
        fi
    }
}

init
{
    run Producer();
    run Consumer();
}

