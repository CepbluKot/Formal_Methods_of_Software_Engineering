
init {
	int a = 3;
	int b = 5;
	
	
//if-else
	if
	:: (a < b) -> printf("if - else: good\n")
	// :: else -> printf("if - else: bad\n")
	fi;
	
	
//Тернарный оператор
	int x1 = 0;
	int x2 = 10;
	int x3 = 15;
	
	if
	:: (x2 > x3) -> x1 = x2
	:: else -> x1 = x3
	fi;
	
	printf("Тернарный оператор: x1 = %d\n",x1);
	
//Цикл while с break
	
	
	int x9 = 2;
	int x10 = 5;
	
	/* цикл,который прерывается,когда a становится меньше b*/ 
	do
	:: (x9 < x10) -> break
	:: else -> x9 = x9 + 1
	od;
	
	printf("цикл: Final x9 = %d\n",x9);
	
	
	
// 5. Цикл for
	
	int i = 0;
	do
	:: (i >= 10) -> break
	:: else -> 
		printf("цикл фор: i = %d\n",i);
		i = i + 1
	od;
	
}