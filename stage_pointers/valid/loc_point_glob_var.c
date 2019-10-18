
int a = 9;

int main() {
        int *x;
        x = &a;

        int *b = &a;
        *b += 9;
        int c = 10 + *b;
        return c;
}
