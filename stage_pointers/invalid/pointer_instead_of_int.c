
int dog(int a) {
        return a;
}

int main() {
        int a = 2;
        int *p = &a;
        return dog(p);
}
