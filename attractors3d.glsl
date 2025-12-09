// used https://paulbourke.net/fractals/
// inspired by https://www.shadertoy.com/view/Msy3Dm
// some stuff from there too

mat2 rot(float a) {
    float c = cos(a), s = sin(a);
    return mat2(c, -s, s, c);
}

#define ATTRACTOR cliff
#define pi 3.14

vec3 dejong(vec3 p) {
    float a = 2.01, b = -2.53, c = 1.61, d = -0.33;
    
    float x = p.x, y = p.y;
    float nx = sin(a*y) - cos(b*x);
    float ny = sin(c*x) - cos(d*y);
    float nz = sin(b*x) - cos(a*y);
    
    return vec3(nx, ny, nz);
}

vec3 cliff(vec3 p) {
    float a = 2.0*atan(iTime), b = 2.0, c = 1.0, d = -1.0;
    
    float x = p.x, y = p.y;
    float nx = sin(a*y) + c*cos(a*x);
    float ny = sin(b*x) + d*cos(b*y);
    float nz = sin(a*x) + c*cos(a*y);
    
    return vec3(nx, ny, nz)*log(texture(iChannel0,vec2(0.05,0.05)).x)*1.5;
}

vec3 lorentz(vec3 p) {
    float x = p.x, y = p.y, z = p.z;
    
    float h = 0.01;
    float a = 10.0;
    float b = 28.0;
    float c = 8.0 / 3.0;

    float nx = x + h * a * (y - x);
    float ny = y + h * (x * (b - z) - y);
    float nz = z + h * (x * y - c * z);
    
    
    return vec3(nx, ny, nz);
}

vec3 juan(vec3 p) {
    float a = -0.7623860293700191;
    float b = -0.6638578730949067;
    float c = 1.8167801002094635;
    float d = -2.7677186549504844;
    
    float x = p.x, y = p.y, z = p.z;
    
    float nx = cos(a*x)*cos(a*x) - sin(b*y)*sin(b*y);
    float ny = 2.*cos(c*x)*sin(d*y);
    float nz = cos(a*x)*cos(a*x) - sin(b*z)*sin(b*z);

    return vec3(nx,ny,nz);
}

// from https://www.shadertoy.com/view/Msy3Dm
vec3 Grad1(float x)
{
    x = clamp(x, 0.0, 1.0);
    
    vec3 col = vec3(1.);
    
    col = mix(col, vec3(1.00, 0.35, 0.00), pow(x, 0.35));
    col = mix(col, vec3(0.50, 0.00, 0.50), smoothstep(0.05,0.8,x));
    
    return col;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - iResolution.xy*0.5) / iResolution.y;
    vec2 res = iResolution.xy / iResolution.y;
    vec3 ro = vec3(0, 0, -10);
    float fov = 90.;
    vec3 rd = normalize(vec3(uv, fov*pi/180.));

    ro.xz *= rot(iTime*0.5);
    rd.xz *= rot(iTime*0.5);

    vec3 prev; 
    vec3 next;
    prev = vec3(0.1,0.1,0.1);
    
    float sum = 0.0;

    int i = 0;
    for(int i = 0; i < 4096; i++) {
        next = ATTRACTOR(prev);
        float d = length(cross(next - ro, rd));

        sum += smoothstep(1.3/iResolution.x, 0.0, d-0.04);
        
        prev = next;
    }
    
    sum /= 1.3/iResolution.x;
    sum *= 0.0001;
    
    fragColor = vec4(Grad1(sum),1.);
}
