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
/*
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
*/


__device__ int g_mutex = 0;

__device__ void blockSync2(int goalVal){
	//int tId = threadIdx.x;
	//if (tId == 0){
		atomicAdd(&g_mutex, 1);

		while (g_mutex != goalVal){
			//printf("gmuted: %d", g_mutex);
			//__syncthreads();
		}
	//}
	__syncthreads();
}
__device__ int g_mutex2 = 0;
__device__ void blockSync3(int goalVal){
	//int tId = threadIdx.x;
	//if (tId == 0){
		atomicAdd(&g_mutex2, 1);

		while (g_mutex2 != goalVal){
			//printf("gmuted: %d", g_mutex);
			//__syncthreads();
		}
	//}
	__syncthreads();
}

//NÃO TAVA PEGANDO COMO RELEASE

__device__ static int grownEnough = false;
__device__ static int growReset = true;
//__device__ static int grownEnough = true;
__global__ void
hausdorffDistanceGPUSync(const bool *img1, const bool *img2,bool *img1P, bool *img2P, bool *img1PAux, bool *img2PAux,
const int WIDTH, const int HEIGHT, const int TILE_SIZE, const bool* structElement, const int STRUCT_SIZE, int *d_distance)
{
	extern __shared__ int imgsBuffer[];
	//if (threadIdx.x == 0) imgsBuffer[0] = 0;
	//bool* img1Buffer = &imgsBuffer[0];
	//bool* img2Buffer = &imgsBuffer[WIDTH*2+2];
	//__shared__ long bla[10000]; //enchendo a memoria
	const int id = blockDim.x * blockIdx.x + threadIdx.x;

	//__shared__ int grownEnoughBlock = true;
	//if (threadIdx.x == 0) grownEnoughBlock = 1;
	//__syncthreads();

	/*
	if (threadIdx.x == 0){
	img1b[]
	}*/
	/*
	//populate buffer
	for (int k = 0; k < TILE_SIZE; k++){//for tilesize
		currentId = id*TILE_SIZE + k;
		img1Buffer[k] = img1P[currentId];
		img2Buffer[k] = img2P[currentId];
	}*/

	int dist = 0, currentId = 0;
	while (!grownEnough || dist == 0 || g_mutex != blockDim.x*gridDim.x /*esse ultimo foi extremamente necessario*/){
		//printf("bla \n");
		//if (id == 0) printf(".");
		//reset grownEnough
		if (id == 0) atomicOr(&grownEnough, true);
		//updating imgP
		/*
		for (int k = 0; k < TILE_SIZE; k++){//for tilesize
			currentId = id*TILE_SIZE + k;
			img1P[currentId] = img1Buffer[k];
			img2P[currentId] = img2Buffer[k];
		}*/
		g_mutex = 0;
		blockSync3(blockDim.x*gridDim.x);
		//printf("%d", TILE_SIZE);
		for (int k = 0; k < TILE_SIZE; k++){//for tilesize
			currentId = id*TILE_SIZE + k;

			if (currentId < WIDTH*HEIGHT){
				//printf("[currentId: %d, img1: %d, img2: %d] ", currentId, img1P[currentId], img2P[currentId]);

				if (img1PAux[currentId]){
					if (currentId + 1 < WIDTH*HEIGHT) img1P[currentId + 1] = true;
					if (currentId - 1 >= 0) img1P[currentId - 1] = true;
					if (currentId + WIDTH < WIDTH*HEIGHT)img1P[currentId + WIDTH] = true;
					if (currentId - WIDTH >= 0) img1P[currentId - WIDTH] = true;
					//diagonais
					if (currentId - WIDTH + 1 >= 0) img1P[currentId - WIDTH + 1] = true;
					if (currentId - WIDTH - 1 >= 0) img1P[currentId - WIDTH - 1] = true;
					if (currentId + WIDTH + 1 < WIDTH*HEIGHT) img1P[currentId + WIDTH + 1] = true;
					if (currentId + WIDTH - 1 < WIDTH*HEIGHT) img1P[currentId + WIDTH - 1] = true;
				}
				if (img2PAux[currentId]){
					if (currentId + 1 < WIDTH*HEIGHT) img2P[currentId + 1] = true;
					if (currentId - 1 >= 0) img2P[currentId - 1] = true;
					if (currentId + WIDTH < WIDTH*HEIGHT) img2P[currentId + WIDTH] = true;
					if (currentId - WIDTH >= 0) img2P[currentId - WIDTH] = true;
					//diagonais
					if (currentId - WIDTH + 1 >= 0) img2P[currentId - WIDTH + 1] = true;
					if (currentId - WIDTH - 1 >= 0) img2P[currentId - WIDTH - 1] = true;
					if (currentId + WIDTH + 1 < WIDTH*HEIGHT) img2P[currentId + WIDTH + 1] = true;
					if (currentId + WIDTH - 1 < WIDTH*HEIGHT) img2P[currentId + WIDTH - 1] = true;
				}
				//hasGrownEnough(currentId, img1, img2, img1P, img2P, WIDTH, HEIGHT, &grownEnoughBlock);
				//__syncthreads();
				//if (threadcurrentIdx.x == 0)
				atomicAnd(&grownEnough, (img2PAux[currentId] || !img1[currentId]) && (img1PAux[currentId] || !img2[currentId]));
				//grownEnough &= (img2P[currentId] || !img1[currentId]) && (img1P[currentId] || !img2[currentId]);
				//if (currentId == 0) finished = &grownEnough;
				//if (currentId == 0) printf("\n finished %d", *grownEnough);
			}
		}
		dist++;
		//blockSync(blockDim.x*dist, arrayIn, arrayOut);
		if (id == 0) atomicOr(&growReset, true);
		g_mutex2 = 0;
		blockSync2(blockDim.x*gridDim.x);
		//COPIAR DA SHARED PRA IMG1P e IMG2p
		for (int k = 0; k < TILE_SIZE; k++){//for tilesize
			currentId = id*TILE_SIZE + k;
			if (currentId < WIDTH*HEIGHT){
				img1PAux[currentId] = img1P[currentId];
				img2PAux[currentId] = img2P[currentId];
			}
			//atomicOr(&img1PAux[currentId], img1P[currentId]);
			//atomicOr(&img2PAux[currentId], img2P[currentId]);
		}
		//__threadfence();
		//if (id == 0) printf(".");
	}
	//if (id == 0) printf("terminou %d\n", dist);
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
	int TILE_SIZE = (WIDTH*HEIGHT + threadsPerBlock*blocksPerGrid - 1) / (threadsPerBlock*blocksPerGrid);

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
	err = cudaMalloc((void **)&d_img1P, size);

	if (err != cudaSuccess)
	{
		fprintf(stderr, "Failed to allocate device vector d_img1P (error code %s)!\n", cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}

	// Allocate the device input vector img2P
	bool *d_img2P = NULL;
	err = cudaMalloc((void **)&d_img2P, size);

	if (err != cudaSuccess)
	{
		fprintf(stderr, "Failed to allocate device vector d_img2P (error code %s)!\n", cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}

	// Allocate the device input vector img2P
	bool *d_img1PAux = NULL;
	err = cudaMalloc((void **)&d_img1PAux, size);

	if (err != cudaSuccess)
	{
		fprintf(stderr, "Failed to allocate device vector d_img1PAux (error code %s)!\n", cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}

	// Allocate the device input vector img2P
	bool *d_img2PAux = NULL;
	err = cudaMalloc((void **)&d_img2PAux, size);

	if (err != cudaSuccess)
	{
		fprintf(stderr, "Failed to allocate device vector d_img2PAux (error code %s)!\n", cudaGetErrorString(err));
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

	err = cudaMemcpy(d_img1P, d_img1, size, cudaMemcpyDeviceToDevice);

	if (err != cudaSuccess)
	{
		fprintf(stderr, "Failed to copy vector img1P from host to device (error code %s)!\n", cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}

	err = cudaMemcpy(d_img2P, d_img2, size, cudaMemcpyDeviceToDevice);

	if (err != cudaSuccess)
	{
		fprintf(stderr, "Failed to copy vector img2P from host to device (error code %s)!\n", cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}

	err = cudaMemcpy(d_img1PAux, d_img1, size, cudaMemcpyDeviceToDevice);

	if (err != cudaSuccess)
	{
		fprintf(stderr, "Failed to copy vector img1PAux from host to device (error code %s)!\n", cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}

	err = cudaMemcpy(d_img2PAux, d_img2, size, cudaMemcpyDeviceToDevice);

	if (err != cudaSuccess)
	{
		fprintf(stderr, "Failed to copy vector img2PAux from host to device (error code %s)!\n", cudaGetErrorString(err));
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
	hausdorffDistanceGPUSync << <blocksPerGrid, threadsPerBlock, 12288*sizeof(int) >> >
		(d_img1, d_img2, d_img1P, d_img2P, d_img1PAux, d_img2PAux, WIDTH, HEIGHT, TILE_SIZE, d_structElement, STRUCT_SIZE, d_distance);
	cudaDeviceSynchronize();
	err = cudaGetLastError();
	if (err != cudaSuccess)
	{
		fprintf(stderr, "Failed to launch hausdorffDistance kernel (error code %s)!\n", cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}

	err = cudaMemcpy(&distance, d_distance, sizeof(int), cudaMemcpyDeviceToHost);
	if (err != cudaSuccess)
	{
		fprintf(stderr, "Failed to copy vector d_distance from device to host (error code %s)!\n", cudaGetErrorString(err));
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


	err = cudaFree(d_img1PAux);

	if (err != cudaSuccess)
	{
		fprintf(stderr, "Failed to free device img1PAux (error code %s)!\n", cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}

	err = cudaFree(d_img2PAux);

	if (err != cudaSuccess)
	{
		fprintf(stderr, "Failed to free device img2PAux (error code %s)!\n", cudaGetErrorString(err));
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




