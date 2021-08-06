using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SkinController : MonoBehaviour {
    public GameObject[] headStyles;
    public Dictionary<int, GameObject[]> bodyStyles = new Dictionary<int, GameObject[]>();

    public GameObject[] bodyStyle1;
    public GameObject[] bodyStyle2;

    private void Start()
    {
        bodyStyles[0] = bodyStyle1;
        bodyStyles[1] = bodyStyle2;
    }
}
