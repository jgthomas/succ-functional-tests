
int a = 10;
int *p = &a;

int main() {
        int x = 20;
        int y = 30;
        int *p1 = &x;
        p1 = &y;
        p = &y;
        p1 = &a;
        p = &x;
        return *p1 + *p;
}

