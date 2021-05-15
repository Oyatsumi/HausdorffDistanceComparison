
#include "itkImage.h"

#include "HausdorffDistanceMetric.h"
#include "dirent.h"

#include "itkImage.h"
//#include "itkVector.h"
//#include "itkImageRegionConstIterator.h"
//#include "itkImageConstIterator.h"
//#include "itkImage.h"


#include <chrono>
#include <iostream>
#include <stdio.h>

#include<stdlib.h>
#include<time.h>
#include<string.h>

#include "itkImageFileReader.h"


#include<vector>



#include <iostream>
#include <sys/types.h>

//#define WIDTH 640
//#define HEIGHT 480
//#define DEPTH 20

#define WIDTH 1392
#define HEIGHT 1040
#define DEPTH 45



inline void listFiles(const char *path, std::vector < std::string > & vector) {
	struct dirent *entry;
	DIR *dir = opendir(path);

	if (dir == NULL) {
		return;
	}

	int counter = 0;
	while ((entry = readdir(dir)) != NULL) {
		if (counter >= 2) {
			//std::cout << entry->d_name << std::endl;
			std::string str = std::string(entry->d_name);
			vector.push_back(str);
			//int pos = vector.size() == 0 ? 0 : (rand() % vector.size());
			//vector.insert(vector.begin() + pos, str);
		}
		counter++;
	}
	closedir(dir);
	//std::sort(vector.begin(), vector.end());
}
inline void listFiles(const std::string& s, std::vector<std::string>& vector) {
	return listFiles(s.c_str(), vector);
}



int main(int argc, char** argv)
{


	typedef itk::Image< unsigned char, 2>   ImageType2D;
	typedef itk::ImageFileReader< ImageType2D >  ReaderType2D;

	typedef itk::Image< unsigned char, 3>   ImageType;
	typedef itk::ImageFileReader< ImageType >  ReaderType;


	//creating a 3D image
	//
	ImageType::Pointer image1_3D = ImageType::New();
	ImageType::Pointer image2_3D = ImageType::New();



	// The image region should be initialized
	const ImageType::SizeType  size = { { WIDTH, HEIGHT, DEPTH} }; //Size along {X,Y,Z}
	const ImageType::IndexType start = { { 0, 0, 0 } }; // First index on {X,Y,Z}

	ImageType::RegionType region;
	region.SetSize(size);
	region.SetIndex(start);

	// Pixel data is allocated
	image1_3D->SetRegions(region);
	image1_3D->Allocate(true); // initialize buffer to zero

	image2_3D->SetRegions(region);
	image2_3D->Allocate(true);


	//volume folders
	const std::string img1Str = "E1/", img2Str = "E1/";

	//iterating folders and reading images
	//const std::string folder = "C:/Users/oyatsumi/Google Drive/Synced Folder/Projetos e Artigos/Hausdorff Morphology/3D/Datasets/Breast Series Images/";
	const std::string folder = "C:/Users/oyatsumi/Google Drive/Synced Folder/Projetos e Artigos/Hausdorff Morphology/3D/Datasets/Thresholded Hepatocyte Cells (BBBC026)/";

	printf("Loading volume 1... \n");

	//first volume
	std::vector<std::string> list;
	listFiles(folder + img1Str, list);

	for (int k = 0; k < list.size(); k++) {
		printf("Reading file %s \n", (folder + img1Str + list.at(k)).c_str());

		ReaderType2D::Pointer reader = ReaderType2D::New();
		
		std::string itFile = folder + img1Str + list.at(k);
		reader->SetFileName(itFile);

		reader->Update();

		ImageType2D::Pointer itImage = reader->GetOutput();


		//write to first 3D volume
		for (int i = 0; i < HEIGHT; i++) {
			for (int j = 0; j < WIDTH; j++) {
				const ImageType::IndexType pixelIndex = { {j, i, k} }; // Position of {X,Y,Z}
				const ImageType2D::IndexType pixelIndex2D = { { j, i } }; // Position of {X,Y}
				const ImageType2D::PixelType   pixelValue = itImage->GetPixel(pixelIndex2D);
				image1_3D->SetPixel(pixelIndex, pixelValue);
			}
		}
	
	}

	printf("Loading volume 2... \n");

	//second volume
	list.clear();
	listFiles(folder + img2Str, list);
	for (int k = 0; k < list.size(); k++) {
		printf("Reading file %s \n", (folder + img2Str + list.at(k)).c_str());
		ReaderType2D::Pointer reader = ReaderType2D::New();

		std::string itFile = folder + img2Str + list.at(k);
		reader->SetFileName(itFile);

		reader->Update();

		ImageType2D::Pointer itImage = reader->GetOutput();


		//write to second 3D volume
		for (int i = 0; i < HEIGHT; i++) {
			for (int j = 0; j < WIDTH; j++) {
				
			
				const ImageType::IndexType pixelIndex = { {j , i , k} }; // Position of {X,Y,Z}
				const ImageType2D::IndexType pixelIndex2D = { { j, i } }; // Position of {X,Y}
				const ImageType2D::PixelType   pixelValue = itImage->GetPixel(pixelIndex2D);
				image2_3D->SetPixel(pixelIndex, pixelValue);
				
			}
		}
	}




	printf("Starting computation... \n");

	auto begin = std::chrono::high_resolution_clock::now();

	HausdorffDistanceMetric hd = HausdorffDistanceMetric(image1_3D, image2_3D, false, 0.00000005, 0);

	double r = hd.CalcHausdorffDistace(1.0);

	auto end = std::chrono::high_resolution_clock::now();
	std::cout << "Total elapsed time: ";
	std::cout << (double)(std::chrono::duration_cast<std::chrono::nanoseconds>(end - begin).count() / (double)1000000000) << "s" << std::endl;


	printf("Distance %f \n", r);

	system("pause"); 


	return EXIT_SUCCESS;
}
