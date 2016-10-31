@* Point in Euclidean space.
|point| 타입은 일반적인 $n$-차원 유클리드 공간에 존재하는 하나의 점을 기술한다.

@<Definition of |point|@>=
struct point { @/
  @<Data members of |point|@>@;
  @<Methods of |point|@>@;
};




@ |point| 타입의 data member는 아주 간단하다.
$n$-차원 유클리드 공간에 존재하는 점은 $n$개의 좌표를 저장한다.

@<Data members of |point|@>=
vector<double> _elem;




@ |point| 타입에 대하여 적용할 수 있는 method들은
\item{1.} 객체에 대한 property들;
\item{2.} Constructor들과 destructor;
\item{3.} Assignment, 덧셈과 뺄셈, 상수배 등의 연산자들;
\item{4.} 점들 사이의 거리를 계산하는 등의 utility 함수들
이 있다.

@<Implementation of |point|@>=
@<Properties of |point|@>@;
@<Constructors and destructor of |point|@>@;
@<Operators of |point|@>@;
@<Other member functions of |point|@>@;
@<Non-member functions for |point|@>@;




@ |point| 타입의 객체가 갖는 property에 접근하기 위한 몇 가지 method들을 정의한다.
|dimension ()|과 |dim ()| method는 |point| 타입의 객체가 몇 차원 공간의
점인지 알려준다.

@<Properties of |point|@>=
size_t point::dimension () const @+ {
  return (this -> _elem).size();
}

size_t point::dim () const @+ {
  return (this -> _elem).size();
}

@ @<Methods of |point|@>=
size_t dimension () const;
size_t dim () const;





@ |point| 타입의 constructor와 destructor를 정의한다.
\def\myitem#1{\item{$\bullet$}#1}
\myitem{아무런 argument가 주어지지 않는 경우 몇 차원의 |point| 객체를 생성해야
  할지 알 수 없으므로, default constructor의 생성을 방지한다.
    (\CPLUSPLUS/11 필요.)}

\myitem{복사 생성자 (copy constructor)는 직접 정의하고, 임의 갯수의 |double| 타입
  인자를 받아 그 갯수만큼의 차원을 갖는 |point| 객체를 생성하기 위하여
  |initializer_list|를 이용한 생성자를 구현한다.}

\myitem{생성자의 인자로 단 하나의 정수 $n$만 주어지면, 모든 원소가 0인 $n$-차원
  |point| 객체를 생성한다.}

\myitem{|double|타입의 배열로부터 |point| 객체를 생성하는 constructor를
정의한다.}

@s initializer_list int

@<Constructors and destructor of |point|@>=
point::point (const point& src) @/
@t\idt@> : _elem (src._elem)
{}

point::point (initializer_list<double> v)
@t\idt@> : _elem (vector<double>(v.begin(), v.end()))
{}

point::point (const double v1, const double v2, const double v3)
@t\idt@> : _elem (vector<double>(3)) @/
{
  _elem[0] = v1;
  _elem[1] = v2;
  _elem[2] = v3;
}

point::point (const size_t n)
@t\idt@> : _elem (vector<double>(n, 0.))
{}

point::point (const size_t n, const double* v)
@t\idt@> : _elem (vector<double>(n, 0.)) @/
{
  for (size_t i = 0; i != n; i++) {
    _elem[i] = v[i];
  }
}

point::~point () @+ {
}

@ @<Methods of |point|@>+=
point () =delete;
point (const point&);
point (initializer_list<double>);
point (const double, const double, const double v3 = 0.);
point (const size_t);
point (const size_t, const double*);
virtual	~point();





@ Operators of point.
|point| 타입 객체들 사이의 덧셈과 뺄셈, scalar와의 곱셈과 나눗셈을 위한 method들을
정의한다.  덧셈과 뺄셈, scalar와의 곱셈, 나눗셈의 구현은 매우 자명하므로
설명은 생략한다.
나눗셈의 경우 젯수가 0이면 아무런 연산도 수행하지 않고 그대로 리턴한다.

@<Operators of |point|@>=
void point::operator= (const point& src) @+ {
  _elem = src._elem;
}

point& point::operator *= (const double s) @+ {
  size_t sz = this -> dim();
  for (size_t i = 0; i != sz; i++) {
    (this -> _elem[i]) *= s;
  }
  return *this;
}

point& point::operator /= (const double s) @+ {
  if (s == 0.) return *this;
  size_t sz = this -> dim();
  for (size_t i = 0; i != sz; i++) {
    (this -> _elem[i]) /= s;
  }
  return *this;
}

point& point::operator += (const point& pt) @+ {
  size_t sz_min = min (this -> dim(), pt.dim());
  for (size_t i = 0; i != sz_min; i++) {
    (this -> _elem[i]) += pt._elem[i];
  }
  return *this;
}

point& point::operator -= (const point& pt) @+ {
  size_t sz_min = min (this -> dim(), pt.dim());
  for (size_t i = 0; i != sz_min; i++) {
    (this -> _elem[i]) -= pt._elem[i];
  }
  return *this;
}

@ @<Methods of |point|@>+=
void  operator= (const point&);
point& operator*= (const double);
point& operator/= (const double);
point& operator+= (const point&);
point& operator-= (const point&);




@ 몇 가지 이항연산자들과 단항연산자(negation)를 추가로 정의한다.
두 개의 |point| 타입 변수 |a|와 |b|에 대하여 |a+b|를 |operator+ (point, point)|
함수 내에서 |return pt1+=pt2|로 구현되어 있다고 해서 |a|가 바뀌는 것은 아니다.
이는 함수 호출의 convention이 call-by-value이기 때문에 |a|와 |b|가 각각 |pt1|와
|pt2|로 복사되기 때문이다.  따라서 |pt1|은 값이 바뀌지만 원래 expression을
구성하는 |a|는 바뀌지 않는다.

@<Non-member functions for |point|@>+=
point cagd::operator* (double s, point pt) @+ {
  return pt*=s;
}

point cagd::operator* (point pt, double s) @+ {
  return pt*=s;
}

point cagd::operator/ (point pt, double s) @+ {
  return pt/=s;
}

point cagd::operator+ (point pt1, point pt2) @+ {
  return pt1+=pt2;
}

point cagd::operator- (point pt1, point pt2) @+ {
  return pt1-=pt2;
}

point cagd::operator- (point pt1) @+ {
  size_t sz = pt1.dim();
  cagd::point negated (sz);
  for (size_t i = 0; i != sz; i++) {
    negated._elem[i] = -pt1._elem[i];
  }
  return negated;
}

@ @<Declaration of |cagd| functions@>=
point operator* (double, point);
point operator* (point, double);
point operator/ (point, double);
point operator+ (point, point);
point operator- (point, point);
point operator- (point);




@ $n$-차원 공간에 존재하는 |point| 타입 객체의 $i$ 번째 좌표에 접근하기 위한
subscript
operator를 정의한다.  \CEE/나 \CPLUSPLUS/ 언어에서는 0이 첫 번째 원소를
가리키는 subscript operator를 사용하지만, |point| 객체에서는 $i$ 번째 원소는
인덱스 $i$가 가리키도록 구현한다.
특히 subscript operator는 |const| 객체와 non-|const| 객체를 대상으로 호출하는
method를 각각 정의하는데, 코드 중복을 피하기 위하여 후자는 전자에 type
casting을 활용하여 정의한다.

비상수 객체를 대상으로 하는 |operator()|가 상수 버전의 |operator()|를
호출하도록 하기 위하여,
비상수 |operator()| 안에서 단순히 |operator()|를 다시 호출하면 그 자신이
재귀적으로 호출된다.
즉 무한 재귀 호출이 되는데, 이것을 방지하기 위하여
``상수 버전의 |operator()|를 호출하고 싶다''는
의미를 코드에 표현해야 한다.  이 때 직접적인 방법이 없으므로 |*this|를 타입
캐스팅해서
비상수 버전의 객체를 상수버전의 객체로 바꾼다.
이는 안전한 타입 변환을 강제로 수행하는 것이므로, |static_cast|만 사용해도
충분하다.
반면, 상수 버전의 |operator()|를 호출해서 반환 받은 객체에서 상수성을 제거하고
비상수 객체를
반환해야 하므로, |const|를 제거해야 하는데, 이는 |const_cast| 이외의 다른
방법이 없다.
따라서, 비상수 버전의 |operator()|는 다음의 순서대로 작동한다.

\item{1.} |(*this)|의 타입에 |static_cast|를 적용하여 |const| 객체로 변환.
\item{2.} 상수 버전의 |operator()|를 호출.
\item{3.} 돌려 받은 |double&| 타입에 |const_cast|를 적용하여 상수성을 제거.

끝으로, \CEE/나 \CPLUSPLUS/의 일반적인 컨벤션과 달리, 이 연산자는 첫 번째
원소를 얻기 위하여 1을 입력 인자로 넘겨줘야 한다.
주어진 인자가 |point| 객체의 차원을 벗어나면 첫 번째 좌표를 반환한다.

@<Operators of |point|@>+=
const double& point::operator() (const size_t& i) const @+ {
  size_t size = _elem.size();
  if ((i < 1) || (size < i)) {
    return _elem[0];
  } @+ else {
    return _elem[i-1];
  }
}

double& point::operator() (const size_t& i) @+ {
  return const_cast<double&>(static_cast<const point&>(*this)(i));
}

@ @<Methods of |point|@>+=
const double& operator() (const size_t&) const;
double& operator() (const size_t&);




@ |dist()| method는 본 객체와 다른 |point| 타입 객체 사이의
거리(Euclidean distance, 2-norm)을 계산한다.
편의상, 두 객체가 같은 차원의 공간에 놓인 점들이 아니라면 -1.0을 반환한다.

@<Other member functions of |point|@>+=
double
point::dist (const point& pt) const @+ {
  if (this -> dim() != pt.dim()) return -1.;

  size_t n = this -> dim();
  double sum = 0.0;
  for (size_t i = 0; i != n; i++) {
    sum += (_elem[i] - pt._elem[i])*(_elem[i] - pt._elem[i]);
  }
  return std::sqrt (sum);
}

@ @<Methods of |point|@>+=
double dist (const point&) const;




@ Debugging을 위해 |point| 타입 객체에 대한 정보를 출력하는 method를 정의한다.

@<Other member functions of |point|@>+=
string point::description () const @+ {
  stringstream buffer;
  buffer << "( ";
  for (size_t i=0; i!=dim()-1; i++) {
    buffer << _elem[i] << ", ";
  }
  buffer << _elem[dim()-1] << " )" << endl;

  return buffer.str();
}

@ @<Methods of |point|@>+=
string description () const;



@ |point| 타입의 member method는 아니지만 두 |point| 객체 사이의 거리를
계산하기 위한 utility 함수를 정의한다.

@<Non-member functions for |point|@>+=
double cagd::dist (const point& pt1, const point& pt2) @+ {
  return pt1.dist (pt2);
}

@ @<Declaration of |cagd| functions@>+=
double dist (const point&, const point&);




@ Test of |point| type.  |point| 객체의 생성과 간단한 연산 기능들을 테스트하고
사용예시를 보여준다.

@<Test routines@>+=
print_title ("operations on point type");
{
  point p0 (3);
  cout << "Dimension of p0 = " << p0.dim() << " : ";
  for (size_t i = 0; i != p0.dim(); i++) {
    cout << p0(i+1) << "  ";
  }
  cout << "\n\n";

  point p1 ({1., 2., 3.});
  cout << "Dimension of p1 = " << p1.dim() << " : ";
  for (size_t i = 0; i != p1.dim(); i++) {
    cout << p1(i+1) << "  ";
  }
  cout << "\n\n";

  point p2 ({2., 4., 6.});
  point p3 = .5*p1 + .5*p2;
  cout << "p3 = .5(1,2,3) + .5(2,4,6) = ";
  for (size_t i = 0; i != p3.dim(); i++) {
    cout << p3(i+1) << "  ";
  }
  cout << "\n\n";

  cout << "Distance from p0 to p1 = " << dist (p0, p1) << "\n";
  cout << "  (It should be 3.741657387)\n\n";
}
