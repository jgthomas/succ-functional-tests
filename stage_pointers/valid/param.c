
int dog(int *p) {
        return *p;
}

int main() {
        int a = 2;
        int *p = &a;
        return dog(p);
}
