int dog(int a);

int main() {
        int b = 2;
        int *p = &b;
        return dog(p);
}

int dog(int a) {
        return a + 3;
}
