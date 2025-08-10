import java.util.Base64;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.io.*;

public class MusicSender {
    public static String encodeFileToBase64(String filePath) throws IOException {
        byte[] fileContent = Files.readAllBytes(Paths.get(filePath));
        return Base64.getEncoder().encodeToString(fileContent);
    }
}