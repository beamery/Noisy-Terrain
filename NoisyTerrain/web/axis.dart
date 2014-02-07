part of noisyterrain;

class Axis {
  Buffer glVertexBuffer;
  int numVertices;
  
  Axis() {
    Float32List vertexData = new Float32List.fromList(
        [// origin
         0.0, 0.0, 0.0,
         1.0, 0.0, 0.0,  
         // x-axis
         1.0, 0.0, 0.0,
         1.0, 0.0, 0.0,
         
         // origin
         0.0, 0.0, 0.0,
         0.0, 1.0, 0.0,
         // y-axis
         0.0, 1.0, 0.0,
         0.0, 1.0, 0.0,
         
         // origin
         0.0, 0.0, 0.0,
         0.0, 0.0, 1.0,
         // z-axis
         0.0, 0.0, 1.0,
         0.0, 0.0, 1.0]
    );
    numVertices = 6;
    
    // Perform GL setup.
    glVertexBuffer = gl.createBuffer();
    gl.bindBuffer(ARRAY_BUFFER, glVertexBuffer);
    gl.bufferDataTyped(ARRAY_BUFFER, vertexData, STATIC_DRAW);
  }
  
  void draw() {
    ShaderProgram program = shaderManager['unlit'];
    mvPush();
    gl.useProgram(program.program);
    
    // Set up array buffer.
    gl.bindBuffer(ARRAY_BUFFER, glVertexBuffer);
    gl.vertexAttribPointer(
        program.attributes['aPosition'], 3, FLOAT, 
        false, 6 * FLOAT_SIZE, 0);
    gl.vertexAttribPointer(
        program.attributes['aColor'], 3, FLOAT, 
        false, 6 * FLOAT_SIZE, 3 * FLOAT_SIZE);
    
    // Set matrix uniforms
    mvp = proj * mv;
    gl.uniformMatrix4fv(program.uniforms['uMVP'], false, mvp.storage);
    
    gl.drawArrays(LINES, 0, numVertices);
    
    mvPop();
  }
}