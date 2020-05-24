int dog(int a);

int main() {
        int b = 2;
        int *p = &b;
        return dog(b);
}

int dog(int *p) {
        return p + 3;
}
