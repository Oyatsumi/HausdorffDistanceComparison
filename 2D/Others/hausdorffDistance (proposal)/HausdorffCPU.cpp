
#define EUCLIDEAN 0
#define MANHATAN 1
#define SUPREMUM 2

#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <Hausdorff_common.h>


inline int d(const int x1, const int y1, const int x2, const int y2, const int METRIC){
	if (METRIC == EUCLIDEAN){
		return round(sqrt((x2 - x1)*(x2 - x1) + (y2 - y1)*(y2 - y1)));
	}
	else if (METRIC == MANHATAN){
		return abs(x2 - x1) + abs(y2 - y1);
	}
	else{//supremum
		return (abs(x2 - x1) > abs(y2 - y1) ? abs(x2 - x1) : abs(y2 - y1));
	}
}


int hdCPU(const bool *img1, const bool *img2, const int WIDTH, const int HEIGHT, const int METRIC){
	unsigned int minImg1 = 0xFFFFFFF, minImg2 = 0xFFFFFFF;
	unsigned int maxImg1 = 0, maxImg2 = 0;

	int pIndex1, pIndex2;

	//printf("Processing images (width=%d, height=%d) \n", WIDTH, HEIGHT);
	
	//printf("Getting minimum distance from image 1 to image 2. \n");
	//IMG1
	//for every pixel of the first image
	for (int i = 0; i < HEIGHT; i++){
		for (int j = 0; j < WIDTH; j++){
			pIndex1 = i*WIDTH + j;
			if (!img1[pIndex1]) continue;
			//every of the second
			for (int i2 = 0; i2 < HEIGHT; i2++){
				for (int j2 = 0; j2 < WIDTH; j2++){
					pIndex2 = i2*WIDTH + j2;
					if (img2[pIndex2])
						if (d(j, i, j2, i2, METRIC) < minImg1) minImg1 = d(j, i, j2, i2, METRIC);
				}
			}
			maxImg1 = (maxImg1 > minImg1 ? maxImg1 : minImg1);
			minImg1 = 0xFFFFFFF;
		}
	}
	//printf("Getting minimum distance from image 2 to image 1. \n");
	//IMG2
	//for every pixel of the second image
	for (int i = 0; i < HEIGHT; i++){
		for (int j = 0; j < WIDTH; j++){
			pIndex2 = i*WIDTH + j;
			if (!img2[pIndex2]) continue;
			//every of the first
			for (int i2 = 0; i2 < HEIGHT; i2++){
				for (int j2 = 0; j2 < WIDTH; j2++){
					pIndex1 = i2*WIDTH + j2;
					if (img1[pIndex1])
						if (d(j, i, j2, i2, METRIC) < minImg2) minImg2 = d(j, i, j2, i2, METRIC);
				}
			}
			maxImg2 = (maxImg2 > minImg2 ? maxImg2 : minImg2);
			minImg2 = 0xFFFFFFF;
		}
	}

	printf("Hausdorff distance: %d \n", (maxImg1 > maxImg2) ? maxImg1 : maxImg2);
	return (maxImg1 > maxImg2) ? maxImg1 : maxImg2;
}




//MORPHOLOGY

inline void dilate(const int id, bool *imgP, const int WIDTH, const int HEIGHT){
	const int x = id % WIDTH, y = id / WIDTH;

	if (x + 1 < WIDTH) imgP[id + 1] = true;
	if (x - 1 >= 0) imgP[id - 1] = true;
	if (y + 1 < HEIGHT) imgP[id + WIDTH] = true;
	if (y - 1 >= 0) imgP[id - WIDTH] = true;
	//diagonais
	if (x + 1 < WIDTH && y - 1 >= 0) imgP[id - WIDTH + 1] = true;
	if (x - 1 >= 0 && y - 1 >= 0) imgP[id - WIDTH - 1] = true;
	if (x + 1 < WIDTH && y + 1 < HEIGHT) imgP[id + WIDTH + 1] = true;
	if (x - 1 >= 0 && y + 1 < HEIGHT) imgP[id + WIDTH - 1] = true;
}


int hdCPUMorphology(const bool *img1, const bool *img2, const int WIDTH, const int HEIGHT, const bool *structElement){
	bool grownEnough = false;
	bool *img1P = new bool[WIDTH*HEIGHT], *img2P = new bool[WIDTH*HEIGHT],
		*img1PAux = new bool[WIDTH*HEIGHT], *img2PAux = new bool[WIDTH*HEIGHT];
	int currentId, dist = 0;
	//populate arrays, saving original images
	for (int i = 0; i < HEIGHT; i++){
		for (int j = 0; j < WIDTH; j++){
			currentId = i*WIDTH + j;
			img1P[currentId] = img1[currentId];
			img2P[currentId] = img2[currentId];
			img1PAux[currentId] = img1[currentId];
			img2PAux[currentId] = img2[currentId];
		}
	}

	while (!grownEnough){
		grownEnough = true;

		//dilate images
		for (int i = 0; i < HEIGHT; i++){
			for (int j = 0; j < WIDTH; j++){
				currentId = i*WIDTH + j;
				if (img1PAux[currentId]) dilate(currentId, img1P, WIDTH, HEIGHT);
				if (img2PAux[currentId]) dilate(currentId, img2P, WIDTH, HEIGHT);
			}
		}
		//update imagepAux
		for (int i = 0; i < HEIGHT; i++){
			for (int j = 0; j < WIDTH; j++){
				currentId = i*WIDTH + j;
				img1PAux[currentId] = img1P[currentId];
				img2PAux[currentId] = img2P[currentId];
				//check if finished
				grownEnough &= (img2PAux[currentId] || !img1[currentId]) && (img1PAux[currentId] || !img2[currentId]);
			}
		}
		dist++;
	}

	delete(img1P);
	delete(img2P);
	delete(img1PAux);
	delete(img2PAux);

	printf("Hausdorf distance: %d \n", dist);
	return dist;
}




