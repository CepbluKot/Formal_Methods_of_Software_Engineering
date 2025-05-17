
#define K 11

byte A[K];        
byte pos;         
bool found = false;

init {
    int rand_id;
    select(rand_id:0..(K-1))
    A[rand_id] = 1;

    run Search();
}

proctype Search() {
    byte old;
    do
    :: 
       if
       :: A[pos] == 1 -> found = true; printf("Found at %d\n", pos); break
       :: else -> skip
       fi;

       pos = (pos + 1) % K;

       {
         old = 0;
         do
         :: (old < K && A[old] != 1) -> old++
         :: else -> break
         od;
         A[old] = 0;
         if
         :: A[(old + 1) % K] = 1 
         :: A[(old + K - 1) % K] = 1  
         :: A[old] = 1
         fi;
       }
    od;
}

ltl p1 { <> ([] found) }
