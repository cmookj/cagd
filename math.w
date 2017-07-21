@* Solution of Tridiagonal Systems.

곡선의 interpolation 문제를 푸는 과정의 핵심은 tridiagonal system의 해법을
구하는 것이다.  가장 먼저 tridiagonal matrix의 역행렬을 구하는 루틴이다.

Riaz A. Usmani, ``Inversion of a Tridiagonal Jacobi Matrix,''
{\sl Linear Algebra and its Applications}, {\bf 212}, 1994, pp.~413--414와
C. M. da Fonseca, ``On the Eigenvalues of Some Tridiagonal Matrices,''
{\sl J. Computational and Applied Mathematics}, {\bf 200}(1), 2007,
pp.~283--286을 참고하면 tridiagonal matrix의 역행렬은 간단한 계산으로 구할
수 있다.

행렬
$$T=\pmatrix{
  \beta_1&\gamma_1&&&&&\cr
  \alpha_2&\beta_2&\gamma_2&&&&\cr
  &&&\ddots&&&\cr
  &&&&\alpha_{n-1}&\beta_{n-1}&\gamma_{n-1}\cr
  &&&&&\alpha_n&\beta_n\cr}$$
의 역행렬 $T^{-1}$의 원소는 다음과 같이 주어진다.
$$\left(T^{-1}\right)_{ij}=
\cases{
  (-1)^{i+j}\gamma_i\cdots\gamma_{j-1}\theta_{i-1}\phi_j/\theta_n,&
  if $i<j$;\cr
  \noalign{\vskip6pt}
  \theta_{i-1}\phi_j/\theta_n,& if $i=j$;\cr
  \noalign{\vskip6pt}
  (-1)^{i+j}\alpha_j\cdots\alpha_{i-1}\theta_{j-1}\phi_i/\theta_n,&
  if $i>j$.\cr
}$$
이 때 $\theta_i$와 $\phi_i$는 다음의 점화식으로부터 얻는다.
$$\vcenter{\halign{$\hfil#$&${}=#\hfil$&$\quad#\hfil$\cr
\theta_i&\beta_i\theta_{i-1}-\gamma_{i-1}\alpha_{i-1}\theta_{i-2}&
  (i=2,3,\ldots,n),\cr
\phi_i&\beta_{i+1}\phi_{i+1}-\gamma_{i+1}\alpha_{i+1}\phi_{i+2}&
  (i=n-2,\ldots,0).\cr
}}$$
이 점화식들의 초기 조건은
$$\eqalign{
\theta_0=1,& \quad\theta_1=\beta_1;\cr
\phi_{n-1}=\beta_n,& \quad\phi_n=1\cr
}$$
이다.

정리하면, tridiagonal matrix의 역행렬을 구하는 과정은 다음과 같다:
{\parindent=40pt
\item{1.} $\theta_0$와 $\theta_1$을 이용하여 $\theta_2,\ldots,\theta_n$을 계산;
\item{2.} $\theta_n=0$이면 행렬이 비가역이므로 계산 종료.
  그렇지 않으면 나머지 단계로 진행;
\item{3.} $\phi_{n-1}$과 $\phi_n$을 이용하여 $\phi_{n-2},\ldots,\phi_1$을 계산;
\item{4.} $\phi_i$와 $\theta_i$들을 이용하여 역행렬의 원소들을 계산.
}

여기에서 정의하는 |invert_tridiagonal()| 함수는 계산한 역행렬을
row-major order, 즉 첫 번째 행부터 마지막 행까지 하나의 |vector|에 순서대로 넣어
반환한다.  행렬이 비가역적이면 함수는 |-1|을, 가역이면 |0|을 반환한다.

@<Implementation of |cagd| functions@>+=
int cagd::invert_tridiagonal (@/
  @t\idt@> const vector<double>& alpha,@/
  @t\idt@> const vector<double>& beta,@/
  @t\idt@> const vector<double>& gamma,@/
  @t\idt@> vector<double>& inverse@/
  @t\idt@> ) @+ {

  size_t n = beta.size();

  vector<double> theta (n+1, 0.); // From 0 to $n$.
  theta[0] = 1.;
  theta[1] = beta[0];

  for (size_t i = 2; i != n+1; i++) {
    theta[i] = beta[i-1]*theta[i-1] - gamma[i-2]*alpha[i-2]*theta[i-2];
  }

  if (theta[n] == 0.) return -1; // The matrix is singular.

  vector<double> phi (n+1, 0.); // From 0 to $n$.
  phi[n] = 1.;
  phi[n-1] = beta[n-1];

  for (size_t i = n-1; i != 0; i--) {
    phi[i-1] = beta[i-1]*phi[i] - gamma[i-1]*alpha[i-1]*phi[i+1];
  }

  for (size_t i = 0; i != n; i++) {
    for (size_t j = 0; j != n; j++) {
      double elem = 0.;
      if (i < j) {
        double prod = 1.;
        for (size_t k = i; k != j; k++) {
          prod *= gamma[k];
        }
        elem = pow (-1, i+j)*prod*theta[i]*phi[j+1]/theta[n];
      } else if (i == j) {
        elem = theta[i]*phi[j+1]/theta[n];
      } else {
        double prod = 1.;
        for (size_t k = j; k != i; k++) {
          prod *= alpha[k];
        }
        elem = pow (-1, i+j)*prod*theta[j]*phi[i+1]/theta[n];
      }
      inverse [i*n + j] = elem;
    }
  }

  return 0; // No error.
}

@ @<Declaration of |cagd| functions@>+=
int invert_tridiagonal (@/
  @t\idt@> const vector<double>&,@/
  @t\idt@> const vector<double>&,@/
  @t\idt@> const vector<double>&,@/
  @t\idt@> vector<double>&
);

@ Test: Inversion of a Tridiagonal Matrix.

예제로
$$\pmatrix{1&4&0&0\cr 3&4&1&0\cr 0&2&3&4\cr 0&0&1&3\cr}$$
의 역행렬을 계산한다.  결과는
$$\pmatrix{-0.304348&0.434783&-0.26087&0.347826\cr
0.326087&-0.108696&0.0652174&-0.0869565\cr
-0.391304&0.130435&0.521739&-0.695652\cr
0.130435&-0.0434783&-0.173913&0.565217\cr}$$
이다.

@<Test routines@>+=
print_title ("inversion of a tridiagonal matrix");
{
  vector<double> alpha(3, 0.);
  alpha[0] = 3.; @+ alpha[1] = 2.; @+ alpha[2] = 1.;

  vector<double> beta(4, 0.);
  beta[0] = 1.; @+ beta[1] = 4.; @+ beta[2] = 3.; @+ beta[3] = 3.;

  vector<double> gamma(3, 0.);
  gamma[0] = 4.; @+ gamma[1] = 1.; @+ gamma[2] = 4.;

  vector<double> inv(4*4, 0.);
  cagd::invert_tridiagonal (alpha, beta, gamma, inv);

  for (size_t i = 0; i != 4; i++) {
    for (size_t j = 0; j != 4; j++) {
      cout << inv[i*4 +j] << "  ";
    }
    cout << endl;
  }
}


@ Multiplication of a matrix and a vector.
Tridiagonal matrix의 역행렬을 이용하여 tridiagonal system의 해를 구하려면,
일반적인 행렬과 벡터의 곱셈이 필요하다.
여기서는 row-major order로 하나의 |vector| 타입 객체에 저장된 정방행렬과
하나의 |vector| 타입 객체에 저장되어 있는 column vector의 곱셈을
구현한다.

@<Implementation of |cagd| functions@>+=
vector<double> cagd::multiply ( @/
                    @t\idt@>const vector<double>& mat, @/
                    @t\idt@>const vector<double>& vec @/
                    @t\idt@>) @+ {
  size_t n = vec.size();
  vector<double> mv (n, 0.);
  for (size_t i = 0; i != n; i++) {
    for (size_t k = 0; k != n; k++) {
      mv[i] += mat[i*n +k] *vec[k];
    }
  }
  return mv;
}

@ @<Declaration of |cagd| functions@>+=
vector<double> multiply ( @/
                    @t\idt@>const vector<double>&, @/
                    @t\idt@>const vector<double>& );


@ Tridiagonal matrix의 역행렬을 이용하여 tridiagonal system의 해를 구하는 것은
매우 간단하다.
$$A\bbx=\bbb$$
에서 세 개의 |vector<double>| 타입의 입력인자, |l|, |d|, |u|는 각각
$n\times n$ 행렬 $A$의 lower diagonal, diagonal, upper diagonal element들이다.
|l|과 |u|는 $n-1$개, |d|는 $n$개의 원소를 가져야 한다.
|vector<point>| 타입의 인자 |b|와 |x|는 각각 방정식의 우변과 해를 의미한다.
방정식의 해가 유일하게 존재하면 함수는 0을, 그렇지 않으면 |-1|을 반환한다.

@<Implementation of |cagd| functions@>+=
int cagd::solve_tridiagonal_system ( @/
  @t\idt@>const vector<double>& l, @/
  @t\idt@>const vector<double>& d, @/
  @t\idt@>const vector<double>& u, @/
  @t\idt@>const vector<point>& b, @/
  @t\idt@>vector<point>& x @/
  @t\idt@>) @+ {

  size_t n = d.size();
  vector<double> Ainv (n*n, 0.);

  if (cagd::invert_tridiagonal (l, d, u, Ainv) != 0) return -1;

  for (size_t i = 1; i != b[0].dim()+1; i++) {
    vector<double> r (n, 0.);
    for (size_t k = 0; k != n; k++) {
      r[k] = b[k](i);
    }

    vector<double> xi = cagd::multiply (Ainv, r);
    for (size_t k = 0; k != n; k++) {
      x[k](i) = xi[k];
    }
  }

  return 0;
}

@ @<Declaration of |cagd| functions@>+=
int solve_tridiagonal_system ( @/
  @t\idt@>const vector<double>&, @/
  @t\idt@>const vector<double>&, @/
  @t\idt@>const vector<double>&, @/
  @t\idt@>const vector<point>&, @/
  @t\idt@>vector<point>&);


@ Ahlberg-Nilson-Walsh Algorithm. (Solution of a cyclic tridiagonal system.)

Tridiagonal system을 구성하는 관계식이 시작점과 끝점에서도 꼬리에 꼬리를 무는
형태로
반복되는 경우 cyclic tridiagonal system이라 부르며, Ahlberg-Nilson-Walsh
algorithm (Clive Temperton, ``Algorithms for the Solution of Cyclic
Tridiagonal Systems,'' {\sl J. Computational Physics}, {\bf 19}(3), 1975,
pp.~317--323)을
참조하면 일반적인 linear system의 해법을 쓰지 않고 변형된 tridiagonal system으로
풀 수 있다.

방정식
$$\pmatrix{
  \beta_1&\gamma_1&&&&&\alpha_1\cr
  \alpha_2&\beta_2&\gamma_2&&&&\cr
  &&&\ddots&&&\cr
  &&&&\alpha_{n-1}&\beta_{n-1}&\gamma_{n-1}\cr
  \gamma_{n}&&&&&\alpha_{n}&\beta_{n}\cr}
\pmatrix{x_1\cr\vdots\cr x_{n}\cr}
=\pmatrix{b_1\cr\vdots\cr b_{n}\cr}$$
이 주어졌을 때,
\def\myvbar{\strut\vrule}
$$\pmatrix{
  \beta_1&\gamma_1&&&&&\myvbar&\alpha_1\cr
  \alpha_2&\beta_2&\gamma_2&&&&\myvbar&\cr
  &&&\ddots&&&\myvbar&\cr
  &&&&\alpha_{n-1}&\beta_{n-1}&\myvbar&\gamma_{n-1}\cr
  \noalign{\smallskip\hrule}\cr
  \gamma_{n}&&&&&\alpha_{n}&\myvbar&\beta_{n}\cr}=
\pmatrix{E&f\cr
g^\top&h\cr
},\quad
\pmatrix{x_1\cr\vdots\cr x_{n-1}\cr\noalign{\smallskip\hrule}\cr x_n\cr}
=\pmatrix{\hat\bbx\cr x_n\cr},\quad
\pmatrix{b_1\cr\vdots\cr b_{n-1}\cr\noalign{\smallskip\hrule}\cr b_n\cr}
=\pmatrix{\hat\bbb\cr b_n\cr}
$$
으로 치환하면,
$$\eqalign{
E\hat\bbx+fx_n&=\hat\bbb\cr
g\trans\hat\bbx+hx_n&=b_n\cr
}$$
이고, tridiagonal matrix $E$는 쉽게 역행렬을 구할 수 있으므로
$$\hat\bbx=E^{-1}(\hat\bbb-fx_n)$$
을 두 번째 방정식에 대입하면
$$x_n={b_n-g\trans E^{-1}\hat\bbb\over h-g\trans E^{-1}f}$$
이고,
$$\hat\bbx=E^{-1}\left(\hat\bbb
  -f{b_n-g\trans E^{-1}\hat\bbb\over h-g\trans E^{-1}f}\right)$$
이다.

아래 함수는 입력 인자, |alpha|, |beta|, |gamma|가 각각
$\alpha_i$, $\beta_i$, $\gamma_i$들을 담고 있음을 가정한다.

@<Implementation of |cagd| functions@>+=
int cagd::solve_cyclic_tridiagonal_system ( @/
  @t\idt@>const vector<double>& alpha, @/
  @t\idt@>const vector<double>& beta, @/
  @t\idt@>const vector<double>& gamma, @/
  @t\idt@>const vector<point>& b, @/
  @t\idt@>vector<point>& x @/
  @t\idt@>) @+ {

  size_t n = beta.size();
  vector<double> Einv ((n-1)*(n-1), 0.);
  @<Calculate $E^{-1}$@>;

  size_t dim = b[0].dim();
  vector<vector<double> > B (dim, vector<double>(n, 0.));
  for (size_t i = 0; i != dim; i++) {
    for (size_t j = 0; j != n; j++) {
      B[i][j] = b[j](i+1);
    }

    @<Calculate $x_n$@>;
    @<Calculate $\hat\bbx$@>;

    for (size_t j = 0; j != n-1; j++) {
      x[j](i+1) = xhat[j];
    }
    x[n-1](i+1) = x_n;
  }

  return 0;
}

@ @<Calculate $E^{-1}$@>=
vector<double> l = vector<double>(n-2, 0.);
vector<double> d = vector<double>(n-1, 0.);
vector<double> u = vector<double>(n-2, 0.);
for (size_t j = 0; j != n-2; j++) {
  l[j] = alpha[j+1];
  d[j] = beta[j];
  u[j] = gamma[j];
}
d[n-2] = beta[n-2];

if (invert_tridiagonal (l, d, u, Einv) != 0) return -1;


@ $g$와 $f$의 특성으로 인하여
\def\Einv#1{E^{-1}_{#1}}
$$\eqalign{
g\trans E^{-1}f &=
\gamma_n\left(\alpha_1\Einv{1,1} + \gamma_{n-1}\Einv{1,n-1}\right)
+\alpha_n\left(\alpha_1\Einv{n-1,1} + \gamma_{n-1}\Einv{n-1,n-1}\right);\cr
g\trans E^{-1}\hat\bbb &=
\gamma_n\left(\Einv{1,1}b_1+\cdots+\Einv{1,n-1}b_{n-1}\right)
+\alpha_n\left(\Einv{n-1,1}b_1+\cdots+\Einv{n-1,n-1}b_{n-1}\right)\cr}
$$ 이다.

@<Calculate $x_n$@>=
double x_n_den = beta[n-1]
  -gamma[n-1]*(alpha[0]*Einv[0] +gamma[n-2]*Einv[n-2])
  -alpha[n-1]*(alpha[0]*Einv[(n-2)*(n-1)] +gamma[n-2]*Einv[(n-1)*(n-1)-1]);

double E1b = 0.;
double Enb = 0.;
for (size_t j = 0; j != n-1; j++) {
  E1b += Einv[j]*B[i][j];
  Enb += Einv[(n-2)*(n-1) +j]*B[i][j];
}
double x_n_num = B[i][n-1] -gamma[n-1]*E1b -alpha[n-1]*Enb;
double x_n = x_n_num/x_n_den;


@ @<Calculate $\hat\bbx$@>=
vector<double> bhat_fxn (n-1, 0.);
for (size_t j = 0; j != n-1; j++) {
  bhat_fxn[j] = B[i][j];
}
bhat_fxn[0] -= alpha[0]*x_n;
bhat_fxn[n-2] -= gamma[n-2]*x_n;

vector<double> xhat = multiply (Einv, bhat_fxn);


@ @<Declaration of |cagd| functions@>+=
int solve_cyclic_tridiagonal_system ( @/
  @t\idt@>const vector<double>&, @/
  @t\idt@>const vector<double>&, @/
  @t\idt@>const vector<double>&, @/
  @t\idt@>const vector<point>&, @/
  @t\idt@>vector<point>& );

@ Test: Cyclic Tridiagonal System.

예제로
$$A=\pmatrix{
2&1&0&0&0&0&1\cr
1&2&1&0&0&0&0\cr
0&1&2&1&0&0&0\cr
0&0&1&2&1&0&0\cr
0&0&0&1&2&1&0\cr
0&0&0&0&1&2&1\cr
1&0&0&0&0&1&2\cr},\quad
\bbb=\pmatrix{
1&7\cr
2&6\cr
3&5\cr
4&4\cr
5&3\cr
6&2\cr
7&1\cr}$$
일 때, $A\bbx=\bbb$의 해를 구하면,
$$\bbx=\pmatrix{
-5&7\cr
4&-2\cr
-1&3\cr
1&1\cr
3&-1\cr
-2&4\cr
7&-5\cr}$$
이다.

@<Test routines@>+=
print_title("cyclic tridiagonal system");
{
  vector<double> alpha (7, 1.);
  vector<double> beta (7, 2.);
  vector<double> gamma (7, 1.);

  vector<point> b (7, point(2));
  b[0] = point ({1., 7.});
  b[1] = point ({2., 6.});
  b[2] = point ({3., 5.});
  b[3] = point ({4., 4.});
  b[4] = point ({5., 3.});
  b[5] = point ({6., 2.});
  b[6] = point ({7., 1.});

  vector<point> x (7, point(2));

  solve_cyclic_tridiagonal_system (alpha, beta, gamma, b, x);

  cout << "x = " << endl;
  for (size_t i = 0; i != 7; i++) {
    cout << "[  " << x[i](1) << " ,  " << x[i](2) << "  ]" << endl;
  }
}
