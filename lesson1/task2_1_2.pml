#define N 10

active proctype ARRAY() {
	int a[N];
	int i = 0;
	
	do
	:: (i >= N) -> break
	:: else -> 
		a[i] = 3;
		printf("[on init] element id %d a[%d] = %d\n",i,i,a[i]);
		i++
	od;
	
	printf("\n ------ \n\n")
	i = 0
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

		printf("[task 1] element id %d a[%d] = %d\n",i,i,a[i]);
		i = i + 1
	od;
	


	printf("\n ------ \n\n")
	i = 0
	/* Вычисление результата: элементы с четными индексами суммируются,с нечетными вычитаются*/ 
	int result = 0;
	i = 0;
	do
	:: (i >= N) -> break
	:: else -> 
		if
		:: ((i % 2) == 0) -> result = result + a[i]
		:: else -> result = result - a[i]
		fi;
		printf("[task 2] element id %d a[%d] = %d\n",i,i,a[i]);
		printf("[task 2] result at a[%d] result = %d\n",i,result);
		i = i + 1
	od;
	
	printf("Result = %d\n",result);


	int even = 0;
    int odd = 0;
    i = 0;
    do
    :: (i >= N) -> break
    :: else ->
         if
         :: ((i % 2) == 0) -> even = even + a[i]
         :: else           -> odd  = odd  + a[i]
         fi;
         printf("[calc] element id %d a[%d] = %d\n", i, i, a[i]);
         printf("[calc] even sum = %d, odd sum = %d\n", even, odd);
         i = i + 1
    od;
    
    int result = even - odd;
    printf("Total result (even - odd) = %d\n", result);
    
    /* В случае интерактивного моделирования можно добавить условие,
       чтобы итоговый результат был равен 1 */
    assert(result == 1)
}
