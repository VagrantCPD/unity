using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AudioController : MonoBehaviour {
    public AudioSource eat;
    public AudioSource gameOver;
    public AudioSource bgm;

	public void OnEat()
    {
        if (PlayerPrefs.GetInt("mute",0) == 0)
        {
            eat.Play();
        }
    }

    public void OnGameOver()
    {
        if (PlayerPrefs.GetInt("mute", 0) == 0)
        {
            gameOver.Play();
        }
    }

    public void InitBgm()
    {
        bgm.Play();
        ControlBgm();
    }

    public void ControlBgm()
    {
        int mute = PlayerPrefs.GetInt("mute", 0);
        if (mute == 0)
        {
            bgm.UnPause();
        }
        else if(mute == 1)
        {
            bgm.Pause();
        }
    }
}
