mtype = { cmd };
chan control = [0] of { mtype, byte };

/* состояния столбцов: 0 = OFF, 1 = ON */
byte state[5];

/* счётчик шагов */
int steps = 0;

init {
    /* инициализация: 1,3,4 = ON; 0,2 = OFF */
    state[1] = 1; state[3] = 1; state[4] = 1;
}

/* каждый столбец – свой процесс */
proctype Pillar(byte id) {
    byte left  = (id + 4) % 5;
    byte right = (id + 1) % 5;
    do
    :: control?cmd(id) ->
         /* переворачиваем себя и соседей */
         state[id]    = 1 - state[id];
         state[left]  = 1 - state[left];
         state[right] = 1 - state[right];
         steps++;     /* инкрементируем шаг */
    od
}

/* командир посылает команды, пока не откроется ворота */
active proctype Commander() {
    byte target;
    do
    :: (state[0]==1 && state[1]==1 && state[2]==1 && state[3]==1 && state[4]==1) ->
         printf(">> Gate opened in %d steps\n", steps);
         break
    :: else ->
         /* nondet выбор одного из 5 столбцов */
         if :: target=0
            :: target=1
            :: target=2
            :: target=3
            :: target=4
         fi;
         control!cmd(target)
    od
}

/* LTL-свойство: когда-нибудь все столбцы станут ON */
ltl p1 { <> (state[0]==1 && state[1]==1 && state[2]==1 && state[3]==1 && state[4]==1) }
