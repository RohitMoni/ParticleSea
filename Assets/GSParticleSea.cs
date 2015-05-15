using UnityEngine;

namespace Assets
{
    [RequireComponent(typeof(MeshRenderer))]
    [RequireComponent(typeof(MeshFilter))]
    public class GSParticleSea : MonoBehaviour
    {
        private Vector3[] _particlesArray;
        private MeshFilter _meshFilter;

        private const int SeaResolution = 200;
        private const float Spacing = 0.3f;
        private const float NoiseScale = 0.05f;
        private const float HeightScale = 3f;

        private float _perlinNoiseAnimX = 0.01f;
        private float _perlinNoiseAnimY = 0.01f;

        private const float AnimationSpeed = 0.2f;

        void Awake()
        {
            _particlesArray = new Vector3[SeaResolution * SeaResolution];
            _meshFilter = GetComponent<MeshFilter>();
        }

        // Use this for initialization
        void Start ()
        {
            CreateParticleSeaMesh();
        }
	
        // Update is called once per frame
        void Update () {
            RePositionParticleSeaMesh();
        }

        void CreateParticleSeaMesh2()
        {
            var vertices = new Vector3[] { new Vector3(-1, 0, 1), new Vector3(1, 0, 1), new Vector3(1, 0, -1), new Vector3(-1, 0, -1) };
            var uv = new Vector2[] { new Vector2(0, 256), new Vector2(256, 256), new Vector2(256, 0), new Vector2(0, 0) };
            var triangles = new int[] { 0, 1, 2, 0, 2, 3 };

            var stuff = new Mesh();
            _meshFilter.mesh = stuff;
            stuff.vertices = vertices;
            stuff.triangles = triangles;
            stuff.uv = uv;
        }

        private void RePositionParticleSeaMesh()
        {
            var particleSeaMesh = _meshFilter.mesh;

            for (var i = 0; i < SeaResolution; i++)
            {
                for (var j = 0; j < SeaResolution; j++)
                {
                    var yPos = Mathf.PerlinNoise(i * NoiseScale + _perlinNoiseAnimX, j * NoiseScale + _perlinNoiseAnimY) * HeightScale;
                    _particlesArray[i * SeaResolution + j] = new Vector3((i - SeaResolution / 2) * Spacing, yPos, (j - SeaResolution / 2) * Spacing);
                }
            }

            particleSeaMesh.vertices = _particlesArray;

            _perlinNoiseAnimX += AnimationSpeed * Time.smoothDeltaTime;
            _perlinNoiseAnimY += AnimationSpeed * Time.smoothDeltaTime;
        }

        void CreateParticleSeaMesh()
        {
            var particleSeaMesh = new Mesh();
            var uv = new Vector2[SeaResolution*SeaResolution];
            const int extra = (3 - (SeaResolution*SeaResolution%3));
            var triangles = new int[SeaResolution*SeaResolution + extra];

            for (var i = 0; i < SeaResolution; i++)
            {
                for (var j = 0; j < SeaResolution; j++)
                {
                    _particlesArray[i * SeaResolution + j] = new Vector3((i - SeaResolution / 2) * Spacing, 0, (j - SeaResolution / 2) * Spacing);
                    uv[i * SeaResolution + j] = new Vector2(i / 256f, j / 256f);
                    triangles[i*SeaResolution + j] = i*SeaResolution + j;
                }
            }

            //triangles = new int[] {0, 1, 2, 0, 2, 3};
            for (var i = 0; i < extra; i++)
            {
                triangles[(SeaResolution*SeaResolution-1 ) + i] = (SeaResolution*SeaResolution -1);
            }

            _meshFilter.mesh = particleSeaMesh;
            particleSeaMesh.vertices = _particlesArray;
            particleSeaMesh.uv = uv;
            particleSeaMesh.triangles = triangles;
        }
    }
}
