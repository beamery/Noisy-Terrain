part of util;


double cubicInterp(val, min, max) {
  return 3 * pow(val, 2) - 2 * pow(val, 3);
}

double linearInterp(val, min, max) {
  return val;
  //return min + (max - min) * val;
}

double interp(val, [type='CUBIC', min=0, max=1]) {
  switch (type) {
    case 'CUBIC':
      return cubicInterp(val, min, max);
      break;
    case 'LINEAR':
      return linearInterp(val, min, max);
      break;
  }
}

double interp2D(x0y0, x0y1, x1y0, x1y1, x, y, type) {
  // Smoothly interpolate in x-direction for y0 and y1.
  double interpX = interp(x, type);
  double xy0 = x0y0 + (x1y0 - x0y0) * interpX;
  double xy1 = x0y1 + (x1y1 - x0y1) * interpX;
  
  // Smoothly interpolate in the y-direction
  var interpY = interp(y, type);
  double outVal = xy0 + (xy1 - xy0) * interpY;
  
  return outVal;
}