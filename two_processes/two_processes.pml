proctype Alpha() 
{
    printf("A");
}


proctype Beta() 
{
    printf("B");
}


init
{
    run Alpha();
    run Beta();
}
