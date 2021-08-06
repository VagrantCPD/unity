using System.Collections;
using System.Collections.Generic;
using UnityEngine.UI;
using UnityEngine.SceneManagement;
using UnityEngine;

public class BeginController : MonoBehaviour {

    public static int skin;

    public static int mode;

    public Text lastGrade;
    public Text bestGrade;

    public Toggle[] skinToggles;
    public Toggle[] modeToggles;
    

    public Button controlSound;
    public Sprite muteSprite;
    public Sprite demuteSprite;

    public GameObject document;

	// Use this for initialization
	void Start () {
        LoadScore();

        skin = PlayerPrefs.GetInt("skin", 0);
        mode = PlayerPrefs.GetInt("mode", 0);

        skinToggles[skin].isOn = true;
        modeToggles[mode].isOn = true;

        if (!PlayerPrefs.HasKey("mute"))
        {
            PlayerPrefs.SetInt("mute", 0);
        }
        int mute = PlayerPrefs.GetInt("mute", 0);
        if(mute == 1)
        {
            controlSound.GetComponent<Image>().sprite = muteSprite;
            controlSound.GetComponent<AudioSource>().Pause();
        }
	}

    private void LoadScore()
    {
        if(!PlayerPrefs.HasKey("lastL"))
        {
            PlayerPrefs.SetInt("lastL", 0);
        }
        if(!PlayerPrefs.HasKey("lastS"))
        {
            PlayerPrefs.SetInt("lastS", 0);
        }
        if(!PlayerPrefs.HasKey("bestL"))
        {
            PlayerPrefs.SetInt("bastL", 0);
        }
        if(!PlayerPrefs.HasKey("bestS"))
        {
            PlayerPrefs.SetInt("bestS", 0);
        }

        int lastLength = PlayerPrefs.GetInt("lastL", 0);
        int lastScore = PlayerPrefs.GetInt("lastS", 0);

        int bestLength = PlayerPrefs.GetInt("bestL", 0);
        int bestScore = PlayerPrefs.GetInt("bestS", 0);

        lastGrade.text = "上次：长度" + lastLength.ToString() + ",\n分数" + lastScore.ToString();
        bestGrade.text = "最好：长度" + bestLength.ToString() + ",\n分数" + bestScore.ToString();
    }
	
	// Update is called once per frame
	void Update () {
		if(Input.GetKeyDown(KeyCode.S))
        {
            ControlSound();
        }
	}

    public void BeginGame()
    {
        SceneManager.LoadSceneAsync("Scenes/Game");
    }

    public void ChangeSkin(Toggle item)
    {
        switch(item.name)
        {
            case "Skin1":
                skin = 0;
                break;
            case "Skin2":
                skin = 1;
                break;
        }
        PlayerPrefs.SetInt("skin", skin);
    }

    public void ChangeMode(Toggle item)
    {
        switch(item.name)
        {
            case "Boundary":
                mode = 0;
                break;
            case "Free":
                mode = 1;
                break;
        }
        PlayerPrefs.SetInt("mode", mode);
    }

    public void QuitGame()
    {
        Application.Quit();
    }

    public void ControlSound()
    {
        int mute = PlayerPrefs.GetInt("mute", 0);
        mute = 1 - mute;
        PlayerPrefs.SetInt("mute", mute);
       
        
        if(mute == 1)
        {
            controlSound.GetComponent<Image>().sprite = muteSprite;
            controlSound.GetComponent<AudioSource>().Pause();
        }
        else if(mute == 0)
        {
            controlSound.GetComponent<Image>().sprite = demuteSprite;
            controlSound.GetComponent<AudioSource>().UnPause();
        }
    }

    public void ShowDocument()
    {
        document.SetActive(true);
    }
}
