attribute vec3 aPosition;
attribute vec3 aNormal;

uniform mat4 uMVP;

varying vec3 vNormal;
varying vec3 vPosition;

void main(void) {
    vNormal = normalize(aNormal);
    vPosition = aPosition;
    gl_Position = uMVP * vec4(aPosition, 1.0);
}