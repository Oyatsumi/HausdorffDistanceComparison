#include <iostream>
#include <Image.h>
#include <Hausdorff_common.h>
#include <chrono>
#include<Volume.h>
#include<stdlib.h>
#include <string>
#include <vector>

using namespace cv;
using namespace std;

int main(int argc, char** argv)
{

	//printf("Device %d \n", *argv[1] - '0');
	//cudaSetDevice(*argv[1] - '0');
	
	printf("%s \n", argv[1]);
	
	String dir = "../Dataset/";
	dir += (argv[1]);
	dir += "/";

	Image img1I = Image(dir + "a.png"),
		img2I = Image(dir + "b.png");

		
	bool* img1 = img1I.getBooleanLinearImage(0);
	bool* img2 = img2I.getBooleanLinearImage(0);
	

	/*
	srand(time(NULL));
	const int WIDTH = 8192, HEIGHT = 8192;
	Volume img1 = Volume(WIDTH, HEIGHT, 1), img2 = Volume(WIDTH, HEIGHT, 1);
	for (int i = 0; i < HEIGHT; i++){
		for (int j = 0; j < WIDTH; j++){
			img1.setPixelValue(1, j, i);
			if (rand() % 7 == 0) img2.setPixelValue(1, j, i);
		}
	}*/
		

	//wcout << "Thrust version: v" << THRUST_MAJOR_VERSION << "." << THRUST_MINOR_VERSION << endl << endl;

	auto begin = std::chrono::high_resolution_clock::now();
	
	//hdCPU(img1, img2, img1I.getWidth(), img2I.getHeight(), 2);


	//struct elements
	//const int SIZE = 1; //qtd total de blocos(SIZE + 1)*(SIZE + 1)
	//bool *structElement = new bool[(SIZE + 1)*(SIZE + 1)] { true, true, true, true }; //orientação: esquerda direita, cima baixo
	bool *structElement = NULL;

	hdCPUMorphology(img1, img2, img1I.getWidth(), img1I.getHeight(), structElement);

	//hdCPUSync(img1B, img2B, img1.getWidth(), img1.getHeight(), structElement, SIZE);

	//hdGPUSync(img1B, img2B, img1.getWidth(), img1.getHeight(), structElement, SIZE);

	//hdGPUSyncShared(img1.getBooleanLinearImage(0), img2.getBooleanLinearImage(0), img1.getWidth(), img1.getHeight(), structElement, SIZE);

	//ferrado \/
	//hdAsync(img1.getBooleanLinearImage(0), img2.getBooleanLinearImage(0), img1.getWidth(), img1.getHeight(), 1);

	//printf("bla %d", img1.getPixel(1, 0, 0));
	//img1.printBooleanLinearImage(0);

	auto end = std::chrono::high_resolution_clock::now();

	std::cout << "Total elapsed time: ";
	std::cout << (double)(::chrono::duration_cast<std::chrono::nanoseconds>(end - begin).count()/(double)1000000000) << "s" << std::endl;

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
