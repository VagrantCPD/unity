using UnityEngine.SceneManagement;
using UnityEngine;

public class BeginController : MonoBehaviour {

    public void BeginGame()
    {
        SceneManager.LoadSceneAsync("Scenes/游戏界面");
    }

    public void QuitGame()
    {
        Application.Quit();
    }
}
