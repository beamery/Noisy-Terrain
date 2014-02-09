part of noisyterrain;

void _testNoise() {
  CanvasElement canvas = querySelector('#test_canvas');
  CanvasRenderingContext2D ctx = canvas.context2D;
  
  var imgData = ctx.createImageData(1, 1);
  
  var noiseData = perlinNoise(canvas.width, 4, 1, 8, 0.5);
  int rows = noiseData.rows;
  int cols = noiseData.cols;
  
  double min = 1000.0;
  double max = -1000.0;
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      if (noiseData[i][j] < min) {
        min = noiseData[i][j];
      }
      if (noiseData[i][j] > max) {
        max = noiseData[i][j];
      }
    }
  }
  print('min: $min');
  print('max: $max');
  
  for (int i = 0 ; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      double pxl = (noiseData[i][j] + 1.0) / 2.0;
      int shade = (pxl * 255.0).ceil();

      imgData.data[0] = shade;
      imgData.data[1] = shade;
      imgData.data[2] = shade;
      imgData.data[3] = 255;
      ctx.putImageData(imgData, i, j);
    }
  }
  
}