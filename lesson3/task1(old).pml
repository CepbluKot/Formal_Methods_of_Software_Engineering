mtype = { letter };
chan g = [0] of { mtype, byte };

byte pattern[13] = {'t','o','b','e','o','r','n','o','t','t','o','b','e'};
byte pat_len = 13;
byte idx = 0;
bit match = 0;

proctype Monkey(byte c) {
    do
    :: g!letter(c);
       /* дебаг: какая обезьянка и что она послала */
    od
}

proctype Reviewer() {
    byte msg;
    do
    :: g?letter(msg) ->
        /* приём и отладочный вывод */
        if
        :: (msg == pattern[idx]) ->
             idx++;
             /* выводим, сколько подряд совпало */
            //  printf("  -> совпало, подряд: %d\n", idx);

             /* дополнительный дебаг, когда подряд > 5 */
             if
             :: (idx > 5) ->
                  printf(">>> DEBUG: более 5 совпадений подряд: %d\n", idx)
             :: else -> skip
             fi

        :: else ->
             idx = 0;
        fi;

        /* проверка на окончание */
        if
        :: (idx == pat_len-1) ->
             match = 1;
             printf(">>> Полное совпадение: idx = %d\n", idx);
             break
        :: else ->
             skip
        fi
    od
}


init {
    byte c = 'a';
    atomic {
        run Reviewer();
        /* порождаем Monkey для каждой буквы от 'a' до 'z' */
        do
        :: (c <= 'z') ->
             run Monkey(c);
             c = c + 1;
        :: else ->
             break;
        od
    }
}
