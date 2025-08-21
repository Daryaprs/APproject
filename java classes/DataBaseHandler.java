import java.io.*;
import java.util.ArrayList;
import java.util.Arrays;
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
            JsonArray users = db.getAsJsonArray("users");
            for (int i = 0; i < users.size(); i++) {
                JsonObject user = users.get(i).getAsJsonObject();
                if (user.get("username").getAsString().equals(username)) {
                    return false;
                }
            }
                // user already exists
            JsonObject newUser = new JsonObject();
            newUser.addProperty("username", username);
            newUser.addProperty("password", password);
            User user = new User(username, password);
            Admin.getInstance().addUser(user);
            users.add(newUser);
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
            JsonArray users = db.getAsJsonArray("users");
            for(int i=0; i<users.size(); i++){
                JsonObject user = users.get(i).getAsJsonObject();
                if(user.get("username").getAsString().equals(username)&&user.get("password").getAsString().equals(password)){
                    return true;
                }
            }
            return false;
        } finally {
            lock.readLock().unlock();
        }
    }
    public boolean deleteUser(String username) throws IOException {
        lock.writeLock().lock();
        try {
            JsonObject db = readDatabase();
            JsonArray users = db.getAsJsonArray("users");
            boolean validate = false;
            for(int i=0; i<users.size(); i++){
                JsonObject user = users.get(i).getAsJsonObject();
                if(user.get("username").equals(username)){
                    validate = true;
                    users.remove(user);
                    break;
                }
            }
            for(User user: Admin.getInstance().getUsers()){
                if(user.getUsername().equals(username)){
                    Admin.getInstance().deleteUser(user);
                    break;
                }
            }
            if(validate) {
                writeDatabase(db);
                return true;
            }
            return false;
        } finally {
            lock.writeLock().unlock();
        }
    }
    public boolean changePassword(String username, String newPassword) throws IOException {
        lock.writeLock().lock();
        try {
            JsonObject db = readDatabase();
            JsonArray users = db.getAsJsonArray("users");
            boolean validate = false;
            for(int i=0; i<users.size(); i++){
                JsonObject user = users.get(i).getAsJsonObject();
                if(user.get("username").equals(username)){
                    user.addProperty("password", newPassword);
                    validate = true;
                }
            }
            for(User user: Admin.getInstance().getUsers()){
                if(user.getUsername().equals(username)){
                    user.changePassword(newPassword);
                }
            }
            if(validate){
                writeDatabase(db);
                return true;
            }
            return false;
        } finally {
            lock.writeLock().unlock();
        }
    }
    public JsonArray getMusicList(String username) throws IOException{
        lock.writeLock().lock();
        try {
            JsonObject db = readDatabase();
            JsonArray users = db.getAsJsonArray("users");
            for (int i = 0; i < users.size(); i++) {
                JsonObject user = users.get(i).getAsJsonObject();
                if (user.get("username").getAsString().equals(username)) {
                    if(user.has("songs")){
                        JsonArray musics = user.getAsJsonArray("songs");
                        return musics;
                    }

                }
            }
            return new JsonArray();


        } finally {
            lock.writeLock().unlock();
        }

    }
    public boolean addSong(String username, String songName) throws IOException {
        lock.writeLock().lock();
        try {
            JsonObject db = readDatabase();
            JsonArray users = db.getAsJsonArray("users");
            for (int i = 0; i < users.size(); i++) {
                JsonObject user = users.get(i).getAsJsonObject();
                if (user.get("username").getAsString().equals(username)) {
                    if(user.has("songs")){
                        JsonArray songs = user.getAsJsonArray("songs");
                        songs.add(songName);
                        writeDatabase(db);
                        return true;
                    }else{
                        JsonArray songs = new JsonArray();
                        songs.add(songName);
                        user.add("songs", songs);
                        writeDatabase(db);
                        return true;
                    }
                }
            }
            return false;

        } finally {
            lock.writeLock().unlock();
        }
    }


}

