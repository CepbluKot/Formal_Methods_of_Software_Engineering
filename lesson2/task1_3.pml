chan ch = [5] of { byte };
byte c;  
proctype Sender() {
    byte i = 'a';
    do
    :: i <= 'z' ->
        ch!i;
        i = i + 1;
    :: else ->
        break;
    od;
}

proctype Receiver() {
    progress: do
    :: ch?c ->
        printf("Got: %c\n", c);
    od;
}

init {
    run Sender();
    run Receiver();
}

ltl eventual_z { <> (c == 'z') }
