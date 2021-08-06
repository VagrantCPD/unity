using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DotCD : MonoBehaviour {

    public bool isSuperDot = false;
    public GameObject gameController;

    private void OnTriggerEnter2D(Collider2D collision)
    {
        if (collision.gameObject.tag == "Pacman")
        {
            Destroy(gameObject);
            gameController.GetComponent<GameController>().OnEat(gameObject,isSuperDot);
        }
    }
}
