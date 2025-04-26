int sum = 0;

active proctype Oscillator() {
    byte v;
    do
    :: (sum > 0) ->
         if :: v = 1
            :: v = 2
            :: v = 3
         fi;
         sum = sum - v

    :: else ->
         /* sum ≤ 0 */
         if :: v = 1
            :: v = 2
            :: v = 3
         fi;
         sum = sum + v
    od
}

ltl p1 {
    [](<> (sum == 0))
}

ltl p2 {
    [] (sum >= -3 && sum <= 3)
}

ltl p3 {
    [] ( (sum > 0)  ->  <> (sum <= 0) )
 && [] ( (sum < 0)  ->  <> (sum > 0) )
}
