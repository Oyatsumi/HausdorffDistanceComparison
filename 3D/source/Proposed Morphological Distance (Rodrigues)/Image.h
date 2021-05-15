#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <iostream>
//#include <LinkedList.h>

typedef unsigned char uchar;

#define MAX_VAL 255

//using namespace cv;
//using namespace std;

#pragma once

class Image
{
private:
	cv::Mat image;
	cv::Vec3b auxColor;
	short* grayImg = NULL;
	int* grayImgInt = NULL;
	bool* boolImg = NULL;
	bool* pinnedBoolImg = NULL;
	int dataType;

public:
	Image(Image* image);
	Image(cv::String path);
	Image(cv::String path, int type);
	Image(int *pixels, int width, int height);
	Image(bool *pixels, int width, int height);
	Image(int width, int height, int bands);
	//get
	int getHeight();
	int getWidth();
	short getPixel(int x, int y, int band);
	short getSample(int x, int y, int band);
	int getNumBands();
	template<class T> T* getLinearImage(int band);
	bool* getBinaryLinearImage(int band, float threshold);
	bool* getBinaryLinearImage(int band);
	//short* getLinearImage(int band);
	//int* getIntegerLinearImage(int band);
	//uchar* getUcharLinearImage(int band);
	//bool* getBooleanLinearImage(int band);
	//bool* getBooleanLinearImage(int band, int threshold);
	//bool* getBooleanLinearImageAtValue(int band, int pixelValue);
	//bool* getBooleanLinearImageAtValue(int pixelValue);
	//bool* getPinnedBooleanLinearImage(int band);
	//bool* getPinnedBooleanLinearImage(int band, int threshold);
	short getMaxValue(int band);
	//set
	void setPixel(int x, int y, int band, int value);
	void setSample(int x, int y, int band, int value);
	//others
	void writeImage(cv::String path);
	void printImage();
	void printLinearImage(int band);
	void printBooleanLinearImage(int band);
	void displayInWindow(cv::String windowTitle);
	void displayInWindow();
	void dispose();
	void indexImagePerIntensity(int *pixels, int width, int height);
	void contrastImage(int *pixels, int maxImgValue, int width, int height);
	void invertImage(int band);

private:
	int getBand(int band);

};


inline Image::Image(Image* image) {
	const int width = (*image).getWidth(), height = (*image).getHeight();
	this->image = cv::Mat::zeros(height, width,
		((*image).getNumBands() == 1) ? CV_8UC1 : ((*image).getNumBands() == 2) ? CV_8UC2 : ((*image).getNumBands() == 3) ? CV_8UC3 : CV_8UC4);
	for (int y = 0; y < height; y++){
		for (int x = 0; x < width; x++){
			for (int b = 0; b < (*image).getNumBands(); b++){
				this->setPixel(x, y, b, (*image).getPixel(x, y, b));
			}
		}
	}
}

inline Image::Image(cv::String path) {
	image = imread(path, cv::IMREAD_COLOR); // Read the file
	if (!image.data)                              // Check for invalid input
	{
		std::cout << "Could not open or find the image on path: ";
		std::cout << path << std::endl;
		exit(-1);
	}
}
inline Image::Image(cv::String path, int type) {
	image = cv::imread(path, type); // Read the file
	if (!image.data)                              // Check for invalid input
	{
		std::cout << "Could not open or find the image on path: ";
		std::cout << path << std::endl;
		exit(-1);
	}
}


inline Image::Image(int width, int height, int bands) {
	image = cv::Mat::zeros(height, width, (bands == 1) ? CV_8UC1 : (bands == 2) ? CV_8UC2 : (bands == 3) ? CV_8UC3 : CV_8UC4);
}

inline Image::Image(int *pixels, int width, int height) {
	image = cv::Mat::zeros(height, width, CV_8UC1);
	//indexImage(pixels, width, height);
	//contrastImage(pixels, 255, width, height);
	for (int i = 0; i < height; i++){
		for (int j = 0; j < width; j++){
			setPixel(j, i, 0, pixels[i*width + j]);
		}
	}
}
inline Image::Image(bool *pixels, int width, int height) {
	image = cv::Mat::zeros(height, width, CV_8UC1);
	//indexImage(pixels, width, height);
	//contrastImage(pixels, 255, width, height);
	for (int i = 0; i < height; i++){
		for (int j = 0; j < width; j++){
			//setPixel(j, i, 0, pixels[i*width + j] ? MAX_VAL : 0);
			setPixel(j, i, 0, pixels[i*width + j] ? 80 : 180);
		}
	}
}

//get
inline int Image::getHeight(){
	return image.rows;
}
inline int Image::getWidth(){
	return image.cols;
}
inline short Image::getPixel(int x, int y, int band){
	if (image.type() == CV_8UC1){
		return image.at<uchar>(y, x);
	}
	else{
		auxColor = image.at<cv::Vec3b>(cv::Point(x, y));
		return auxColor[getBand(band)];
	}
}
inline short Image::getSample(int x, int y, int band){
	return getPixel(x, y, band);
}
inline int Image::getBand(int band){
	return (band == 0) ? 2 : (band == 2) ? 0 : 1;
}
inline int Image::getNumBands(){
	return image.channels();
}
template<class T>
inline T* Image::getLinearImage(int band){
	T *grayImg = new T[getHeight()*getWidth()];
	for (int i = 0; i < getHeight(); i++){
		for (int j = 0; j < getWidth(); j++){
			grayImg[i*getWidth() + j] = (T) getPixel(j, i, band);
		}
	}
	return grayImg;
}
inline bool* Image::getBinaryLinearImage(int band, float threshold){
	bool* boolImg = new bool[getHeight()*getWidth()];
	for (int i = 0; i < getHeight(); i++){
		for (int j = 0; j < getWidth(); j++){
			boolImg[i*getWidth() + j] = (getPixel(j, i, band) >= threshold);
		}
	}
	return boolImg;
}
inline bool* Image::getBinaryLinearImage(int band){//if the image is already binary
	return getBinaryLinearImage(band, getMaxValue(band));
}

inline short Image::getMaxValue(int band){
	int max = 0;
	for (int i = 0; i < getHeight(); i++){
		for (int j = 0; j < getWidth(); j++){
			max = (getPixel(j, i, band) > max ? getPixel(j, i, band) : max);
		}
	}
	return max;
}


//set
inline void Image::setPixel(int x, int y, int band, int value){
	if (image.type() == CV_8UC1)
		image.at<uchar>(y,x) = (unsigned char)value;
	else
		image.at<cv::Vec3b>(cv::Point(x, y))[getBand(band)] = value;
}
inline void Image::setSample(int x, int y, int band, int value){
	setPixel(x, y, band, value);
}


//others
inline void Image::writeImage(cv::String path){
	imwrite(path, image);
}
inline void Image::printImage(){
	for (int i = 0; i < getHeight(); i++){
		for (int j = 0; j < getWidth(); j++){
			std::cout << "[";
			for (int b = 0; b < getNumBands(); b++){
				std::cout << getPixel(j, i, b);
				if (b < getNumBands() - 1) std::cout << ",";
			}
			std::cout << "]";
		}
		std::cout << "\n";
	}
}
inline void Image::printLinearImage(int band){
	short* grayImg = getLinearImage<short>(band);
	for (int k = 0; k < getHeight()*getWidth(); k++){
		std::cout << (grayImg[k]) << " ";
	}
	std::cout << "\n";
}
inline void Image::printBooleanLinearImage(int band){
	bool* boolImg = getBinaryLinearImage(band);
	for (int k = 0; k < getHeight()*getWidth(); k++){
		std::cout << (boolImg[k]) << " ";
	}
	std::cout << "\n";
}
inline void Image::displayInWindow(){
	displayInWindow("Image");
}
inline void Image::displayInWindow(cv::String windowTitle){
	cv::namedWindow(windowTitle, cv::WINDOW_AUTOSIZE); // Create a window for display.
	imshow(windowTitle, image); // Show our image inside it.
}
inline void Image::dispose(){
	if (grayImg != NULL) delete[] grayImg;
	if (grayImgInt != NULL) delete[] grayImgInt;
	if (boolImg != NULL) delete[] boolImg;
	//cudaFreeHost(&pinnedBoolImg);
}
inline void Image::contrastImage(int *pixels, int maxImgValue, int width, int height){
	int maxP = 0, minP = INT_MAX;
	//get max value
	for (int i = 0; i < height; i++){
		for (int j = 0; j < width; j++){
			if (pixels[i*width + j] > maxP){
				maxP = pixels[i*width + j];
			}
			if (pixels[i*width + j] < minP && pixels[i*width + j] >= 0){
				minP = pixels[i*width + j];
			}
		}
	}




	for (int i = 0; i < height; i++){
		for (int j = 0; j < width; j++){
			pixels[i*width + j] = (int) std::round(maxImgValue*pixels[i*width + j]/(float)(maxP - minP) - maxImgValue*minP/(float)(maxP - minP));
		}
	}


}

/*
inline void Image::indexImagePerIntensity(int *pixels, int width, int height){
	LinkedList array = LinkedList();
	for (int i = 0; i < height; i++){
		for (int j = 0; j < width; j++){
			if (!array.contains(pixels[i*width + j])){
				array.add(pixels[i*width + j]);
			}
		}
	}
	for (int i = 0; i < height; i++){
		for (int j = 0; j < width; j ++){
			for (int k = 0; k < array.size(); k++){
				if (array.get(k).value == pixels[i*width + j]){
					pixels[i*width + j] = k;
					k = array.size();
				}
			}
		}
	}
	array.dispose();
}
*/

inline void Image::invertImage(int band){
	for (int i = 0; i < this->getHeight(); i++){
		for (int j = 0; j < this->getWidth(); j++){
			//int newValue = (MAX_VAL - this->getPixel(j, i, band));
			if (this->getPixel(j, i, band) == MAX_VAL) this->setPixel(j, i, band, 0);
			else this->setPixel(j, i, band, MAX_VAL);
		}
	}
}