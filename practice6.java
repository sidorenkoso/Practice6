import java.util.Scanner;

public class practice6 {
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);

        // Зчитування підрядка, який потрібно знайти
        System.out.print("Enter a substring to find: ");
        String substringToFind = scanner.nextLine();

        String[] lines = new String[100]; // Максимум 100 рядків

        // Читання рядків 
        int numberOfLines = 0;
        System.out.println("To end the input press enter and 1.");
        System.out.println("Start entering substring:");
        while (numberOfLines < 100) {
            String line = scanner.nextLine();
            if (line.equals("1")) {
                break; // Завершення введення, якщо користувач ввів "1"
            }
            lines[numberOfLines++] = line;
        }
        if(numberOfLines==100){
            System.out.println("You exceeded the number of lines.");
        }

        // Знаходження входжень підрядка в кожному рядку та зберігання результатів
        Result[] results = new Result[numberOfLines];
        for (int i = 0; i < numberOfLines; i++) {
            String line = lines[i];
            int occurrences = countOccurrences(line, substringToFind);
            results[i] = new Result(occurrences, i);
        }

        // Просте сортування за кількістю входжень (bubble sort)
        for (int i = 0; i < numberOfLines - 1; i++) {
            for (int j = 0; j < numberOfLines - i - 1; j++) {
                if (results[j].occurrences > results[j + 1].occurrences) {
                    Result temp = results[j];
                    results[j] = results[j + 1];
                    results[j + 1] = temp;
                }
            }
        }
        System.out.println("The result:");
        System.out.println("The number of occurrences,  index of line");
        for (Result result : results) {
            System.out.println(result.occurrences + " " + result.index);
        }
    }

    // Метод для підрахунку входжень підрядка в рядок
    private static int countOccurrences(String text, String pattern) {
        int count = 0;
        int index = 0;
        while ((index = text.indexOf(pattern, index)) != -1) {
            count++;
            index += pattern.length();
        }
        return count;
    }

    // Клас для зберігання результатів
    static class Result {
        int occurrences;
        int index;

        Result(int occurrences, int index) {
            this.occurrences = occurrences;
            this.index = index;
        }
    }
}