
#define EUCLIDEAN 0
#define MANHATAN 1
#define SUPREMUM 2

#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include "BoolVolume.h"



//MORPHOLOGY

/*
inline void dilate(const int x, const int y, const int z, Volume *v) {

	//structuring element (represents the sup metric in this current format)


	//2d linear
	if (x + 1 < v->getWidth())
		v->setVoxelValue(true, x + 1, y, z);

	if (x - 1 >= 0)
		v->setVoxelValue(true, x - 1, y, z);

	if (y + 1 < v->getHeight())
		v->setVoxelValue(true, x, y + 1, z);

	if (y - 1 >= 0)
		v->setVoxelValue(true, x, y - 1, z);

	//3d linear
	if (z + 1 < v->getDepth())
		v->setVoxelValue(true, x, y, z + 1);

	if (z - 1 >= 0)
		v->setVoxelValue(true, x, y, z - 1);


	//2d diagonals
	if (x + 1 < v->getWidth() && y - 1 >= 0)
		v->setVoxelValue(true, x + 1, y - 1, z);

	if (x - 1 >= 0 && y - 1 >= 0)
		v->setVoxelValue(true, x - 1, y - 1, z);

	if (x + 1 < v->getWidth() && y + 1 < v->getHeight())
		v->setVoxelValue(true, x + 1, y + 1, z);

	if (x - 1 >= 0 && y + 1 < v->getHeight())
		v->setVoxelValue(true, x - 1, y + 1, z);


	//3d diagonals (front)
	if (z + 1 < v->getDepth()) {
		//2d linear
		if (x + 1 < v->getWidth())
			v->setVoxelValue(true, x + 1, y, z + 1);

		if (x - 1 >= 0)
			v->setVoxelValue(true, x - 1, y, z + 1);

		if (y + 1 < v->getHeight())
			v->setVoxelValue(true, x, y + 1, z + 1);

		if (y - 1 >= 0)
			v->setVoxelValue(true, x, y - 1, z + 1);


		//2d diagonals
		if (x + 1 < v->getWidth() && y - 1 >= 0)
			v->setVoxelValue(true, x + 1, y - 1, z + 1);

		if (x - 1 >= 0 && y - 1 >= 0)
			v->setVoxelValue(true, x - 1, y - 1, z + 1);

		if (x + 1 < v->getWidth() && y + 1 < v->getHeight())
			v->setVoxelValue(true, x + 1, y + 1, z + 1);

		if (x - 1 >= 0 && y + 1 < v->getHeight())
			v->setVoxelValue(true, x - 1, y + 1, z + 1);

	}

	if (z - 1 >= 0) {
		//2d linear
		if (x + 1 < v->getWidth())
			v->setVoxelValue(true, x + 1, y, z - 1);

		if (x - 1 >= 0)
			v->setVoxelValue(true, x - 1, y, z - 1);

		if (y + 1 < v->getHeight())
			v->setVoxelValue(true, x, y + 1, z - 1);

		if (y - 1 >= 0)
			v->setVoxelValue(true, x, y - 1, z - 1);


		//2d diagonals
		if (x + 1 < v->getWidth() && y - 1 >= 0)
			v->setVoxelValue(true, x + 1, y - 1, z - 1);

		if (x - 1 >= 0 && y - 1 >= 0)
			v->setVoxelValue(true, x - 1, y - 1, z - 1);

		if (x + 1 < v->getWidth() && y + 1 < v->getHeight())
			v->setVoxelValue(true, x + 1, y + 1, z - 1);

		if (x - 1 >= 0 && y + 1 < v->getHeight())
			v->setVoxelValue(true, x - 1, y + 1, z - 1);

	}

}
*/


inline void dilate(const int x, const int y, const int z, Volume *v){

	//structuring element (represents the sup metric in this current format)

	//2d linear
	if (x + 1 < v->getWidth()) {
		v->setVoxelValue(true, x + 1, y, z);

		//2d diagonals
		if (y - 1 >= 0)
			v->setVoxelValue(true, x + 1, y - 1, z);
		if (y + 1 < v->getHeight())
			v->setVoxelValue(true, x + 1, y + 1, z);

		//3d
		if (z + 1 < v->getDepth())
			v->setVoxelValue(true, x + 1, y, z + 1);
		if (z + 1 < v->getDepth() && y - 1 >= 0)
			v->setVoxelValue(true, x + 1, y - 1, z + 1);
		if (z + 1 < v->getDepth() && y + 1 < v->getHeight())
			v->setVoxelValue(true, x + 1, y + 1, z + 1);
		if (z - 1 >= 0)
			v->setVoxelValue(true, x + 1, y, z - 1);
		if (z - 1 >= 0 && y - 1 >= 0)
			v->setVoxelValue(true, x + 1, y - 1, z - 1);
		if (z - 1 >= 0 && y + 1 < v->getHeight())
			v->setVoxelValue(true, x + 1, y + 1, z - 1);
	}
	
	if (x - 1 >= 0) {
		v->setVoxelValue(true, x - 1, y, z);

		//3d
		if (z + 1 < v->getDepth())
			v->setVoxelValue(true, x - 1, y, z + 1);
		if (z + 1 < v->getDepth() && y - 1 >= 0)
			v->setVoxelValue(true, x - 1, y - 1, z + 1);
		if (z + 1 < v->getDepth() && y + 1 < v->getHeight())
			v->setVoxelValue(true, x - 1, y + 1, z + 1);
		if (z - 1 >= 0)
			v->setVoxelValue(true, x - 1, y, z - 1);
		if (z - 1 >= 0 && y - 1 >= 0)
			v->setVoxelValue(true, x - 1, y - 1, z - 1);
		if (z - 1 >= 0 && y + 1 < v->getHeight())
			v->setVoxelValue(true, x - 1, y + 1, z - 1);

	}

	if (y + 1 < v->getHeight()) {
		v->setVoxelValue(true, x, y + 1, z);

		//2d diagonals
		if (x - 1 >= 0)
			v->setVoxelValue(true, x - 1, y + 1, z);

		//3d
		if (z + 1 < v->getDepth())
			v->setVoxelValue(true, x, y + 1, z + 1);
		if (z - 1 >= 0)
			v->setVoxelValue(true, x, y + 1, z - 1);
	}

	if (y - 1 >= 0) {
		v->setVoxelValue(true, x, y - 1, z);

		//2d diagonals
		if (x - 1 >= 0)
			v->setVoxelValue(true, x - 1, y - 1, z);

		//3d
		if (z + 1 < v->getDepth())
			v->setVoxelValue(true, x, y - 1, z + 1);
		if (z - 1 >= 0)
			v->setVoxelValue(true, x, y - 1, z - 1);
	}

	//3d linear
	if (z + 1 < v->getDepth())
		v->setVoxelValue(true, x, y, z + 1);

	if (z - 1 >= 0)
		v->setVoxelValue(true, x, y, z - 1);

}


inline int hdCPUMorphology(Volume *v1, Volume* v2){
	bool grownEnough = false;

	const int WIDTH = v1->getWidth(), HEIGHT = v1->getHeight(), DEPTH = v1->getDepth();

	Volume *v1p = new Volume(WIDTH, HEIGHT, DEPTH), *v1Aux = new Volume(WIDTH, HEIGHT, DEPTH),
		*v2p = new Volume(WIDTH, HEIGHT, DEPTH), *v2Aux = new Volume(WIDTH, HEIGHT, DEPTH);

	int dist = 0;
	//bool same = true; //you should keep this line uncommented if you want to avoid the case where the images are the same
	//populate auxiliary arrays (initialization)
	for (int d = 0; d < DEPTH; d++) {
		for (int i = 0; i < HEIGHT; i++) {
			for (int j = 0; j < WIDTH; j++) {

				const int v1V = v1->getVoxelValue(j, i, d),
					v2V = v2->getVoxelValue(j, i, d);

				v1p->setVoxelValue(v1V, j, i, d);
				v2p->setVoxelValue(v2V, j, i, d);
				
				v1Aux->setVoxelValue(v1V, j, i, d);
				v2Aux->setVoxelValue(v2V, j, i, d);


				//you should keep this line uncommented if you want to avoid the case where the images are the same
				//same &= v1V == v2V;
			}
		}
	}
	//you should keep this line uncommented if you want to avoid the case where the images are the same
	//if (same) return 0;

	//actual processing
	while (!grownEnough){
		grownEnough = true;

		//dilate images
		for (int d = 0; d < DEPTH; d++) {
			for (int i = 0; i < HEIGHT; i++) {
				for (int j = 0; j < WIDTH; j++) {
					if (v1Aux->getVoxelValue(j, i, d)) dilate(j, i, d, v1p);
					if (v2Aux->getVoxelValue(j, i, d)) dilate(j, i, d, v2p);
				}
			}
		}

		//update imagepAux
		for (int d = 0; d < DEPTH; d++) {
			for (int i = 0; i < HEIGHT; i++) {
				for (int j = 0; j < WIDTH; j++) {

					const int v1V = v1p->getVoxelValue(j, i, d),
						v2V = v2p->getVoxelValue(j, i, d);
					v1Aux->setVoxelValue(v1V, j, i, d);
					v2Aux->setVoxelValue(v2V, j, i, d);

					//check if finished
					//grownEnough &= (((v2Aux->getVoxelValue(j, i, d) == v1->getVoxelValue(j, i, d)) && v1->getVoxelValue(j, i, d)) || !v1->getVoxelValue(j, i, d))
					//	&& (((v1Aux->getVoxelValue(j, i, d) == v2->getVoxelValue(j, i, d)) && v2->getVoxelValue(j, i, d)) || !v2->getVoxelValue(j, i, d));

					grownEnough &= (v2V || !v1->getVoxelValue(j, i, d))
						&& (v1V || !v2->getVoxelValue(j, i, d));
				}
			}
		}
		dist++;
	}


	delete(v1p);
	delete(v2p);
	delete(v1Aux);
	delete(v2Aux);

	printf("Hausdorf distance: %d \n", dist);
	return dist;
}




