#include <stdio.h>
#include <math.h>




// For the CUDA runtime routines (prefixed with "cuda_")
#include <cuda_runtime.h>
#include "cuda.h"
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

//to call from .cpp
#include "Hausdorff_common.h"


//BLOCK SYNC

__device__ volatile static int* arrayIn;
__device__ volatile static int* arrayOut;
__device__ void blockSync(int goalVal, volatile int *arrayIn, volatile int *arrayOut){
	//thread ID in a block
	int tId = threadIdx.x,
		bNum = gridDim.x,
		bId = blockIdx.x;

	//only thread 0 is used for synchronization
	if (tId == 0)
		arrayIn[bId] = goalVal;

	if (bId == 1){
		if (tId < bNum){
			while (arrayIn[tId] != goalVal){
				//
			}
		}

		__syncthreads();
		if (tId < bNum){
			arrayOut[tId] = goalVal;
		}
	}

	if (tId == 0){
		while (arrayOut[bId] != goalVal){
			//
		}
	}
	__syncthreads();
}



__device__ volatile static int g_mutex = 0;

__device__ void blockSync2(int goalVal){
	int tId = threadIdx.x;
	if (tId == 0){
		atomicAdd((int *)&g_mutex, 1);

		while (g_mutex != goalVal){
			//printf("gmuted: %d", g_mutex);
		}
	}
	__syncthreads();
}
__device__ volatile static int g_mutex2 = 0;
__device__ void blockSync3(int goalVal){
	int tId = threadIdx.x;
	if (tId == 0){
		atomicAdd((int *)&g_mutex2, 1);

		while (g_mutex2 != goalVal){
			//printf("gmuted: %d", g_mutex);
		}
	}
	__syncthreads();
}

__device__ static int grownEnough = true;
__device__ static int growReset = true;
//__device__ static int grownEnough = true;
__global__ void
hausdorffDistanceGPUSync(const bool *img1, const bool *img2, volatile bool *img1P, volatile bool *img2P, 
const int WIDTH, const int HEIGHT, const bool* structElement, const char STRUCT_SIZE, int *d_distance)
{
	extern __shared__ int img2Buffer[];
	if (threadIdx.x == 0) img2Buffer[0] = 0;
	//__shared__ long bla[10000]; //enchendo a memoria
	const int id = blockDim.x * blockIdx.x + threadIdx.x;

	//__shared__ int grownEnoughBlock = true;
	//if (threadIdx.x == 0) grownEnoughBlock = 1;
	//__syncthreads();

	/*
	if (threadIdx.x == 0){
	img1b[]
	}*/
	int dist = 0;
	while (!grownEnough || dist == 0){
		printf("bla \n");
		/*
		if (g_mutex == (gridDim.x)) {
			g_mutex = 0; //resetting
			grownEnough = true;
			__syncthreads();
		}*/
		//grownEnough = true;
		//printf("teste: %d, %d", g_mutex, gridDim.x*dist);
		/*
		if (growReset && threadIdx.x == 0) {//devia ser sync de bloco
			atomicOr(&grownEnough, true);
			atomicAnd(&growReset, false);
		}
		__syncthreads();*/
		if (id == 0) atomicOr(&grownEnough, true);
		blockSync3(gridDim.x*(dist+1));
		if (id < WIDTH*HEIGHT){
			//printf("[id: %d, img1: %d, img2: %d] ", id, img1P[id], img2P[id]);

			if (img1P[id]){
				if (id + 1 < WIDTH*HEIGHT) img1P[id + 1] = true;
				if (id - 1 >= 0) img1P[id - 1] = true;
				if (id + WIDTH < WIDTH*HEIGHT)img1P[id + WIDTH] = true;
				if (id - WIDTH >= 0) img1P[id - WIDTH] = true;
				//diagonais
				if (id - WIDTH + 1 >= 0) img1P[id - WIDTH + 1] = true;
				if (id - WIDTH - 1 >= 0) img1P[id - WIDTH - 1] = true;
				if (id + WIDTH + 1 < WIDTH*HEIGHT) img1P[id + WIDTH + 1] = true;
				if (id + WIDTH - 1 < WIDTH*HEIGHT) img1P[id + WIDTH - 1] = true;
			}
			if (img2P[id]){
				if (id + 1 < WIDTH*HEIGHT) img2P[id + 1] = true;
				if (id - 1 >= 0) img2P[id - 1] = true;
				if (id + WIDTH < WIDTH*HEIGHT) img2P[id + WIDTH] = true;
				if (id - WIDTH >= 0) img2P[id - WIDTH] = true;
				//diagonais
				if (id - WIDTH + 1 >= 0) img2P[id - WIDTH + 1] = true;
				if (id - WIDTH - 1 >= 0) img2P[id - WIDTH - 1] = true;
				if (id + WIDTH + 1 < WIDTH*HEIGHT) img2P[id + WIDTH + 1] = true;
				if (id + WIDTH - 1 < WIDTH*HEIGHT) img2P[id + WIDTH - 1] = true;
			}

			/*
			//pixel index (linear)
			int pIndex;
			//divergencia de dados - precisa de sincronização
			for (char dY = -1; dY <= 1; dY++){
			for (char dX = -1; dX <= 1; dX++){
			if (dX == 0 || dY == 0) continue;
			for (char i = 0; i <= STRUCT_SIZE; i++){//structuring element
			for (char j = 0; j <= STRUCT_SIZE; j++){
			//if (id == 0)printf("\n bla0 %d, %d\n", (STRUCT_SIZE + 1)*i + j, structElement[(STRUCT_SIZE + 1)*i + j]);
			if (!structElement[(STRUCT_SIZE+1)*i + j]) continue;
			//if (id==0)printf("\n bla i:%d, j:%d, dX:%d, dY:%d \n", i*dX, j*dY, dX, dY);

			pIndex = id + (j*dX) + WIDTH*(i*dY);
			//if (id==0)printf("[he: %d \n", pIndex);
			if (img1[id]){//if there is a pixel in img1, dilate
			if (pIndex >= 0 && pIndex < WIDTH*HEIGHT){//boundaries
			img1P[pIndex] = true;
			}
			}
			if (img2[id]){//if there is a pixel in img2, dilate
			if (pIndex >= 0 && pIndex < WIDTH*HEIGHT){//boundaries
			img2P[pIndex] = true;
			}
			}
			}
			}
			}
			}
			*/
			//printf("[id: %d, img1: %d, img2: %d] ", id, img1P[id], img2P[id]);
			//hasGrownEnough(id, img1, img2, img1P, img2P, WIDTH, HEIGHT, &grownEnoughBlock);
			//__syncthreads();
			//if (threadIdx.x == 0)
			atomicAnd(&grownEnough, (img2P[id] || !img1[id]) && (img1P[id] || !img2[id]));
			//grownEnough &= (img2P[id] || !img1[id]) && (img1P[id] || !img2[id]);
			//if (id == 0) finished = &grownEnough;
			//if (id == 0) printf("\n finished %d", *grownEnough);
		}
		dist++;
		//blockSync(blockDim.x*dist, arrayIn, arrayOut);
		if (id == 0) atomicOr(&growReset, true);
		blockSync2(gridDim.x*dist);
		//
		if (id == 0) printf("dps do sync");
	}
	if (id == 0) printf("terminou %d\n", dist);
	*d_distance = dist;
}






/**
* Host main routine
*/


int
hdGPUSync(bool *img1, bool *img2, const int WIDTH, const int HEIGHT, bool *structElement, const int STRUCT_SIZE)
{
	// Error code to check return values for CUDA calls
	cudaError_t err = cudaSuccess;

	// Print the vector length to be used, and compute its size
	//int numElements = 50000;
	//size_t size = numElements * sizeof(float);
	printf("Processing images (width=%d, height=%d)...\n", WIDTH, HEIGHT);

	// Allocate the host input vector A
	//float *h_A = (float *)malloc(size);

	// Allocate the host input vector B
	//float *h_B = (float *)malloc(size);

	// Allocate the host output vector C
	//float *h_C = (float *)malloc(size);

	// Verify that allocations succeeded
	/*
	if (h_A == NULL || h_B == NULL || h_C == NULL)
	{
	fprintf(stderr, "Failed to allocate host vectors!\n");
	exit(EXIT_FAILURE);
	}

	// Initialize the host input vectors
	for (int i = 0; i < numElements; ++i)
	{
	h_A[i] = rand() / (float)RAND_MAX;
	h_B[i] = rand() / (float)RAND_MAX;
	}*/

	size_t size = WIDTH*HEIGHT*sizeof(bool);
	//short *h_distance = (short *)malloc(sizeof(short));

	//Kernel variables
	//int threadsPerBlock = 512;
	//int blocksPerGrid = (WIDTH*HEIGHT + threadsPerBlock - 1) / threadsPerBlock;
	int blocksPerGrid = 5;
	int threadsPerBlock = 1024;

	// Allocate the device input vector img1
	bool *d_img1 = NULL;
	err = cudaMalloc((void **)&d_img1, size);

	if (err != cudaSuccess)
	{
		fprintf(stderr, "Failed to allocate device vector d_img1 (error code %s)!\n", cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}

	// Allocate the device input vector img2
	bool *d_img2 = NULL;
	err = cudaMalloc((void **)&d_img2, size);

	if (err != cudaSuccess)
	{
		fprintf(stderr, "Failed to allocate device vector d_img2 (error code %s)!\n", cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}

	// Allocate the device input vector img1P
	bool *d_img1P = NULL;
	err = cudaMalloc((void **)&d_img1P, WIDTH*HEIGHT*sizeof(volatile bool));

	if (err != cudaSuccess)
	{
		fprintf(stderr, "Failed to allocate device vector d_img1P (error code %s)!\n", cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}

	// Allocate the device input vector img2P
	bool *d_img2P = NULL;
	err = cudaMalloc((void **)&d_img2P, WIDTH*HEIGHT*sizeof(volatile bool));

	if (err != cudaSuccess)
	{
		fprintf(stderr, "Failed to allocate device vector d_img2P (error code %s)!\n", cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}


	// Allocate the device structElement
	size_t STRUCT_SIZE_T = (STRUCT_SIZE + 1)*(STRUCT_SIZE + 1)*sizeof(bool);
	bool *d_structElement = NULL;
	err = cudaMalloc((void **)&d_structElement, STRUCT_SIZE_T);

	if (err != cudaSuccess)
	{
		fprintf(stderr, "Failed to allocate device vector d_structElement (error code %s)!\n", cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}




	// Allocate the device output grownEnough var
	int *d_distance = NULL;
	err = cudaMalloc((void **)&d_distance, sizeof(int));

	if (err != cudaSuccess)
	{
		fprintf(stderr, "Failed to allocate device d_distance (error code %s)!\n", cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}

	// Copy the host input vectors A and B in host memory to the device input vectors in
	// device memory
	printf("Copy input data from the host memory to the CUDA device\n");
	err = cudaMemcpy(d_img1, img1, size, cudaMemcpyHostToDevice);

	if (err != cudaSuccess)
	{
		fprintf(stderr, "Failed to copy vector img1 from host to device (error code %s)!\n", cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}

	err = cudaMemcpy(d_img2, img2, size, cudaMemcpyHostToDevice);

	if (err != cudaSuccess)
	{
		fprintf(stderr, "Failed to copy vector img2 from host to device (error code %s)!\n", cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}

	err = cudaMemcpy(d_img1P, img1, size, cudaMemcpyHostToDevice);

	if (err != cudaSuccess)
	{
		fprintf(stderr, "Failed to copy vector img1P from host to device (error code %s)!\n", cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}

	err = cudaMemcpy(d_img2P, img2, size, cudaMemcpyHostToDevice);

	if (err != cudaSuccess)
	{
		fprintf(stderr, "Failed to copy vector img2P from host to device (error code %s)!\n", cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}

	err = cudaMemcpy(d_structElement, structElement, STRUCT_SIZE_T, cudaMemcpyHostToDevice);

	if (err != cudaSuccess)
	{
		fprintf(stderr, "Failed to copy vector structElement from host to device (error code %s)!\n", cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}


	int distance = 0;

	err = cudaMemcpy(d_distance, &distance, sizeof(int), cudaMemcpyHostToDevice);
	if (err != cudaSuccess)
	{
		fprintf(stderr, "Failed to copy vector d_distance from host to device (error code %s)!\n", cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}

	//possivelmente device mem copy struct...
	printf("CUDA kernel launch with %d blocks of %d threads\n", blocksPerGrid, threadsPerBlock);
	hausdorffDistanceGPUSync << <blocksPerGrid, threadsPerBlock, 12288*sizeof(int)>> >
		(d_img1, d_img2, d_img1P, d_img2P, WIDTH, HEIGHT, d_structElement, STRUCT_SIZE, d_distance);
	err = cudaGetLastError();
	if (err != cudaSuccess)
	{
		fprintf(stderr, "Failed to launch hausdorffDistance kernel (error code %s)!\n", cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}

	err = cudaMemcpy(&distance, d_distance, sizeof(int), cudaMemcpyDeviceToHost);
	if (err != cudaSuccess)
	{
		fprintf(stderr, "Failed to copy vector d_distance from host to device (error code %s)!\n", cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}

	printf("Hausdorff distance: %d\n", distance);
	

	

	/*
	// Verify that the result vector is correct
	for (int i = 0; i < numElements; ++i)
	{
	if (fabs(h_A[i] + h_B[i] - h_C[i]) > 1e-5)
	{
	fprintf(stderr, "Result verification failed at element %d!\n", i);
	exit(EXIT_FAILURE);
	}
	}

	printf("Test PASSED\n");
	*/

	// Free device global memory
	err = cudaFree(d_img1);

	if (err != cudaSuccess)
	{
		fprintf(stderr, "Failed to free device vector img1 (error code %s)!\n", cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}

	err = cudaFree(d_img2);

	if (err != cudaSuccess)
	{
		fprintf(stderr, "Failed to free device vector img2 (error code %s)!\n", cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}

	err = cudaFree(d_img1P);

	if (err != cudaSuccess)
	{
		fprintf(stderr, "Failed to free device img1P (error code %s)!\n", cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}

	err = cudaFree(d_img2P);

	if (err != cudaSuccess)
	{
		fprintf(stderr, "Failed to free device img2P (error code %s)!\n", cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}




	err = cudaFree(d_structElement);

	if (err != cudaSuccess)
	{
		fprintf(stderr, "Failed to free d_structElement (error code %s)!\n", cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}

	err = cudaFree(d_distance);

	if (err != cudaSuccess)
	{
		fprintf(stderr, "Failed to free d_structElement (error code %s)!\n", cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}




	// Free host memory
	//free(h_distance);
	/*
	free(h_A);
	free(h_B);
	free(h_C);
	*/

	// Reset the device and exit
	// cudaDeviceReset causes the driver to clean up all state. While
	// not mandatory in normal operation, it is good practice.  It is also
	// needed to ensure correct operation when the application is being
	// profiled. Calling cudaDeviceReset causes all profile data to be
	// flushed before the application exits
	err = cudaDeviceReset();

	if (err != cudaSuccess)
	{
		fprintf(stderr, "Failed to deinitialize the device! error=%s\n", cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}

	printf("Done\n");
	return 0;
}




