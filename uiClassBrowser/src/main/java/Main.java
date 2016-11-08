
import javax.swing.*;

public class Main {
    public static void main(String[] args) {

        javax.swing.SwingUtilities.invokeLater( () -> createAndShowGUI() );
    }

    private static void createAndShowGUI() {

        JFrame frame = new JFrame("Class Browser");
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

        frame.setContentPane(new MainUI().mainPanel);

        frame.pack();
        frame.setVisible(true);
    }
}
