import java.io.*;
import java.net.*;
import java.nio.file.Files;
import java.util.Base64;

import com.google.gson.*;

public class ClientHandler extends Thread {
    private final Socket socket;
    private final DataBaseHandler db;

    public ClientHandler(Socket socket, DataBaseHandler db) {
        this.socket = socket;
        this.db = db;
    }

    @Override
    public void run() {
        try (
                BufferedReader reader = new BufferedReader(new InputStreamReader(socket.getInputStream()));
                PrintWriter writer = new PrintWriter(socket.getOutputStream(), true)
        ) {
            String request;
            while ((request = reader.readLine()) != null) {
                JsonObject json = JsonParser.parseString(request).getAsJsonObject();
                String type = json.get("type").getAsString();

                if (type.equals("signup")) {
                    String user = json.get("username").getAsString();
                    String pass = json.get("password").getAsString();
                    boolean result = db.addUser(user, pass);
                    writer.println(result ? "signup_success" : "signup_fail");
                } else if (type.equals("login")) {
                    String user = json.get("username").getAsString();
                    String pass = json.get("password").getAsString();
                    boolean result = db.validateUser(user, pass);
                    writer.println(result ? "login_success" : "login_fail");

                }else if (type.equals("delete")) {
                    String user = json.get("username").getAsString();
                    boolean result = db.deleteUser(user);
                    writer.println(result ? "delete_success" : "delete_fail");
                }else if (type.equals("change_password")) {
                    String user = json.get("username").getAsString();
                    String newPass = json.get("new_password").getAsString();
                    boolean result = db.changePassword(user, newPass);
                    writer.println(result ? "change_success" : "change_fail");
                }else if(type.equals("get_music_list")){
                    File musicFolder = new File("Musics");
                    String[] files = musicFolder.list((dir, name) -> name.endsWith(".mp3"));
                    if (files == null) files = new String[0];

                    JsonObject response = new JsonObject();
                    response.addProperty("status", "ok");
                    JsonArray list = new JsonArray();
                    for (String fileName : files) {
                        list.add(fileName);
                    }
                    response.add("music_list", list);

                    writer.println(response.toString());
                    writer.flush();
                }else if(type.equals("get_music_file")){
                    String fileName = json.get("file_name").getAsString();
                    try {
                        File file = new File("Musics/" + fileName);
                        if (file.exists()) {
                            byte[] fileBytes = Files.readAllBytes(file.toPath());
                            String base64Data = Base64.getEncoder().encodeToString(fileBytes);

                            JsonObject response = new JsonObject();
                            response.addProperty("status", "ok");
                            response.addProperty("file_data", base64Data);

                            writer.println(response);
                        } else {
                            JsonObject response = new JsonObject();
                            response.addProperty("status", "error");
                            response.addProperty("message", "File not found");
                            writer.println(response);
                        }
                    } catch (IOException e) {
                        JsonObject response = new JsonObject();
                        response.addProperty("status", "error");
                        response.addProperty("message", "Could not read file");
                        writer.println(response);
                    }
                }
                else {
                    writer.println("unknown_command");
                }
            }
        } catch (IOException e) {
            System.out.println("Client disconnected");
        }
    }
}
