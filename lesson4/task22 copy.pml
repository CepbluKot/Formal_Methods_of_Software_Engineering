#define N       7           /* число кочек */
#define EMPTY   0
#define GREEN   1
#define PURPLE  2
#define M       15          /* длина заданной последовательности */

byte pads[N] = { GREEN, GREEN, GREEN, EMPTY, PURPLE, PURPLE, PURPLE };
byte seq[M]  = { 1,2,2,1,1,1,2,2,2,1,1,1,2,2,1 };

int  totalmoves = 0;       /* глобальный счётчик ходов */
byte idx = 0;              /* индекс в seq */
byte Empty;                /* позиция пустой кочки (0-based) */

/* inline для печати состояния */
inline print_state() {
    int j;
    printf("After move %d: ", totalmoves);
    j = 0;
    do
    :: j < N ->
         printf("%d ", pads[j]);
         j = j + 1;
    :: else -> break;
    od;
    printf("\n");
}

/* Монитор финального состояния */
proctype Monitor() {
    /* ждём, пока все ходы не будут “съедены” */
    do
    :: idx < M -> skip
    :: else -> break
    od;
    if
    :: (pads[0]==PURPLE && pads[1]==PURPLE && pads[2]==PURPLE &&
        pads[3]==EMPTY  &&
        pads[4]==GREEN  && pads[5]==GREEN  && pads[6]==GREEN) ->
         printf("Total States = %d (goal reached)\n", totalmoves);
    :: else ->
         printf("Total States = %d (goal NOT reached)\n", totalmoves);
    fi;
}

/* Каждый Frog – свой процесс */
proctype Frog(int color; int id) {
    int pos;   /* текущая позиция */
    int dir;   /* направление: +1 или –1 */
    /* Инициализация */
    if
    :: color == GREEN  -> pos = id;       dir =  1;
    :: color == PURPLE -> pos = N-1-id;   dir = -1;
    fi;

    do
    :: atomic {
         /* берём ход, только если seq[idx] == наш цвет */
         idx < M && seq[idx] == color ->
         /* пробуем шаг */
         if
         :: (pos+dir >= 0 && pos+dir < N && pads[pos+dir] == EMPTY) ->
              pads[pos] = EMPTY;
              pos = pos + dir;
              pads[pos] = color;
         /* или прыжок */
         :: (pos+2*dir >= 0 && pos+2*dir < N
             && pads[pos+dir] != EMPTY
             && pads[pos+2*dir] == EMPTY) ->
              pads[pos] = EMPTY;
              pos = pos + 2*dir;
              pads[pos] = color;
         :: else ->
              /* ход не выполнен – выходим из atomic, процесс завершится */
              break;
         fi;
         /* обновляем Empty — сканируем доску */
         {
           byte k = 0;
           do
           :: k < N ->
                if
                :: pads[k] == EMPTY -> Empty = k; break
                :: else -> k = k + 1
                fi
           :: else -> break
           od
         }
         totalmoves = totalmoves + 1;
         print_state();
         idx = idx + 1;
      }
    :: else -> break
    od
}

init {
    byte i;
    /* найдём стартовую пустую кочку */
    i = 0;
    do
    :: i < N ->
         if
         :: pads[i] == EMPTY -> Empty = i; break
         :: else -> i = i + 1
         fi
    :: else -> break
    od;

    printf("Initial state:\n");
    print_state();

    run Monitor();
    run Frog(GREEN,  0);
    run Frog(GREEN,  1);
    run Frog(GREEN,  2);
    run Frog(PURPLE, 0);
    run Frog(PURPLE, 1);
    run Frog(PURPLE, 2);
}
