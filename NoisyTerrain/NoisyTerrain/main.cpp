#include <iostream>
#include <GL/freeglut.h>
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp> 
#include "MatrixStack.h"
#include "Scene.h"

using namespace std;

struct WindowData {
	GLint height, width;
	GLint handle;
	bool wireframe;
} window;

struct Camera {
	float yRot;
	glm::vec3 pos;
} camera;


MatrixStack mv;
Scene scene;

void displayFunc() {
	glEnable(GL_LIGHTING);
	glEnable(GL_LIGHT0);
	glEnable(GL_COLOR_MATERIAL);

	glEnable(GL_DEPTH_TEST);
	glPolygonMode(GL_FRONT_AND_BACK, window.wireframe ? GL_LINE : GL_FILL);
	glClearColor(0.7f, 0.7f, 1.0f, 1.0f);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	glViewport(0, 0, window.width, window.height);
	glMatrixMode(GL_PROJECTION);

	glm::mat4 projection_matrix = glm::perspective(
		50.0f, float(window.width) / float(window.height), 0.01f, 1000.0f);
	glLoadMatrixf(glm::value_ptr(projection_matrix));

	glMatrixMode(GL_MODELVIEW);

	mv.push();

	mv.active = glm::translate(mv.active, camera.pos);
	mv.active = glm::rotate(mv.active, camera.yRot, glm::vec3(0.0f, 1.0f, 0.0f));
	//mv.active = glm::rotate(mv.active, -45.0f, glm::vec3(1.0f, 0.0f, 0.0f));
	

	glLoadMatrixf(glm::value_ptr(mv.active));
	glutSolidCube(0.03f);
	scene.draw(mv);


	mv.pop();
	glutSwapBuffers();
	glutPostRedisplay();
}

void reshapeFunc(GLint w, GLint h) {
	if (h > 0) {
		window.height = h;
		window.width = w;
	}
}

void keyboardFunc(unsigned char c, int x, int y) {
	switch (c) {
	case 27:
		glutLeaveMainLoop();
		return;
	case 'f':
		window.wireframe = !window.wireframe;
		break;
	}
}

void specialFunc(int c, int x, int y) {
	switch (c) {
	case GLUT_KEY_RIGHT:
		camera.yRot -= 2.0f;
		break;
	case GLUT_KEY_LEFT:
		camera.yRot += 2.0f;
		break;
	case GLUT_KEY_UP:
		camera.pos = glm::vec3(camera.pos.x, camera.pos.y, camera.pos.z + 0.1);
		break;
	case GLUT_KEY_DOWN:
		camera.pos = glm::vec3(camera.pos.x, camera.pos.y, camera.pos.z - 0.1);
		break;
	}
}


int main(int argc, char *argv[]) {
	window.wireframe = false;
	camera.yRot = 0.0f;
	camera.pos = glm::vec3(0.0f, 0.0f, 0.0f);

	glutInit(&argc, argv);
	glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE | GLUT_DEPTH);
	glutInitWindowSize(1024, 768);
	window.handle = glutCreateWindow("Noisy Terrain");
	glutDisplayFunc(displayFunc);
	glutReshapeFunc(reshapeFunc);
	glutKeyboardFunc(keyboardFunc);
	glutSpecialFunc(specialFunc);

	glutMainLoop();
}
