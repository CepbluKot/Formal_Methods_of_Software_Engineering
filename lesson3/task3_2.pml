bool open = false;
byte pillar[5];

active proctype commander() { 
    do
    ::
        byte cmd;
        select(cmd: 0..4);

        printf("Command called: %d\n", cmd);

        byte left = (cmd + 4) % 5;
        byte right = (cmd + 1) % 5;

        pillar[cmd] = 1 - pillar[cmd];
        pillar[left] = 1 - pillar[left];
        pillar[right] = 1 - pillar[right];

        if
        :: (pillar[0] && pillar[1] && pillar[2] && pillar[3] && pillar[4]) -> 
            open = true;
            printf("Gate opened!");
            break;
        :: else -> skip;
        fi;
    
    od;
}

init {
    pillar[0] = 0;
    pillar[1] = 1;
    pillar[2] = 0;
    pillar[3] = 1;
    pillar[4] = 1;
}

ltl p1 { []!open }