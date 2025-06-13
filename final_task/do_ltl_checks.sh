#!/bin/bash
# filepath: /home/oleg/Documents/Formal_Methods_of_Software_Engineering/final_task/run_all_ltl.sh

LTL_LIST=(
  safety_1_SN
  safety_2_EW
  safety_3_SW
  safety_4_ES
  safety_5_WE
  safety_6_PED
  liveness_1_SN
  liveness_2_EW
  liveness_3_SW
  liveness_4_ES
  liveness_5_WE
  liveness_6_PED
  fairness_1_SN
  fairness_2_EW
  fairness_3_SW
  fairness_4_ES
  fairness_5_WE
  fairness_6_PED
)

echo "🚦 Запуск LTL-проверок Spin..."

for ltl in "${LTL_LIST[@]}"
do
  echo -e "🔎 Проверка ${ltl}... ⏳"
  ../spin651_linux64 -search -m1000000 -ltl $ltl task.pml > "${ltl}.txt"
  if [ $? -eq 0 ]; then
    echo -e "✅ ${ltl} завершена! Результат сохранён в ${ltl}.txt"
  else
    echo -e "❌ Ошибка при проверке ${ltl}!"
  fi
done

echo "🎉 Все LTL проверки завершены!"