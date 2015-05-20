using UnityEditor;
using UnityEngine;
using System.Collections;

public class ParticleSea : MonoBehaviour
{
    public Gradient ColourGradient;

    private ParticleSystem _particleSystem;
    private ParticleSystem.Particle[] _particlesArray;

    private const int SeaResolution = 200;
    private const float Spacing = 0.3f;
    private const float NoiseScale = 0.05f;
    private const float HeightScale = 3f;

    private float _perlinNoiseAnimX = 0.01f;
    private float _perlinNoiseAnimY = 0.01f;

    private const float AnimationSpeed = 0.2f;

    void Awake()
    {
        _particlesArray = new ParticleSystem.Particle[SeaResolution * SeaResolution];
        _particleSystem = GetComponent<ParticleSystem>();
    }

	// Use this for initialization
	void Start () {
        _particleSystem.maxParticles = SeaResolution*SeaResolution;
        _particleSystem.Emit(SeaResolution * SeaResolution);
	    _particleSystem.GetParticles(_particlesArray);

        PositionParticles();
	}
	
	// Update is called once per frame
	void Update () {
	    PositionParticles();
	}

    void PositionParticles()
    {
        for (var i = 0; i < SeaResolution; i++)
        {
            for (var j = 0; j < SeaResolution; j++)
            {
                var yPos = Mathf.PerlinNoise(i*NoiseScale + _perlinNoiseAnimX, j*NoiseScale + _perlinNoiseAnimY) * HeightScale;
                _particlesArray[i * SeaResolution + j].position = new Vector3((i - SeaResolution/2) * Spacing, yPos, (j - SeaResolution/2) * Spacing);
                _particlesArray[i*SeaResolution + j].color = ColourGradient.Evaluate(yPos / HeightScale);
            }
        }
        _particleSystem.SetParticles(_particlesArray, _particlesArray.Length);

        _perlinNoiseAnimX += AnimationSpeed * Time.smoothDeltaTime;
        _perlinNoiseAnimY += AnimationSpeed * Time.smoothDeltaTime;
    }


}
