#ifndef GROUND_H
#define GROUND_H

#define GRID_SIZE 512

#include <gl/freeglut.h>
#include "MatrixStack.h"

// Contains coordinates and drawing functionality for the floor of
// our world
class Ground {

public:

	// initializes the floor as a 10ft by 10ft grid, separated into
	// 6in by 6in sections
	Ground();

	// Draws the grid
	void draw(MatrixStack &mViewStack);

private:
	glm::vec3 grid[GRID_SIZE][GRID_SIZE];

};


#endif