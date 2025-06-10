import java.io.*;
import java.util.concurrent.locks.*;
import com.google.gson.*;

public class DataBaseHandler {
    private final File file = new File("users.json");
    private final Gson gson = new GsonBuilder().setPrettyPrinting().create();
    private final ReadWriteLock lock = new ReentrantReadWriteLock();

    public DataBaseHandler() {
        if (!file.exists()) {
            JsonObject initial = new JsonObject();
            initial.add("users", new JsonObject());
            try {
                writeDatabase(initial);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    public JsonObject readDatabase() throws IOException {
        lock.readLock().lock();
        try (FileReader reader = new FileReader(file)) {
            return gson.fromJson(reader, JsonObject.class);
        } finally {
            lock.readLock().unlock();
        }
    }

    public void writeDatabase(JsonObject data) throws IOException {
        lock.writeLock().lock();
        try (FileWriter writer = new FileWriter(file)) {
            gson.toJson(data, writer);
        } finally {
            lock.writeLock().unlock();
        }
    }

    public boolean addUser(String username, String password) throws IOException {
        lock.writeLock().lock();
        try {
            JsonObject db = readDatabase();
            JsonObject users = db.getAsJsonObject("users");
            if (users.has(username)) return false;  // user already exists
            users.addProperty(username, password);
            writeDatabase(db);
            return true;
        } finally {
            lock.writeLock().unlock();
        }
    }

    public boolean validateUser(String username, String password) throws IOException {
        lock.readLock().lock();
        try {
            JsonObject db = readDatabase();
            JsonObject users = db.getAsJsonObject("users");
            return users.has(username) && users.get(username).getAsString().equals(password);
        } finally {
            lock.readLock().unlock();
        }
    }
    public boolean deleteUser(String username) throws IOException {
        lock.writeLock().lock();
        try {
            JsonObject db = readDatabase();
            JsonObject users = db.getAsJsonObject("users");
            if (!users.has(username)) return false;
            users.remove(username);
            writeDatabase(db);
            return true;
        } finally {
            lock.writeLock().unlock();
        }
    }
    public boolean changePassword(String username, String newPassword) throws IOException {
        lock.writeLock().lock();
        try {
            JsonObject db = readDatabase();
            JsonObject users = db.getAsJsonObject("users");
            if (!users.has(username)) return false;
            users.addProperty(username, newPassword);
            writeDatabase(db);
            return true;
        } finally {
            lock.writeLock().unlock();
        }
    }


}

