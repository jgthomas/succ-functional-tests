
int cat(int *p);

int dog(int a) {
        return cat(a);
}

int cat(int *p) {
        return *p + 2;
}

int main() {
        int a = 2;
        return dog(a);
}

