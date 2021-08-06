using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class PostEffectsManager : MonoBehaviour
{
    public enum EffectType { BrightAndContrast, EdgeDetect, GuassBlur, Bloom };

    private EffectType lastType;

    [SerializeField, SetProperty("effectType")]
    private EffectType m_effectType = (EffectType)0;
    public EffectType effectType
    {
        get
        {
            return m_effectType;
        }
        set
        {
            m_effectType = effectType;
            OnEffectTypeChanged(effectType);
        }
    }

    List<PostEffectsBase> effects;


    // Start is called before the first frame update
    void Start()
    {
        effects = new List<PostEffectsBase>(GetComponents<PostEffectsBase>());
        lastType = EffectType.BrightAndContrast;
    }

    void OnEffectTypeChanged(EffectType type)
    {
        effects[(int)lastType].enabled = false;
        effects[(int)m_effectType].enabled = true;
        lastType = m_effectType;
        UnityEditor.Selection.objects = new Object[] { effects[(int)m_effectType] };
    }
}
