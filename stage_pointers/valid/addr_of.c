int dog(int *p);

int main() {
        int a = 2;
        return dog(&a);
}

int dog(int *p) {
        return *p + 3;
}
