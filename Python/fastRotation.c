#include <math.h>

void
rotateAround(double v[3], double axis[3], double theta)
{
    double x = sqrt(axis[0] * axis[0] + axis[1] * axis[1] + axis[2] * axis[2]);
    double a = cos(theta / 2.0);
    double b = -(axis[0] / x) * sin(theta / 2.0);
    double c = -(axis[1] / x) * sin(theta / 2.0);
    double d = -(axis[2] / x) * sin(theta / 2.0);

    double mat[9];
    
    mat[0] = a*a + b*b - c*c - d*d;
    mat[1] = 2 * (b*c - a*d);
    mat[2] = 2 * (b*d + a*c);

    mat[3*1 + 0] = 2*(b*c+a*d);
    mat[3*1 + 1] = a*a+c*c-b*b-d*d;
    mat[3*1 + 2] = 2*(c*d-a*b);

    mat[3*2 + 0] = 2*(b*d-a*c);
    mat[3*2 + 1] = 2*(c*d+a*b);
    mat[3*2 + 2] = a*a+d*d-b*b-c*c;

}
