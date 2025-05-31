#include<iostream>
#include<cuda_runtime.h>
using namespace std;

/* a kernel is launched as a grid of threads, a grid is a 3d array and for simiplicity we are working with 1d, 
blockid is index of current block, threadid is index of current thread, and blockDim specifoes the no. of threads in each dim of a block.*/

/* idx here is unique identifier for a thread with the entire grid, we do it to access elementd in the global memory*/

__global__ void vectadd_kernel(float *A, float *B, float *C, int n) {
	int idx= blockIdx.x * blockDim.x + threadIdx.x;
	if(idx < n) {
		C[idx] = A[idx] + B[idx];
	}
}

__global__ void vectnumadd_kernel(int a, int b, int *c) {
	*c = a + b;
}

void vectadd(float *A, float *B, float *C, int n){
	int size = n * sizeof(float);
	float *d_A, *d_B, *d_C; //these are gpu pointers

	cudaMalloc((void**)&d_A, size); //allocate memory with cudamalloc
	cudaMalloc((void**)&d_B, size);
	cudaMalloc((void**)&d_C, size);

	//before kernel call we transfer variables to device
	cudaMemcpy(d_A, A, size, cudaMemcpyHostToDevice);
	cudaMemcpy(d_B, B, size, cudaMemcpyHostToDevice);

	//kernel call
	vectadd_kernel<<<ceil(n/256.0), 256>>>(d_A, d_B, d_C, n);

	cudaMemcpy(C, d_C, size, cudaMemcpyDeviceToHost); //gpu to host

	//free device memory
	cudaFree(d_A);
	cudaFree(d_B);
	cudaFree(d_C);
}

void vectnumadd(int a, int b, int *c){
	int *d_num_c;
	cudaMalloc((void**)&d_num_c, sizeof(int));
	vectnumadd_kernel<<<1,1>>>(a, b, d_num_c);
	cudaMemcpy(c, d_num_c, sizeof(int), cudaMemcpyDeviceToHost);
	cudaFree(d_num_c);
}

int main() {
    int n = 1000;
    size_t size = n * sizeof(float); 
    float *h_A = (float*)malloc(size);
    float *h_B = (float*)malloc(size);
    float *h_C = (float*)malloc(size);

    for(int i = 0; i < n; i++) {
        h_A[i] = static_cast<float>(i);
        h_B[i] = static_cast<float>(i * 2);
    }

    //vector add
    vectadd(h_A, h_B, h_C, n);

    //first and last elements of the vector
    cout << "C[0] = " << h_C[0] << endl;
    cout << "C[" << n-1 << "] = " << h_C[n-1] << endl;

    free(h_A);
    free(h_B);
    free(h_C);

    int r;
    vectnumadd(2,7, &r);
    cout << r << endl;
    return 0;
}
