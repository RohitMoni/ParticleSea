using UnityEngine;
using System.Collections;

public class CameraScript : MonoBehaviour
{

    private GameObject _cpuParticleSea;
    private GameObject _gpuParticleSea;

    void Awake()
    {
        _cpuParticleSea = GameObject.Find("Particle Sea");
        _gpuParticleSea = GameObject.Find("GPU Particle Sea");
    }

	// Use this for initialization
	void Start ()
	{
	    _gpuParticleSea.SetActive(true);
	    _cpuParticleSea.SetActive(false);
	}
	
	// Update is called once per frame
	void Update () {
        if (Input.GetKeyDown(KeyCode.Alpha1))
        {
            _cpuParticleSea.SetActive(false);
            _gpuParticleSea.SetActive(true);
        }
        if (Input.GetKeyDown(KeyCode.Alpha2))
        {
            _cpuParticleSea.SetActive(true);
            _gpuParticleSea.SetActive(false);
        }
        if (Input.GetKeyDown(KeyCode.Alpha3))
        {
            _cpuParticleSea.SetActive(true);
            _gpuParticleSea.SetActive(true);
        }
	}
}
