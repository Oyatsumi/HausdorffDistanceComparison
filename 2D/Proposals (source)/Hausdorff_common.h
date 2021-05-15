

int hdCPUSync(bool *img1, bool *img2, const int WIDTH, const int HEIGHT, bool *structElement, const char STRUCT_SIZE);

int hdCPU(const bool *img1, const bool *img2, const int WIDTH, const int HEIGHT, const int METRIC);

//int hdAsync(bool *img1, bool *img2, const int WIDTH, const int HEIGHT, int METRIC);

int hdGPUSync(bool *img1, bool *img2, const int WIDTH, const int HEIGHT, bool *structElement, const int STRUCT_SIZE);

int hdCPUMorphology(const bool *img1, const bool *img2, const int WIDTH, const int HEIGHT, const bool *structElement);