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
typedef Volume::voxelStr voxelStrt;




__global__ void directedDistance(const voxelStrt *img1, const voxelStrt *img2, int *cMax, const int numVoxels1, const int numVoxels2){
	const int id = blockDim.x * blockIdx.x + threadIdx.x;
	
	
	//__shared__ int cmax;
	//if (threadIdx.x == 0) cmax = 0;
	//__syncthreads();

	int dist, cmin = 999999999;


	if (id < numVoxels1){

		const int x = img1[id].x, y = img1[id].y, z = img1[id].z;

		//computing the min distance
		for (int k = 0; k < numVoxels2; k++){
			//sup metric
			dist = abs(img2[k].x - x);
			dist = abs(img2[k].y - y) > dist ? abs(img2[k].y - y) : dist;
			dist = abs(img2[k].z - z) > dist ? abs(img2[k].z - z) : dist;
			//early break
			if (dist < (*cMax)) return; //early break
			//else, update
			cmin = (cmin > dist) ? dist : cmin;

		}
		atomicMax(cMax, cmin);
		//atomicMax(&cmax, cmin);
	}

	//__syncthreads();

	//if (threadIdx.x == 0){
	//	atomicMax(cMax, cmax);
	//}
	
}


int HausdorffDistance::computeDistance(Volume *img1, Volume *img2, Volume *img1D2, Volume *img2D2){

	//const int height = (*img1).getHeight(), width = (*img1).getWidth(), depth = (*img1).getDepth();

	size_t size1 = (*img1).getNumOfVoxels()*sizeof(voxelStrt), size2 = (*img2).getNumOfVoxels()*sizeof(voxelStrt),
		size1D2 = (*img1D2).getNumOfVoxels()*sizeof(voxelStrt), size2D2 = (*img2D2).getNumOfVoxels()*sizeof(voxelStrt);

	//getting details of your CUDA device
	cudaDeviceProp props;
	cudaGetDeviceProperties(&props, CUDA_DEVICE_INDEX); //change to the proper index of your cuda device
	const int threadsPerBlock = props.maxThreadsPerBlock/2;
	int blocksPerGrid = ((*img1).getNumOfVoxels() + threadsPerBlock - 1) / threadsPerBlock;

	

	//allocating the input data in the GPU
	voxelStrt *d_img1, *d_img2;
	cudaMalloc(&d_img1, size1);
	cudaMalloc(&d_img2, size2);
	int *d_cMax;
	cudaMalloc(&d_cMax, sizeof(int));


	//copying the data to the allocated memory on the GPU
	cudaMemcpy(d_img1, (*img1).getVolume(), size1, cudaMemcpyHostToDevice);
	cudaMemcpy(d_img2, (*img2).getVolume(), size2, cudaMemcpyHostToDevice);

	//resetting cMax
	int t = 0;
	//cudaMemcpyToSymbol(cMax, &t, sizeof(t));
	cudaMemcpy(d_cMax, &t, sizeof(int), cudaMemcpyHostToDevice);

	//print(cudaGetLastError(), "b1");

	//computing h(A,B)
	directedDistance << < blocksPerGrid, threadsPerBlock >> >(d_img1, d_img2, d_cMax, (*img1).getNumOfVoxels(), (*img2).getNumOfVoxels());

	//copying the data to the allocated memory on the GPU to compute the other directed distance
	cudaDeviceSynchronize();
	cudaFree(d_img1); cudaFree(d_img2);
	cudaMalloc(&d_img1, size1D2);
	cudaMalloc(&d_img2, size2D2);
	cudaMemcpy(d_img1, (*img1D2).getVolume(), size1D2, cudaMemcpyHostToDevice);
	cudaMemcpy(d_img2, (*img2D2).getVolume(), size2D2, cudaMemcpyHostToDevice);

	//cudaDeviceSynchronize();
	//print(cudaGetLastError(), "b2");

	//resetting the variable
	blocksPerGrid = ((*img2).getNumOfVoxels() + threadsPerBlock - 1) / threadsPerBlock;

	//computing h(B,A)
	directedDistance << < blocksPerGrid, threadsPerBlock >> >(d_img2, d_img1, d_cMax, (*img2D2).getNumOfVoxels(), (*img1D2).getNumOfVoxels());
	
	cudaDeviceSynchronize();
	//print(cudaGetLastError(), "b3");

	//copying the result back
	int distance;
	//cudaMemcpyFromSymbol(&distance, cMax, sizeof(int));
	cudaMemcpy(&distance, d_cMax, sizeof(int), cudaMemcpyDeviceToHost);

	//print(cudaGetLastError(), "b4");
	
	//freeing memory
	cudaFree(d_img1); cudaFree(d_img2);
	cudaFree(d_cMax);

	
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
