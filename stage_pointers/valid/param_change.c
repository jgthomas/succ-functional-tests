
int dog(int *p) {
       *p += 10;
       return 2;
}

int main() {
        int a = 2;
        int *p = &a;
        int x = dog(p);
        return *p;
}
