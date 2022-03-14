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
                float3 sPos = p - _sphere1.xyz;

                bPos.yz = mul(Rotate(_rotation.x), bPos.yz);
                bPos.xz = mul(Rotate(_rotation.y), bPos.xz);
                bPos.xy = mul(Rotate(_rotation.z), bPos.xy);

            // //-------------------------BoxFract-------------------------  
            //    float3 foldVector = float3(sin(_Time.y)*10. - 40., -cos(_Time.y ) * 1.25 + 3.75 , cos(_Time.y ) * 50. - 50);
            //    for (int i = 0; i <_scale; i++ ){
            //    //     bPos = fold(bPos, normalize(float3(sin(_Time.z/50.), -cos(_Time.z/50.), sin(_Time.z/50.))));
            //         // if(bPos.x + bPos.y < 0.) bPos.xy = -bPos.yx;
            //         // if(bPos.x + bPos.z < 0.) bPos.xz = -bPos.zx;
            //         // if(bPos.y + bPos.z < 0.) bPos.zy = -bPos.yz;
            //         bPos = fold(bPos, normalize(foldVector));
            //         bPos = abs(bPos);
            //         bPos.x -= 1;
            //         bPos.y -= 5; 
            //         bPos.z -= 0.5; 
            //         bPos = fold(bPos, normalize(-foldVector));
            //         _box1.w = sin(_Time.z)*2.5 + 4.;
            //  //      bPos = fold(bPos, normalize(float3(cos(_Time.z/50.), sin(_Time.z/50.), cos(_Time.z/50.))));
                    
            //    }
               
               
            //-------------------------MandelBoxWannabe-----------------
                // float dR = 1.0;
                // float3 offset = bPos;
                // for (int i = 0; i <_scale; i++){
                //     bPos = boxFold(bPos, _box1.w);
                //     bPos = sphereFold(bPos, dR, 1., _box1.w);
                    
                //     bPos = _Power * bPos + offset;
                //     dR = dR*abs(_Power) + 1.0;
                // }
                // float r = length(bPos)/abs(dR);


                float4 Menger = float4(_color.rgb, sdMengerSponge(bPos, 4., _box1.w));
                float4 Sierpinsky = float4(_color.rgb, sdFraktal(bPos, _Power, _scale));
                float4 Box = float4(_color.rgb, sdBox(bPos, _box1.w));
                float4 HollowBox = opColS(float4(_color.rgb, sdSphere(bPos, _box1.w*1.1)), float4(_color.rgb, sdBox(bPos, _box1.w)));
                float4 Sphere = float4(_color.rgb, sdSphere(sPos, _sphere1.w));
                float4 Plane = float4(1, 1, 1, p.y);
                 
                Scene = opColU(Menger , Plane);
                return Scene;
            }
            float2 RayMarch(float3 ro, float3 rd){
                float dO = 0.;
                int steps;
                for (int i = 0; i <_maxSteps; i++){
                    if (dO>_maxDistance){
                        steps = i;
                        break;
                    } 

                    float3 p = ro + rd * dO;
                    float4 dS = getDist(p);
                    if (dS.w < _surfDist){
                        _difColor = dS.rgb; // +float3(sin(2.*length(p)), cos(30.*length(p)) , sin(5.*length(p)))/2. ; //+ float3(i/_maxSteps, i/_maxSteps, i/_maxSteps);
                        steps = i;
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
            float getShadow(float3 p, float d, float k)
            {
                float result = 1.0;
                if(d < length(_lightPos - p)) {
                    return 0.2;
                }
                return result;
            }   
            float3 getLight(float3 p, float3 c, float3 ro, float3 rd){
                float3 color = c.rgb * _colorIntensity;
                
                float3 lightPos = _lightPos;//float3( 20*sin(_Time.y), 20, 20*cos(_Time.y)); 
                
                float3 l = normalize(lightPos - p);
                
                float3 n = getNormal(p);

                float ao = ambientOcclusion(p, n);
                
                float dif = clamp(dot(n, l), 0.,1.);
                float d = RayMarch(p + n*_surfDist*2., l).x;
                float steps = RayMarch(ro, rd ).y;
                float shadow = getShadow(p, d, 12);
                float3 glow = float3(1., 1., 1.) * pow(steps/70., 2);

                return dif * color * ao * shadow; //+ glow;
            }
            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 col = tex2D(_MainTex, i.uv);
               // float3 col = 0;
                float3 rd = normalize(i.ray.xyz);
                float3 ro = _WorldSpaceCameraPos;

                float d = RayMarch(ro, rd).x;
    
                float3 p = ro + rd * d; 
                float3 dif = getLight(p, _difColor, ro, rd);
                col = dif + float3(0.1,0.1,0.1);
                float4 fragColor = float4(col.rgb,1.0);
                return fragColor;
            }
            ENDCG
        }
    }
}
