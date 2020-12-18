// Daniel Ko

int arr2D[128][8];

int main(int argc, char *argv[]) {

	for(int i = 0; i < 100; i++){
		for(int row = 0; row < 128; row += 64){
			for(int col = 0; col < 8; col++){
			arr2D[row][col] = i + row + col;
			}
		}
	}
	return 0;
}