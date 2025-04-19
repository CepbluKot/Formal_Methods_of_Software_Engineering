chan ch = [0] of { byte };
byte c;                      

active proctype Sender() {
    byte i = 'a';
    do
    :: i <= 'z' ->
        ch!i;
        i = i + 1;         
    :: else ->
        break;              
    od;                     
}

active proctype Receiver() {
    progress: do           
    :: ch?c ->
        printf("Got: %c\n", c);
    od;
    assert(c == 'z');
}

// init {
//     run Receiver();
//     run Sender();
// }
ltl eventual_z { <> (c == 'z') }
