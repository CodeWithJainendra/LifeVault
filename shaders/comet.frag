#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;

out vec4 fragColor;

// --- UTILS ---
float random(in vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

float noise(in vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

#define OCTAVES 5
float fbm(in vec2 st) {
    float v = 0.0;
    float a = 0.5;
    mat2 rot = mat2(cos(0.5), sin(0.5), -sin(0.5), cos(0.5));
    for (int i = 0; i < OCTAVES; ++i) {
        v += a * noise(st);
        st = rot * st * 2.0;
        a *= 0.5;
    }
    return v;
}

// --- MAIN FUNCTION ---
void main() {
    vec2 uv = FlutterFragCoord().xy / uSize;
    
    // Correct Aspect Ratio for square particles
    vec2 pos = uv;
    pos.x *= uSize.x / uSize.y;
    pos -= vec2(0.5 * (uSize.x / uSize.y), 0.5); // Center origin

    // 1. MOVEMENT LOGIC (More Elegant than simple Sine)
    // Lissajous curve for organic floating feel
    float t = uTime * 0.6;
    vec2 cometPos = vec2(
        sin(t) * 0.35 + sin(t * 2.1) * 0.05, 
        cos(t * 0.8) * 0.2
    );

    // Coordinate relative to the comet
    vec2 dCoord = pos - cometPos;
    float dist = length(dCoord);

    // 2. THE TAIL (DOMAIN WARPING)
    // Rotate the noise based on angle to simulate trailing
    // Instead of simple noise, we warp the space to make it look like "Liquid flow"
    vec2 warp = dCoord;
    float angle = atan(dCoord.y, dCoord.x);
    // Warping creates that "trailing behind" effect
    warp.x += fbm(warp * 3.0 - t) * 0.2; 
    warp.y += fbm(warp * 3.0 + t) * 0.2;

    float tailNoise = fbm(warp * 8.0 - vec2(t * 3.0, 0.0));
    
    // 3. SHAPE DEFINITION
    // Core Glow (Sharp Laser-like)
    float core = 0.002 / (dist + 0.0001); // Super bright center
    core = pow(core, 1.3);

    // Outer Aura (Whispy)
    float aura = smoothstep(0.4, 0.0, dist) * tailNoise * 2.0;
    
    // Combine Core + Aura
    float brightness = core + aura * 0.5;

    // 4. COLORS (LifeVault Theme)
    // Cyan (Security/Tech) + Gold (Value/Premium)
    vec3 colCore = vec3(0.0, 0.9, 1.0); // Electric Cyan
    vec3 colGold = vec3(1.0, 0.7, 0.1); // Deep Gold
    vec3 colVoid = vec3(0.02, 0.02, 0.04); // Deep Blue-Black Void (Not just black)

    // Mix colors based on distance from center
    vec3 finalColor = mix(colGold, colCore, smoothstep(0.01, 0.1, dist));
    
    // Apply brightness to color
    finalColor *= brightness;

    // 5. CINEMATIC POST-PROCESSING
    // Add Chromatic Aberration (Split RGB slightly at edges of the glow)
    float aber = 0.002; // Shift amount
    // Simple fake aberration by sampling brightness at offsets (hack for performance)
    float r = brightness * (1.0 + aber * 10.0 * dist);
    float b = brightness * (1.0 - aber * 10.0 * dist);
    
    vec3 cinematicColor = vec3(finalColor.r * 1.5, finalColor.g, finalColor.b * 1.2);
    // Add the RGB split feeling roughly
    cinematicColor.r += r * 0.1;
    cinematicColor.b += b * 0.1;

    // Add background
    cinematicColor += colVoid;

    // Vignette (Darken corners for focus)
    float vign = length(uv - 0.5);
    cinematicColor *= 1.0 - vign * 0.6;

    fragColor = vec4(cinematicColor, 1.0);
}