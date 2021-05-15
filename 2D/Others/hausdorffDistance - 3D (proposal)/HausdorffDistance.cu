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


//global variable that indicates when to stop processing
__device__ uint finished;

//constant variables that contain the size of the volume
__constant__ __device__ int WIDTH, HEIGHT, DEPTH;

//3d texture declaration
texture<uchar, cudaTextureType3D, cudaReadModeElementType> img1Tex, img2Tex;
//3d surface declaration
surface<void, 3> img1Surf, img2Surf;




__global__ void dilate(){

	const int x = blockIdx.x * blockDim.x + threadIdx.x;
	const int y = blockIdx.y * blockDim.y + threadIdx.y;
	const int z = blockIdx.z * blockDim.z + threadIdx.z;

	if (x < WIDTH && y < HEIGHT && z < DEPTH){

		const uchar p1 = tex3D(img1Tex, x + 0.5f, y + 0.5f, z + 0.5f), p2 = tex3D(img2Tex, x + 0.5f, y + 0.5f, z + 0.5f);

		if (p1 != 1){

			uchar res = tex3D(img1Tex, x - 1 + 0.5f, y + 0.5f, z + 0.5f) |
				tex3D(img1Tex, x + 1 + 0.5f, y + 0.5f, z + 0.5f) |
				tex3D(img1Tex, x + 0.5f, y - 1 + 0.5f, z + 0.5f) |
				tex3D(img1Tex, x + 0.5f, y + 1 + 0.5f, z + 0.5f);
			#if IS_3D
			res |= text3D(img1Tex, x + 0.5f, y + 0.5f, z + 1 + 0.5f) |
				text3D(img1Tex, x + 0.5f, y + 0.5f, z - 1 + 0.5f);
			#endif
			#if CHEBYSHEV
			res |= tex3D(img1Tex, x + 1 + 0.5f, y + 1 + 0.5f, z + 0.5f) |
				tex3D(img1Tex, x - 1 + 0.5f, y + 1 + 0.5f, z + 0.5f) |
				tex3D(img1Tex, x + 1 + 0.5f, y - 1 + 0.5f, z + 0.5f) |
				tex3D(img1Tex, x - 1 + 0.5f, y - 1 + 0.5f, z + 0.5f);
			#if IS_3D
			res |= tex3D(img1Tex, x + 1 + 0.5f, y + 1 + 0.5f, z + 1 +0.5f) |
				tex3D(img1Tex, x - 1 + 0.5f, y + 1 + 0.5f, z + 1 + 0.5f) |
				tex3D(img1Tex, x + 1 + 0.5f, y - 1 + 0.5f, z + 1 + 0.5f) |
				tex3D(img1Tex, x - 1 + 0.5f, y - 1 + 0.5f, z + 1 + 0.5f) |
				tex3D(img1Tex, x + 1 + 0.5f, y + 1 + 0.5f, z - 1 + 0.5f) |
				tex3D(img1Tex, x - 1 + 0.5f, y + 1 + 0.5f, z - 1 + 0.5f) |
				tex3D(img1Tex, x + 1 + 0.5f, y - 1 + 0.5f, z - 1 + 0.5f) |
				tex3D(img1Tex, x - 1 + 0.5f, y - 1 + 0.5f, z - 1 + 0.5f);
			#endif
			#endif
			res = (res > 0) ? 2 : 0;

			surf3Dwrite(res, img1Surf, x * sizeof(uchar), y, z);
		}

		if (p2 != 1){
			uchar res2 = tex3D(img2Tex, x - 1 + 0.5f, y + 0.5f, z + 0.5f) |
				tex3D(img2Tex, x + 1 + 0.5f, y + 0.5f, z + 0.5f) |
				tex3D(img2Tex, x + 0.5f, y - 1 + 0.5f, z + 0.5f) |
				tex3D(img2Tex, x + 0.5f, y + 1 + 0.5f, z + 0.5f);
			#if IS_3D
			res2 |= text3D(img2Tex, x + 0.5f, y + 0.5f, z + 1 + 0.5f) |
				text3D(img2Tex, x + 0.5f, y + 0.5f, z - 1 + 0.5f);
			#endif
			#if CHEBYSHEV
			res2 |= tex3D(img2Tex, x + 1 + 0.5f, y + 1 + 0.5f, z + 0.5f) |
				tex3D(img2Tex, x - 1 + 0.5f, y + 1 + 0.5f, z + 0.5f) |
				tex3D(img2Tex, x + 1 + 0.5f, y - 1 + 0.5f, z + 0.5f) |
				tex3D(img2Tex, x - 1 + 0.5f, y - 1 + 0.5f, z + 0.5f);
			#if IS_3D
			res2 |= tex3D(img2Tex, x + 1 + 0.5f, y + 1 + 0.5f, z + 1 + 0.5f) |
				tex3D(img2Tex, x - 1 + 0.5f, y + 1 + 0.5f, z + 1 + 0.5f) |
				tex3D(img2Tex, x + 1 + 0.5f, y - 1 + 0.5f, z + 1 + 0.5f) |
				tex3D(img2Tex, x - 1 + 0.5f, y - 1 + 0.5f, z + 1 + 0.5f) |
				tex3D(img2Tex, x + 1 + 0.5f, y + 1 + 0.5f, z - 1 + 0.5f) |
				tex3D(img2Tex, x - 1 + 0.5f, y + 1 + 0.5f, z - 1 + 0.5f) |
				tex3D(img2Tex, x + 1 + 0.5f, y - 1 + 0.5f, z - 1 + 0.5f) |
				tex3D(img2Tex, x - 1 + 0.5f, y - 1 + 0.5f, z - 1 + 0.5f);
			#endif
			#endif
			res2 = (res2 > 0) ? 2 : 0;
			surf3Dwrite(res2, img2Surf, x * sizeof(uchar), y, z);
		}


		atomicAnd(&finished, (p2 > 0 && p1 > 0) || (p2 != 1 && p1 != 1));

	}

}


int HausdorffDistance::computeDistance(Volume *img1, Volume *img2){

	const uint height = (*img1).getHeight(), width = (*img1).getWidth(), depth = (*img1).getDepth();

	cudaArray *d_img1Array = 0, *d_img2Array = 0;
	const cudaExtent volumeSize = make_cudaExtent(width, height, depth);

	//copying the dimensions to the GPU
	cudaMemcpyToSymbolAsync(WIDTH, &width, sizeof(width));
	cudaMemcpyToSymbolAsync(HEIGHT, &height, sizeof(height));
	cudaMemcpyToSymbolAsync(DEPTH, &depth, sizeof(depth));

	// create 3D arrays
	cudaChannelFormatDesc channelDesc = cudaCreateChannelDesc<uchar>();
	//cudaChannelFormatDesc channelDesc = cudaCreateChannelDesc(8, 0, 0, 0, cudaChannelFormatKindUnsigned);
	cudaMalloc3DArray(&d_img1Array, &channelDesc, volumeSize);
	cudaMalloc3DArray(&d_img2Array, &channelDesc, volumeSize);

	cudaArray *d_img1SurfArray = 0, *d_img2SurfArray = 0;
	cudaMalloc3DArray(&d_img1SurfArray, &channelDesc, volumeSize, cudaArraySurfaceLoadStore);
	cudaMalloc3DArray(&d_img2SurfArray, &channelDesc, volumeSize, cudaArraySurfaceLoadStore);

	// copy data to 3D array
	cudaMemcpy3DParms copyParams = { 0 };
	copyParams.srcPtr = make_cudaPitchedPtr((void *)(*img1).getVolume(), volumeSize.width*sizeof(uchar), volumeSize.width, volumeSize.height);
	copyParams.extent = volumeSize;
	copyParams.kind = cudaMemcpyHostToDevice;
	copyParams.dstArray = d_img1Array;
	print(cudaMemcpy3D(&copyParams), "copying for img1 (texture).");
	//img2
	copyParams.srcPtr = make_cudaPitchedPtr((void *)(*img2).getVolume(), volumeSize.width*sizeof(uchar), volumeSize.width, volumeSize.height);
	copyParams.dstArray = d_img2Array;
	print(cudaMemcpy3D(&copyParams), "copying for img2 (texture).");


	//Copy data to 3D surfaces
	copyParams = { 0 };
	copyParams.extent = volumeSize;
	copyParams.kind = cudaMemcpyDeviceToDevice;
	copyParams.dstArray = d_img1SurfArray;
	copyParams.srcArray = d_img1Array;
	print(cudaMemcpy3D(&copyParams), "copying for surface1.");
	//img2
	//copyParams = { 0 };
	//copyParams.extent = volumeSize;
	//copyParams.kind = cudaMemcpyDeviceToDevice;
	copyParams.dstArray = d_img2SurfArray;
	copyParams.srcArray = d_img2Array;
	print(cudaMemcpy3D(&copyParams), "copying for surface2.");



	// set texture parameters
	img1Tex.normalized = false;                      // access with normalized texture coordinates
	//img1.filterMode = cudaFilterModeLinear;      // linear interpolation
	img1Tex.addressMode[0] = cudaAddressModeBorder;   // wrap texture coordinates
	img1Tex.addressMode[1] = cudaAddressModeBorder;
	img1Tex.addressMode[2] = cudaAddressModeBorder;
	//img2
	img2Tex.normalized = false;                      // access with normalized texture coordinates
	//img1.filterMode = cudaFilterModeLinear;      // linear interpolation
	img2Tex.addressMode[0] = cudaAddressModeBorder;   // wrap texture coordinates
	img2Tex.addressMode[1] = cudaAddressModeBorder;
	img2Tex.addressMode[2] = cudaAddressModeBorder;


	// bind array to 3D texture
	print(cudaBindTextureToArray(img1Tex, d_img1Array, channelDesc), "binding texture to array 1.");
	print(cudaBindTextureToArray(img2Tex, d_img2Array, channelDesc), "binding texture to array 2.");
	//bind array to 3D surface
	print(cudaBindSurfaceToArray(img1Surf, d_img1SurfArray, channelDesc), "binding surface to array 1.");
	print(cudaBindSurfaceToArray(img2Surf, d_img2SurfArray, channelDesc), "binding surface to array 2.");



	// launching kernel
	const int tSize = 8; //otimizar o tam automaticamente dps
	const dim3 threadsPerBlock(tSize, tSize, (*img1).getDepth() == 1 ? 1 : tSize);
	const dim3 blocksPerGrid((int)(width + threadsPerBlock.x - 1) / threadsPerBlock.x,
		(int)(height + threadsPerBlock.y - 1) / threadsPerBlock.y,
		(int)(depth + threadsPerBlock.z - 1) / threadsPerBlock.z);

	int distance = -1;
	uint loopEnded = false;
	const uint t = 1;
	//cudaMalloc(&finished, sizeof(uint));
	while (!loopEnded){

		cudaMemcpyToSymbolAsync(finished, &t, sizeof(uint), 0, cudaMemcpyHostToDevice);

		dilate << <blocksPerGrid, threadsPerBlock >> >();
		
		copyParams = { 0 };
		copyParams.extent = volumeSize;
		copyParams.kind = cudaMemcpyDeviceToDevice;
		copyParams.srcArray = d_img1SurfArray;
		copyParams.dstArray = d_img1Array;
		cudaMemcpy3D(&copyParams);

		//copyParams = { 0 };
		//copyParams.extent = volumeSize;
		//copyParams.kind = cudaMemcpyDeviceToDevice;
		copyParams.srcArray = d_img2SurfArray;
		copyParams.dstArray = d_img2Array;
		cudaMemcpy3D(&copyParams);

		cudaMemcpyFromSymbol(&loopEnded, finished, sizeof(uint), 0, cudaMemcpyDeviceToHost);

		distance++;

	}

	print(cudaGetLastError(), "kernel launch.");


	//free
	cudaFreeArray(d_img1Array);
	cudaFreeArray(d_img2Array);
	cudaFreeArray(d_img1SurfArray);
	cudaFreeArray(d_img2SurfArray);
	
	print(cudaDeviceReset(), "device reset.");

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
