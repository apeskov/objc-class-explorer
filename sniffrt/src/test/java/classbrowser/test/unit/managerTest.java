package classbrowser.test.unit;

import classbrowser.Manager;

import org.junit.Test;

public class managerTest {

    @Test
    public void readFromConnection() {

        Manager manager = new Manager();
        manager.startSniffing();
    }

}
