#include <iostream>
#include <Image.h>
#include <chrono>
#include<stdlib.h>
#include <string>
#include <vector>
#include <string>
#include "dirent.h"
#include "BoolVolume.h"
#include "HausdorffCPU.h"



#define WIDTH 1392
#define HEIGHT 1040
#define DEPTH 45

using namespace std;


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
			vector.push_back(std::string(entry->d_name));
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
	Volume *v1 = new Volume(WIDTH, HEIGHT, DEPTH), *v2 = new Volume(WIDTH, HEIGHT, DEPTH);

	//iterating folders and reading images
	//const std::string folder = "C:/Users/oyatsumi/Google Drive/Synced Folder/Projetos e Artigos/Hausdorff Morphology/3D/Datasets/Breast Series Images/";
	//const std::string folder = "C:/Users/oyatsumi/Google Drive/Synced Folder/Projetos e Artigos/Hausdorff Morphology/3D/Datasets/FatImages/Unregistered Dicom/Fat Images/";
	const std::string folder = "C:/Users/oyatsumi/Google Drive/Synced Folder/Projetos e Artigos/Hausdorff Morphology/3D/Datasets/Thresholded Hepatocyte Cells (BBBC026)/";
	//const std::string img1Str = "ID_30/", img2Str = "ID_37/";
	const std::string img1Str = "E1/", img2Str = "E1/";

	/*This implementation is made to work with volumes of same size (x, y and z). However, it can be easily converted to create null spaces over the images to 
	accomodate for any sizes.*/

	printf("Loading volume 1... \n");


	std::vector<std::string> list;
	listFiles(folder + img1Str, list);
	for (int k = 0; k < list.size(); k++) {
		printf("Reading file (%d) %s \n", k, (folder + img1Str + list.at(k)).c_str());

		Image itImage = Image(folder + img1Str + list.at(k));

		for (int i = 0; i < itImage.getHeight(); i++) {
			for (int j = 0; j < itImage.getWidth(); j++) {
				//v1.v[j][i][k] = itImage.getPixel(j, i, 0);

				(*v1).setVoxelValue(itImage.getPixel(j, i, 0) > 0, j, i, k);
			}
		}

	}

	printf("Loading volume 2... \n");

	list.clear();
	listFiles(folder + img2Str, list);
	for (int k = 0; k < list.size(); k++) {
		printf("Reading file (%d) %s \n", k, (folder + img2Str + list.at(k)).c_str());

		Image itImage = Image(folder + img2Str + list.at(k));

		for (int i = 0; i < itImage.getHeight(); i++) {
			for (int j = 0; j < itImage.getWidth(); j++) {
				//v1.v[j][i][k] = itImage.getPixel(j, i, 0);
				(*v2).setVoxelValue(itImage.getPixel(j, i, 0) > 0, j, i, k);
			}
		}
	}


	auto begin = std::chrono::high_resolution_clock::now();
	
	hdCPUMorphology(v1, v2);
	
	auto end = std::chrono::high_resolution_clock::now();

	std::cout << "Total elapsed time: ";
	std::cout << (double)(::chrono::duration_cast<std::chrono::nanoseconds>(end - begin).count()/(double)1000000000) << "s" << std::endl;

	delete(v1);
	delete(v2);

	system("pause");

	return 0;
}

