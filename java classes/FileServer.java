import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.util.Base64;

public class FileServer {
    public String getSong(String fileName) {
        File file = new File("Musics/" + fileName);
        try {
            if (file.exists()) {
                // خواندن فایل و ارسال Base64
                byte[] fileBytes = Files.readAllBytes(file.toPath());
                String base64 = Base64.getEncoder().encodeToString(fileBytes);
                return base64;
            } else {
                return "fileNotFound";
            }
        }catch (IOException e){
            e.printStackTrace();
        }
        return "error";
    }
}
