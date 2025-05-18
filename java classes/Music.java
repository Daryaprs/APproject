import java.util.ArrayList;
import java.util.Objects;

public class Music {
    private String name;
    private String artist;
    private String album;
    private boolean isFavorite=false;
    private ArrayList<PlayList> playLists;

    public Music(String name, String artist, String album){
        this.name = name;
        this.artist = artist;
        this.album = album;
    }

    @Override
    public boolean equals(Object o) {
        if (o == null || getClass() != o.getClass()) return false;
        Music music = (Music) o;
        return isFavorite == music.isFavorite && Objects.equals(name, music.name) && Objects.equals(artist, music.artist) && Objects.equals(album, music.album) && Objects.equals(playLists, music.playLists);
    }

    @Override
    public int hashCode() {
        return Objects.hash(name, artist, album, isFavorite, playLists);
    }
}
