#include <iostream>
#include <Image.h>
#include <chrono>
#include<stdlib.h>

#include<HausdorffDistance.cuh>

/*
This code was made by Érick Oliveira Rodrigues
Please check the HausdorffDistance.cuh file and change the top constants if desired
This code was compiled and built with CUDA 7.5 toolkit and Visual Studio 2013 on Windows, they are recommended 
(but not strictly necessary) to run the code
*/


int main(int argc, char** argv)
{

	//printf("Device %d \n", *argv[1] - '0');
	//cudaSetDevice(*argv[1] - '0');
	
	const int WIDTH = atoi(argv[1]), HEIGHT = WIDTH, DEPTH = 1;
	Volume img1 = Volume(WIDTH, HEIGHT, DEPTH), img2 = Volume(WIDTH, HEIGHT, DEPTH);
	/*
	srand(time(NULL));

	for (int i = 0; i < HEIGHT; i++){
		for (int j = 0; j < WIDTH; j++){
			img1.setPixelValue(true, j, i);
			if (rand() % 7 == 0) img2.setPixelValue(true, j, i);
		}
	}*/
	
	
	//for (int k = 0; k < 1; k++){
	String dir = "../Dataset/";
	dir += (argv[1]);
	dir += "/";


	Image img1I = Image(dir + "a.png"),
		img2I = Image(dir + "b.png");

		
	bool* img1B = img1I.getBooleanLinearImage(0);
	bool* img2B = img2I.getBooleanLinearImage(0);

	for (int i = 0; i < HEIGHT; i++){
		for (int j = 0; j < WIDTH; j++){
			img1.setPixelValue(img1B[i*WIDTH + j], j, i);
			img2.setPixelValue(img2B[i*WIDTH + j], j, i);
		}
	}
		
				
	//}

	
	//Volume img1 = Volume(256, 256, 1), img2 = Volume(256,256, 1);

	/*
	for (int i = 0; i < 100; i++){
		for (int j = 0; j < 100; j++){
			img1.setVoxelValue(1, j, i, 0);
			img2.setVoxelValue(1, j, i, 0);
		}
	}*/

	//img1.setVoxelValue(1, 0, 0, 0);
	//img2.setVoxelValue(1, 34, 9, 0);
	/*
	for (int i = 0; i < HEIGHT; i++){
		for (int j = 0; j < WIDTH; j++){
			for (int z = 0; z < DEPTH; z++){
				img1.setVoxelValue(1, j, i, z);
				if (j == i && i == z) img2.setVoxelValue(1, j, i, z);
			}
		}
	}*/

	auto begin = std::chrono::high_resolution_clock::now();

	//img1.setVoxelValue(1, 0, 0, 0);
	//img2.setVoxelValue(1, 255, 0, 0);

	HausdorffDistance *hd = new HausdorffDistance();
	int dist = (*hd).computeDistance(&img1, &img2);
	


	auto end = std::chrono::high_resolution_clock::now();

	std::cout << "Total elapsed time: ";
	std::cout << (double)(::chrono::duration_cast<std::chrono::nanoseconds>(end - begin).count()/(double)1000000000) << "s" << std::endl;

	printf("HD: %d \n", dist);

	//freeing memory
	img1.dispose(); img2.dispose();

	system("pause");
	return 0;
}










void printCudaSpecs(){
	const int kb = 1024;
	const int mb = kb * kb;
	wcout << "NBody.GPU" << endl << "=========" << endl << endl;

	wcout << "CUDA version:   v" << CUDART_VERSION << endl;
	int devCount;
	cudaGetDeviceCount(&devCount);
	wcout << "CUDA Devices: " << endl << endl;

	for (int i = 0; i < devCount; ++i)
	{
		cudaDeviceProp props;
		cudaGetDeviceProperties(&props, i);
		wcout << i << ": " << props.name << ": " << props.major << "." << props.minor << endl;
		wcout << "  Global memory:   " << props.totalGlobalMem / mb << "mb" << endl;
		wcout << "  Shared memory:   " << props.sharedMemPerBlock / kb << "kb" << endl;
		wcout << "  Constant memory: " << props.totalConstMem / kb << "kb" << endl;
		wcout << "  Block registers: " << props.regsPerBlock << endl;
		wcout << "  Multiprocessors: " << props.multiProcessorCount << endl << endl;


		wcout << "  Warp size:         " << props.warpSize << endl;
		wcout << "  Threads per block: " << props.maxThreadsPerBlock << endl;
		wcout << "  Max block dimensions: [ " << props.maxThreadsDim[0] << ", " << props.maxThreadsDim[1] << ", " << props.maxThreadsDim[2] << " ]" << endl;
		wcout << "  Max grid dimensions:  [ " << props.maxGridSize[0] << ", " << props.maxGridSize[1] << ", " << props.maxGridSize[2] << " ]" << endl;
		wcout << endl;
	}
}

/*
CImg<unsigned char> src("test.bmp");
int width = src.width();
int height = src.height();
src(0, 0, 0, 0) = 100;
cout << width << "x" << height << endl;
for (int r = 0; r < height; r++)
for (int c = 0; c < width; c++)
cout << "(" << r << "," << c << ") ="
<< " R" << (int)src(c, r, 0, 0)
<< " G" << (int)src(c, r, 0, 1)
<< " B" << (int)src(c, r, 0, 2) << endl;

src.normalize(0, 255);
src.save("img2.bmp");
return 0;
*/
