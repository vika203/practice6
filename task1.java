/*

Постановка задачі

Прочитати з stdin N рядків до появи EOF (максимум 10000 рядків).
Рядки розділяються АБО послідовністю байтів 0x0D та 0x0A (CR LF), або одним символом - 0x0D чи 0x0A.
Кожен рядок це пара "<key> <value>" (розділяються пробілом), де ключ - це текстовий ідентифікатор макс 16 символів
 (будь-які символи окрім white space chars - пробілу чи переводу на новий рядок), 
 а значення - це десяткове ціле знакове число в діапазоні [-10000, 10000]. 
Провести групування: заповнити два масиви (або масив структур з 2х значень) для зберігання пари <key> та <average> ,
 які будуть включати лише унікальні значення <key> а <average> - це средне значення, обраховане для всіх <value>,
  що відповідають конкретному значенню <key>.
Відсортувати алгоритмом merge sort за <average>, та вивести в stdout  значення key від більших до менших (average desc),
 кожен key окремим рядком.
Наприклад:
a1 1
a1 2
a1 3
a2 0
a2 10 
Результат (average для a2=(0+10)/2=5, для a1=(1+2+3)/3 = 2):
a2
a1
 */

import java.io.IOException;

import java.util.*;

public class Main {
    public static void main(String[] args) {
        DataInput dataInput = new DataInput(); 
        // Масив для зберігання пар <key> та <value>
        String[][] data = new String[10000][2]; 
        int dataSize = 0; 

   
        while (true) {
            String line = dataInput.getString(); 
            if (line.isEmpty()) {
                break; 
            }

            //розбиваємо рядок за допомогою регулярних виразів на частини
            String[] parts = line.split(" ");
            // Зберегти ключ
            data[dataSize][0] = parts[0]; 

            // Зберегти значення
            data[dataSize][1] = parts[1]; 
            dataSize++;
        }

        // Обчислення середніх значень та підготовка даних для сортування
        String[][] averages = new String[10000][2];
        int averagesSize = 0;

        for (int i = 0; i < dataSize; i++) {
            String key = data[i][0];
            int value = Integer.parseInt(data[i][1]);
            double sum = value;
            int count = 1;

            // Знайти всі значення для даного ключа та обчислити їх суму та кількість
            for (int j = i + 1; j < dataSize; j++) {
                if (data[j][0].equals(key)) {
                    sum += Integer.parseInt(data[j][1]);
                    count++;
                    i++;
                }
            }

            // Обчислити середнє значення
            double average = sum / count;

            // Зберегти пару <key, average>
            averages[averagesSize][0] = key;
            averages[averagesSize][1] = Double.toString(average);
            averagesSize++;
        }

       
    }
}
