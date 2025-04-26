#define TARGET_LEN 13

bool matched = false;
byte pos;
chan ch = [0] of { byte }; 

byte target[TARGET_LEN] = {
    't','o','b','e','o','r','n','o','t','t','o','b','e'
};

proctype Monkey(byte c) {
    do
    :: matched        -> break;   /* если уже найдено — выходим */
    :: !matched       -> ch!c;    /* иначе шлём букву */
    od;
}

proctype Reviewer() {
    byte received;
    pos = 0;
    do
    :: ch?received -> 
        if
        :: received == target[pos] -> 
            pos++;
            if
            :: pos == TARGET_LEN -> 
                matched = true;
                break
            :: else -> skip 
            fi
        :: else ->
            pos = 0;
            if
            :: received == target[0] -> pos = 1
            :: else -> skip
            fi
        fi
    od
}

init {

    atomic {
        byte c;

        for (c: 'a'..'z') {
            run Monkey(c)
        }

        run Reviewer();
    }
}

ltl p1 { []! matched }