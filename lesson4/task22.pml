#define N       7
#define EMPTY   0
#define GREEN   1
#define PURPLE  2
#define M       15

byte pads[N] = { GREEN, GREEN, GREEN, EMPTY, PURPLE, PURPLE, PURPLE };
byte seq[M]  = { 1 };
byte idx = 0;           
int  totalmoves = 0;
byte Empty;             

inline print_state() {
    int j;
    printf("After move %d: ", totalmoves);
    j = 0;
    do
    :: j < N ->
         printf("%d ", pads[j]);
         j = j + 1
    :: else -> break
    od;
    printf("\n");
}

proctype Game() {
    do
    :: idx < M ->
        if
        :: seq[idx] == GREEN ->
            if
            :: (Empty > 0 && pads[Empty-1] == GREEN) ->
                 pads[Empty]   = GREEN;
                 pads[Empty-1] = EMPTY;
                 Empty = Empty - 1
            :: (Empty > 1 && pads[Empty-2] == GREEN && pads[Empty-1] == PURPLE) ->
                 pads[Empty]   = GREEN;
                 pads[Empty-2] = EMPTY;
                 Empty = Empty - 2
            :: else ->
                 printf("ERROR at move %d: illegal GREEN move\n", totalmoves+1)
            fi
        :: seq[idx] == PURPLE ->
            if
            :: (Empty < N-1 && pads[Empty+1] == PURPLE) ->
                 pads[Empty]   = PURPLE;
                 pads[Empty+1] = EMPTY;
                 Empty = Empty + 1
            :: (Empty < N-2 && pads[Empty+2] == PURPLE && pads[Empty+1] == GREEN) ->
                 pads[Empty]   = PURPLE;
                 pads[Empty+2] = EMPTY;
                 Empty = Empty + 2
            :: else ->
                 printf("ERROR at move %d: illegal PURPLE move\n", totalmoves+1)
            fi
        fi;
        totalmoves = totalmoves + 1;
        print_state();
        idx = idx + 1
    :: else -> break
    od;

    if
    :: (pads[0]==PURPLE && pads[1]==PURPLE && pads[2]==PURPLE &&
        pads[3]==EMPTY  &&
        pads[4]==GREEN  && pads[5]==GREEN  && pads[6]==GREEN) ->
         printf("Total States = %d (goal reached)\n", totalmoves)
    :: else ->
         printf("Current State Number = %d (goal NOT reached)\n", totalmoves)
    fi
}

init {
    byte i;
    i = 0;
    do
    :: i < N ->
         if
         :: pads[i] == EMPTY -> Empty = i; break
         :: else -> i = i + 1
         fi
    :: else -> break
    od;
    printf("Initial state:\n");
    print_state();
    run Game();
}
