part of noisyterrain;

class Mesh {
  Float32List vertexData;
  List<int> indices;
  int rows, cols;
  
  Mesh(List<Vertex> vertices, int rows, int cols) {
    this.indices = [];
    this.rows = rows;
    this.cols = cols;
    
    createIndexArray(rows, cols);
    flattenVertices(vertices);
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
  
  int getIndex(r, c) {
    return r * rows + c;
  }

}