#include<stdio.h>
#include<Volume.h>
#include<HausdorffDistance.cuh>
// For the CUDA runtime routines (prefixed with "cuda_")
#include <cuda_runtime.h>
#include "cuda.h"
#include "cuda_runtime.h"
#include "device_launch_parameters.h"


typedef unsigned char uchar;
typedef unsigned int uint;


__device__ int finished; //global variable that contains a boolean which indicates when to stop the kernel processing

__constant__ __device__ int WIDTH, HEIGHT, DEPTH; //constant variables that contain the size of the volume



__global__ void dilate(const bool *IMG1, const bool *IMG2, const bool *img1Read, const bool *img2Read, 
	bool *img1Write, bool *img2Write){

	const int id = blockDim.x * blockIdx.x + threadIdx.x;
	#if !IS_3D
	const int x = id % WIDTH, y = id / WIDTH;
	#else
	const int x = id % WIDTH, y = (id/WIDTH) % HEIGHT, z = (id/WIDTH)/HEIGHT;
	#endif

	if (id < WIDTH*HEIGHT*DEPTH){


		if (img1Read[id]){
			if (x + 1 < WIDTH) img1Write[id + 1] = true;
			if (x - 1 >= 0) img1Write[id - 1] = true;
			if (y + 1 < HEIGHT) img1Write[id + WIDTH] = true;
			if (y - 1 >= 0) img1Write[id - WIDTH] = true;
			#if IS_3D //if working with 3d volumes, then the 3D part
			if (z + 1 < DEPTH) img1Write[id + WIDTH*HEIGHT] = true;
			if (z - 1 >=0) img1Write[id - WIDTH*HEIGHT] = true;
			#endif
			
			#if CHEBYSHEV
			//diagonals
			if (x + 1 < WIDTH && y - 1 >= 0) img1Write[id - WIDTH + 1] = true;
			if (x - 1 >= 0 && y - 1 >= 0) img1Write[id - WIDTH - 1] = true;
			if (x + 1 < WIDTH && y + 1 < HEIGHT) img1Write[id + WIDTH + 1] = true;
			if (x - 1 >= 0 && y + 1 < HEIGHT) img1Write[id + WIDTH - 1] = true;
			#if IS_3D //if working with 3d volumes, then the 3D part
			if (z + 1 < DEPTH && x + 1 < WIDTH && y - 1 >= 0) img1Write[id - WIDTH + 1 + WIDTH*HEIGHT] = true;
			if (z + 1 < DEPTH && x - 1 >= 0 && y - 1 >= 0) img1Write[id - WIDTH - 1 + WIDTH*HEIGHT] = true;
			if (z + 1 < DEPTH && x + 1 < WIDTH && y + 1 < HEIGHT) img1Write[id + WIDTH + 1 + WIDTH*HEIGHT] = true;
			if (z + 1 < DEPTH && x - 1 >= 0 && y + 1 < HEIGHT) img1Write[id + WIDTH - 1 + WIDTH*HEIGHT] = true;
			if (z - 1 >= 0 && x + 1 < WIDTH && y - 1 >= 0) img1Write[id - WIDTH + 1 - WIDTH*HEIGHT] = true;
			if (z - 1 >= 0 && x - 1 >= 0 && y - 1 >= 0) img1Write[id - WIDTH - 1 - WIDTH*HEIGHT] = true;
			if (z - 1 >= 0 && x + 1 < WIDTH && y + 1 < HEIGHT) img1Write[id + WIDTH + 1 - WIDTH*HEIGHT] = true;
			if (z - 1 >= 0 && x - 1 >= 0 && y + 1 < HEIGHT) img1Write[id + WIDTH - 1 - WIDTH*HEIGHT] = true;
			#endif
			#endif
		}


		if (img2Read[id]){
			if (x + 1 < WIDTH) img2Write[id + 1] = true;
			if (x - 1 >= 0) img2Write[id - 1] = true;
			if (y + 1 < HEIGHT) img2Write[id + WIDTH] = true;
			if (y - 1 >= 0) img2Write[id - WIDTH] = true;
			#if IS_3D //if working with 3d volumes, then the 3D part
			if (z + 1 < DEPTH) img2Write[id + WIDTH*HEIGHT] = true;
			if (z - 1 >= 0) img2Write[id - WIDTH*HEIGHT] = true;
			#endif

			#if CHEBYSHEV
			//diagonals
			if (x + 1 < WIDTH && y - 1 >= 0) img2Write[id - WIDTH + 1] = true;
			if (x - 1 >= 0 && y - 1 >= 0) img2Write[id - WIDTH - 1] = true;
			if (x + 1 < WIDTH && y + 1 < HEIGHT) img2Write[id + WIDTH + 1] = true;
			if (x - 1 >= 0 && y + 1 < HEIGHT) img2Write[id + WIDTH - 1] = true;
			#if IS_3D //if working with 3d volumes, then the 3D part
			if (z + 1 < DEPTH && x + 1 < WIDTH && y - 1 >= 0) img2Write[id - WIDTH + 1 + WIDTH*HEIGHT] = true;
			if (z + 1 < DEPTH && x - 1 >= 0 && y - 1 >= 0) img2Write[id - WIDTH - 1 + WIDTH*HEIGHT] = true;
			if (z + 1 < DEPTH && x + 1 < WIDTH && y + 1 < HEIGHT) img2Write[id + WIDTH + 1 + WIDTH*HEIGHT] = true;
			if (z + 1 < DEPTH && x - 1 >= 0 && y + 1 < HEIGHT) img2Write[id + WIDTH - 1 + WIDTH*HEIGHT] = true;
			if (z - 1 >= 0 && x + 1 < WIDTH && y - 1 >= 0) img2Write[id - WIDTH + 1 - WIDTH*HEIGHT] = true;
			if (z - 1 >= 0 && x - 1 >= 0 && y - 1 >= 0) img2Write[id - WIDTH - 1 - WIDTH*HEIGHT] = true;
			if (z - 1 >= 0 && x + 1 < WIDTH && y + 1 < HEIGHT) img2Write[id + WIDTH + 1 - WIDTH*HEIGHT] = true;
			if (z - 1 >= 0 && x - 1 >= 0 && y + 1 < HEIGHT) img2Write[id + WIDTH - 1 - WIDTH*HEIGHT] = true;
			#endif
			#endif
		}


		//this is an atomic and computed to the finished global variable, if image 1 contains all of image 2 and image 2 contains all pixels of
		//image 1 then finished is true
		atomicAnd(&finished, (img2Read[id] || !IMG1[id]) && (img1Read[id] || !IMG2[id]));
	}
}


int HausdorffDistance::computeDistance(Volume *img1, Volume *img2){

	const int height = (*img1).getHeight(), width = (*img1).getWidth(), depth = (*img1).getDepth();

	size_t size = width*height*depth*sizeof(bool);

	//getting details of your CUDA device
	cudaDeviceProp props;
	cudaGetDeviceProperties(&props, CUDA_DEVICE_INDEX); //device index = 0, you can change it if you have more CUDA devices
	const int threadsPerBlock = props.maxThreadsPerBlock/2;
	const int blocksPerGrid = (height*width*depth + threadsPerBlock - 1) / threadsPerBlock;


	//copying the dimensions to the GPU
	cudaMemcpyToSymbolAsync(WIDTH, &width, sizeof(width));
	cudaMemcpyToSymbolAsync(HEIGHT, &height, sizeof(height));
	cudaMemcpyToSymbolAsync(DEPTH, &depth, sizeof(depth));


	//allocating the input images on the GPU
	bool *d_img1, *d_img2;
	cudaMalloc(&d_img1, size);
	cudaMalloc(&d_img2, size);


	//copying the data to the allocated memory on the GPU
	cudaMemcpyAsync(d_img1, (*img1).getVolume(), size, cudaMemcpyHostToDevice);
	cudaMemcpyAsync(d_img2, (*img2).getVolume(), size, cudaMemcpyHostToDevice);


	//allocating the images that will be the processing ones
	bool *d_img1Write, *d_img1Read, *d_img2Write, *d_img2Read;
	cudaMalloc(&d_img1Write, size); cudaMalloc(&d_img1Read, size);
	cudaMalloc(&d_img2Write, size); cudaMalloc(&d_img2Read, size);


	//cloning the input images to these two image versions (write and read)
	cudaMemcpyAsync(d_img1Read, d_img1, size, cudaMemcpyDeviceToDevice);
	cudaMemcpyAsync(d_img2Read, d_img2, size, cudaMemcpyDeviceToDevice);
	cudaMemcpyAsync(d_img1Write, d_img1, size, cudaMemcpyDeviceToDevice);
	cudaMemcpyAsync(d_img2Write, d_img2, size, cudaMemcpyDeviceToDevice);



	//required variables to compute the distance
	int h_finished = false, t = true;
	int distance = -1;

	//where the magic happens
	while (!h_finished){
		//reset the bool variable that verifies if the processing ended
		cudaMemcpyToSymbol(finished, &t, sizeof(h_finished));


		//lauching the verify kernel, which verifies if the processing finished
		dilate << < blocksPerGrid, threadsPerBlock >> >(d_img1, d_img2, d_img1Read, d_img2Read, d_img1Write, d_img2Write);

		//cudaDeviceSynchronize();

		//updating the imgRead (cloning imgWrite to imgRead)
		cudaMemcpy(d_img1Read, d_img1Write, size, cudaMemcpyDeviceToDevice);
		cudaMemcpy(d_img2Read, d_img2Write, size, cudaMemcpyDeviceToDevice);

		

		//copying the result back to host memory
		cudaMemcpyFromSymbol(&h_finished, finished, sizeof(h_finished));


		//incrementing the distance at each iteration
		distance++;
	}


	//freeing memory
	cudaFree(d_img1); cudaFree(d_img2);
	cudaFree(d_img1Write); cudaFree(d_img1Read);
	cudaFree(d_img2Write); cudaFree(d_img2Read);

	//resetting device
	cudaDeviceReset();

	print(cudaGetLastError(), "processing CUDA. Something may be wrong with your CUDA device.");

	return distance;

}

inline void HausdorffDistance::print(cudaError_t error, char* msg){
	if (error != cudaSuccess)
	{
		printf("Error on %s ", msg);
		fprintf(stderr, "Error code: %s!\n", cudaGetErrorString(error));
		exit(EXIT_FAILURE);
	}
}
