using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
[ExecuteInEditMode]
public class RaymarchCamera : SceneViewFilter
{
    public float mouseSensitivty = 300f;
    public float moveSpeed = 20f;
    float xRotation = 0f;
    float yRotation = 0f; 
    void Start(){
        Cursor.lockState = CursorLockMode.Locked;
    }
    void Update(){
        float mouseX = Input.GetAxis("Mouse X") * mouseSensitivty * Time.deltaTime;
        float mouseY = Input.GetAxis("Mouse Y") * mouseSensitivty * Time.deltaTime;
        xRotation -= mouseY;
        yRotation -= mouseX;
        xRotation = Mathf.Clamp(xRotation, -90f, 90f);

        //transform.localRotation = Quaternion.Euler(, 0f, 0f);
      
        float x = Input.GetAxis("Horizontal");
        float z = Input.GetAxis("Vertical");
        float y = 0;

        if(Input.GetKey(KeyCode.Space))
            y = 0.7f;
        else if(Input.GetKey(KeyCode.LeftShift))
            y = -0.7f;

         Vector3 dir; 
        if(_lockCameraBool)
        {
            dir = new Vector3(Mathf.Sin(Time.realtimeSinceStartup + Mathf.PI)*moveSpeed , 5f  , Mathf.Cos(Time.realtimeSinceStartup+Mathf.PI)*moveSpeed);
            transform.position = dir;
            transform.localRotation = Quaternion.Euler(0f, (Time.realtimeSinceStartup/Mathf.PI)*180, 0f);//(Time.realtimeSinceStartup/Mathf.PI)*90);
        }
        else{
            dir = transform.right * x + transform.up * y + transform.forward * z;
            transform.position += dir * Time.deltaTime*moveSpeed;
            transform.localRotation = Quaternion.Euler(xRotation, -yRotation, 0f);
        } 
   
        //Rotate
        if(Input.GetKeyUp(KeyCode.R)){
            if(_rotate == 1){
                _rotateBool = false;
                _rotate = 0;
            }
            else{
                _rotateBool = true;
                _rotate = 1;    
            }
        }
        if(Input.GetKeyUp(KeyCode.M)){
            if(_mirror == 1){
                _mirrorBool = false;
                _mirror = 0;
            }
            else{
                _mirrorBool = true;
                _mirror = 1;    
            }
        }

         if(Input.GetKeyUp(KeyCode.L)){
            if(_lockCameraBool){
                _lockCameraBool = false;
            }
            else{
                _lockCameraBool = true;
            }
        }
        if(Input.GetKeyUp(KeyCode.O)){
            if(_smoothness>0.1) _smoothness -= 0.1f; 
        }
        if(Input.GetKeyUp(KeyCode.P)){
            _smoothness += 0.1f; 
        }
        if(Input.GetKeyUp(KeyCode.C)){
            _change = (_change+1) % 3; 
        }
        
        if(Input.GetKeyUp(KeyCode.X)){
            _scale += 1; 
        }
        
        if(Input.GetKeyUp(KeyCode.Y)){
            if(_scale >= 1) _scale -= 1; 
        }
        if(Input.GetKeyUp(KeyCode.F)){
            _glowIntensity -= 0.1f; 
        }
        if(Input.GetKeyUp(KeyCode.G)){
            _glowIntensity += 0.1f; 
        }
        _rotate = _rotateBool? 1 : 0;
        _mirror = _mirrorBool? 1 : 0;
        _boxInt = _showBox? 1 : 0;
        _sphereInt = _showSphere? 1 : 0;
        _torusInt = _showTorus? 1 : 0;


    }
    
    
    [SerializeField]
    private Shader _shader;

    public Material _raymarchMaterial
    {
        get
        {
            if (!_raymarchMat && _shader)
            {
                _raymarchMat = new Material(_shader);
                _raymarchMat.hideFlags = HideFlags.HideAndDontSave;
            }
            return _raymarchMat;
        }
    }

    private Material _raymarchMat;
    
    public Camera _camera
    {
        get
        {
            if (!_cam)
            {
                _cam = GetComponent<Camera>();   
            }
            return _cam;

        }

    }
    public bool _lockCameraBool;
    int _lockCam;
    int _change;
    private Camera _cam;
    [Header("RayMarching")]
    [Range(1, 300)]
    public float _maxDistance;
    [Range(1, 1000)]
    public float _maxSteps;
    [Range(0.1f, 0.001f)]
    public float _surfDist;

    public Vector3 _lightPos;
    [Header("AmbientOcclusion")]
    [Range(0.01f, 10.0f)]
    public float _AOStepsize;
    [Range(0,1)]
    public float _AOIntensity;
    [Range(1,50)]
    public int _AOIterations;

    [Header("Mirroring")]
   
    public bool _mirrorBool; 
    [Range(0, 1)]
    int _mirror;
    public float _modX;
    public float _modY;
    public float _modZ;

    [Range(0, 50)]
    public int _replicateX;
    
    [Range(0, 50)]
    public int _replicateY;
    
    [Range(0, 50)]
    public int _replicateZ;
    public float _offset;

    [Header("Smooth transition")]
    public bool _smoothTransition;
    int _smooth;
    [Range(0f, 15f)]
    public float _smoothness;
    [Header("Color")]
    [Range(0f, 2f)]
    public float _colorIntensity;
    public Color _color;
    [Header("Glow")]
    [Range(0f, 2f)]
    public float _glowIntensity;
    public Color _glowColor;
    [Header("Objects")]
    [Range(0f, 10f)]
    public float _objScale;
    public Vector4 _obj;
    [Header("Box")]
    public bool _showBox;
    public bool _smoothBox;
    int _boxInt;
    public Color _boxColor;
    public Vector4 _box;
    [Header("Sphere")]
    public bool _showSphere;
    public bool _smoothSphere;
    int _sphereInt;
    public Color _sphereColor;
    public Vector4 _sphere;
    [Header("Torus")]
    public bool _showTorus;
    public bool _smoothTorus;
    int _torusInt;
    public Color _torusColor;
    public Vector4 _torus;
    [Header("Fractal")]
    [Range(-3.0f, 3.0f)]
    public float _Power;
    [Header("Rotation")]
    public bool _rotateBool;
    [Range(0, 1)]
    int _rotate;

    public Vector3 _rotation;

    [Range(0f, 50.0f)]
    public float _scale;

   // public Transform _directionalLight;

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(!_raymarchMaterial)
        {
            Graphics.Blit(source, destination);
            return;
        }

        _raymarchMaterial.SetMatrix("_CamFrustum", CamFrustum(_camera));
        _raymarchMaterial.SetMatrix("_CamToWorld", _camera.cameraToWorldMatrix);
        _raymarchMaterial.SetVector("_lightPos", _lightPos);
        _raymarchMaterial.SetFloat("_maxDistance", _maxDistance);
        _raymarchMaterial.SetFloat("_maxSteps", _maxSteps);
        _raymarchMaterial.SetFloat("_surfDist", _surfDist);
        _raymarchMaterial.SetFloat("_AOIntensity", _AOIntensity);
        _raymarchMaterial.SetFloat("_AOStepsize", _AOStepsize);
        _raymarchMaterial.SetInt("_AOIterations", _AOIterations);
        _raymarchMaterial.SetFloat("_modX", _modX);
        _raymarchMaterial.SetFloat("_modY", _modY);
        _raymarchMaterial.SetFloat("_modZ", _modZ);
        _raymarchMaterial.SetFloat("_Power", _Power);
        _raymarchMaterial.SetFloat("_smoothness", _smoothness);
        _raymarchMaterial.SetFloat("_colorIntensity", _colorIntensity);
        _raymarchMaterial.SetVector("_sphere", _sphere);
        _raymarchMaterial.SetFloat("_objScale",_objScale);
        _raymarchMaterial.SetVector("_obj", _obj);
        _raymarchMaterial.SetVector("_box", _box);
        _raymarchMaterial.SetVector("_torus", _torus);
        _raymarchMaterial.SetInt("_rotate", _rotate);
        _raymarchMaterial.SetVector("_rotation", _rotation);
        _raymarchMaterial.SetFloat("_scale", _scale);
        //_raymarchMaterial.SetVector("_LightDir", _directionalLight? _directionalLight.forward : Vector3.down);
        _raymarchMaterial.SetColor("_color", _color);
        _raymarchMaterial.SetFloat("_glowIntensity", _glowIntensity);
        _raymarchMaterial.SetColor("_glowColor", _glowColor);
        _raymarchMaterial.SetInt("_mirror", _mirror);
        _raymarchMaterial.SetInt("_replicateX", _replicateX);
        _raymarchMaterial.SetInt("_replicateY", _replicateY);
        _raymarchMaterial.SetInt("_replicateZ", _replicateZ);
        _raymarchMaterial.SetFloat("_offset", _offset);
        _raymarchMaterial.SetInt("_boxInt", _boxInt);
        _raymarchMaterial.SetInt("_sphereInt", _sphereInt);
        _raymarchMaterial.SetInt("_torusInt", _torusInt);
        _raymarchMaterial.SetInt("_change", _change);
        _raymarchMaterial.SetColor("_boxColor", _boxColor);
        _raymarchMaterial.SetColor("_sphereColor", _sphereColor);
        _raymarchMaterial.SetColor("_torusColor", _torusColor);
        RenderTexture.active = destination;
        _raymarchMaterial.SetTexture("_MainTex", source);
        GL.PushMatrix();
        GL.LoadOrtho();
        _raymarchMaterial.SetPass(0);
        GL.Begin(GL.QUADS);
        
        //Bottom Left
        GL.MultiTexCoord2(0, 0.0f, 0.0f);
        GL.Vertex3(0.0f, 0.0f, 3.0f);
        //Bottom Right
        GL.MultiTexCoord2(0, 1.0f, 0.0f);
        GL.Vertex3(1.0f, 0.0f, 2.0f);
        //Top Right
        GL.MultiTexCoord2(0, 1.0f, 1.0f);
        GL.Vertex3(1.0f, 1.0f, 1.0f);
        //Top Left
        GL.MultiTexCoord2(0, 0.0f, 1.0f);
        GL.Vertex3(0.0f, 1.0f, 0.0f);

        GL.End();
        GL.PopMatrix();
    }
    private Matrix4x4 CamFrustum(Camera cam)
    {
        Matrix4x4 frustum = Matrix4x4.identity;
        float fov = Mathf.Tan((cam.fieldOfView * 0.5f) * Mathf.Deg2Rad);

        Vector3 goUp = Vector3.up * fov;
        Vector3 goRight = Vector3.right * fov * cam.aspect;

        //calculating all corners of frustum based on aspectratio and fov
        Vector3 TL = (-Vector3.forward - goRight + goUp);
        Vector3 TR = (-Vector3.forward + goRight + goUp);
        Vector3 BR = (-Vector3.forward + goRight - goUp);
        Vector3 BL = (-Vector3.forward - goRight - goUp);
        
        frustum.SetRow(0, TL);
        frustum.SetRow(1, TR);
        frustum.SetRow(2, BR);
        frustum.SetRow(3, BL);

        return frustum;
    }
}
