#pragma once
#include <stdlib.h>


typedef unsigned char uchar;
typedef unsigned short ushort;
typedef unsigned int uint;

class Volume{



private:
	int voxelsQuantity;
	int cIndex = 0;


public:
	Volume(int voxelsQuantity);
	void setVoxelValue(bool value, int x, int y, int z);
	void addVoxel(int x, int y, int z);
	void addVoxel(int x, int y);
	int getNumOfVoxels();
	void dispose();

	struct voxelStr{
		unsigned short x, y, z;
	};
	voxelStr *volume;

	voxelStr* getVolume();
};

inline Volume::Volume(int voxelsQuantity){
	volume = (voxelStr*)malloc(voxelsQuantity * sizeof(voxelStr));
	srand(time(NULL));
	this->voxelsQuantity = voxelsQuantity;
}


inline void Volume::addVoxel(int x, int y, int z){ 
	volume[cIndex].x = x; volume[cIndex].y = y; volume[cIndex].z = z;
	cIndex++;
	//if it is the last element then randomize the order linearly
	if (cIndex == voxelsQuantity){
		unsigned short x, y, z;
		for (int k = 0; k < voxelsQuantity; k++){
			int id = rand() * rand() + rand();
			id = id % voxelsQuantity;
			x = volume[k].x; y = volume[k].y; z = volume[k].z;
			volume[k].x = volume[id].x; volume[k].y = volume[id].y; volume[k].z = volume[id].z;
			volume[id].x = x; volume[id].y = y; volume[id].z = z;
		}
	}
}

inline int Volume::getNumOfVoxels(){
	return this->voxelsQuantity;
}


inline Volume::voxelStr* Volume::getVolume(){ return this->volume; }



inline void Volume::dispose(){
	free(volume);
}