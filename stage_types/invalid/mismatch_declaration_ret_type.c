
int *dog(int *a);


int main() {
        int a = 10;
        int *c = dog(&a);
        return a + *c;
}


int *dog(int *a) {
        int x = 90;
        return x;
}
