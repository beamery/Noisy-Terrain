#include <iostream>
#include <GL/freeglut.h>

using namespace std;

struct WindowData {
	GLint height, width;
	GLint handle;
	bool wireframe;
} window;

void displayFunc() {
	glEnable(GL_DEPTH_TEST);
	glPolygonMode(GL_FRONT_AND_BACK, window.wireframe ? GL_LINE : GL_FILL);
	glClearColor(0.2f, 0.2f, 0.2f, 1.0f);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

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
	}
}

void specialFunc(int c, int x, int y) {

}


int main(int argc, char *argv[]) {
	window.wireframe = false;

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
