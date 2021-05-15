#pragma once

#include<Volume.h>

#define CUDA_DEVICE_INDEX 0 //setting the index of your CUDA device

#define IS_3D 0 //setting this to 0 would grant a very slightly improvement on the performance if working with images only
#define CHEBYSHEV 1 //if not set to 1, then this algorithm would use an Euclidean-like metric, it is just an approximation. 
//It can be changed according to the structuring element

class HausdorffDistance{

private:
	void print(cudaError_t error, char* msg);

public:
	int computeDistance(Volume *img1, Volume *img2);

};

