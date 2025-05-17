

#define N 3
#define L (2*N+1)

mtype = {EMPTY, GREEN, PURPLE};

mtype pads[L];       // shared board
byte steps = 0;      // global move counter
bool finished = false;

/* initialize board */
init {
    byte i;
    /* set greens */
    i = 0;
    do :: (i < N) -> pads[i] = GREEN; i++ :: else -> break od;
    /* empty middle */
    pads[N] = EMPTY;
    /* set purples */
    i = N+1;
    do :: (i < L) -> pads[i] = PURPLE; i++ :: else -> break od;

    /* spawn one process per frog */
    atomic {
      /* green at positions 0..N-1 */
      i = 0;
      do :: (i < N) -> run Frog(GREEN, i); i++ :: else -> break od;
    }
    atomic {
      /* purple at positions N+1..L-1 */
      i = 0;
      do :: (i < N) -> run Frog(PURPLE, N+1+i); i++ :: else -> break od;
    }
}

/* Frog process: color and current position idx */
proctype Frog(mtype color, byte init_pos) {
    byte pos = init_pos;
    do
    :: finished -> break
    ::
       /* try step or hop moves */
       atomic {
         /* STEP forward/backward */
         if
         :: color==GREEN && pos+1 < L && pads[pos+1]==EMPTY ->
              pads[pos] = EMPTY; pads[pos+1] = GREEN;
              pos = pos+1;
              steps++;
              printf("GREEN step: %d -> %d (step %d)\n", pos-1, pos, steps)
         :: color==PURPLE && pos-1 >= 0 && pads[pos-1]==EMPTY ->
              pads[pos] = EMPTY; pads[pos-1] = PURPLE;
              pos = pos-1;
              steps++;
              printf("PURPLE step: %d -> %d (step %d)\n", pos+1, pos, steps)
         /* HOP over one frog */
         :: color==GREEN && pos+2 < L && pads[pos+1]!=EMPTY && pads[pos+2]==EMPTY ->
              pads[pos] = EMPTY; pads[pos+2] = GREEN;
              pos = pos+2;
              steps++;
              printf("GREEN hop: %d -> %d (step %d)\n", pos-2, pos, steps)
         :: color==PURPLE && pos>=2 && pads[pos-1]!=EMPTY && pads[pos-2]==EMPTY ->
              pads[pos] = EMPTY; pads[pos-2] = PURPLE;
              pos = pos-2;
              steps++;
              printf("PURPLE hop: %d -> %d (step %d)\n", pos+2, pos, steps)
         :: else -> skip
         fi;
       }
       /* check goal after each move */
       atomic {
         /* if board == PPP _ GGG */
         if
         :: (pads[0]==PURPLE && pads[1]==PURPLE && pads[2]==PURPLE
             && pads[3]==EMPTY
             && pads[4]==GREEN && pads[5]==GREEN && pads[6]==GREEN) ->
               printf("Goal reached in %d moves!\n", steps);
               assert(steps == 15);
               finished = true;
         :: else -> skip
         fi;
       }
    od;
}
