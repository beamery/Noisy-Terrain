part of noisyterrain;

class Mesh {
  Float32List vertexData;
  Buffer glVertexBuffer, glIndexBuffer;
  List<int> indices;
  int rows, cols;
  
  Mesh(List<Vertex> vertices, int rows, int cols) {
    this.indices = [];
    this.rows = rows;
    this.cols = cols;
    
    createIndexArray(rows, cols);
    flattenVertices(vertices);
    glSetup();
  }
  
  /**
   * Create an index array which specifies the drawing order of our vertices.
   * We will draw all of our triangles clockwise for consistency.
   */
  void createIndexArray(int rows, int cols) {
    for (int i = 0; i < rows - 1; i++) {
      for (int j = 0; j < cols - 1; j++) {
        // top-left triangle
        indices.add(getIndex(i, j));
        indices.add(getIndex(i, j+1));
        indices.add(getIndex(i+1, j));
        
        // bottom-right triangle
        indices.add(getIndex(i+1, j));
        indices.add(getIndex(i, j+1));
        indices.add(getIndex(i+1, j+1));
      }
    }
  }
  
  /**
   * Flatten the vertex array into a 1D array of Float32 objects. This makes
   * our meshes easier for the rendering system to handle.
   */
  void flattenVertices(List<Vertex> vertices) {
    vertexData = new Float32List(vertices.length * Vertex.size);
    
    for (int i = 0; i < vertices.length; i++) {   
      Float32List vxData = vertices[i].data;
      for (int j = 0; j < vxData.length; j++) {
        vertexData[i * Vertex.size + j] = vxData[j];
      }
    }
  }
  
  /**
   * Set up WebGL with a buffer for this mesh
   */
  void glSetup() {
    glVertexBuffer = gl.createBuffer();
    gl.bindBuffer(ARRAY_BUFFER, glVertexBuffer);
    gl.bufferDataTyped(ARRAY_BUFFER, vertexData, STATIC_DRAW);
    
    glIndexBuffer = gl.createBuffer();
    gl.bindBuffer(ELEMENT_ARRAY_BUFFER, glIndexBuffer);
    gl.bufferDataTyped(ELEMENT_ARRAY_BUFFER, new Int16List.fromList(indices), STATIC_DRAW);
  }
  
  int getIndex(r, c) {
    return r * cols + c;
  }
  
  void draw(ShaderProgram program) {
    mvPush();
    
    // Set up array buffer.
    gl.bindBuffer(ARRAY_BUFFER, glVertexBuffer);
    gl.vertexAttribPointer(program.attributes['aVertexPosition'], 3, 
                           FLOAT, false, Vertex.size * 4, 0);
    
    // Set up index buffer.
    gl.bindBuffer(ELEMENT_ARRAY_BUFFER, glIndexBuffer);
    
    // Set matrix transforms
    gl.uniformMatrix4fv(program.uniforms['uMVMatrix'], false, mv.storage);
    gl.uniformMatrix4fv(program.uniforms['uPMatrix'], false, proj.storage);
    
    // Draw lines for debugging purposes only
    gl.drawElements(LINES, indices.length, UNSIGNED_SHORT, 0);
    //gl.drawElements(TRIANGLES, indices.length, UNSIGNED_SHORT, 0);
    
    mvPop();
  }

}