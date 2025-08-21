import java.util.ArrayList;
import java.util.Objects;

public class Music {
    private String name;
    private String filePath;
    private boolean isFavorite=false;
    private ArrayList<PlayList> playLists;

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
}
