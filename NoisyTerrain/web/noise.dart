part of util;


/**
 * Create a [size] by [size] grid of Perlin noise. The algorithm used to
 * generate Perlin noise can be found here:
 * 
 * http://webstaff.itn.liu.se/~stegu/TNM022-2005/perlinnoiselinks/perlin-noise-math-faq.html
 */
Grid2D<double> perlinNoise(size, freq, amp, octaves, persistence) {
  return _generateNoise('PERLIN', size, freq, amp, octaves, persistence);  
}

/**
 * Create a [size] by [size] grid of value noise. The algorithm for value noise
 * is relatively simple:
 * 
 * for each octave:
 *   generate a random grid with size based on the frequency, range of values
 *   based on the amplitude
 *   amplitude *= persistence
 *   frequency *= 2
 */
Grid2D<double> valueNoise(size, freq, amp, octaves, persistence) {
  return _generateNoise('VALUE', size, freq, amp, octaves, persistence); 
}

Grid2D<double> _generateNoise(type, size, freq, amp, octaves, persistence) {
  
  // Initialize output grid to all 0's
  Grid2D<double> output = new Grid2D(size, size);
  for (int i = 0; i < output.rows; i++) {
    for (int j = 0; j < output.cols; j++) {
      output[i][j] = 0.0;
    }
  }
  
  // Create the specified number of octaves of noise, adding them as we go.
  Grid2D<double> noiseOctave;
  for (int i = 0; i < octaves; i++) {
    switch (type) {
      case 'PERLIN':
        noiseOctave = _perlin(size, freq, amp);
        break;
      case 'VALUE':
        noiseOctave = _value(size, freq, amp);
        break;
    }   
    output = output + noiseOctave;
    freq *= 2;
    amp *= persistence;
  }
  return output;
}

Grid2D<double> _perlin(size, freq, amp) {
  
  Random rng = new Random();
  Grid2D<double> output = new Grid2D<double>(size, size);
  Grid2D<Vector2> vals = new Grid2D<Vector2>(freq, freq);
  
  // Cell size is the number of output points per value point.
  double cellSize = size / (freq - 1);
  
  for (int i = 0; i < vals.rows; i++) {
    for (int j = 0; j < vals.cols; j++) {
      // Generate a random angle from 0 to 2*PI.
      double theta = rng.nextDouble() * 2 * PI;
      
      // X and Y components range from -1 to +1
      vals[i][j] = new Vector2(cos(theta), sin(theta));
    }
  }
  
  // For each point in the output, get its value and store it in [output]
  for (int i = 0; i < output.rows; i++) {
    // X coord in the value grid corresponding to this output point.
    double x = i / cellSize;
    int x0 = x.floor();
    int x1 = x.ceil();
    for (int j = 0; j < output.cols; j++) {
      // Y coord in the value grid corresponding to this output point.
      double y = j / cellSize;
      int y0 = y.floor();
      int y1 = y.ceil();
      
      // Get vectors from grid points to this output point.
      Vector2 v_x0y0 = new Vector2(x - x0, y - y0);
      Vector2 v_x0y1 = new Vector2(x - x0, y - y1);
      Vector2 v_x1y0 = new Vector2(x - x1, y - y0);
      Vector2 v_x1y1 = new Vector2(x - x1, y - y1);
      
      // Calculate the dot products to find the weight of each corner on
      // the output point.
      double mag_x0y0 = v_x0y0.dot(vals[x0][y0]);
      double mag_x0y1 = v_x0y1.dot(vals[x0][y1]);
      double mag_x1y0 = v_x1y0.dot(vals[x1][y0]);
      double mag_x1y1 = v_x1y1.dot(vals[x1][y1]);
      
      // Get the output value, interpolated in the x and y directions.
      output[i][j] = amp * interp2D(
          mag_x0y0, mag_x0y1, 
          mag_x1y0, mag_x1y1, 
          v_x0y0.x, v_x0y0.y, 'CUBIC');
    }
  }
  return output;
}

Grid2D<double> _value(size, freq, amp) {
  Random rng = new Random();
  Grid2D<double> output = new Grid2D<double>(size, size);
  Grid2D<double> vals = new Grid2D<double>(freq, freq);
  
  // Cell size is the number of output points per value point.
  double cellSize = size / (freq - 1);
  
  for (int i = 0; i < vals.rows; i++) {
    for (int j = 0; j < vals.cols; j++) {
      // X and Y components range from -1 to +1
      vals[i][j] = (2 * rng.nextDouble()) - 1;
    }
  }
  
  // For each point in the output, get its value and store it in [output]
  for (int i = 0; i < output.rows; i++) {
    // X coord in the value grid corresponding to this output point.
    double x = i / cellSize;
    int x0 = x.floor();
    int x1 = x.ceil();
    for (int j = 0; j < output.cols; j++) {
      // Y coord in the value grid corresponding to this output point.
      double y = j / cellSize;
      int y0 = y.floor();
      int y1 = y.ceil();

      // Calculate the vector from x0y0 to xy, used in the interpolatiion step.
      Vector2 v_x0y0 = new Vector2(x - x0, y - y0);
      
      // Get the weight at each corner.
      double mag_x0y0 = vals[x0][y0];
      double mag_x0y1 = vals[x0][y1];
      double mag_x1y0 = vals[x1][y0];
      double mag_x1y1 = vals[x1][y1];
      
      // Get the output value, interpolated in the x and y directions.
      output[i][j] = amp * interp2D(
          mag_x0y0, mag_x0y1, 
          mag_x1y0, mag_x1y1, 
          v_x0y0.x, v_x0y0.y, 'CUBIC');
    }
  }
  return output;
}

