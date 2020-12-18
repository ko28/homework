// Daniel Ko

int arr2D[3000][500];

int main(int argc, char *argv[]) {

	for(int j = 0; j < 500; j++){
		for(int i = 0; i < 3000; i++){
			arr2D[i][j] = i + j;
		}
	}
	return 0;
}