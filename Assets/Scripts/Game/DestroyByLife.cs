using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DestroyByLife : MonoBehaviour {
    public float life;
    private float beginTime;
	// Use this for initialization
	void Start () {
        beginTime = Time.time;
	}
	
	// Update is called once per frame
	void Update () {
		if(Time.time - beginTime >= life)
        {
            Destroy(gameObject);
        }
	}
}
