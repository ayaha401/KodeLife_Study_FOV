#version 150

uniform float time;
uniform vec2 resolution;
uniform vec2 mouse;
uniform vec3 spectrum;

uniform sampler2D texture0;
uniform sampler2D texture1;
uniform sampler2D texture2;
uniform sampler2D texture3;
uniform sampler2D prevFrame;
uniform sampler2D prevPass;

in VertexData
{
    vec4 v_position;
    vec3 v_normal;
    vec2 v_texcoord;
} inData;

out vec4 fragColor;
vec3 L = normalize(vec3(1., 1., 1.));
const float PI = acos(-1.);
const float DEG2RAD = PI/180.;

float sdSphere(vec3 p, float r)
{
    return length(p) - r;
}

vec3 repeat(vec3 p, float n)
{
    return abs(mod(p, n)) - n*.5;
}

float map(vec3 p)
{
    p = repeat(p, 2.);
    return sdSphere(p, .5);
}

vec3 makeN(vec3 p)
{
    vec2 eps = vec2(.0001, 0.);
    return normalize(vec3(map(p+eps.xyy) - map(p-eps.xyy), 
                          map(p+eps.yxy) - map(p-eps.yxy),
                          map(p+eps.yyx) - map(p-eps.yyx)));
}


void main(void)
{
    vec2 uv = (2. * gl_FragCoord.xy - resolution.xy)/resolution.y;
    
    // fov
    float fov = mix(30., 90., mix(.5, 1., sin(time)))*DEG2RAD;
    float zfacter = 1./tan(fov/2.);
    vec3 ro = vec3(0., 0., 5.);
    vec3 rd = normalize(vec3(uv.xy, -zfacter));
    float dist = 0.;
    vec3 col = vec3(0.);
    vec3 rp = ro + rd * dist;
    float hit;
    
    for(int i=0;i<120;i++)
    {
        dist = map(rp);
        if(dist < .0001)
        {
            vec3 N = makeN(rp);
            float diff = dot(N, L);
            col = vec3(1.)*diff;
            break;
        }
        hit += dist;
        rp = ro + rd * hit;
    }
    fragColor = vec4(col, 1.0);
}