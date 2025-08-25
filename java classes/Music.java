import java.util.ArrayList;
import java.util.Objects;
import com.google.gson.*;


public class Music {
    private String name;
    private String filePath;
    private boolean isFavorite=false;
    private ArrayList<PlayList> playLists;
    private long addedAt;

    public Music(String name, String filePath){
        this.name = name;
        this.filePath = filePath;
    }

    @Override
    public boolean equals(Object o) {
        if (o == null || getClass() != o.getClass()) return false;
        Music music = (Music) o;
        return isFavorite == music.isFavorite && Objects.equals(name, music.name) && Objects.equals(filePath, music.filePath) && Objects.equals(playLists, music.playLists);
    }

    @Override
    public int hashCode() {
        return Objects.hash(name, filePath, isFavorite, playLists);
    }

    public String getName() {
        return name;
    }

    public String getFilePath() {
        return filePath;
    }

    public void setFavorite(boolean favorite) {
        isFavorite = favorite;
    }

    public void setAddedAt(long addedAt) {
        this.addedAt = addedAt;
    }

    public long getAddedAt() {
        return addedAt;
    }
    public JsonObject toJson() {
        JsonObject json = new JsonObject();
        json.addProperty("name", name);
        json.addProperty("filePath", filePath);
        return json;
    }
    public static Music fromJson(JsonObject json) {
        Music music = new Music(
                json.get("name").getAsString(),
                json.get("filePath").getAsString()
        );
        music.addedAt = json.get("addedAt").getAsLong();
        return music;
    }
}
