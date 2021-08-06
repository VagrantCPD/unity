using UnityEngine.SceneManagement;
using System.Collections.Generic;
using UnityEngine;

public class GameController : MonoBehaviour {

    private List<GameObject> dots = new List<GameObject>();
    private bool hasSuperDot = false;
    private int initCount;

    private GameObject[] enemies;

    public GameObject countDown;
    public GameObject ui;
    public GameObject uiController;

    public enum GAMESTATE { WAITING=0,PLAYING,GAMEOVER};
    public static GAMESTATE gameState;

    private int score = 0;
    private int remain = 0;
    private int eat = 0;
    

    // Use this for initialization
    void Start () {
        GameObject maze = GameObject.FindGameObjectWithTag("Maze");
        Transform[] transforms = maze.GetComponentsInChildren<Transform>();
        foreach (Transform t in transforms)
        {
            dots.Add(t.gameObject);
        }
        initCount = dots.Count;
        remain = dots.Count - 1;

        enemies = GameObject.FindGameObjectsWithTag("Enemy");
        
        countDown = Instantiate(countDown) as GameObject;
        gameState = GAMESTATE.WAITING;
        Invoke("StartGame", 4.0f);
	}

    private void Update()
    {
        if(Input.GetKeyDown(KeyCode.Escape))
        {
            SceneManager.LoadSceneAsync("Scenes/开始界面");
        }
        if(Input.GetKeyDown(KeyCode.R))
        {
            if(gameState == GAMESTATE.GAMEOVER)
            {
                SceneManager.LoadSceneAsync("Scenes/游戏界面");
            }
        }
    }

    private void StartGame()
    {
        gameState = GAMESTATE.PLAYING;
        ui.SetActive(true);
        Destroy(countDown);
        Invoke("GenSuperDot", 10.0f);

        uiController.GetComponent<UIController>().UpdateEat(eat);
        uiController.GetComponent<UIController>().UpdateRemain(remain);
        uiController.GetComponent<UIController>().UpdateScore(score);
    }

    public void OnEat(GameObject dot,bool isSuper)
    {
        dots.Remove(dot);

        if(isSuper)
        {
            Invoke("GenSuperDot", 10.0f);
            FreezeEnemy();
            score += 50;
        }
        else
        {
            score += 20;
        }

        remain--;
        eat++;
        uiController.GetComponent<UIController>().UpdateEat(eat);
        uiController.GetComponent<UIController>().UpdateRemain(remain);
        uiController.GetComponent<UIController>().UpdateScore(score);

        if(remain == 0)
        {
            WinGame();
        }
    }

    public void OnEatEnemy()
    {
        score += 100;
        uiController.GetComponent<UIController>().UpdateScore(score);
    }

    public void FreezeEnemy()
    {
        CancelInvoke("UnFreezeEnemy");
        foreach(GameObject enemy in enemies)
        {
            enemy.GetComponent<EnemyMove>().OnFreeze();
        }
        Invoke("UnFreezeEnemy", 5.0f);
    }

    private void UnFreezeEnemy()
    {
        foreach (GameObject enemy in enemies)
        {
            enemy.GetComponent<EnemyMove>().UnFreeze();
        }
    }

    private void GenSuperDot()
    {
        if (dots.Count / (float)initCount <= 0.2f) return;
        int index = Random.Range(0, dots.Count);
        dots[index].transform.localScale = new Vector3(3, 3, 3);
        dots[index].GetComponent<DotCD>().isSuperDot = true;
    }

    public void GameOver()
    {
        Destroy(GameObject.FindGameObjectWithTag("Pacman"));
        uiController.GetComponent<UIController>().UpdateMessage(false);
        gameState = GAMESTATE.GAMEOVER;
    }

    public void WinGame()
    {
        uiController.GetComponent<UIController>().UpdateMessage(true);
        gameState = GAMESTATE.GAMEOVER;
    }
}
