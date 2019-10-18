
int dog(int a) {
        return a * 2;
}

int cat(int h) {
        return dog(h);
}

int main() {
        int d = 7;
        return cat(7);
}
