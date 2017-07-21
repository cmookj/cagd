@q ************************************************************************** @>
@q                                                                            @>
@q                          B E Z I E R    C U R V E                          @>
@q                                                                            @>
@q ************************************************************************** @>
@* B\'ezier Curve.

|bezier| 타입은 $n$-차원 유클리드 공간에 존재하는 컨트롤 포인트를 갖는 \bezier\
곡선을 기술한다.  앞에서 정의한 |curve| 타입의 파생 클래스 (derived class)로
정의한다.

@<Definition of |bezier|@>=
class bezier : public curve {
  @<Data members of |bezier|@>@;
  @<Methods of |bezier|@>@;
};




@ |bezier| 타입은 \bezier\ 곡선의 차수를 저장하기 위한 |_degree| 변수와,
실제 컨트롤 포인트들을 저장하고 위한 |_ctrl_pts| 변수는 |curve| 타입에서 
상속받는다.

@<Data members of |bezier|@>=
protected:@/
  unsigned long _degree;





@ |bezier| 타입에 대한 method들은 다음과 같다.
\beginitems
\item{1.} Properties;
\item{2.} Constructor들과 destructor;
\item{3.} Operators;
\item{4.} 곡선상 점들의 위치와 속도, 곡률을 계산하는 methods;
\item{5.} 곡선을 임의의 점에서 분할하는 method;
\item{5.} 곡선의 차수를 높이거나 낮추기 위한 methods;
\item{6.} PostScript 파일로 출력하기 위한 methods.
\enditems 

@<Implementation of |bezier|@>=
@<Properties of |bezier|@>@;
@<Constructors and destructor of |bezier|@>@;
@<Operators of |bezier|@>@;
@<Evaluation of |bezier|@>@;
@<Subdivision of |bezier|@>@;
@<Degree elevation and reduction of |bezier|@>@;
@<Output to PostScript of |bezier|@>@;




@ |bezier| 타입의 대표적인 property는 곡선의 차수(degree)와 차원(dimension)이다.
차원에 대한 것은 |curve| 타입에서 정의했으므로, |bezier| 타입에서 별도로 
정의하지는 않는다.

@<Properties of |bezier|@>=
unsigned long
bezier::degree () const @+ {
  return _degree;
}

@ @<Methods of |bezier|@>+=
public: @/
unsigned long degree () const;




@ 몇 가지 생성자들을 정의한다.
간단한 복사 생성자와 standard library의 |vector| 또는 |list|를 이용하여
컨트롤 포인트들을 넘겨 받았을 때 곡선을 생성하는 생성자들이다.

@<Constructors and destructor of |bezier|@>=
bezier::bezier () @+ {}

bezier::bezier (const bezier& src) @+ {
  _degree = src._degree;
  _ctrl_pts = src._ctrl_pts;
}

bezier::bezier (vector<point> points) @+ {
  _degree = points.size() - 1;
  _ctrl_pts = points;
}

bezier::bezier (list<point> points) @+ {
  _degree = points.size() - 1;
  _ctrl_pts = vector<point> (points.size(), *points.begin());
  list<point>::const_iterator iter = points.begin();
  for (size_t i = 0; iter != points.end(); iter++, i++) {
    _ctrl_pts[i] = *iter;
  }
}

bezier::~bezier() @+ {
}

@ @<Methods of |bezier|@>+=
public:@/
  bezier ();
  bezier (const bezier&);
  bezier (vector<point>);
  bezier (list<point>);
  virtual ~bezier ();




@ 다른 |bezier| 객체로부터의 assignment operator.

@<Operators of |bezier|@>=
bezier& bezier::operator= (const bezier& src) @+ {
  _degree = src._degree;
  curve::operator= (src);

  return *this;
}

@ @<Methods of |bezier|@>+=
public: @/
bezier& operator= (const bezier&);

@ @<Error codes of |cagd|@>+=
DEGREE_MISMATCH,




@ \bezier\ 곡선상 각 점의 위치와 속도는 de Casteljau의 recursive linear 
interpolation algorithm을 이용한다.

@<Evaluation of |bezier|@>=
point
bezier::evaluate (const double t) const @+ {
  vector<point> coeff;
  for (size_t i = 0; i != _ctrl_pts.size(); ++i) {
    coeff.push_back (_ctrl_pts[i]);
  }
  double t1 = 1.0 - t;
  for (size_t r = 1; r != _degree+1; r++) {
    for (size_t i = 0; i != _degree-r+1; i++) {
      coeff[i] = t1*coeff[i] + t*coeff[i+1];
    }
  }
  return coeff[0];
}

point
bezier::derivative (const double t) const @+ {
  vector<point> coeff;
  for (size_t i = 0; i != _ctrl_pts.size() - 1; ++i) {
    coeff.push_back(_degree*(_ctrl_pts[i+1] - _ctrl_pts[i]));
  }
  double t1 = 1.0 - t;
  for (size_t r = 1; r != _degree; r++) {
    for (size_t i = 0; i != _degree - r ; i++) {
      coeff[i] = t1*coeff[i] + t*coeff[i+1];
    }
  }
  return coeff[0];
}

@ @<Methods of |bezier|@>+=
public: @/
point evaluate (const double) const;
point derivative (const double) const;




@ \bezier\ 곡선의 임의의 점에서 곡률을 계산하는 method를 정의한다.
|curvature_at_zero()| 함수는 곡선 시작점에서의 곡률을 계산한다.
|signed_curvature()| 함수는 |b|부터 |e|까지로 한정되는 곡선의 일부 구간에 대하여
곡률을 계산한다.
먼저 곡률을 계산할 구간을 |density|개의 등간격으로 나누고, 각 지점에서 \bezier\
곡선의 subdivision을 구한다.
계산의 수치적 안정성을 위하여 둘로 나뉜 곡선 조각들 중 큰 쪽에서 
|curvature_at_zero()|
함수를 이용하여 곡률을 계산하고 그 결과를 하나의 |vector| 객체에 담아 반환한다.
|curvature_at_zero()| 함수는 |signed_area()| 함수를 이용하여 부호가 붙은 곡률을 
반환하므로,
곡선의 전반부에서 계산하는 곡률은 부호를 반대로 뒤집어서 반환함에 유의한다.

@<Evaluation of |bezier|@>+=
double @/
bezier::curvature_at_zero() const @+ {
  double dist = cagd::dist (_ctrl_pts[0], _ctrl_pts[1]);
  return 2.0*(_degree - 1) * @/
    cagd::signed_area (_ctrl_pts[0], _ctrl_pts[1], _ctrl_pts[2])
    / (_degree * dist * dist * dist);
}

vector<point> @/
bezier::signed_curvature(const unsigned density,
                         const double b,
                         const double e
                         ) const @+ {
/* |b|: begin of the interval.
   |e|: end of the interval.
*/
  double delta = (e-b)/density;
  unsigned half = density/2;
  vector<point> kappa;
@#
  for (size_t i = 0; i <= density; i++) {
    double t = b + i*delta;
    bezier left (*this);
    bezier right (*this);
    if (i <= half) {
      subdivision (t, left, right);
      double h = right.curvature_at_zero();
      kappa.push_back (point ({t, h}));
    } @+ else {
      subdivision (t, left, right);
      double h = left.curvature_at_zero();
      kappa.push_back (point ({t, std::fabs(-h)}));
    }
  }
  return kappa;
}

@ @<Methods of |bezier|@>+=
public: @/
double curvature_at_zero () const;
vector<point> signed_curvature (const unsigned,
                   const double b=0., const double e=1.) const;




@ |signed_area()| 함수는 2-차원 평면상에 존재하는 세 개의 점으로 이루어지는
삼각형의 면적을 계산한다.

@<Implementation of |cagd| functions@>+=
double
cagd::signed_area (const point p1, const point p2, const point p3) @+ {
  double area;
  area = ((p2(1)-p1(1))*(p3(2)-p1(2)) - (p2(2)-p1(2))*(p3(1)-p1(1)))/2.0;
  return area;
}

@ @<Declaration of |cagd| functions@>+=
double signed_area (const point, const point, const point);


@ \bezier\ 곡선을 임의의 점에서 두 개의 곡선으로 분할하는 method를 정의한다.
이해를 돕기 위해 컨트롤 포인트 $\bbb_0$, $\bbb_1$, $\bbb_2$, $\bbb_3$로 정의되는
3차 \bezier\ 곡선을
파라미터~$c$인 지점에서 둘로 나누는 과정을 설명한다.
\bezier\ 곡선을 두개로 분할하고 새로운 컨트롤 포인트들을 구하는 것은 de Casteljau
알고리즘을 적용하는 과정과 동일하다.
즉, 선분 $\bbb_i$-$\bbb_{i+1}$을 $c:1-c$로 내분하는 점을
$\bbb_i^1(c), (i=0, 1, 2)$이라 하고,
다시 선분 $\bbb_i^1(c)$-$\bbb_{i+1}^1(c)$를 $c:1-c$로 내분하는 점을
$\bbb_i^2(c) (i=0, 1)$, 또 선분 $\bbb_i^2(c)$-$\bbb_{i+1}^2(c)$를 $c:1-c$로
내분하는 점을 $\bbb_i^3(c) (i=0)$이라 하자.
그러면 파라미터 $[0,c]$ 구간에 해당하는 곡선의 분할에 대한 새로운 컨트롤 
포인트들은
$\bbc_0=\bbb_0$, $\bbc_1=\bbb_0^1(c)$, $\bbc_2=\bbb_0^2(c)$, 
  $\bbc_c=\bbb_0^3(c)$가 된다.
$[c,1]$ 구간도 마찬가지로 de Casteljau 알고리즘에 의해 얻어지는 중간 단계의 
점들이 새로운 컨트롤 포인트가 된다.
\medskip
\noindent\centerline{%
\includegraphics{figs/fig-1.mps}}
\medskip

@<Subdivision of |bezier|@>=
void
bezier::subdivision (double t, bezier& left, bezier& right) const @+ {
  double t1 = 1.0 - t;
  vector<point> points;		// temporary store
@#
  @<Obtain the right subpolygon of \bezier\ curve@>;
  @<Obtain the left subpolygon of \bezier\ curve@>;
}

@ 우측, 즉 파라미터 $[c,1]$ 구간에 대한 control polygon을 구한다.
먼저 control point들을 temporary store에 복사하고, 그 point들에 de Casteljau 
알고리즘을 적용하여 subpolygon의 control point들을 구한다.
Temporary store들어 있던 결과가 우측 부분 곡선의 control point들이므로 그것들을 
복사해 온다.

@<Obtain the right subpolygon of \bezier\ curve@>=
right._ctrl_pts.clear();
right._degree = _degree;
for (size_t i = 0; i != _ctrl_pts.size(); i++) {
  points.push_back (_ctrl_pts[i]);
}
@<Obtain the right subpolygon using the de Casteljau algorithm@>;
for (size_t i = 0; i != (_degree + 1); i++) {
  right._ctrl_pts.push_back (points[i]);
}

@ @<Obtain the right subpolygon using the de Casteljau algorithm@>=
for (size_t r = 1; r != _degree+1; r++) {
  for (size_t i = 0; i != _degree-r+1; i++) {
    points[i] = t1*points[i] + t*points[i+1];
  }
}

@ 왼쪽, 즉 파라미터 $[0,c]$ 구간에 대한 control polygon을 구한다.
방법은 오른쪽 부분 곡선을 구할때와 마찬가지인데, control point들을 temporary 
store에 역순으로 복사하고 $t$를 $1-t$로 바꿔 놓은 후 de Casteljau 알고리즘을 
적용한다.
즉, 곡선과 파라미터를 모두 뒤집어 놓고 같은 과정을 반복하는 것이다.

@<Obtain the left subpolygon of \bezier\ curve@>=
t = 1.0 - t;
t1 = 1.0 - t1;
points.clear();
left._ctrl_pts.clear();
left._degree = _degree;
unsigned long index = _degree;
for (size_t i = 0; i != _ctrl_pts.size(); i++) { // Reverse order.
  points[index--] = _ctrl_pts[i];
}
@<Obtain the left subpolygon using de Casteljau algorithm@>;
for (size_t i = 0; i != _degree+1; i++) {
  left._ctrl_pts.push_back (points[i]);
}

@ @<Obtain the left subpolygon using de Casteljau algorithm@>=
for (size_t r = 1; r != _degree+1; r++) {
  for (size_t i = 0; i != _degree-r+1; i++) {
    points[i] = t1*points[i] + t*points[i+1];
  }
}

@ @<Methods of |bezier|@>+=
public: @/
void subdivision (const double, bezier&, bezier&) const;




@ \bezier\ 곡선의 차수를 높이는 method를 구현한다.
|elevate_degree()|는 \bezier\ 곡선의 차수를 하나 높이며, 여러 차수를 한번에 
높이려면 recursion을 수행한다.  따라서 method 시작부분에서는 오류처리와 
종료조건을 점검하며, 그 이후에는 컨트롤 포인트를 하나 추가하는 작업을 한다.
만약 현재 곡선의 차수보다 낮은 차수로 올리려고 하면 (nonsense!), 객체 내에
|DEGREE_ELEVATION_FAIL| 오류코드를 저장하고 바로 반환한다.

@<Degree elevation and reduction of |bezier|@>=
void bezier::elevate_degree (unsigned long dgr) @+ {
  if (_degree > dgr) {
    _err = DEGREE_ELEVATION_FAIL;
    return;
  }
  if (_degree == dgr) {
    return;
  }
  _degree++;
  point backup_point = _ctrl_pts[0];
  unsigned long counter = 1;
  for (size_t i = 1; i != _ctrl_pts.size(); ++i) {
    point tmp_point = backup_point;
    backup_point = _ctrl_pts[i];
    double ratio = double(counter)/double(_degree);
    _ctrl_pts[i] = ratio*tmp_point + (1.0 - ratio)*backup_point;
    counter++;
  }
  _ctrl_pts.push_back (backup_point);
  return elevate_degree (dgr);
}

@ @<Methods of |bezier|@>+=
public: @/
void elevate_degree (unsigned long);

@ @<Error codes of |cagd|@>+=
DEGREE_ELEVATION_FAIL,




@ 다음에 정의할 함수를 위해 먼저 factorial을 구하는 함수를 |cagd| namespace에 
정의한다.

@<Implementation of |cagd| functions@>+=
unsigned long cagd::factorial (unsigned long n) @+ {
  if (n <= 0) {
    return 1UL;
  } @+ else {
    return n*factorial (n-1);
  }
}

@ @<Declaration of |cagd| functions@>+=
unsigned long factorial (unsigned long);




@ \bezier\ 곡선의 차수를 낮추는 method를 구현한다.
이 함수도 차수를 하나씩 낮추도록 구현되어 있으며, 한번에 여러 차수를 낮추려면
recursion을 수행한다.

앞에서 설명했듯이, $n$차 \bezier\ 곡선을 정확하게 $n+1$차 \bezier\ 곡선으로 차수를
높이는 것은 가능하지만, $n+1$차 \bezier\ 곡선의 형상 변화 없이 $n$차 \bezier\
곡선으로 차수를 낮추는 것은 불가능하다.
어느 정도 곡선의 변화를 수반할 수 밖에 없는데,
이는 $n+2$개의 컨트롤 포인트들, ${\bf b}_i^{(1)}\,(i=0,\ldots, n+1)$을
$n+1$개의 컨트롤 포인트들, ${\bf b}_i\,(i=0,\ldots,n)$로 근사화하는 다음의 문제로
  이해할 수 있다. ($n$차 \bezier\ 곡선은 $n+1$개의 컨트롤 포인트들을 갖는다.)
$$\left(\matrix{1&&&&&\cr
                *&*&&&&\cr
                &*&*&&&\cr
                &&&\ddots&&\cr
                &&&&*&*\cr
                &&&&&1\cr}\right)
\left(\matrix{\bbb_0\cr \vdots\cr \bbb_n\cr}\right)
=\left(\matrix{\bbb_0^{(1)}\cr \vdots\cr \bbb_{n+1}^{(1)}\cr}\right).$$
이를 다시 줄여 쓰면,
$$M{\bf B}={\bf B}^{(1)}$$
이며, $M$은 $(n+2)\times(n+1)$ 행렬이다.
이는 정방행렬이 아니므로 위의 등식을 풀기 위하여 양변에 $M^\top$을 곱하면,
$$M^\top M{\bf B}=M^\top{\bf B}^{(1)}$$
으로 $M^\top M$이 정방행렬이므로 역행렬을 구해서 양변에 곱함으로써 해를 구할
수 있다.
$M$ 행렬 주대각의 첫 번째원소와 마지막 원소가 1인 것은 \bezier\ 곡선의 차수를
낮추더라도 시작점과 끝점은 그대로 유지하기 위함이다.

만약 현재 곡선의 차수보다 높은 차수로 낮추려고 하면 (nonsense!)
|DEGREE_REDUCTION_FAIL| 오류코드를 남기고 method는 즉시 반환한다.

@<Degree elevation and reduction of |bezier|@>+=
void bezier::reduce_degree (const unsigned long dgr) @+ {
  if (_degree < dgr) {
    _err = DEGREE_REDUCTION_FAIL;
    return;
  }
  if (_degree == dgr) {
    return;
  }

  vector<point> l2r;
  l2r.push_back(_ctrl_pts[0]);
  unsigned long counter = 1;
  for (size_t i = 1; i != _ctrl_pts.size() - 1; ++i) {
    l2r.push_back ((double(_degree)*_ctrl_pts[i] - double(counter)*(l2r.back()))
                /double(_degree - counter));
    counter++;
  }

  vector<point> r2l_reversed;
  r2l_reversed.push_back (_ctrl_pts.back());
  counter = _degree;
  for (size_t i = _ctrl_pts.size() - 2; i != 0; --i) {
    r2l_reversed.push_back ((double(_degree)*(_ctrl_pts[i])
        - double(_degree - counter)*r2l_reversed.front())/double(counter));
    counter--;
  }
  vector<point> r2l;
  size_t r2l_reversed_size = r2l_reversed.size();
  for (size_t i = 0; i != r2l_reversed_size; i++) {
    r2l.push_back (r2l_reversed.back ());
    r2l_reversed.pop_back ();
  }

  point backup1 = _ctrl_pts[0];
  point backup2 = _ctrl_pts.back();
  _ctrl_pts.clear();
  _ctrl_pts.push_back(backup1);

  for (size_t i = 1; i <= _degree - 2; ++i) {
    unsigned long combi = 0;
    for (size_t j = 0; j <= i; ++j) {
      combi += cagd::factorial(2*_degree)/
            (cagd::factorial(2*j)*cagd::factorial(2*(_degree - j)));
    }
    double lambda = double(combi)/std::pow(2., 2*_degree - 1);
    _ctrl_pts.push_back((1.0 - lambda)*l2r[i] + lambda*r2l[i]);
  }

  _ctrl_pts.push_back (backup2);
  _degree--;
  return reduce_degree (dgr);
}

@ @<Methods of |bezier|@>+=
public: @/
void reduce_degree (const unsigned long);

@ @<Error codes of |cagd|@>+=
DEGREE_REDUCTION_FAIL,



@ \bezier\ curve의 PostScript 출력을 위한 몇 가지 함수들을 정의한다.
|write_curve_in_postscript()| 함수는 \bezier\ 곡선을 그리기 위한 함수.
PostScript은 2-차원 평면 용지에 페이지를 기술하는 언어이므로, $n$-차원 공간에 
존재하는 \bezier\ 곡선의 몇 번째와 몇 번째 좌표를 그릴 것인지 지정해야 한다.
만약 아무런 지정이 없으면, 첫 번째와 두 번째 좌표를 출력한다.

@<Output to PostScript of |bezier|@>=
void
bezier::write_curve_in_postscript (@/
  @t\idt@>psf& ps_file, @/
  @t\idt@>unsigned step,@/
  @t\idt@>float line_width,@/
  @t\idt@>int x, int y,@/
  @t\idt@>float magnification@/
  @t\idt@>) const @+ {

  ios_base::fmtflags previous_options = ps_file.flags();
  ps_file.precision(4);
  ps_file.setf (ios_base::fixed, ios_base::floatfield);
  ps_file << "newpath" << endl
          << "[] 0 setdash " << line_width << " setlinewidth" << endl;
  point pt = magnification*evaluate (0);
  ps_file << pt(x) << "\t" << pt(y) << "\t"
          << "moveto" << endl;
  for (size_t i = 1; i <= step; i++) {
    double t = double(i)/double(step);
    pt = magnification*evaluate (t);
    ps_file << pt(x) << "\t" << pt(y) << "\t"
            << "lineto" << endl;
  }
  ps_file << "stroke" << endl;
  ps_file.flags (previous_options);
}

void
bezier::write_control_polygon_in_postscript (@/
  @t\idt@>psf& ps_file,@/
  @t\idt@>float line_width,@/
  @t\idt@>int x, int y,@/
  @t\idt@>float magnification@/
  @t\idt@>) const @+ {

  ios_base::fmtflags previous_options = ps_file.flags();
  ps_file.precision(4);
  ps_file.setf (ios_base::fixed, ios_base::floatfield);
  ps_file << "newpath" << endl;
  ps_file << "[] 0 setdash " << .5*line_width << " setlinewidth" << endl;
  point	pt = magnification*_ctrl_pts[0];
  ps_file << pt(x) << "\t" << pt(y) << "\t"
          << "moveto" << endl;
  for (size_t i = 1; i != _ctrl_pts.size(); ++i) {
    pt = magnification*_ctrl_pts[i];
    ps_file << pt(x) << "\t" << pt(y) << "\t"
            << "lineto" << endl;
  }
  ps_file << "stroke" << endl;
  ps_file.flags (previous_options);
}

void
bezier::write_control_points_in_postscript (@/
  @t\idt@>psf& ps_file,@/
  @t\idt@>float line_width,@/
  @t\idt@>int x, int y,@/
  @t\idt@>float magnification@/
  @t\idt@>) const @+ {

  ios_base::fmtflags previous_options = ps_file.flags();
  ps_file.precision(4);
  ps_file.setf (ios_base::fixed, ios_base::floatfield);

  ps_file << "0 setgray" << endl;
  ps_file << "newpath" << endl;

  point pt = magnification*_ctrl_pts[0];
  ps_file << pt(x) << "\t" << pt(y) << "\t";
  ps_file << (line_width*3) << "\t" << 0.0 << "\t" << 360 << "\t"
          << "arc" << endl;
  ps_file << "closepath" << endl;
  ps_file << "fill stroke" << endl;

  if (_ctrl_pts.size() > 2) @+ {
    for (size_t i = 1; i != _ctrl_pts.size() - 1; ++i) {
      ps_file << "newpath" << endl;
      pt = magnification*_ctrl_pts[i];
      ps_file << pt(x) << "\t" << pt(y) << "\t";
      ps_file << (line_width*3) << "\t" << 0.0 << "\t" << 360 << "\t"
              << "arc" << endl;
      ps_file << "closepath" << endl;
      ps_file << line_width << "\t" << "setlinewidth" << endl;
      ps_file << "stroke" << endl;
    }
    ps_file << "0 setgray" << endl;
    ps_file << "newpath" << endl;
    pt = magnification*_ctrl_pts.back();
    ps_file << pt(x) << "\t" << pt(y) << "\t";
    ps_file << (line_width*3) << "\t" << 0.0 << "\t" << 360 << "\t"
            << "arc" << endl;
    ps_file << "closepath" << endl;
    ps_file << "fill stroke" << endl;
  }
  ps_file.flags (previous_options);
}

@ @<Methods of |bezier|@>+=
void write_curve_in_postscript (@/
  @t\idt@>psf&, unsigned, float, int x=1, int y=2,@/
  @t\idt@>float magnification=1.) const;

void write_control_polygon_in_postscript (@/
  @t\idt@>psf&, float, int x=1, int y=2,@/
  @t\idt@>float magnification=1.) const;

void write_control_points_in_postscript (@/
  @t\idt@>psf&, float, int x=1, int y=2,@/
  @t\idt@>float magnification=1.) const;
