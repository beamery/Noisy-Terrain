precision mediump float;

varying vec3 vNormal;
varying vec3 vPosition;

uniform vec4 uLightPos;
uniform vec3 uKa; // material ambient reflection
uniform vec3 uLa; // light ambient intensity
uniform vec3 uKd; // material diffuse reflection
uniform vec3 uLd; // light diffuse intensity
uniform vec3 uKs; // material specular reflection
uniform vec3 uLs; // light specular intensity
uniform float uShine;

uniform mat4 uMV;
uniform mat4 uNormalMat;

void main(void) {
    vec3 norm = vNormal;
    if (!gl_FrontFacing) {
        norm = -norm;
    }
    // convert normal and position to eye coordinates
    vec3 eyeNorm = vec3(normalize(mat3(uNormalMat) * norm));
    vec4 eyePos = uMV * vec4(vPosition, 1.0);

    // get the vector from the surface to the light
    vec3 vxToLight = normalize(vec3(uLightPos - eyePos));
    vec3 vxToEye = normalize(-eyePos.xyz);
    vec3 lightReflect = reflect(-vxToLight, eyeNorm);

    // add ambient light
    vec3 ambient = uLa * uKa;

    // apply the diffuse equation
    float normDotLight = max(dot(vxToLight, eyeNorm), 0.0);
    vec3 diffuse = uLd * uKd * normDotLight;

    vec3 specular = vec3(0.0);
    // if the light is shining on the surface, get the specular component
    if (normDotLight > 0.0) {
        specular = uLs * uKs * pow(max(dot(lightReflect, vxToEye), 0.0), uShine);
    }

    vec3 lightIntensity;
    lightIntensity = ambient + diffuse + specular;
    gl_FragColor = vec4(lightIntensity, 1.0);
}