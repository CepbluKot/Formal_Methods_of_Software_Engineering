// Черное
#define SN_ROAD_ID 1
// Фиолетовое
#define EW_ROAD_ID 2
// Синее
#define SW_ROAD_ID 3
// Оранжевое
#define ES_ROAD_ID 4
// Красное
#define WE_ROAD_ID 5
// Пешеходы
#define PED_ROAD_ID 6

chan SN_LIGHT_CHANNEL = [1] of {byte};
chan EW_LIGHT_CHANNEL = [1] of {byte};
chan SW_LIGHT_CHANNEL = [1] of {byte};
chan ES_LIGHT_CHANNEL = [1] of {byte};
chan WE_LIGHT_CHANNEL = [1] of {byte};
chan PED_LIGHT_CHANNEL = [1] of {byte};


byte n = 10;

byte currentTurn = 1;
byte queue [6]  = {0,0,0,0,0,0};
short requests [7]  = {0,0,0,0,0,0};
bool statuses [6]  = {false, false, false, false, false, false};


proctype TrafficLight (byte curr_road_id; byte next_road_id; byte competitor_1; byte competitor_2; byte competitor_3; byte competitor_4; chan traffic_channel){
    short competitor_1_value=0;
    short competitor_2_value=0;
    short competitor_3_value=0;
    short competitor_4_value = 0;
    short curr_road_value = 0;

    byte temp = 0;
    do
        ::  currentTurn == curr_road_id  ->
        if
        // Есть трафик для этого светофора
        ::    traffic_channel?temp->
        
                requests[0] = 0; 
                queue[curr_road_id-1] = temp; 
                 atomic {  
                printf("\n\n");      
                printf("Proc :%d\n", curr_road_id);
                printf("Is green = %d\n", statuses[curr_road_id-1]);
                printf("Cars? %d\n", queue[curr_road_id-1]);
                printf("Request: %d\n", requests[curr_road_id]);
                 }

                if
                    :: statuses[curr_road_id-1] == true ->
                           requests [curr_road_id] =0; 
                           statuses[curr_road_id-1] = false;
                           printf ("Set color as red at %d\n", curr_road_id);
                           printf("And now its request is: %d\n", requests[curr_road_id]);
                    :: else -> skip;
                fi;
                
                if
                :: requests[curr_road_id] > 0  ->
                        if
                        :: (requests[competitor_1] == 0  ) && 
                            (requests[competitor_2] == 0 ) && 
                            (requests[competitor_3] == 0  ) &&
                            (requests[competitor_4] == 0  )
                            ->
                                statuses[curr_road_id-1] = true;
                                queue[curr_road_id-1] = 0;
                                printf ("Set color as green (no enemies) at %d\n", curr_road_id);
                                currentTurn = next_road_id

                        :: else ->
                                if // Первый соперник
                                    :: requests[competitor_1] > 0 -> competitor_1_value = requests[competitor_1];
                                    :: else -> competitor_1_value = 0;
                                fi;
                                if // Второй соперник
                                    :: requests[competitor_2] >0 -> competitor_2_value = requests[competitor_2];
                                    :: else -> competitor_2_value = 0;
                                fi;
                                if // Третий соперник
                                    :: requests[competitor_3] >0 -> competitor_3_value = requests[competitor_3];
                                    :: else -> competitor_3_value = 0;
                                fi
                                if // 4 соперник
                                    :: requests[competitor_4] >0 -> competitor_4_value = requests[competitor_4];
                                    :: else -> competitor_4_value = 0;
                                fi

                                curr_road_value = requests[curr_road_id];
                                atomic {

                                printf("(%d) enemies are: %d,%d,%d\n", curr_road_id, competitor_1, competitor_2, competitor_3, competitor_4);
                                printf("And values for #%d : (%d) and for enemies are: %d,%d,%d\n", curr_road_id, curr_road_value, competitor_1_value, competitor_2_value, competitor_3_value, competitor_4_value);
                                }

                                if 
                                            :: competitor_1_value > curr_road_value || competitor_2_value > curr_road_value || competitor_3_value > curr_road_value ->
                                                    requests[curr_road_id] =  curr_road_value + n; 
                                                    requests[competitor_1] = competitor_1_value + n;
                                                    requests[competitor_2] = competitor_2_value + n;
                                                    requests[competitor_3] = competitor_3_value + n;
                                                    requests[competitor_4] = competitor_4_value + n;
                                                    
                                                    printf ("(%d) will wait for enemies \n", curr_road_id);
                                                    printf("(%d) new value is (%d) and for enemies: %d,%d,%d\n",  curr_road_id, requests[curr_road_id], requests[competitor_1], requests[competitor_2], requests[competitor_3], requests[competitor_4]);
                                                    skip
                                            :: else ->
                                                 printf ("Set color as green as (%d) was MAX \n", curr_road_id);
                                                 statuses[curr_road_id-1] = true;
                                                 queue[curr_road_id-1] = 0;
                                                 requests[curr_road_id] = 999 + curr_road_id

                                fi;
                        atomic{
                        printf("Requests are 1 (%d), 2 (%d), 3 (%d), 4 (%d), 5 (%d), 6 (%d)\n", requests[1],requests[2],requests[3],requests[4],requests[5],requests[6]);
                        printf("Statuses are 1 (%d), 2 (%d), 3 (%d), 4 (%d), 5 (%d), 6 (%d)\n", statuses[0],statuses[1],statuses[2],statuses[3],statuses[4],statuses[5]);
                        printf("Cars waiting at 1 (%d), 2 (%d), 3 (%d), 4 (%d), 5 (%d), 6 (%d)\n", queue[0],queue[1],queue[2],queue[3],queue[4],queue[5]);
                        }
                        currentTurn = next_road_id;
                        requests[0] = 0;


                        fi

                :: else ->
                        requests[curr_road_id] = curr_road_id;
                        currentTurn = next_road_id;
                fi;
            fi;
    od
}

proctype TrafficGenerator(){
    do
        :: SN_LIGHT_CHANNEL!1
        :: EW_LIGHT_CHANNEL!1
        :: SW_LIGHT_CHANNEL!1
        :: ES_LIGHT_CHANNEL!1
        :: WE_LIGHT_CHANNEL!1
        :: PED_LIGHT_CHANNEL!1
    od
}


init {
    /* curr_road_id, next_road_id, competitor_1, competitor_2, competitor_3, competitor_4 */
    /* (1=S→N, 2=E→W, 3=S→W, 4=E→S, 5=W→E, 6=Ped). */

    run TrafficLight(SN_ROAD_ID, EW_ROAD_ID, EW_ROAD_ID, ES_ROAD_ID, WE_ROAD_ID, 0, SN_LIGHT_CHANNEL); /* S->N  ↔ E->W(2), E->S(4), W->E(5) */
    run TrafficLight(EW_ROAD_ID, SW_ROAD_ID, PED_ROAD_ID, SN_ROAD_ID, 0, 0, EW_LIGHT_CHANNEL); /* E->W  ↔ Ped(6), S->N(1) */
    run TrafficLight(SW_ROAD_ID, ES_ROAD_ID, ES_ROAD_ID, WE_ROAD_ID, 0, 0, SW_LIGHT_CHANNEL); /* S->W  ↔ E->S(4), W->E(5) */
    run TrafficLight(ES_ROAD_ID, WE_ROAD_ID, PED_ROAD_ID, SN_ROAD_ID, SW_ROAD_ID, WE_ROAD_ID, ES_LIGHT_CHANNEL); /* E->S  ↔ Ped(6), S->N(1), S->W(3), W->E(5) */
    run TrafficLight(WE_ROAD_ID, PED_ROAD_ID, ES_ROAD_ID, SW_ROAD_ID, SN_ROAD_ID, PED_ROAD_ID, WE_LIGHT_CHANNEL); /* W->E  ↔ E->S(4), S->W(3), S->N(1), Ped(6) */
    run TrafficLight(PED_ROAD_ID, SN_ROAD_ID, EW_ROAD_ID, ES_ROAD_ID, WE_ROAD_ID, 0, PED_LIGHT_CHANNEL); /* Ped   ↔ E->W(2), E->S(4), W->E(5) */

    run TrafficGenerator();
}


// Безопасность - нет пересечений между:

/* 1: S->N  ∧ (E->W, E->S, W->E) */
ltl s1 { [] ! (statuses[SN_ROAD_ID-1] && (statuses[EW_ROAD_ID-1] || statuses[ES_ROAD_ID-1] || statuses[WE_ROAD_ID-1])) }
/* 2: E->W  ∧ (Ped, S->N) */
ltl s2 { [] ! (statuses[EW_ROAD_ID-1] && (statuses[PED_ROAD_ID-1] || statuses[SN_ROAD_ID-1])) }
/* 3: S->W  ∧ (E->S, W->E) */
ltl s3 { [] ! (statuses[SW_ROAD_ID-1] && (statuses[ES_ROAD_ID-1] || statuses[WE_ROAD_ID-1])) }
/* 4: E->S  ∧ (Ped, S->N, S->W, W->E) */
ltl s4 { [] ! (statuses[ES_ROAD_ID-1] && (statuses[PED_ROAD_ID-1] || statuses[SN_ROAD_ID-1] || statuses[SW_ROAD_ID-1] || statuses[WE_ROAD_ID-1])) }
/* 5: W->E  ∧ (E->S, S->W, S->N, Ped) */
ltl s5 { [] ! (statuses[WE_ROAD_ID-1] && (statuses[ES_ROAD_ID-1] || statuses[SW_ROAD_ID-1] || statuses[SN_ROAD_ID-1] || statuses[PED_ROAD_ID-1])) }
/* 6: Ped   ∧ (E->W, E->S, W->E) */
ltl s6 { [] ! (statuses[PED_ROAD_ID-1] && (statuses[EW_ROAD_ID-1] || statuses[ES_ROAD_ID-1] || statuses[WE_ROAD_ID-1])) }




/* === LTL-живость === */
ltl l1 { []( (queue[SN_ROAD_ID-1] == 1 && statuses[SN_ROAD_ID-1]==false) -> <> (statuses[SN_ROAD_ID-1]==true) ) }
ltl l2 { []( (queue[EW_ROAD_ID-1] == 1 && statuses[EW_ROAD_ID-1]==false) -> <> (statuses[EW_ROAD_ID-1]==true) ) }
ltl l3 { []( (queue[SW_ROAD_ID-1] == 1 && statuses[SW_ROAD_ID-1]==false) -> <> (statuses[SW_ROAD_ID-1]==true) ) }
ltl l4 { []( (queue[ES_ROAD_ID-1] == 1 && statuses[ES_ROAD_ID-1]==false) -> <> (statuses[ES_ROAD_ID-1]==true) ) }
ltl l5 { []( (queue[WE_ROAD_ID-1] == 1 && statuses[WE_ROAD_ID-1]==false) -> <> (statuses[WE_ROAD_ID-1]==true) ) }
ltl l6 { []( (queue[PED_ROAD_ID-1] == 1 && statuses[PED_ROAD_ID-1]==false) -> <> (statuses[PED_ROAD_ID-1]==true) ) }

/* === LTL-честность === */
ltl f1 { []( <> (statuses[SN_ROAD_ID-1] == false) ) }
ltl f2 { []( <> (statuses[EW_ROAD_ID-1] == false) ) }
ltl f3 { []( <> (statuses[SW_ROAD_ID-1] == false) ) }
ltl f4 { []( <> (statuses[ES_ROAD_ID-1] == false) ) }
ltl f5 { []( <> (statuses[WE_ROAD_ID-1] == false) ) }
ltl f6 { []( <> (statuses[PED_ROAD_ID-1] == false) ) }
// Одновременный проезд 