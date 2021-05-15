#include <stdlib.h>
#pragma once

typedef unsigned char uchar;
typedef unsigned int uint;

class Volume{

private:
	bool* volume;
	int width, height, depth;
public:
	int getLinearIndex(int x, int y, int z);
	bool getVoxelValue(int x, int y, int z);
	bool getVoxelValue(int linearId);
	bool getPixelValue(int x, int y);
	int getWidth();
	int getHeight();
	int getDepth();
	bool* getVolume();
	void setVoxelValue(bool value, int x, int y, int z);
	void setVoxelValue(bool value, int linearId);
	void setPixelValue(bool value, int x, int y);
	Volume(int width, int height, int depth);
	Volume(int width, int height);
	void dispose();

};

/**
Declares a 3 dimensional volume

@param1 digit the single digit to encode.
*/
inline Volume::Volume(int width, int height, int depth){
	this->width = width; this->height = height; this->depth = depth;
	volume = (bool*)calloc(width * height * depth, sizeof(bool));
}

inline Volume::Volume(int width, int height){
	this->width = width; this->height = height; this->depth = 1;
	volume = (bool*)calloc(width * height * depth, sizeof(bool));
}

inline int Volume::getLinearIndex(int x, int y, int z){
	const int a = 1, b = width, c = (width)* (height);
	return a*x + b*y + c*z;
}

inline int Volume::getWidth(){ return this->width; }
inline int Volume::getHeight(){ return this->height; }
inline int Volume::getDepth(){ return this->depth; }
inline bool* Volume::getVolume(){ return this->volume; }
inline bool Volume::getPixelValue(int x, int y){ return this->volume[getLinearIndex(x, y, 0)]; }

inline bool Volume::getVoxelValue(int x, int y, int z){
	return volume[getLinearIndex(x, y, z)];
}

inline bool Volume::getVoxelValue(int linearId) {
	return volume[linearId];
}

inline void Volume::setPixelValue(bool value, int x, int y){
	volume[getLinearIndex(x, y, 0)] = value;
}

inline void Volume::setVoxelValue(bool value, int x, int y, int z){
	volume[getLinearIndex(x, y, z)] = value;
}
inline void Volume::setVoxelValue(bool value, int linearId) {
	volume[linearId] = value;
}

inline void Volume::dispose(){
	free(volume);
}
