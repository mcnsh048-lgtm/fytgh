// Physically-Based Rendering implementation
// Version 1.0

#ifndef PBR_GLSL
#define PBR_GLSL

#include "util.glsl"

// ============================================
// PBR MATERIAL STRUCTURE
// ============================================

struct PBRMaterial {
    vec3 albedo;           // Base color
    vec3 normal;           // Surface normal
    float metallic;        // Metallic factor (0.0-1.0)
    float roughness;       // Roughness factor (0.0-1.0)
    float ambientOcclusion; // AO factor (0.0-1.0)
};

// ============================================
// FRESNEL FUNCTIONS
// ============================================

vec3 fresnelSchlick(float cosTheta, vec3 F0) {
    return F0 + (1.0 - F0) * pow(clamp(1.0 - cosTheta, 0.0, 1.0), 5.0);
}

vec3 fresnelSchlickRoughness(float cosTheta, vec3 F0, float roughness) {
    return F0 + (max(vec3(1.0 - roughness), F0) - F0) * pow(clamp(1.0 - cosTheta, 0.0, 1.0), 5.0);
}

// ============================================
// DISTRIBUTION FUNCTIONS
// ============================================

float distributionGGX(vec3 normal, vec3 halfway, float roughness) {
    float a = roughness * roughness;
    float a2 = a * a;
    float NdotH = max(dot(normal, halfway), 0.0);
    float NdotH2 = NdotH * NdotH;
    
    float nom = a2;
    float denom = (NdotH2 * (a2 - 1.0) + 1.0);
    denom = PI * denom * denom;
    
    return nom / max(denom, 0.0001);
}

// ============================================
// GEOMETRY FUNCTIONS
// ============================================

float geometrySchlickGGX(float NdotV, float roughness) {
    float r = (roughness + 1.0);
    float k = (r * r) / 8.0;
    
    float nom = NdotV;
    float denom = NdotV * (1.0 - k) + k;
    
    return nom / max(denom, 0.0001);
}

float geometrySmith(vec3 normal, vec3 viewDir, vec3 lightDir, float roughness) {
    float NdotV = max(dot(normal, viewDir), 0.0);
    float NdotL = max(dot(normal, lightDir), 0.0);
    float ggx2 = geometrySchlickGGX(NdotV, roughness);
    float ggx1 = geometrySchlickGGX(NdotL, roughness);
    
    return ggx1 * ggx2;
}

// ============================================
// PBR CALCULATION
// ============================================

vec3 calculatePBR(PBRMaterial material, vec3 lightDir, vec3 viewDir, vec3 lightColor) {
    vec3 N = material.normal;
    vec3 V = normalize(viewDir);
    vec3 L = normalize(lightDir);
    vec3 H = normalize(V + L);
    
    float distance = length(lightDir);
    float attenuation = 1.0 / (distance * distance);
    vec3 radiance = lightColor * attenuation;
    
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
    vec3 Lo = (kD * material.albedo * INV_PI + specular) * radiance * NdotL;
    
    return Lo;
}

// ============================================
// METALLIC/ROUGHNESS DECODING
// ============================================

vec3 decodeMetallic(vec3 metallic) {
    return metallic;
}

vec3 decodeRoughness(vec3 roughness) {
    return roughness * roughness; // Perceptual to linear
}

#endif
