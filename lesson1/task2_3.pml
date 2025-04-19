#define N 6

active proctype ARRAY() {
    int a[N];
    int i = 0;
    
    do
    :: (i >= N) -> break
    :: else ->
         a[i] = 3;
         printf("[on init] element id %d a[%d] = %d\n", i, i, a[i]);
         i = i + 1
    od;
    
    printf("\n ------ \n\n");
    
    i = 0;
    do
    :: (i >= N) -> break
    :: else ->
         if
         :: a[i] = 0
         :: a[i] = 1
         :: a[i] = 2
         :: a[i] = 3
         :: a[i] = 4
         :: a[i] = 5
         fi;
         printf("[task 1] element id %d a[%d] = %d\n", i, i, a[i]);
         i = i + 1
    od;
    
    printf("\n ------ \n\n");
    
    int result = 0;
    i = 0;
    do
    :: (i >= N) -> break
    :: else ->
		// result = 1
         if
         :: ((i % 2) == 0) -> result = result + a[i]
         :: else           -> result = result - a[i]
         fi;
         printf("[task 2] element id %d a[%d] = %d\n", i, i, a[i]);
         printf("[task 2] result at a[%d] result = %d\n", i, result);
         i = i + 1
    od;
    
    printf("Result = %d\n", result);
    
    assert(result == 1);
}
