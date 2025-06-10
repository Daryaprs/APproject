import java.io.*;
import java.net.ServerSocket;
import java.net.Socket;
import com.google.gson.Gson;

public class TcpServer {
    public static void main(String[] args) {
        int port = 3000;
        DataBaseHandler db = new DataBaseHandler();

        try (ServerSocket serverSocket = new ServerSocket(port)) {
            System.out.println("Server started on port " + port);

            while (true) {
                Socket clientSocket = serverSocket.accept();
                System.out.println("New client connected");

                ClientHandler handler = new ClientHandler(clientSocket, db);
                handler.start();  // starts a new thread
            }
        } catch (IOException e) {
            e.printStackTrace();
        }

    }
}