#ifndef CUSTOM_BRDF_INCLUDED
#define CUSTOM_BRDF_INCLUDED

#define MIN_REFLECTIVITY 0.04

struct BRDF
{
    float3 diffuse;
    float3 specular;
    float roughness;
};
//1 마이너스니까 결과가 0이면 금속. 결과가 1이면 비금속. (원래 반사율이 1이 금속.)
float OneMinusReflectivity(float metallic)
{
    float range = 1.0 - MIN_REFLECTIVITY;
    return range - metallic * range;
}

BRDF GetBRDF(Surface surface, bool applyAlphaToDiffuse = false)
{
    BRDF brdf;
    float oneMinusReflectivity = OneMinusReflectivity(surface.metallic);
    brdf.diffuse = surface.color * oneMinusReflectivity;
    if (applyAlphaToDiffuse)
        brdf.diffuse *= surface.alpha;
    brdf.specular = lerp(MIN_REFLECTIVITY, surface.color, surface.metallic);//metallic이 0이면 MIN_REFLECTIVITY, 1이면 surface.color. 0.5면 반반섞임
    float perceptualRoughness = PerceptualSmoothnessToPerceptualRoughness(surface.smoothness);
    brdf.roughness = PerceptualRoughnessToRoughness(perceptualRoughness);
    return brdf;
}

float SpecularStrength(Surface surface, BRDF brdf, Light light)
{
    //H = (L + V)
    float3 h = SafeNormalize(light.direction + surface.viewDirection);
    //(N·H)²
    float nh2 = Square(saturate(dot(surface.normal, h)));
    //(L·H)²
    float lh2 = Square(saturate(dot(light.direction, h)));
    //r²
    float r2 = Square(brdf.roughness);
    //d = (N·H)²(r²-1) + 1.0001
    //d² = ((N·H)²(r²-1) + 1.0001)²
    float d2 = Square(nh2 * (r2 - 1.0) + 1.0001);
    //n = 4r + 2
    float normalization = brdf.roughness * 4.0 + 2.0;
    return r2 / (d2 * max(0.1, lh2) * normalization);
}

float3 DirectBRDF(Surface surface, BRDF brdf, Light light)
{
    return SpecularStrength(surface, brdf, light) * brdf.specular + brdf.diffuse;
}


#endif