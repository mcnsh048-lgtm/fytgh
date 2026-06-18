// Terrain fragment shader - PBR implementation
// Version 1.0
#version 120

// Varyings from vertex shader
varying vec3 vPosition;
varying vec3 vNormal;
varying vec2 vTexCoord;
varying vec4 vShadowCoord;
varying vec3 vTangent;
varying vec3 vBitangent;
varying vec3 vViewDir;
varying float vHeight;

// Textures
uniform sampler2D texture;
uniform sampler2D normalTexture;
uniform sampler2D specularTexture;
uniform sampler2D shadowmap;
uniform samplerCube skyTexture;

// Material parameters
uniform float metallic;
uniform float roughness;
uniform float ambientOcclusion;

// Lighting parameters
uniform vec3 sunDir;
uniform vec3 sunColor;
uniform vec3 moonDir;
uniform vec3 moonColor;
uniform vec3 ambientColor;

// Shadow parameters
uniform float shadowBias;
uniform float shadowDistance;
uniform int shadowQuality;

// Effect toggles
uniform bool enablePBR;
uniform bool enableNormalMapping;
uniform bool enableParallax;
uniform float parallaxDepth;

// Fog and atmosphere
uniform float fogDensity;
uniform float sunIntensity;

#include "../lib/util.glsl"
#include "../lib/pbr.glsl"
#include "../lib/lighting.glsl"
#include "../lib/atmosphere.glsl"

float calculateShadowFactor() {
    vec3 projCoords = vShadowCoord.xyz / vShadowCoord.w;
    projCoords = projCoords * 0.5 + 0.5;
    
    if (projCoords.z > 1.0) return 1.0;
    
    float closestDepth = texture2D(shadowmap, projCoords.xy).r;
    float currentDepth = projCoords.z;
    float bias = shadowBias;
    
    float shadow = 0.0;
    float texelSize = 1.0 / 2048.0;
    
    for (int x = -2; x <= 2; x++) {
        for (int y = -2; y <= 2; y++) {
            float pcfDepth = texture2D(shadowmap, projCoords.xy + vec2(x, y) * texelSize).r;
            shadow += (currentDepth - bias > pcfDepth) ? 0.0 : 1.0;
        }
    }
    
    return shadow / 25.0;
}

void main() {
    // Sample textures
    vec3 albedo = texture2D(texture, vTexCoord).rgb;
    
    // Normal mapping
    vec3 normal = vNormal;
    if (enableNormalMapping) {
        vec3 normalMap = texture2D(normalTexture, vTexCoord).rgb;
        normal = normalize(
            normalMap.x * vTangent +
            normalMap.y * vBitangent +
            normalMap.z * vNormal
        );
    }
    
    // Create PBR material
    PBRMaterial material;
    material.albedo = sRGBToLinear(albedo);
    material.normal = normal;
    material.metallic = metallic;
    material.roughness = roughness;
    material.ambientOcclusion = ambientOcclusion;
    
    // Calculate lighting
    vec3 viewDir = normalize(vViewDir);
    vec3 lighting = vec3(0.0);
    
    // Directional sunlight
    float shadowFactor = calculateShadowFactor();
    lighting += calculateDirectionalLight(material, sunDir, viewDir, sunColor * sunIntensity, shadowFactor);
    
    // Moon light (reduced intensity)
    lighting += calculateDirectionalLight(material, moonDir, viewDir, moonColor * 0.2, 1.0);
    
    // Ambient lighting
    lighting += calculateAmbientLight(material, ambientColor);
    
    // Apply fog
    float distance = length(vPosition);
    vec3 finalColor = lighting * material.albedo;
    finalColor = applyFog(finalColor, ambientColor * 0.5, distance, 0.0, shadowDistance * 16.0);
    
    // Tone mapping
    finalColor = toneMapACES(finalColor);
    finalColor = linearToSRGB(finalColor);
    
    gl_FragColor = vec4(finalColor, 1.0);
}
