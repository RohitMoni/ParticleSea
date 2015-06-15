using UnityEngine;

namespace Assets
{
    [RequireComponent(typeof(MeshRenderer))]
    [RequireComponent(typeof(MeshFilter))]
    public class GSParticleSea : MonoBehaviour
    {
        public Gradient ColourGradient;

        private Vector3[] _particlesArray;
        private MeshFilter _meshFilter;
        private Texture2D _gradient1DTexture;
        private Material _material;

        private const int SeaResolution = 200;
        private const int GradientTextureResolution = 100;
        private const float Spacing = 0.3f;
        private const float NoiseScale = 0.05f;
        private const float HeightScale = 3f;

        void Awake()
        {
            _particlesArray = new Vector3[SeaResolution * SeaResolution];
            _meshFilter = GetComponent<MeshFilter>();
            _material = GetComponent<Renderer>().material;
        }

        // Use this for initialization
        void Start ()
        {
            CreateParticleSeaMesh();
            SetUpShaderProperties();
        }
	
        void CreateParticleSeaMesh()
        {
            var particleSeaMesh = new Mesh();

            // The extra variable adds indices so that we get an even set of triangles no matter the resolution of the mesh. (Ex: 40,000 vertices = 40,002 indices)
            // This is because each vertice in every triangle is used to make a particle, so we don't actually use the triangles anyway, it's just to pass it into the shader
            // The last triangle (assuming there are extra indices needed) will use the same vertice multiple times. This is smallest inefficiency I could think of to make this work.

            const int extra = (3 - (SeaResolution*SeaResolution%3));
            var triangles = new int[SeaResolution * SeaResolution + extra];

            for (var i = 0; i < SeaResolution; i++)
            {
                for (var j = 0; j < SeaResolution; j++)
                {
                    _particlesArray[i * SeaResolution + j] = new Vector3((i - SeaResolution / 2) * Spacing, 0, (j - SeaResolution / 2) * Spacing);
                    triangles[i*SeaResolution + j] = i*SeaResolution + j;
                }
            }

            for (var i = 0; i < extra; i++)
            {
                triangles[(SeaResolution*SeaResolution-1 ) + i] = (SeaResolution*SeaResolution -1);
            }

            _meshFilter.mesh = particleSeaMesh;
            particleSeaMesh.vertices = _particlesArray;
            particleSeaMesh.triangles = triangles;
        }

        void SetUpShaderProperties()
        {
            // Create a texture from the colour gradient in the inspector and insert it as a property into the shader
            _gradient1DTexture = CreateGradientTexture();
            _material.SetTexture("_Gradient", _gradient1DTexture);

            // Set up other properties
            _material.SetInt("_SeaResolution", SeaResolution);
            _material.SetFloat("_Spacing", Spacing);
            _material.SetFloat("_NoiseScale", NoiseScale);
            _material.SetFloat("_HeightScale", HeightScale);
        }

        Texture2D CreateGradientTexture()
        {
            var texture = new Texture2D(GradientTextureResolution, 1);

            for (var i = 0; i < GradientTextureResolution; i++)
            {
                texture.SetPixel(i, 0, ColourGradient.Evaluate((float)i / GradientTextureResolution));
                //texture.SetPixel(GradientTextureResolution - i, 0, ColourGradient.Evaluate((float)i / GradientTextureResolution));
            }
            texture.Apply();

            return texture;
        }
    }
}
