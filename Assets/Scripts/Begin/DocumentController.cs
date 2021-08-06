using System.Collections;
using System.Collections.Generic;
using UnityEngine.UI;
using UnityEngine;

public class DocumentController : MonoBehaviour {

    public GameObject document;
    public Image[] backgrounds;
    public GameObject[] gameObjects;
    

	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
	    if(Input.GetKeyDown(KeyCode.H))
        {
            document.SetActive(true);
        }
        else if(Input.GetKeyDown(KeyCode.Escape))
        {
            document.SetActive(false);
        }
	}

    public void SwitchOption(Toggle option)
    {
        if(option.name == "Game")
        {
            gameObjects[0].SetActive(true);
            gameObjects[1].SetActive(false);

            backgrounds[0].color = new Color32(224, 193, 5, 137);
            backgrounds[1].color = new Color32(111, 97, 14, 137);
            
        }
        else if(option.name == "ShortCut")
        {
            gameObjects[0].SetActive(false);
            gameObjects[1].SetActive(true);

            backgrounds[0].color = new Color32(111, 97, 14, 137);
            backgrounds[1].color = new Color32(224, 193, 5, 137);
        }
    }
}
