// Utility functions for realistic shader pack
// Version 1.0

#ifndef UTIL_GLSL
#define UTIL_GLSL

// Constants
const float PI = 3.14159265359;
const float TAU = 6.28318530718;
const float INV_PI = 0.31830988618;
const float INV_TAU = 0.15915494309;

// ============================================
// MATH UTILITIES
// ============================================

float saturate(float x) {
    return clamp(x, 0.0, 1.0);
}

vec2 saturate(vec2 x) {
    return clamp(x, vec2(0.0), vec2(1.0));
}

vec3 saturate(vec3 x) {
    return clamp(x, vec3(0.0), vec3(1.0));
}

vec4 saturate(vec4 x) {
    return clamp(x, vec4(0.0), vec4(1.0));
}

float remap(float x, float a, float b, float c, float d) {
    return mix(c, d, (x - a) / (b - a));
}

float smootherstep(float edge0, float edge1, float x) {
    x = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0);
    return x * x * x * (x * (x * 6.0 - 15.0) + 10.0);
}

// ============================================
// COLOR UTILITIES
// ============================================

float luminance(vec3 color) {
    return dot(color, vec3(0.299, 0.587, 0.114));
}

vec3 toneMapACES(vec3 color) {
    const float a = 2.51;
    const float b = 0.03;
    const float c = 2.43;
    const float d = 0.59;
    const float e = 0.14;
    
    return clamp((color * (a * color + b)) / (color * (c * color + d) + e), 0.0, 1.0);
}

vec3 toneMapReinhard(vec3 color) {
    return color / (color + vec3(1.0));
}

vec3 sRGBToLinear(vec3 color) {
    return mix(
        color / 12.92,
        pow((color + 0.055) / 1.055, vec3(2.4)),
        step(0.04045, color)
    );
}

vec3 linearToSRGB(vec3 color) {
    return mix(
        color * 12.92,
        1.055 * pow(color, vec3(1.0 / 2.4)) - 0.055,
        step(0.0031308, color)
    );
}

// ============================================
// RANDOM FUNCTIONS
// ============================================

float rand(vec2 x) {
    return fract(sin(dot(x, vec2(12.9898, 78.233))) * 43758.5453);
}

float hash(float n) {
    return fract(sin(n) * 43758.5453);
}

vec2 hash2(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * vec3(0.1031, 0.1030, 0.0973));
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.xx + p3.yz) * p3.zy);
}

// ============================================
// NOISE FUNCTIONS
// ============================================

float perlinNoise(vec2 p) {
    vec2 pi = floor(p);
    vec2 pf = fract(p);
    
    vec2 w = pf * pf * (3.0 - 2.0 * pf);
    
    float n00 = dot(hash2(pi + vec2(0.0, 0.0)), pf - vec2(0.0, 0.0));
    float n10 = dot(hash2(pi + vec2(1.0, 0.0)), pf - vec2(1.0, 0.0));
    float n01 = dot(hash2(pi + vec2(0.0, 1.0)), pf - vec2(0.0, 1.0));
    float n11 = dot(hash2(pi + vec2(1.0, 1.0)), pf - vec2(1.0, 1.0));
    
    float nx0 = mix(n00, n10, w.x);
    float nx1 = mix(n01, n11, w.x);
    return mix(nx0, nx1, w.y);
}

// ============================================
// GEOMETRY UTILITIES
// ============================================

vec3 reconstructNormal(vec3 normal, vec3 tangent, vec3 bitangent) {
    return normalize(normal);
}

vec3 perturbNormal(vec3 normal, vec3 tangent, vec3 bitangent, vec3 normalMap) {
    normalMap = normalMap * 2.0 - 1.0;
    return normalize(
        normalMap.x * tangent +
        normalMap.y * bitangent +
        normalMap.z * normal
    );
}

#endif
