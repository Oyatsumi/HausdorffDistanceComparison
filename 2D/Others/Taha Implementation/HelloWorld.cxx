
#include "itkImage.h"

#include "HausdorffDistanceMetric.h"

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




int main(int argc, char** argv)
{
	typedef itk::Image< unsigned char, 2>   ImageType;
	typedef itk::ImageFileReader< ImageType >  ReaderType;


	ReaderType::Pointer reader = ReaderType::New();
	ReaderType::Pointer reader2 = ReaderType::New();
	std::string filename = "../Dataset/", filename2 = "../Dataset/";
	filename += argv[1]; filename2 += argv[1];
	filename += "/a.png"; filename2 += "/b.png";
	reader->SetFileName(filename); reader2->SetFileName(filename2);
	reader->Update(); reader2->Update();
	ImageType::Pointer image = reader->GetOutput();
	ImageType::Pointer image2 = reader2->GetOutput();


	/*
	typedef unsigned char                            ComponentType;
	typedef itk::RGBPixel < ComponentType >          RGBPixelType;
	typedef itk::Image< RGBPixelType, 2 >    ImageType;

	itk::ImageFileReader<ImageType>::Pointer PNGreader;
	PNGreader = itk::ImageFileReader<ImageType>::New();


	std::string filename = "../Dataset/", filename2 = "../Dataset/";
	filename += argv[1]; filename2 += argv[1];
	filename += "/a.png"; filename2 += "/b.png";

	printf("%s \n", filename.c_str());

	PNGreader->SetImageIO(itk::PNGImageIO::New());

	PNGreader->SetFileName(filename.c_str());

	try
	{
	PNGreader->Update();
	}
	catch (itk::ExceptionObject & excp)
	{
	std::cerr << excp << std::endl;
	return 1;
	}

	ImageType::Pointer image = PNGreader->GetOutput();

	PNGreader->SetFileName(filename2.c_str());

	PNGreader->Update();

	ImageType::Pointer image2 = PNGreader->GetOutput();

	ImageType::IndexType pixelIndex = { { 0, 0 } }; // Position of {X,Y,Z}

	printf("%d %d \n", image->GetPixel(pixelIndex).GetLuminance(), image2->GetPixel(pixelIndex).GetScalarValue());
	*/


	/*
	ImageType::Pointer image = ImageType::New(), image2 = ImageType::New();
	// The image region should be initialized

	const int width = 256, height = width, depth = width;


	const ImageType::SizeType  size = { { width, height } }; //Size along {X,Y,Z}
	const ImageType::IndexType start = { { 0, 0 } }; // First index on {X,Y,Z}
	ImageType::RegionType region;
	region.SetSize(size);
	region.SetIndex(start);
	// Pixel data is allocated
	image->SetRegions(region);
	image->Allocate(true); // initialize buffer to zero
	image2->SetRegions(region);
	image2->Allocate(true);

	ImageType::IndexType pixelIndex = { { 0, 0 } }; // Position of {X,Y,Z}
	srand(time(NULL));


	//image->SetPixel(pixelIndex, 255);
	//pixelIndex = { { 200, 177, 139 } };
	//image2->SetPixel(pixelIndex, 255);

	for (int i = 0; i < height; i++){
	for (int j = 0; j < width; j++){
	for (int z = 0; z < depth; z++){
	pixelIndex = { { j, i } };
	image->SetPixel(pixelIndex, 255);
	if (j == i) image2->SetPixel(pixelIndex, 255);
	}
	}
	}
	*/

	/*
	for (int i = 0; i < height; i++){
	for (int j = 0; j < width; j++){
	pixelIndex = { { j, i } };
	image->SetPixel(pixelIndex, 255);
	if (rand() % 7 == 0) image2->SetPixel(pixelIndex, 255);
	}
	}*/
	//image->SetPixel(pixelIndex, 255);
	//pixelIndex = { { 255, 255 } }; // Position of {X,Y,Z}
	//image2->SetPixel(pixelIndex, 255);

	//ImageType::PixelType   pixelValue = image->GetPixel(pixelIndex);

	auto begin = std::chrono::high_resolution_clock::now();

	HausdorffDistanceMetric hd = HausdorffDistanceMetric(image, image2, false, 0.00000005);

	double r = hd.CalcHausdorffDistace(1.0);

	auto end = std::chrono::high_resolution_clock::now();
	std::cout << "Total elapsed time: ";
	std::cout << (double)(std::chrono::duration_cast<std::chrono::nanoseconds>(end - begin).count() / (double)1000000000) << "s" << std::endl;


	printf("Distance %f", r);

	return EXIT_SUCCESS;
}
