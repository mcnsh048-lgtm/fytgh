// Terrain vertex shader
// Version 1.0
#version 120

// Vertex attributes
varying vec3 vPosition;
varying vec3 vNormal;
varying vec2 vTexCoord;
varying vec4 vShadowCoord;
varying vec3 vTangent;
varying vec3 vBitangent;
varying vec3 vViewDir;
varying float vHeight;

// Uniforms
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

uniform float near;
uniform float far;

// Time and world info
uniform int worldTime;
uniform float frameTimeCounter;

void main() {
    // Transform vertex position
    vPosition = (gl_ModelViewMatrix * gl_Vertex).xyz;
    
    // Transform normal
    vNormal = normalize(gl_NormalMatrix * gl_Normal);
    
    // Pass texture coordinates
    vTexCoord = gl_MultiTexCoord0.xy;
    
    // Calculate tangent space
    vTangent = normalize(gl_NormalMatrix * vec3(1.0, 0.0, 0.0));
    vBitangent = cross(vNormal, vTangent);
    
    // Calculate view direction
    vViewDir = -vPosition;
    
    // Store height for calculations
    vHeight = gl_Vertex.y;
    
    // Calculate shadow map coordinates
    vec4 shadowPos = shadowProjection * shadowModelView * gl_ModelViewMatrixInverse * gl_Vertex;
    vShadowCoord = shadowPos;
    
    // Final vertex position
    gl_Position = gl_ProjectionMatrix * vec4(vPosition, 1.0);
}
