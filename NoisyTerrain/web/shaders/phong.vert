attribute vec3 aPosition;
attribute vec3 aNormal;

uniform mat4 uMV;
uniform mat4 uProj;

varying vec3 vNormal;
varying vec3 vPosition;

void main(void) {
    vNormal = normalize(aNormal);
    vPosition = aPosition;
    gl_Position = uProj * uMV * vec4(aPosition, 1.0);
}