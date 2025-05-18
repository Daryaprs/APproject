import java.util.ArrayList;

public class PlayList {
    private String name;
    private ArrayList<Music> musics;

    public PlayList(String name){
        this.name = name;
    }

    public boolean addMusic(Music m){
        if(!musics.contains(m)){
            musics.add(m);
            return true;
        }
        return false;
    }
     public boolean removeMusic(Music m){
        if(musics.contains(m)){
            musics.remove(m);
            return true;
        }
        return false;
     }
}
