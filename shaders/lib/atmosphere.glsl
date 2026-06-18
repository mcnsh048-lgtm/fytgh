// Atmospheric scattering and sky calculations
// Version 1.0

#ifndef ATMOSPHERE_GLSL
#define ATMOSPHERE_GLSL

#include "util.glsl"

// ============================================
// ATMOSPHERIC CONSTANTS
// ============================================

const vec3 rayleighCoefficient = vec3(0.0, 0.0, 0.0);
const vec3 mieCoefficient = vec3(0.0, 0.0, 0.0);
const float miePhaseGCoefficient = 0.758;

// ============================================
// RAYLEIGH SCATTERING
// ============================================

float rayleighPhase(float cosTheta) {
    return (3.0 / (16.0 * PI)) * (1.0 + cosTheta * cosTheta);
}

vec3 calculateRayleighScattering(vec3 viewDir, vec3 sunDir, vec3 sunColor) {
    float cosTheta = dot(normalize(viewDir), normalize(sunDir));
    float phase = rayleighPhase(cosTheta);
    
    vec3 scattering = vec3(0.0);
    scattering.x = phase * pow(1.0 / 380.0, 4.0);
    scattering.y = phase * pow(1.0 / 550.0, 4.0);
    scattering.z = phase * pow(1.0 / 700.0, 4.0);
    
    return scattering * sunColor;
}

// ============================================
// MIE SCATTERING
// ============================================

float miePhase(float cosTheta) {
    float g = miePhaseGCoefficient;
    float g2 = g * g;
    
    float numerator = 3.0 * (1.0 - g2) * (2.0 + g2);
    float denominator = 2.0 * (2.0 + 3.0 * g2) * pow(1.0 + g2 - 2.0 * g * cosTheta, 1.5);
    
    return (1.0 / (4.0 * PI)) * (numerator / denominator);
}

vec3 calculateMieScattering(vec3 viewDir, vec3 sunDir, vec3 sunColor) {
    float cosTheta = dot(normalize(viewDir), normalize(sunDir));
    float phase = miePhase(cosTheta);
    
    return mieCoefficient * phase * sunColor;
}

// ============================================
// VOLUMETRIC FOG
// ============================================

float calculateFogDensity(float distance, float fogStart, float fogEnd) {
    return smoothstep(fogStart, fogEnd, distance);
}

vec3 applyFog(vec3 color, vec3 fogColor, float distance, float fogStart, float fogEnd) {
    float fogFactor = calculateFogDensity(distance, fogStart, fogEnd);
    return mix(color, fogColor, fogFactor);
}

// ============================================
// SKY COLOR
// ============================================

vec3 calculateSkyColor(vec3 viewDir, vec3 sunDir, float sunIntensity, float timeOfDay) {
    vec3 sunColor = vec3(1.0);
    
    // Adjust color based on time of day
    if (timeOfDay < 0.25) {
        // Night
        sunColor = mix(vec3(0.1, 0.1, 0.2), vec3(0.2, 0.2, 0.3), timeOfDay * 4.0);
    } else if (timeOfDay < 0.5) {
        // Sunrise
        float t = (timeOfDay - 0.25) * 4.0;
        sunColor = mix(vec3(0.2, 0.2, 0.3), vec3(1.0, 0.6, 0.3), t);
    } else if (timeOfDay < 0.75) {
        // Day
        sunColor = vec3(1.0, 1.0, 1.0);
    } else {
        // Sunset
        float t = (timeOfDay - 0.75) * 4.0;
        sunColor = mix(vec3(1.0, 1.0, 1.0), vec3(1.0, 0.3, 0.1), t);
    }
    
    vec3 rayleigh = calculateRayleighScattering(viewDir, sunDir, sunColor);
    vec3 mie = calculateMieScattering(viewDir, sunDir, sunColor);
    
    return (rayleigh + mie) * sunIntensity;
}

// ============================================
// CLOUD RENDERING
// ============================================

float cloudDensity(vec3 pos, float time) {
    float density = perlinNoise(pos.xy * 0.001 + time * 0.01);
    density += 0.5 * perlinNoise(pos.xy * 0.002 + time * 0.02);
    density += 0.25 * perlinNoise(pos.xy * 0.004 + time * 0.03);
    
    return clamp(density, 0.0, 1.0);
}

vec3 renderClouds(vec3 rayDir, float time, vec3 sunDir, vec3 sunColor) {
    vec3 pos = rayDir * 1000.0;
    float density = cloudDensity(pos, time);
    
    vec3 cloudColor = mix(vec3(0.8), vec3(1.0), density);
    
    return cloudColor * density * 0.5;
}

#endif
