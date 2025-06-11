
chan TL1 = [1] of {byte};
chan TL2 = [1] of {byte};
chan TL3 = [1] of {byte};
chan TL4 = [1] of {byte};
chan TL5 = [1] of {byte};
chan TL6 = [1] of {byte};


byte n = 10;

byte currentTurn = 1;
byte queue [6]  = {0,0,0,0,0,0};
short requests [7]  = {0,0,0,0,0,0};
bool statuses [6]  = {false, false, false, false, false, false};


proctype TrafficLight (byte number; byte nextNum; byte fProblem; byte sProblem; byte tProblem; byte uProblem; chan tlChan){
    short fValue=0;
    short sValue=0;
    short tValue=0;
    short nValue = 0;
    short uValue = 0;

    byte temp = 0;
    do
        ::  currentTurn == number  ->
        if
        // Есть трафик для этого светофора
        ::    tlChan?temp->
        
                requests[0] = 0; 
                queue[number-1] = temp; 
                 atomic {  
                printf("\n\n");      
                printf("Proc :%d\n", number);
                printf("Is green = %d\n", statuses[number-1]);
                printf("Cars? %d\n", queue[number-1]);
                printf("Request: %d\n", requests[number]);
                 }

                if
                    :: statuses[number-1] == true ->
                           requests [number] =0; 
                           statuses[number-1] = false;
                           printf ("Set color as red at %d\n", number);
                           printf("And now its request is: %d\n", requests[number]);
                    :: else -> skip;
                fi;
                
                if
                :: requests[number] > 0  ->
                        if
                        :: (requests[fProblem] == 0  ) && 
                            (requests[sProblem] == 0 ) && 
                            (requests[tProblem] == 0  ) &&
                            (requests[uProblem] == 0  )
                            ->
                                statuses[number-1] = true;
                                queue[number-1] = 0;
                                printf ("Set color as green (no enemies) at %d\n", number);
                                currentTurn = nextNum

                        :: else ->
                                if // Первый соперник
                                    :: requests[fProblem] > 0 -> fValue = requests[fProblem];
                                    :: else -> fValue = 0;
                                fi;
                                if // Второй соперник
                                    :: requests[sProblem] >0 -> sValue = requests[sProblem];
                                    :: else -> sValue = 0;
                                fi;
                                if // Третий соперник
                                    :: requests[tProblem] >0 -> tValue = requests[tProblem];
                                    :: else -> tValue = 0;
                                fi
                                if // 4 соперник
                                    :: requests[uProblem] >0 -> uValue = requests[uProblem];
                                    :: else -> uValue = 0;
                                fi

                                nValue = requests[number];
                                atomic {

                                printf("(%d) enemies are: %d,%d,%d\n", number, fProblem, sProblem, tProblem, uProblem);
                                printf("And values for #%d : (%d) and for enemies are: %d,%d,%d\n", number, nValue, fValue, sValue, tValue, uValue);
                                }

                                if 
                                            :: fValue > nValue || sValue > nValue || tValue > nValue ->
                                                    requests[number] =  nValue + n; 
                                                    requests[fProblem] = fValue + n;
                                                    requests[sProblem] = sValue + n;
                                                    requests[tProblem] = tValue + n;
                                                    requests[uProblem] = uValue + n;
                                                    
                                                    printf ("(%d) will wait for enemies \n", number);
                                                    printf("(%d) new value is (%d) and for enemies: %d,%d,%d\n",  number, requests[number], requests[fProblem], requests[sProblem], requests[tProblem], requests[uProblem]);
                                                    skip
                                            :: else ->
                                                 printf ("Set color as green as (%d) was MAX \n", number);
                                                 statuses[number-1] = true;
                                                 queue[number-1] = 0;
                                                 requests[number] = 999 + number

                                 fi;
                        atomic{
                        printf("Requests are 1 (%d), 2 (%d), 3 (%d), 4 (%d), 5 (%d), 6 (%d)\n", requests[1],requests[2],requests[3],requests[4],requests[5],requests[6]);
                        printf("Statuses are 1 (%d), 2 (%d), 3 (%d), 4 (%d), 5 (%d), 6 (%d)\n", statuses[0],statuses[1],statuses[2],statuses[3],statuses[4],statuses[5]);
                        printf("Cars waiting at 1 (%d), 2 (%d), 3 (%d), 4 (%d), 5 (%d), 6 (%d)\n", queue[0],queue[1],queue[2],queue[3],queue[4],queue[5]);
                        }
                        currentTurn = nextNum;
                        requests[0] = 0;


                        fi

                :: else ->
                        requests[number] = number;
                        currentTurn = nextNum;
                fi;
            fi;
    od
}

proctype TrafficGenerator(){
    do
        :: TL1!1
        :: TL2!1
        :: TL3!1
        :: TL4!1
        :: TL5!1
        :: TL6!1
    od
}


init {
    /* number, nextNum, fProblem, sProblem, tProblem, uProblem */
    /* (1=S→N, 2=E→W, 3=S→W, 4=E→S, 5=W→E, 6=Ped). */

    run TrafficLight(1, 2, 2,4,5, 0, TL1); /* S->N  ↔ E->W(2), E->S(4), W->E(5) */
    run TrafficLight(2, 3, 6,1,0, 0, TL2); /* E->W  ↔ Ped(6), S->N(1) */
    run TrafficLight(3, 4, 4,5,0, 0, TL3); /* S->W  ↔ E->S(4), W->E(5) */
    run TrafficLight(4, 5, 6,1,3, 5, TL4); /* E->S  ↔ Ped(6), S->N(1), S->W(3), W->E(5) */
    run TrafficLight(5, 6, 4,3,1, 6, TL5); /* W->E  ↔ E->S(4), S->W(3), S->N(1), Ped(6) */
    run TrafficLight(6, 1, 2,4,5, 0, TL6); /* Ped   ↔ E->W(2), E->S(4), W->E(5) */

    run TrafficGenerator();
}


// Безопасность - нет пересечений между:

/* 1: S->N  ∧ (E->W, E->S, W->E) */
ltl s1 { [] ! (statuses[0] && (statuses[1] || statuses[3] || statuses[4])) }
/* 2: E->W  ∧ (Ped, S->N) */
ltl s2 { [] ! (statuses[1] && (statuses[5] || statuses[0])) }
/* 3: S->W  ∧ (E->S, W->E) */
ltl s3 { [] ! (statuses[2] && (statuses[3] || statuses[4])) }
/* 4: E->S  ∧ (Ped, S->N, S->W, W->E) */
ltl s4 { [] ! (statuses[3] && (statuses[5] || statuses[0] || statuses[2] || statuses[4])) }
/* 5: W->E  ∧ (E->S, S->W, S->N, Ped) */
ltl s5 { [] ! (statuses[4] && (statuses[3] || statuses[2] || statuses[0] || statuses[5])) }
/* 6: Ped   ∧ (E->W, E->S, W->E) */
ltl s6 { [] ! (statuses[5] && (statuses[1] || statuses[3] || statuses[4])) }




/* === LTL-живость === */
ltl l1 { []( (queue[0] == 1 && statuses[0]==false) -> <> (statuses[0]==true) ) }
ltl l2 { []( (queue[1] == 1 && statuses[1]==false) -> <> (statuses[1]==true) ) }
ltl l3 { []( (queue[2] == 1 && statuses[2]==false) -> <> (statuses[2]==true) ) }
ltl l4 { []( (queue[3] == 1 && statuses[3]==false) -> <> (statuses[3]==true) ) }
ltl l5 { []( (queue[4] == 1 && statuses[4]==false) -> <> (statuses[4]==true) ) }
ltl l6 { []( (queue[5] == 1 && statuses[5]==false) -> <> (statuses[5]==true) ) }

/* === LTL-честность === */
ltl f1 { []( <> (statuses[0] == false) ) }
ltl f2 { []( <> (statuses[1] == false) ) }
ltl f3 { []( <> (statuses[2] == false) ) }
ltl f4 { []( <> (statuses[3] == false) ) }
ltl f5 { []( <> (statuses[4] == false) ) }
ltl f6 { []( <> (statuses[5] == false) ) }
// Одновременный проезд 