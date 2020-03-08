

int *dog(int a) {
        return &a;
}

int main() {
        int *b = dog(2);
        return 1;
}
