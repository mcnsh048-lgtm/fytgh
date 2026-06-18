// Water fragment shader - Advanced water rendering
// Version 1.0
#version 120

varying vec3 vPosition;
varying vec3 vNormal;
varying vec2 vTexCoord;
varying vec4 vShadowCoord;
varying vec3 vViewDir;
varying float vWave;

uniform sampler2D texture;
uniform sampler2D normalTexture;
uniform sampler2D waterNormalA;
uniform sampler2D waterNormalB;
uniform samplerCube reflectionTexture;
uniform samplerCube refractionTexture;

uniform bool enableReflections;
uniform bool enableRefractions;
uniform bool enableCaustics;
uniform float reflectivity;
uniform float waveStrength;

uniform float frameTimeCounter;

#include "../lib/util.glsl"

vec3 calculateWaterNormal() {
    vec2 uv1 = vTexCoord + frameTimeCounter * 0.05;
    vec2 uv2 = vTexCoord - frameTimeCounter * 0.03;
    
    vec3 normal1 = texture2D(waterNormalA, uv1).rgb * 2.0 - 1.0;
    vec3 normal2 = texture2D(waterNormalB, uv2).rgb * 2.0 - 1.0;
    
    vec3 combinedNormal = normalize(normal1 + normal2);
    return normalize(vNormal + combinedNormal * 0.3);
}

vec3 calculateCaustics(vec3 normal) {
    vec2 causticUV = vPosition.xz * 0.1 + frameTimeCounter * 0.05;
    float caustic = sin(causticUV.x * 10.0) * cos(causticUV.y * 10.0);
    caustic = caustic * caustic;
    caustic *= 0.5;
    
    return vec3(caustic * 0.3);
}

float calculateFresnel(vec3 normal, vec3 viewDir) {
    float dot_product = clamp(dot(normal, -viewDir), 0.0, 1.0);
    return pow(1.0 - dot_product, 3.0);
}

void main() {
    vec3 waterNormal = calculateWaterNormal();
    vec3 viewDir = normalize(vViewDir);
    
    // Fresnel effect
    float fresnel = calculateFresnel(waterNormal, viewDir);
    
    // Base water color
    vec3 waterColor = vec3(0.1, 0.3, 0.5);
    
    // Reflections
    if (enableReflections) {
        vec3 reflectDir = reflect(-viewDir, waterNormal);
        vec3 reflection = textureCube(reflectionTexture, reflectDir).rgb;
        waterColor += reflection * fresnel * reflectivity;
    }
    
    // Refractions
    if (enableRefractions) {
        vec3 refractDir = refract(-viewDir, waterNormal, 0.75);
        vec3 refraction = textureCube(refractionTexture, refractDir).rgb;
        waterColor = mix(waterColor, refraction, 0.3);
    }
    
    // Caustics
    if (enableCaustics) {
        waterColor += calculateCaustics(waterNormal);
    }
    
    // Apply tone mapping
    waterColor = toneMapACES(waterColor);
    waterColor = linearToSRGB(waterColor);
    
    gl_FragColor = vec4(waterColor, 0.8);
}
