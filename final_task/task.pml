// Вариант 6

#define SN_ROAD_ID 1
#define EW_ROAD_ID 2
#define SW_ROAD_ID 3
#define ES_ROAD_ID 4
#define WE_ROAD_ID 5
#define PED_ROAD_ID 6

chan SN_LIGHT_CHANNEL = [1] of {byte};
chan EW_LIGHT_CHANNEL = [1] of {byte};
chan SW_LIGHT_CHANNEL = [1] of {byte};
chan ES_LIGHT_CHANNEL = [1] of {byte};
chan WE_LIGHT_CHANNEL = [1] of {byte};
chan PED_LIGHT_CHANNEL = [1] of {byte};

byte priority_coef = 10;


short n_requests_per_road [7] = {0,0,0,0,0,0};
bool road_sensor_state[7] = {false, false, false, false, false, false, false};
bool traffic_lights_states [7] = {false, false, false, false, false, false, false};


byte current_processed_road_id = 1;


proctype CarTrafficGenerator(){
    do
        :: SN_LIGHT_CHANNEL!1
        :: EW_LIGHT_CHANNEL!1
        :: SW_LIGHT_CHANNEL!1
        :: ES_LIGHT_CHANNEL!1
        :: WE_LIGHT_CHANNEL!1
    od
}

proctype PedTrafficGenerator(){
    do
        :: PED_LIGHT_CHANNEL!1
    od
}

proctype TrafficLight (byte curr_road_id; byte next_road_id; byte competitor_1; byte competitor_2; byte competitor_3; byte competitor_4; chan traffic_channel){
    short curr_road_value = 0;
    short competitor_1_value = 0;
    short competitor_2_value = 0;
    short competitor_3_value = 0;
    short competitor_4_value = 0;
    byte channel_data = 0;
    do
        :: current_processed_road_id == curr_road_id ->
        if
        :: traffic_channel?channel_data->
                n_requests_per_road[0] = 0; 
                road_sensor_state[curr_road_id] = (channel_data == 1);

                atomic {
                    printf("\n\n\nProcess for road id: %d", curr_road_id);
                    printf("\nN of n_requests_per_road: %d", n_requests_per_road[curr_road_id]);
                    printf("\nCar sensor state: %d", road_sensor_state[curr_road_id]);
                    printf("\nTraffic Light opened: %d", traffic_lights_states[curr_road_id]);
                }

                if
                    :: traffic_lights_states[curr_road_id] == true ->
                        n_requests_per_road[curr_road_id] = 0; 
                        traffic_lights_states[curr_road_id] = false;
                        printf ("\n\n\nClose traffic light for road_id: %d", curr_road_id);
                        printf("\nN n_requests_per_road for this road_id: %d", n_requests_per_road[curr_road_id]);
                    :: else -> skip;
                fi;
                
                if
                :: n_requests_per_road[curr_road_id] > 0 ->
                        printf("\n\n\nAvailable n_requests_per_road for road_id: %d", curr_road_id)
                        if
                        :: (n_requests_per_road[competitor_1] == 0) && 
                            (n_requests_per_road[competitor_2] == 0) && 
                            (n_requests_per_road[competitor_3] == 0) &&
                            (n_requests_per_road[competitor_4] == 0)
                            ->
                                printf("\n\n\nOpen traffic light for road_id: %d", curr_road_id);
                                traffic_lights_states[curr_road_id] = true;
                                road_sensor_state[curr_road_id] = false;
                                current_processed_road_id = next_road_id
                        :: else ->
                                printf("\n\n\nFailed to open traffic light for road_id: %d", curr_road_id);
                                if
                                    :: n_requests_per_road[competitor_1] > 0 -> competitor_1_value = n_requests_per_road[competitor_1];
                                    :: else -> competitor_1_value = 0;
                                fi;
                                if
                                    :: n_requests_per_road[competitor_2] >0 -> competitor_2_value = n_requests_per_road[competitor_2];
                                    :: else -> competitor_2_value = 0;
                                fi;
                                if
                                    :: n_requests_per_road[competitor_3] >0 -> competitor_3_value = n_requests_per_road[competitor_3];
                                    :: else -> competitor_3_value = 0;
                                fi
                                if
                                    :: n_requests_per_road[competitor_4] >0 -> competitor_4_value = n_requests_per_road[competitor_4];
                                    :: else -> competitor_4_value = 0;
                                fi

                                curr_road_value = n_requests_per_road[curr_road_id];
                                
                                atomic {
                                    printf("\n\n\n --- N n_requests_per_road status (BEFORE CHECK) --- ")
            
                                    printf("\n\nN n_requests_per_road for curr road_id %d: %d \nN n_requests_per_road for competitor_1 road_id %d: %d \nN n_requests_per_road for competitor_2 road_id %d: %d \nN n_requests_per_road for competitor_3 road_id %d: %d \nN n_requests_per_road for competitor_4 road_id %d: %d", curr_road_id, curr_road_value, competitor_1, competitor_1_value, competitor_2, competitor_2_value, competitor_3, competitor_3_value, competitor_4, competitor_4_value);
                                }

                                if 
                                    :: competitor_1_value > curr_road_value || competitor_2_value > curr_road_value || competitor_3_value > curr_road_value ->
                                        n_requests_per_road[curr_road_id] = curr_road_value + priority_coef; 
                                        n_requests_per_road[competitor_1] = competitor_1_value + priority_coef;
                                        n_requests_per_road[competitor_2] = competitor_2_value + priority_coef;
                                        n_requests_per_road[competitor_3] = competitor_3_value + priority_coef;
                                        n_requests_per_road[competitor_4] = competitor_4_value + priority_coef;
                                        
                                        printf("\n\n\n --- N n_requests_per_road status (AFTER CHECK, FAILED TO OPEN TRAFFIC LIGHT) --- ")
                                        printf("\n\nN n_requests_per_road for curr road_id %d: %d \nN n_requests_per_road for competitor_1 road_id %d: %d \nN n_requests_per_road for competitor_2 road_id %d: %d \nN n_requests_per_road for competitor_3 road_id %d: %d \nN n_requests_per_road for competitor_4 road_id %d: %d", curr_road_id, n_requests_per_road[curr_road_id], competitor_1, n_requests_per_road[competitor_1], competitor_2, n_requests_per_road[competitor_2], competitor_3, n_requests_per_road[competitor_3], competitor_4, n_requests_per_road[competitor_4]);
                                        skip
                                    :: else ->
                                        printf("\n\n\n --- N n_requests_per_road status (AFTER CHECK, SUCCEEDED TO OPEN TRAFFIC LIGHT) --- ")
                                        printf("\n\nN n_requests_per_road for curr road_id %d: %d \nN n_requests_per_road for competitor_1 road_id %d: %d \nN n_requests_per_road for competitor_2 road_id %d: %d \nN n_requests_per_road for competitor_3 road_id %d: %d \nN n_requests_per_road for competitor_4 road_id %d: %d", curr_road_id, n_requests_per_road[curr_road_id], competitor_1, n_requests_per_road[competitor_1], competitor_2, n_requests_per_road[competitor_2], competitor_3, n_requests_per_road[competitor_3], competitor_4, n_requests_per_road[competitor_4]);
                                        traffic_lights_states[curr_road_id] = true;
                                        road_sensor_state[curr_road_id] = false;
                                        n_requests_per_road[curr_road_id] = 999 + curr_road_id
                                fi;
                        
                        current_processed_road_id = next_road_id;
                        n_requests_per_road[0] = 0;
                        // atomic{
                        //     printf("\n\n\n --- Global status --- ")
                        //     printf("\n\nN n_requests_per_road for road_id 1: %d \nN n_requests_per_road for road_id 2: %d \nN n_requests_per_road for road_id 3: %d \nN n_requests_per_road for road_id 4: %d \nN n_requests_per_road for road_id 5: %d \nN n_requests_per_road for road_id 6: %d", n_requests_per_road[1],n_requests_per_road[2],n_requests_per_road[3],n_requests_per_road[4],n_requests_per_road[5],n_requests_per_road[6]);
                        //     printf("\n\nStatus for road_id 1: %d \nStatus for road_id 2: %d \nStatus for road_id 3: %d \nStatus for road_id 4: %d \nStatus for road_id 5: %d \nStatus for road_id 6: %d", traffic_lights_states[0],traffic_lights_states[1],traffic_lights_states[2],traffic_lights_states[3],traffic_lights_states[4],traffic_lights_states[5]);
                        //     printf("\n\nCar sensor state for road_id 1: %d \nCar sensor state for road_id 2: %d \nCar sensor state for road_id 3: %d \nCar sensor state for road_id 4: %d \nCar sensor state for road_id 5: %d \nCar sensor state for road_id 6: %d", road_sensor_state[0],road_sensor_state[1],road_sensor_state[2],road_sensor_state[3],road_sensor_state[4],road_sensor_state[5]);
                        // }
                        fi
                :: else ->
                        printf("\n\n\nNo n_requests_per_road for road_id: %d", curr_road_id)
                        n_requests_per_road[curr_road_id] = curr_road_id;
                        current_processed_road_id = next_road_id;
                fi;
            fi;
    od
}


init {
    run TrafficLight(SN_ROAD_ID, EW_ROAD_ID, EW_ROAD_ID, ES_ROAD_ID, WE_ROAD_ID, 0, SN_LIGHT_CHANNEL); /* S->N: E->W(2), E->S(4), W->E(5) */
    run TrafficLight(EW_ROAD_ID, SW_ROAD_ID, PED_ROAD_ID, SN_ROAD_ID, 0, 0, EW_LIGHT_CHANNEL); /* E->W: Ped(6), S->N(1) */
    run TrafficLight(SW_ROAD_ID, ES_ROAD_ID, ES_ROAD_ID, WE_ROAD_ID, 0, 0, SW_LIGHT_CHANNEL); /* S->W: E->S(4), W->E(5) */
    run TrafficLight(ES_ROAD_ID, WE_ROAD_ID, PED_ROAD_ID, SN_ROAD_ID, SW_ROAD_ID, WE_ROAD_ID, ES_LIGHT_CHANNEL); /* E->S: Ped(6), S->N(1), S->W(3), W->E(5) */
    run TrafficLight(WE_ROAD_ID, PED_ROAD_ID, ES_ROAD_ID, SW_ROAD_ID, SN_ROAD_ID, PED_ROAD_ID, WE_LIGHT_CHANNEL); /* W->E: E->S(4), S->W(3), S->N(1), Ped(6) */
    run TrafficLight(PED_ROAD_ID, SN_ROAD_ID, EW_ROAD_ID, ES_ROAD_ID, WE_ROAD_ID, 0, PED_LIGHT_CHANNEL); /* Ped: E->W(2), E->S(4), W->E(5) */

    run CarTrafficGenerator();
    run PedTrafficGenerator();
}

// Safety
ltl safety_1_SN { [] ! (traffic_lights_states[SN_ROAD_ID] && (traffic_lights_states[EW_ROAD_ID] || traffic_lights_states[ES_ROAD_ID] || traffic_lights_states[WE_ROAD_ID])) } /* 1: S->N and (E->W, E->S, W->E) */
ltl safety_2_EW { [] ! (traffic_lights_states[EW_ROAD_ID] && (traffic_lights_states[PED_ROAD_ID] || traffic_lights_states[SN_ROAD_ID])) } /* 2: E->W and (Ped, S->N) */
ltl safety_3_SW { [] ! (traffic_lights_states[SW_ROAD_ID] && (traffic_lights_states[ES_ROAD_ID] || traffic_lights_states[WE_ROAD_ID])) } /* 3: S->W and (E->S, W->E) */
ltl safety_4_ES { [] ! (traffic_lights_states[ES_ROAD_ID] && (traffic_lights_states[PED_ROAD_ID] || traffic_lights_states[SN_ROAD_ID] || traffic_lights_states[SW_ROAD_ID] || traffic_lights_states[WE_ROAD_ID])) } /* 4: E->S and (Ped, S->N, S->W, W->E) */
ltl safety_5_WE { [] ! (traffic_lights_states[WE_ROAD_ID] && (traffic_lights_states[ES_ROAD_ID] || traffic_lights_states[SW_ROAD_ID] || traffic_lights_states[SN_ROAD_ID] || traffic_lights_states[PED_ROAD_ID])) } /* 5: W->E and (E->S, S->W, S->N, Ped) */
ltl safety_6_PED { [] ! (traffic_lights_states[PED_ROAD_ID] && (traffic_lights_states[EW_ROAD_ID] || traffic_lights_states[ES_ROAD_ID] || traffic_lights_states[WE_ROAD_ID])) } /* 6: Ped and (E->W, E->S, W->E) */

// Liveness
ltl liveness_1_SN { []( (road_sensor_state[SN_ROAD_ID] == true && traffic_lights_states[SN_ROAD_ID]==false) -> <> (traffic_lights_states[SN_ROAD_ID]==true) ) } /* for SN road */
ltl liveness_2_EW { []( (road_sensor_state[EW_ROAD_ID] == true && traffic_lights_states[EW_ROAD_ID]==false) -> <> (traffic_lights_states[EW_ROAD_ID]==true) ) } /* for EW road */
ltl liveness_3_SW { []( (road_sensor_state[SW_ROAD_ID] == true && traffic_lights_states[SW_ROAD_ID]==false) -> <> (traffic_lights_states[SW_ROAD_ID]==true) ) } /* for SW road */
ltl liveness_4_ES { []( (road_sensor_state[ES_ROAD_ID] == true && traffic_lights_states[ES_ROAD_ID]==false) -> <> (traffic_lights_states[ES_ROAD_ID]==true) ) } /* for ES road */
ltl liveness_5_WE { []( (road_sensor_state[WE_ROAD_ID] == true && traffic_lights_states[WE_ROAD_ID]==false) -> <> (traffic_lights_states[WE_ROAD_ID]==true) ) } /* for WE road */
ltl liveness_6_PED { []( (road_sensor_state[PED_ROAD_ID] == true && traffic_lights_states[PED_ROAD_ID]==false) -> <> (traffic_lights_states[PED_ROAD_ID]==true) ) } /* for PED road */

// Fairness
ltl fairness_1_SN { []( <> (traffic_lights_states[SN_ROAD_ID] == false) ) }  /* for SN road */
ltl fairness_2_EW { []( <> (traffic_lights_states[EW_ROAD_ID] == false) ) }  /* for EW road */
ltl fairness_3_SW { []( <> (traffic_lights_states[SW_ROAD_ID] == false) ) }  /* for SW road */
ltl fairness_4_ES { []( <> (traffic_lights_states[ES_ROAD_ID] == false) ) }  /* for ES road */
ltl fairness_5_WE { []( <> (traffic_lights_states[WE_ROAD_ID] == false) ) }  /* for WE road */
ltl fairness_6_PED { []( <> (traffic_lights_states[PED_ROAD_ID] == false) ) } /* for PED road */
