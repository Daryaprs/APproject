import java.util.ArrayList;

public class User {
    private String username;
    private String password;
    private ArrayList<PlayList> playlists;
    private PlayList musics;
    private boolean isLogedIn;

    public User(String username, String password){
        this.username = username;
        this.password = password;
    }

    public boolean addPlayList(PlayList p){
        if(!playlists.contains(p)){
            playlists.add(p);
            return true;
        }
        return false;
    }



}
