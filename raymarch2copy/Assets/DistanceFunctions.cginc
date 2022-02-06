// Sphere
// s: radius
float sdSphere(float3 p, float s)
{
	return length(p) - s;
}
// Torus
// t: x and y radius
float sdTorus( float3 p, float2 t )
{
  float2 q = float2(length(p.xy)- t.x,p.z);
  return length(q)-t.y;
 }

// Box
// b: size of box in x/y/z
float sdBox(float3 p, float3 b)
{
	float3 d = abs(p) - b;
	return min(max(d.x, max(d.y, d.z)), 0.0) +
		length(max(d, 0.0));
}
// Pyramid
//
float sdPyramid( float3 p, float h)
{
  float m2 = h*h + 0.25;
    
  p.xz = abs(p.xz);
  p.xz = (p.z>p.x) ? p.zx : p.xz;
  p.xz -= 0.5;

  float3 q = float3( p.z, h*p.y - 0.5*p.x, h*p.x + 0.5*p.y);
   
  float s = max(-q.x,0.0);
  float t = clamp( (q.y-0.5*p.z)/(m2+0.25), 0.0, 1.0 );
    
  float a = m2*(q.x+s)*(q.x+s) + q.y*q.y;
  float b = m2*(q.x+0.5*t)*(q.x+0.5*t) + (q.y-m2*t)*(q.y-m2*t);
    
  float d2 = min(q.y,-q.x*m2-q.y*0.5) > 0.0 ? 0.0 : min(a,b);
    
  return sqrt( (d2+q.z*q.z)/m2 ) * sign(max(q.z,-p.y));
}

//Infinite Cylinder
float sdCylinder( float3 p, float3 c )
{
  return length(p.xz-c.xy)-c.z;
}
//Cone
float sdCone( in float3 p, in float2 c, float h )
{
  // c is the sin/cos of the angle, h is height
  // Alternatively pass q instead of (c,h),
  // which is the point at the base in 2D
  float2 q = h*float2(c.x/c.y,-1.0);
    
  float2 w = float2( length(p.xz), p.y );
  float2 a = w - q*clamp( dot(w,q)/dot(q,q), 0.0, 1.0 );
  float2 b = w - q*float2( clamp( w.x/q.x, 0.0, 1.0 ), 1.0 );
  float k = sign( q.y );
  float d = min(dot( a, a ),dot(b, b));
  float s = max( k*(w.x*q.y-w.y*q.x),k*(w.y-q.y)  );
  return sqrt(d)*sign(s);
}
//Infinite cone
float sdCone( float3 p, float2 c )
{
    // c is the sin/cos of the angle
    float2 q = float2( length(p.xz), -p.y );
    float d = length(q-c*max(dot(q,c), 0.0));
    return d * ((q.x*c.y-q.y*c.x<0.0)?-1.0:1.0);
}

float sdFraktal(float3 p, float scale, float it){
    float3 a1 = float3(1,1,1);
  float3 a2 = float3(-1,-1,1);
	float3 a3 = float3(1,-1,-1);
	float3 a4 = float3(-1,1,-1);
	float3 c;
	int n = 0;
	float dist, d;
	while (n < it) {
	  c = a1; dist = length(p-a1);
	  d = length(p-a2); if (d < dist) { c = a2; dist=d; }
		d = length(p-a3); if (d < dist) { c = a3; dist=d; }
		d = length(p-a4); if (d < dist) { c = a4; dist=d; }
		p = scale*p-c*(scale-1.0);
		n++;
	}

	return  length(p) * pow(scale, float(-n));

}


// BOOLEAN OPERATORS //
float2x2 Rotate (float angle) {
  float s = sin(angle);
  float c = cos(angle);
  return float2x2(c, -s, s, c);
}
// Union
float opU(float d1, float d2)
{
	return min(d1, d2);
}
//color Union
float4 opColU(float4 d1, float4 d2)
{
	float d = min(d1.w, d2.w);
  return d == d1.w? d1 : d2;
}

// Subtraction
float opS(float d1, float d2)
{
	return max(-d1, d2);
}

float4 opColS(float4 d1, float4 d2)
{
	float d = max(-d1.w, d2.w);
  return d == -d1.w? float4(d1.r, d1.g, d1.b, -d1.w) : d2;
}
// Intersection
float opI(float d1, float d2)
{
	return max(d1, d2);
}

// Smooth union
float opSmoothUnion( float d1, float d2, float k ) {
    float h = clamp( 0.5 + 0.5*(d2-d1)/k, 0.0, 1.0 );
    return lerp( d2, d1, h ) - k*h*(1.0-h);
    }
// Smooth color union

float4 opSmoothColU( float4 d1, float4 d2, float k ) {
    float h = clamp( 0.5 + 0.5*(d2.w-d1.w)/k, 0.0, 1.0 );
    float d = lerp( d2.w, d1.w, h ) - k*h*(1.0-h);
    float3 c = lerp(d2.rgb, d1.rgb, h);
    return float4(c, d );
    }

// Smooth subtraction
float opSmoothSubtraction( float d1, float d2, float k ) {
    float h = clamp( 0.5 - 0.5*(d2+d1)/k, 0.0, 1.0 );
    return lerp( d2, -d1, h ) + k*h*(1.0-h); 
}
// Smooth intersection
float opSmoothIntersection( float d1, float d2, float k ) {
    float h = clamp( 0.5 - 0.5*(d2-d1)/k, 0.0, 1.0 );
    return lerp( d2, d1, h ) + k*h*(1.0-h); 
}
// Mod Position Axis
float pMod1 (inout float p, float size)
{
	float halfsize = size * 0.5;
	float c = floor((p+halfsize)/size);
	p = fmod(p+halfsize,size)-halfsize;
	p = fmod(-p+halfsize,size)-halfsize;
	return c;
}

float3 opRepLim( inout float3 p, inout float c, inout float3 l )
{
    float3 q = p-c*clamp(round(p/c),-l,l);
    return q;
}
