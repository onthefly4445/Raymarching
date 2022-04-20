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
            uniform float4 _obj;
            uniform float4 _box1;
            uniform float4 _box2;
            uniform float4 _box3;
            uniform float4 _sphere1;
            uniform float4 _torus1;
            uniform int _rotate;
            uniform float3 _rotation;
            uniform float _scale;
            uniform float _fractalScale;
            uniform float3 _lightPos;
            uniform float _Power;
            uniform float _modX;
            uniform float _modY;
            uniform float _modZ;
            uniform float3 _color;
            uniform float3 _glowColor;
            uniform float _glowIntensity;
            uniform int _mirror;
            uniform int _smooth;
            uniform float _smoothness;
            uniform float3 _difColor;
            uniform float _colorIntensity = 1.;
            uniform int _replicateX;
            uniform int _replicateY;
            uniform int _replicateZ;
            uniform float _offset;
            uniform float _objScale;

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

                o.ray = normalize(o.ray);

                o.ray = mul(_CamToWorld, o.ray);
                return o;
            }
            float4 getDist(float3 p){
                float4 Scene;
                if(_mirror  == 1){ 
                    if(_modX != 0)  float modX = pMod1(p.x, _modX);
                    if(_modY != 0)  float modY = pMod1(p.y, _modY);
                    if(_modZ != 0)  float modZ = pMod1(p.z, _modZ);
                }
                _sphere1.y = sin(_Time.y)*2.;
                float3 objP = (p - _obj.xyz)/_objScale;
                float3 boxP1 = p - _box1.xyz;
                float3 boxP2 = p - _box2.xyz;
                float3 boxP3 = p - _box3.xyz;
                float3 sphP = p - _sphere1.xyz;
                float3 torP = p - _torus1.xyz;

                // objP.yz = mul(Rotate(_rotation.x), objP.yz);
                // objP.xz = mul(Rotate(_rotation.y), objP.xz);
                // objP.xy = mul(Rotate(_rotation.z), objP.xy);

            //-------------------------BoxFract-------------------------  
            //    float3 foldVector = float3(sin(_Time.y*1.7)*10. - 30., -cos(_Time.y*0.5 ) * 1.15 + 7.75 , cos(_Time.y ) * 50. - 50);
            //    float3 objColor = float3(sin(_Time.y), 0., 0. );
            //    float3 glowColor = float3(cos(_Time.y), 0., 0.); 
            //    for (int i = 0; i <_scale; i++ ){
            //    //     objP = fold(objP, normalize(float3(sin(_Time.z/50.), -cos(_Time.z/50.), sin(_Time.z/50.))));
            //         // if(objP.x + objP.y < 0.) objP.xy = -objP.yx;
            //         // if(objP.x + objP.z < 0.) objP.xz = -objP.zx;
            //         // if(objP.y + objP.z < 0.) objP.zy = -objP.yz;
            //         objP = fold(objP, normalize(foldVector));
            //         objP = abs(objP);
            //         objP.x -= 1;
            //         objP.y -= 5; 
            //         objP.z -= 0.5; 
            //         objP = fold(objP, normalize(-foldVector));
            //         _obj.w = sin(_Time.z)*2.5 + 4.;
            //  //      objP = fold(objP, normalize(float3(cos(_Time.z/50.), sin(_Time.z/50.), cos(_Time.z/50.))));
            //   }
            //-------------------------RatationBoxFract--------------------------
            //    float3 foldVector = float3(sin(_Time.y*1.7)*10. - 30., -cos(_Time.y*0.5 ) * 1.15 + 7.75 , cos(_Time.y ) * 50. - 50);
            //    //float3 foldVector = float3(_torus1.x, _torus1.y, _torus1.z);
                float3 objColor = float3(sin(_Time.y), 0., 0. );
            //    float3 glowColor = float3(cos(_Time.y), 0., 0.); 
            //    for (int i = 0; i <_scale; i++ ){
            //    //     objP = fold(objP, normalize(float3(sin(_Time.z/50.), -cos(_Time.z/50.), sin(_Time.z/50.))));
            //         // if(objP.x + objP.y < 0.) objP.xy = -objP.yx;
            //         // if(objP.x + objP.z < 0.) objP.xz = -objP.zx;
            //         // if(objP.y + objP.z < 0.) objP.zy = -objP.yz;
            //       //  objP.yz = mul(Rotate(foldVector.x/50.), objP.yz);
            //       //  objP.xz = mul(Rotate(foldVector.y/50.), objP.xz);
            //       //  objP.xy = mul(Rotate(foldVector.z/50.), objP.xy);

            //         objP = fold(objP, normalize(foldVector));
            //         objP = abs(objP);
            //         objP.x -= 1.5;
            //         objP.y -= 3; 
            //         objP.z -= 0.75; 
               

            //         objP = fold(objP, normalize(-foldVector));

                    
                  
            //  //      objP = fold(objP, normalize(float3(cos(_Time.z/50.), sin(_Time.z/50.), cos(_Time.z/50.))));
            //   }
               
            //-------------------------MandelBoxWannabe-----------------
                // float dR = 1.0;
                // float3 offset = objP;
                // for (int i = 0; i <_scale; i++){
                //     objP = boxFold(objP, _obj.w);
                //     objP = sphereFold(objP, dR, 1., _obj.w);
                    
                //     objP = _Power * objP + offset;
                //     dR = dR*abs(_Power) + 1.0;
                // }
                // float r = length(objP)/abs(dR);

            //--------------------------OBJECTS--------------------------

                float4 Plane = float4(1, 1, 1, p.y/_objScale);
                float4 Cross = float4(_color.rgb, sdCross(boxP2, 2*_box1.w, .98*_box2.w));
                float4 Sphere1 = float4(float3(1.,0.,0.), sdSphere(float3(boxP1.x, boxP1.y, boxP1.z + sin(_Time.y)*_box1.w*2), _box1.w));
                float4 Sphere2 = float4(_color.rgb, sdSphere(float3(boxP3.x, boxP3.y, boxP3.z + sin(_Time.y)*_box3.w*2), _box3.w*1.5));
                float4 Torus = float4(float3(1., 0., 0.), sdTorus(float3(boxP2.x, boxP2.y,  sin(_Time.y)*_box3.w*1.5 + boxP2.z) , float2(_box1.w/1.75, _box1.w/3.5)));
                float4 HollowBox = opColS(float4 (objColor, sdSphere(objP, 1.1*_obj.w)), float4(objColor, sdBox(objP, _obj.w)));

                if(_rotate == 1){
                    boxP1.xz = mul(Rotate(_Time.x*6. % 6.28), boxP1.xz);
                    boxP2.xz = mul(Rotate(_Time.x*6. % 6.28), boxP2.xz);
                    boxP3.xz = mul(Rotate(_Time.x*6. % 6.28), boxP3.xz);
                }
                
                float4 Box1 = float4(_color.rgb, sdBox(boxP1, _box1.w));
                float4 Box2 = float4(float3(1., 0., 0.), sdBox(boxP2, _box2.w));
                float4 Box3 = float4(_color.rgb, sdBox(boxP3, _box3.w));
                
                float4 BoxFrame1 = float4(float3(1., 0., 0.), sdBoxFrame(boxP1, _box1.w));
                float4 BoxFrame2 = float4(float3(1., 0., 0.), sdBoxFrame(boxP2, _box2.w));
                float4 BoxFrame3 = float4(float3(1., 0., 0.), sdBoxFrame(boxP3, _box3.w));

                float4 Menger = float4(_color.rgb, sdMengerSponge(objP, 6., _obj.w));
                float4 Sierpinsky = float4(_color.rgb, sdFraktal(objP, _Power, _scale));
                
                Scene = opColU(Plane, Plane);
                Scene = opColU(Scene, BoxFrame1);
                Scene = opColU(Scene, BoxFrame2);
                Scene = opColU(Scene, BoxFrame3);
                if(_smooth){
                    Scene = opColU(Scene, opSmoothColU(Sphere1, Box1, _smoothness));
                    Scene = opColU(Scene, opSmoothColS(Box3, Sphere2, _smoothness));
                    Scene = opColU(Scene, opSmoothColI(Torus, Box2, _smoothness));
                }
                else{
                    Scene = opColU(Scene, opColU(Sphere1, Box1));
                    Scene = opColU(Scene, opColS(Box3, Sphere2));
                    Scene = opColU(Scene, opColI(Torus, Box2));
                    
                }
                float4 result = float4(opColU(Menger, Plane));
                result.w = result.w * _objScale;
                return result;
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
                
                float3 lightPos = _lightPos; 
                
                float3 l = normalize(lightPos - p);
                
                float3 n = getNormal(p);

                float ao = ambientOcclusion(p, n);
                
                float dif = clamp(dot(n, l), 0.,1.);
                float d = RayMarch(p + n*_surfDist*2., l).x;
                float steps = RayMarch(ro, rd ).y;
                float shadow = getShadow(p, d, 12);
                float3 glow = _glowColor * pow(steps/70., 2) * _glowIntensity;

                return dif * color * ao * shadow + glow;
            }
            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 col = tex2D(_MainTex, i.uv);
               // float3 col = 0;
                float3 rd = i.ray.xyz;
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
