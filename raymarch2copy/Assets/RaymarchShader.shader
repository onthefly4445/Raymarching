Shader "Martin/RaymarchShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 5.0
            

            #include "UnityCG.cginc"
            #include "DistanceFunctions.cginc"
            sampler2D _MainTex;
            uniform float4x4 _CamFrustum, _CamToWorld;
            uniform float _maxDistance;
            uniform float _maxSteps;
            uniform float _surfDist;
            uniform float4 _sphere1;
            uniform float3 _rotation;
            uniform float _scale;
            uniform float _fractalScale;
            uniform float4 _box1;
            uniform float3 _lightPos;
            uniform float _Power;
            uniform float _modX;
            uniform float _modY;
            uniform float _modZ;
            uniform float3 _color;
            uniform int _mirror;
            uniform float _smoothness;
            uniform float3 _difColor;
            uniform float _colorIntensity = 1.;
            uniform int _replicateX;
            uniform int _replicateY;
            uniform int _replicateZ;
            uniform float _offset;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            
            struct v2f
            {
                float2 uv : TEXCOORD0; 
                float4 vertex : SV_POSITION;
                float3 ray : TEXCOORD1;
            };
            
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                half index = v.vertex.z;
                v.vertex.z = 0;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.ray = _CamFrustum[(int)index].xyz;

                o.ray /= abs(o.ray.z);

                o.ray = mul(_CamToWorld, o.ray);
                return o;
            }
            float4 getDist(float3 p){
                float4 Scene;
                if(_mirror  == 1){ 
                      float modX = pMod1(p.x, _modX);
                   //   float modY = pMod1(p.y, _modY);
                      float modZ = pMod1(p.z, _modZ);
                }
                float3 bPos = p - _box1.xyz;
              
                bPos.yz = mul(Rotate(_rotation.x), bPos.yz);
                bPos.xz = mul(Rotate(_rotation.y), bPos.xz);
                bPos.xy = mul(Rotate(_rotation.z), bPos.xy);
             
                float3 cPos = bPos;
                float4 Box = float4(_color.rgb, sdBox(bPos,1.));
                float s = 1.;
                bPos.yz = mul(Rotate(_rotation.x), bPos.yz);
                bPos.xz = mul(Rotate(_rotation.y), bPos.xz);
                bPos.xy = mul(Rotate(_rotation.z), bPos.xy);
                for( int m=0; m<5; m++ )
                {
                    float3 a = fmod((bPos+4)*s, 2.0 )-1.0;
                    s *= 3.0;
                    float3 r = abs(1.0 - 3.0*abs(a));
                    float da = max(r.x,r.y);
                    float db = max(r.y,r.z);
                    float dc = max(r.z,r.x);
                    float c = (min(da,min(db,dc))-1.0)/s;

                    Box.w = max(Box.w,c);

                }



                float4 Plane = float4(1, 1, 1, p.y);
                 
                Scene = opColU(Box, Plane);
                return Scene;
            }
            float2 RayMarch(float3 ro, float3 rd){
                float dO = 0.;
                int steps;
                for (steps = 0; steps <_maxSteps; steps++){
                    if (dO>_maxDistance){
                        break;
                    } 

                    float3 p = ro + rd * dO;
                    float4 dS = getDist(p);
                    if (dS.w < _surfDist){
                        _difColor = dS.rgb; //+ float3(i/_maxSteps, i/_maxSteps, i/_maxSteps);
                        break;
                    }
    
                    dO += dS.w;
                } 
               return float2 (dO, steps);
            }
            float3 getNormal(float3 p){
                float d = getDist(p).w;
                float2 e = float2(0.0001, 0);
                float3 n = d - float3(
                    getDist(p-e.xyy).w, 
                    getDist(p-e.yxy).w, 
                    getDist(p-e.yyx).w);
                return normalize(n);
            }
             uniform float _AOStepsize, _AOIntensity;
             uniform int _AOIterations;
            float ambientOcclusion (float3 p, float3 n)
            {
                float step = _AOStepsize;
                float ao = 0.0;
                float dist;

                for (int i = 1; i <= _AOIterations; i++)
                {
                    dist = step * i;
                    ao += max(0.0, (dist - getDist(p + n * dist).w)/dist);
                } 
                return (1.0 - (ao * _AOIntensity));

            }
            float getShadow(float3 p, float d, int steps, float k)
            {
                float result = 1.0;
                if(d <   length(_lightPos - p)) {
                    return 0.1;
                }
                return result;
            }   
            float3 getLight(float3 p, float3 c){
                float3 color = c.rgb * _colorIntensity;
                
                float3 lightPos = _lightPos;//float3( 20*sin(_Time.y), 20, 20*cos(_Time.y)); 
                
                float3 l = normalize(lightPos - p);
                
                float3 n = getNormal(p);

                float ao = ambientOcclusion(p, n);
                
                float dif = clamp(dot(n, l), 0.,1.);
                float d = RayMarch(p+n*_surfDist*2., l).x;
                int steps = RayMarch(p+n*_surfDist*2., l).y;
                float shadow = getShadow(p, d, steps, 12);

                return dif * color * ao * shadow;
            }
            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 col = tex2D(_MainTex, i.uv);
               // float3 col = 0;
                float3 rd = normalize(i.ray.xyz);
                float3 ro = _WorldSpaceCameraPos;

                float d = RayMarch(ro, rd).x;
    
                float3 p = ro + rd * d; 
                float3 dif = getLight(p, _difColor);
                col = dif + float3(0.1,0.1,0.1);
                float4 fragColor = float4(col.rgb,1.0);
                return fragColor;
            }
            ENDCG
        }
    }
}
