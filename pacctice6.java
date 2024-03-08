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
        
    }    
}