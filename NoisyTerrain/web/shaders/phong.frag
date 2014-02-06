precision mediump float;

varying vec3 vNormal;
varying vec3 vPosition;

void main(void) {
    vec3 norm = vNormal;
    if (!gl_FrontFacing) {
        norm = -norm;
    }
    gl_FragColor = vec4(norm.x, 0.0, norm.z, 1.0);
}