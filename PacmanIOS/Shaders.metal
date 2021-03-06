//
//  Shaders.metal
//  PacmanIOS
//
//  Created by Jack Armstrong on 12/29/18.
//  Copyright © 2018 Jack Armstrong. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 uv;
    float3 sqColor;
};


vertex VertexOut textVertex(const device packed_float2*pos[[buffer(0)]],
                            const device packed_float2*uv[[buffer(1)]],
                            constant float2 &u_pos [[buffer(2)]],
                            constant float2 &u_size [[buffer(3)]],
                            constant float2 &u_wsize [[buffer(4)]],
                            unsigned int vid[[vertex_id]]){
    VertexOut vout;
    vout.position=float4(pos[vid]*u_size+u_pos,0.0,1.0);
    if(u_wsize.y>u_wsize.x){
        vout.position.y/=u_wsize.y/u_wsize.x;
    }else{
        vout.position.x*=u_wsize.y/u_wsize.x;
    }
    vout.uv=uv[vid];
    vout.uv.y=1.0-vout.uv.y;
    return vout;
}

fragment half4 textFragment(VertexOut vout[[stage_in]],
                            sampler texSampler[[sampler(0)]],
                            texture2d<half> texture[[texture(0)]]){
    half4 col=texture.sample(texSampler,vout.uv);
    if(all(col.xyz==half3(0.0))){
        discard_fragment();
    }
    return col;
//    return half4(half2(vout.uv),0.0,1.0);
}

vertex VertexOut vertexShader(const device packed_float3*vertex_array[[buffer(0)]],unsigned int vid[[vertex_id]],
                              constant float2 &pos[[buffer(1)]],
                              constant float2 &size[[buffer(2)]],
                              constant float2 &wsize[[buffer(3)]],
                              constant float3 &sqColor[[buffer(4)]],
                              constant float2 &gsize[[buffer(5)]]){
    VertexOut vout;
    vout.position = float4(vertex_array[vid].xy*size+pos,0.0,1.0);
    vout.position.xy*=2.0;
    vout.position.xy-=1.0;
    if(wsize.y>wsize.x){
        vout.position.y/=wsize.y/wsize.x;
    }else{
        vout.position.x*=wsize.y/wsize.x;
    }
    vout.position.y*=-1;
//    vout.position.x*=gsize.x/gsize.y;
    vout.uv=vertex_array[vid].xy;
    vout.sqColor=sqColor;
    return vout;
}

fragment half4 fragmentShader(VertexOut vout [[stage_in]]){
//    return half4(vout.uv.x,vout.uv.y,0.0,1.0);
    return half4(half3(vout.sqColor),1.0);
}

fragment half4 fragmentShaderTexture(VertexOut vout [[stage_in]],
                                     sampler tex_sampler [[sampler(0)]],
                                     texture2d<half> texture [[texture(0)]]){
    // 1,0,0 -> 0,0,1
    // 0,1,1 -> 1,1,0
    half4 col = texture.sample(tex_sampler,vout.uv).zyxw;
    if(all(col.xyz == half3(0.0))){
        discard_fragment();
    }
    return col;
}
