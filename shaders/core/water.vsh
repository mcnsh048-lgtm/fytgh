// Water vertex shader
// Version 1.0
#version 120

varying vec3 vPosition;
varying vec3 vNormal;
varying vec2 vTexCoord;
varying vec4 vShadowCoord;
varying vec3 vViewDir;
varying float vWave;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjection;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

uniform float frameTimeCounter;
uniform float waveStrength;

// Wave function
float calculateWave(vec3 pos, float time) {
    float wave = sin(pos.x * 0.1 + time) * 0.1;
    wave += sin(pos.z * 0.15 + time * 0.8) * 0.08;
    wave += sin((pos.x + pos.z) * 0.05 + time * 0.5) * 0.05;
    return wave * waveStrength;
}

void main() {
    vec3 position = gl_Vertex.xyz;
    
    // Apply wave animation
    vWave = calculateWave(position, frameTimeCounter);
    position.y += vWave;
    
    // Transform vertex
    vPosition = (gl_ModelViewMatrix * vec4(position, 1.0)).xyz;
    vNormal = normalize(gl_NormalMatrix * gl_Normal);
    vTexCoord = gl_MultiTexCoord0.xy + frameTimeCounter * 0.01;
    vViewDir = -vPosition;
    
    // Shadow coordinates
    vec4 shadowPos = shadowProjection * shadowModelView * gl_ModelViewMatrixInverse * vec4(position, 1.0);
    vShadowCoord = shadowPos;
    
    gl_Position = gl_ProjectionMatrix * vec4(vPosition, 1.0);
}
