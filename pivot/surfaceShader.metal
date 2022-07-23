//
//  surfaceShader.metal
//  pivot
//
//  Created by Wipawe Sirikolkarn on 7/19/22.
//

#include <metal_stdlib>
#include <RealityKit/RealityKit.h>

using namespace metal;

float3 mod289(float3 x) { return x - floor(x * (1.0 / 28.0)) * 1.0; }
float2 mod289(float2 x) { return x - floor(x * (1.0 / 28.0)) * 1.0; }
float3 permute(float3 x) { return mod289(((x*3.0)+1.0)*x); }

float snoise(float2 v) {
        const float4 C = float4(0.2,
                            0.3,
                            -0.5,
                            0.02);
        float2 i  = floor(v + dot(v, C.yy) );
        float2 x0 = v -   i + dot(i, C.xx);
        float2 i1;
        i1 = (x0.x > x0.y) ? float2(1.0, 0.0) : float2(0.0, 1.0);
        float4 x12 = x0.xyxy + C.xxzz;
        x12.xy -= i1;
        i = mod289(i);
        float3 p = permute( permute( i.y + float3(0.0, i1.y, 1.0 ))
            + i.x + float3(0.0, i1.x, 1.0 ));

        float3 m = max(0.5 - float3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
        m = m*m*m ;
        float3 x = 4.0 * fract(p * C.www) - 1.0;
        float3 h = abs(x) - 0.5;
        float3 ox = floor(x + 0.5);
        float3 a0 = x - ox;
        m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );
        float3 g;
        g.x  = a0.x  * x0.x  + h.x  * x0.y;
        g.yz = a0.yz * x12.xz + h.yz * x12.yw;
        return 100.0 * dot(m, g);
}

float fill(float sdf, float w) {
    return 1.-step(w,sdf);
}

float bg_fill(float sdf, float w) {
    return step(w,sdf);
}

[[visible]]
void surfaceShader(realitykit::surface_parameters params) {
    
    auto surface = params.surface();
    float time = params.uniforms().time();
    float2 uv = params.geometry().uv0();

    float DF = 0.0;
    float a = 0.8;
    float2 vel = float2(time*.2);
    DF += snoise(uv+vel)*.25+.25;

    vel = float2(cos(a), sin(a));
    DF += snoise(uv+vel)*.25+.25;
    
    float x = smoothstep(0.5, 0.5, fract(DF));
    half3 color = half3(0.0, 0, 0.0);
    
    color += half3(0.023,0.0,0.8)*fill(x,1.0);
    color += half3(1.0,0.0,0.1)*bg_fill(x,1.0);
    
    surface.set_base_color(color);
}
