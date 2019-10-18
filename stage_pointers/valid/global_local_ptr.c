
int *p;

int dog(int *p) {
        return *p;
}

int main() {
        int a = 10;
        p = &a;
        *p += 90;
        return dog(p);
}
