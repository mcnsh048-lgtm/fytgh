// Advanced lighting calculations
// Version 1.0

#ifndef LIGHTING_GLSL
#define LIGHTING_GLSL

#include "pbr.glsl"

// ============================================
// DIRECTIONAL LIGHTING
// ============================================

vec3 calculateDirectionalLight(PBRMaterial material, vec3 lightDir, vec3 viewDir, vec3 lightColor, float shadowFactor) {
    vec3 N = material.normal;
    vec3 L = normalize(lightDir);
    vec3 V = normalize(viewDir);
    vec3 H = normalize(V + L);
    
    // Calculate F0
    vec3 F0 = vec3(0.04);
    F0 = mix(F0, material.albedo, material.metallic);
    
    // Cook-Torrance BRDF
    float NDF = distributionGGX(N, H, material.roughness);
    float G = geometrySmith(N, V, L, material.roughness);
    vec3 F = fresnelSchlick(max(dot(H, V), 0.0), F0);
    
    vec3 kS = F;
    vec3 kD = vec3(1.0) - kS;
    kD *= 1.0 - material.metallic;
    
    vec3 numerator = NDF * G * F;
    float denominator = 4.0 * max(dot(N, V), 0.0) * max(dot(N, L), 0.0);
    vec3 specular = numerator / max(denominator, 0.001);
    
    float NdotL = max(dot(N, L), 0.0);
    vec3 Lo = (kD * material.albedo * INV_PI + specular) * lightColor * NdotL;
    
    return Lo * shadowFactor;
}

// ============================================
// POINT LIGHTING
// ============================================

vec3 calculatePointLight(PBRMaterial material, vec3 fragPos, vec3 lightPos, vec3 viewDir, vec3 lightColor, float lightRange) {
    vec3 lightDir = lightPos - fragPos;
    float distance = length(lightDir);
    
    if (distance > lightRange) return vec3(0.0);
    
    float attenuation = 1.0 - (distance / lightRange);
    attenuation *= attenuation;
    
    return calculateDirectionalLight(material, lightDir, viewDir, lightColor * attenuation, 1.0);
}

// ============================================
// AMBIENT LIGHTING
// ============================================

vec3 calculateAmbientLight(PBRMaterial material, vec3 ambientColor) {
    vec3 F0 = vec3(0.04);
    F0 = mix(F0, material.albedo, material.metallic);
    
    vec3 kS = vec3(0.0);
    vec3 kD = 1.0 - kS;
    kD *= 1.0 - material.metallic;
    
    vec3 ambient = kD * material.albedo * ambientColor;
    
    return ambient * material.ambientOcclusion;
}

// ============================================
// SHADOW MAPPING
// ============================================

float calculateShadow(sampler2D shadowMap, vec3 shadowCoord, float bias) {
    vec3 projCoords = shadowCoord * 0.5 + 0.5;
    
    if (projCoords.z > 1.0) return 1.0;
    
    float closestDepth = texture(shadowMap, projCoords.xy).r;
    float currentDepth = projCoords.z;
    
    float shadow = currentDepth - bias > closestDepth ? 0.0 : 1.0;
    
    return shadow;
}

// PCF Shadow
float calculateShadowPCF(sampler2D shadowMap, vec3 shadowCoord, float bias, float texelSize) {
    vec3 projCoords = shadowCoord * 0.5 + 0.5;
    
    if (projCoords.z > 1.0) return 1.0;
    
    float shadow = 0.0;
    
    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            float pcfDepth = texture(shadowMap, projCoords.xy + vec2(x, y) * texelSize).r;
            shadow += (projCoords.z - bias > pcfDepth) ? 0.0 : 1.0;
        }
    }
    
    return shadow / 9.0;
}

// ============================================
// IBL (Image-Based Lighting)
// ============================================

vec3 calculateIBL(PBRMaterial material, samplerCube irradianceMap, samplerCube prefilterMap, sampler2D brdfLUT, vec3 viewDir) {
    vec3 N = material.normal;
    vec3 V = normalize(viewDir);
    
    vec3 F0 = vec3(0.04);
    F0 = mix(F0, material.albedo, material.metallic);
    
    vec3 F = fresnelSchlickRoughness(max(dot(N, V), 0.0), F0, material.roughness);
    
    vec3 kS = F;
    vec3 kD = 1.0 - kS;
    kD *= 1.0 - material.metallic;
    
    vec3 irradiance = texture(irradianceMap, N).rgb;
    vec3 diffuse = irradiance * material.albedo;
    
    vec3 R = reflect(-V, N);
    vec3 prefilteredColor = texture(prefilterMap, R).rgb;
    vec2 brdf = texture(brdfLUT, vec2(max(dot(N, V), 0.0), material.roughness)).rg;
    vec3 specular = prefilteredColor * (F * brdf.x + brdf.y);
    
    return (kD * diffuse + specular) * material.ambientOcclusion;
}

#endif
