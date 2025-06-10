import java.util.ArrayList;

public class Admin {
    private ArrayList<User> users = new ArrayList<User>();
    private static Admin instance;
    private Admin() {}
    public static Admin getInstance() {
        if (instance == null) {
            instance = new Admin();
        }
        return instance;
    }
    public void addUser(User user){
        users.add(user);
    }

}
