part of noisyterrain;

/**
 * Wrapper class used to manage shader compilation and the inclusion of 
 * attributes and uniforms.
 */
class ShaderProgram {
  Map<String, int> attributes = new Map<String, int>();
  Map<String, UniformLocation> uniforms = new Map<String, UniformLocation>();
  Program program;
  
  Shader vertShader, fragShader;
  
  ShaderProgram(String vertSrc, String fragSrc, List<String> attributeNames, 
      List<String> uniformNames) {
    
    vertShader = gl.createShader(VERTEX_SHADER);
    gl.shaderSource(vertShader, vertSrc);
    gl.compileShader(vertShader);
    if (!gl.getShaderParameter(vertShader, COMPILE_STATUS)) {
      print(gl.getShaderInfoLog(vertShader));
    }
    
    
    fragShader = gl.createShader(FRAGMENT_SHADER);
    gl.shaderSource(fragShader, fragSrc);
    gl.compileShader(fragShader);
    if (!gl.getShaderParameter(fragShader, COMPILE_STATUS)) {
      print(gl.getShaderInfoLog(fragShader));
    }
    
    program = gl.createProgram();
    gl.attachShader(program, vertShader);
    gl.attachShader(program, fragShader);
    gl.linkProgram(program);

    if (!gl.getProgramParameter(program, LINK_STATUS)) {
      print(gl.getProgramInfoLog(program));
    }
    
    for (String attrib in attributeNames) {
      int attributeLocation = gl.getAttribLocation(program, attrib);
      gl.enableVertexAttribArray(attributeLocation);
      attributes[attrib] = attributeLocation;
    }
    
    for (String uniform in uniformNames) {
      UniformLocation uniformLocation = gl.getUniformLocation(program, uniform);
      uniforms[uniform] = uniformLocation;
    }
  }
}