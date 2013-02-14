#include "Scene.h"

Scene::Scene() {
}

void Scene::draw(MatrixStack &mv, bool hasTable) {

	// save previous transformation matrix
	mv.push();

	// set up floor transformations
	mv.active = glm::scale(mv.active, 
		glm::vec3(METERS_PER_WORLD_UNIT, METERS_PER_WORLD_UNIT, METERS_PER_WORLD_UNIT));
	mv.active = glm::translate(mv.active, 
		glm::vec3(-GRID_SIZE / 2.0f, -1.0f, -GRID_SIZE / 2.0f));

	// draw the floor
	glLoadMatrixf(glm::value_ptr(mv.active));
	ground.draw(mv);

	mv.pop();
}

void Scene::adjustStoolHeights(float amount) {
}


void Scene::print() const {
}
