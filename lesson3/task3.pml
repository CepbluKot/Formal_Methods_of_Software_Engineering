mtype = { cmd };
chan control = [0] of { mtype, byte };

byte state[5];
int steps = 0;

init {
    state[1] = 1; state[3] = 1; state[4] = 1;
}

proctype Pillar(byte id) {
    byte left = (id + 4) % 5;
    byte right = (id + 1) % 5;
    do
    :: control?cmd(id) ->
         state[id] = 1 - state[id];
         state[left] = 1 - state[left];
         state[right] = 1 - state[right];
         steps++;
    od
}

active proctype Commander() {
    byte target;
    do
    :: (state[0] == 1 && state[1] == 1 && state[2] == 1 && state[3] == 1 && state[4] == 1) ->
         printf(">> Gate opened in %d steps\n", steps);
         break
    :: else ->
         if
         :: target = 0
         :: target = 1
         :: target = 2
         :: target = 3
         :: target = 4
         fi;
         control!cmd(target)
    od
}

ltl p1 { <> (state[0] == 1 && state[1] == 1 && state[2] == 1 && state[3] == 1 && state[4] == 1) }
