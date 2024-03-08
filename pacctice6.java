import java.util.*;
class pactice6{
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        String[] lines = new String[100];
        int countlines = 0;
        while(scanner.hasNextLine() && countlines < 100){
            lines[countlines] = scanner.nextLine();
        }
        System.out.println("Введіть підрядок для знаходження: ");
        String find = args[0];
        result[] results = new result[countlines];
        for(int i=0; i<countlines; i++){
            String line = lines[i];
            int findings = Countfindings(line, find);
            results[i] = new result(findings, i);
        }
    }

    private static int Countfindings(String text, String pattern){
        int count = 0;
        int index = 0;
        while((index = text.indexOf(pattern, index))!= -1){
            count++;
            index+=pattern.length();
        }
        return count;
    }

    static class result {
        int index;
        int numberOffindinig;
        public result(int index, int numberOffinding){
            this.index = index;
            this.numberOffindinig = numberOffinding;
        }
    }   
}