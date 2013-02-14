#include "Ground.h"

Ground::Ground() {

	// Initialize grid to a 60m square, with points every meter
	double xPos = 0;
	float height = 0.0f;
	for (int i = 0; i < GRID_SIZE; i++) {
		double zPos = 0;
		for (int j = 0; j < GRID_SIZE; j++) {
			grid[i][j] = glm::vec3(xPos, height, zPos);
			zPos++;
		}
		xPos++;
	}
}


void Ground::draw(MatrixStack &mv) {
	// save previous modelview matrix
	mv.push();

	/*
	// Draw axes
	// y coord offset by 0.01 to stop the lines from fighting each other
	glLineWidth(3.0f);
	glBegin(GL_LINES);
	// x
	glColor4f(1.0f, 0.0f, 0.0f, 1.0f);
	glVertex4f(60.0f, 0.01f, 60.0f, 1.0f);
	glVertex4f(120.0f, 0.01f, 60.0f, 1.0f);
	// y
	glColor4f(0.0f, 1.0f, 0.0f, 1.0f);
	glVertex4f(60.0f, 0.0f, 60.0f, 1.0f);
	glVertex4f(60.0f, 60.0f, 60.0f, 1.0f);
	// z
	glColor4f(0.0f, 0.0f, 1.0f, 1.0f);
	glVertex4f(60.0f, 0.01f, 60.0f, 1.0f);
	glVertex4f(60.0f, 0.01f, 120.0f, 1.0f);
	glEnd();
	*/


	// Draw floor grid
	glLineWidth(1.0f);
	float shade = 0.0f;
	for (int i = 0; i < GRID_SIZE - 1; i++) {
		glBegin(GL_QUADS);
		for (int j = 0; j < GRID_SIZE - 1; j++) {
			glColor4f(shade, -shade, shade * shade, 1.0f);
			glColor4f(0.5f, 1.0f, 0.5f, 1.0f);

			glVertex4f(grid[i][j].x, grid[i][j].y, grid[i][j].z, 1.0f);
			glVertex4f(grid[i+1][j].x, grid[i+1][j].y, grid[i+1][j].z, 1.0f);
			glVertex4f(grid[i+1][j+1].x, grid[i+1][j+1].y, grid[i+1][j+1].z, 1.0f);
			glVertex4f(grid[i][j+1].x, grid[i][j+1].y, grid[i][j+1].z, 1.0f);
			
			shade += 0.1f;
			if (shade > 1.0f)
				shade = 0.0f;
		}
		glEnd();
	}
	// restore previous modelview matrix
	mv.pop();
}
