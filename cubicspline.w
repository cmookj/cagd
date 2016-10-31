@q ************************************************************************** @>
@q                                                                            @>
@q                          C U B I C    S P L I N E                          @>
@q                                                                            @>
@q ************************************************************************** @>

@* Cubic Spline Curve.

@s cubic_spline int

@<Definition of |cubic_spline|@>=
class cubic_spline : public curve {
  @<Data members of |cubic_spline|@>@;
  @<Enumerations of |cubic_spline|@>@;
  @<Methods of |cubic_spline|@>@;
};




@ |cubic_spline| 타입은 spline 곡선의 knot sequence를 data member로 갖는다.
컨트롤 포인트들을 저장하는 멤버는 |curve| 타입으로부터 상속받는다.
그리고 knot sequence를 반복문에서 간편하게 지칭하기 위한 iterator들의 타입을
선언한다.
OpenCL을 이용해서 곡선상의 점들을 한꺼번에 계산하기 위한 |mpoi| 타입의 객체를
멤버로 갖는다.

@s knot_itr int
@s const_knot_itr int
@s mpoi int

@<Data members of |cubic_spline|@>=
protected:@/
vector<double> _knot_sqnc;
mutable mpoi _mp;
size_t _kernel_id;

protected:@/
typedef vector<double>::iterator knot_itr;
typedef vector<double>::const_iterator const_knot_itr;




@ |cubic_spline| 타입의 method들은 다음과 같다.

@<Implementation of |cubic_spline|@>=
@<Constructors and destructor of |cubic_spline|@>@;
@<Properties of |cubic_spline|@>@;
@<Operators of |cubic_spline|@>@;
@<Description of |cubic_spline|@>@;
@<Evaluation and derivative of |cubic_spline|@>@;
@<Methods for interpolation of |cubic_spline|@>@;
@<Methods to obtain a |bezier| curve for a segment of |cubic_spline|@>@;
@<Methods to calculate curvature of |cubic_spline|@>@;
@<Methods for knot insertion and removal of |cubic_spline|@>@;
@<Methods for PostScript output of |cubic_spline|@>@;
@<Miscellaneous methods of |cubic_spline|@>@;




@ 다른 |cubic_spline| 객체가 주어졌을 때 그것을 복제하는 복사생성자와,
그리고 (당연하게도) knot sequence와 control point들이 주어졌을 때 그것에 상응하는
곡선을 생성하는 constructor를 정의한다.

@<Constructors and destructor of |cubic_spline|@>=
cubic_spline::cubic_spline (const cubic_spline& src) @/
  @t\idt@>: curve (src),@/
  @t\idt@>_knot_sqnc (src._knot_sqnc),@/
  @t\idt@>_mp (src._mp),@/
  @t\idt@>_kernel_id (src._kernel_id)
{
}

cubic_spline::cubic_spline (const vector<double>& knots,
                            const vector<point>& pts
                            ) @/
  @t\idt@>: curve (pts),@/
  @t\idt@>_mp ("./cspline.cl"),@/
  @t\idt@>_knot_sqnc (knots),@/
  @t\idt@>_kernel_id (_mp.create_kernel("evaluate_crv"))
{
}

cubic_spline::~cubic_spline() @+ {
}

@
@<Methods of |cubic_spline|@>+=
public: @/
cubic_spline () =delete;
cubic_spline (const cubic_spline&);
cubic_spline (const vector<double>&, const vector<point>&);
virtual ~cubic_spline ();




@ |cubic_spline| 객체의 대표적인 property는 차원과 차수다.
또한 knot sequence와 control point를 반환하는 method도 정의한다.

@<Properties of |cubic_spline|@>=
unsigned long
cubic_spline::degree () const @+ {
  return 3;
}

vector<double>
cubic_spline::knot_sequence () const @+ {
  return _knot_sqnc;
}

vector<point>
cubic_spline::control_points () const @+ {
  return _ctrl_pts;
}

@ @<Methods of |cubic_spline|@>+=
public: @/
unsigned long degree () const;
vector<double> knot_sequence () const;
vector<point> control_points () const;




@ Operators of |cubic_spline|.

@<Operators of |cubic_spline|@>=
cubic_spline& cubic_spline::operator= (const cubic_spline& crv) @+ {
  curve::operator= (crv);
  _knot_sqnc = crv._knot_sqnc;
  _mp = crv._mp;
  _kernel_id = crv._kernel_id;

  return *this;
}

@ @<Methods of |cubic_spline|@>+=
public:@/
cubic_spline& operator= (const cubic_spline&);




@ Debugging을 위한 method를 정의한다.

@<Description of |cubic_spline|@>=
string cubic_spline::description () const @+ {
  stringstream buffer;
  buffer << curve::description();
  buffer << "  Knot Scquence:" << endl;
  for (size_t i=0; i!=_knot_sqnc.size(); i++) {
    buffer << "    " << _knot_sqnc[i] << endl;
  }

  return buffer.str();
}

@ @<Methods of |cubic_spline|@>+=
public: @/
string description () const;




@ Cubic spline 곡선 위의 점은 잘 알려진바와 같이 de Boor 알고리즘으로 계산한다.
Degree $n$이고 $L$개의 다항함수 조각(polynomial segments)으로 이루어진 B-spline
곡선은 $L+2n-1$개의 nondecreasing knot sequence
$$u_0,\ldots,\underbrace{u_{n-1},\ldots,u_{L+n-1}}_{\rm domain\ knots},
\ldots,u_{L+2n-2}$$
를 갖는다.
이 때, 앞과 뒤 각각 $n$개씩의 knots에서는 곡선이 정의되지 않고,
가운데의 $L+1$개의 knots에서 곡선이 정의되기에 $[u_{n-1},\ldots,u_{L+n-1}]$를
domain knots라 부른다.

이 때, $n+L$개의 Greville abscissas
$$\xi_i={1\over n}(u_i+\cdots+u_{i+n-1});\quad i=0,\ldots,L+n-1$$
에 control point들이 대응된다.  이는 functional spline을 생각하면 좀 더
쉽게 이해되는데, 점 $(\xi_i, d_i);\ i=0,\ldots,L+n-1$들이 다각형 $P$를 이루고,
de Boor algorithm은 이 다각형으로부터 반복적인 piecewise linear
interpolation을 수행하여 곡선상의 점을 구하는 것이다.

구체적으로, degree $n$인 B-spline 곡선의
knot sequence ${u_j}$와 control points ${d_i}$가 있을때,
$u\in[u_I,u_{I+1})\subset[u_{n-1},u_{L+n-1}]$를 만족하는 $u$에 대응하는
곡선상의 점은,
$k=1,\ldots,n-r$, $i=I-n+k+1,\ldots,I-r+1$에 대하여
$$d_i^k(u)={u_{i+n-k}-u\over u_{i+n-k}-u_{i-1}}d_{i-1}^{k-1}(u)
+{u-u_{i-1}\over u_{i+n-k}-u_{i-1}}d_i^{k-1}(u)$$
을 반복적으로 계산한 결과
$$d_{I-r+1}^{n-r}(u)$$
이다.  이때, $r$은 $u$가 knot sequence 중 하나의 값일 때, 그것의
중첩도(multiplicity)이며, 특정한 knot sequence 값이 아니면 0으로 둔다.
위 점화식의 초기조건은
$$d_i^0(u)=d_i$$
로 둔다.  Knot sequence에 해당하지 않는 $u\in[u_I,u_{I+1}]$에 대한 de Boor
알고리즘을 그림으로 표시하면 다음과 같다:
$$\matrix{
d_{I-n+1}&&&&\cr
d_{I-n+2}&d_{I-n+2}^1&&&\cr
\vdots&\vdots&\ddots&&\cr
d_I&d_I^1&\cdots&d_I^{n-1}&\cr
d_{I+1}&d_{I+1}^1&\cdots&d_{I+1}^{n-1}&d_{I+1}^n\cr
}$$

|evaluate()| method는 세 가지 종류가 있다.
첫 번째는 evaluation abscissa $u$와 그것이 속하는 구간에 대한 index $I$를
입력으로 받는 method다.  Index $I$는 de Boor 알고리즘을 적용하기 위하여
반드시 필요한 것이지만, 대체로 곡선상의 점을 계산하기 위하여 일일이 $I$까지
알아내고 그것을 함께 인자로 전달하는 것은 번거로운 일이다.
따라서 두 번째 method는 evaluation abscissa $u$만 인자로 전달 받으며,
|find_index_in_knot_sequence()| 함수를 호출해서
$u[I]\leq u<u[I+1]$을 만족하는 정수 $I$를 찾는다.
끝으로 세 번째 method는 OpenCL을 이용해서 주어진 간격 수로 evaluation abscissa
범위를 등간격으로 나눈 후, 그 값들에 대응하는 곡선상의 점들을 한꺼번에 계산한다.

첫 번째와 두 번째 method는 de Casteljau의 repeated linear interpolation
algorithm의 일반화된 version이라고 이해할 수 있으므로 자세한 설명은 생략한다.

@<Evaluation and derivative of |cubic_spline|@>=
point
cubic_spline::evaluate (const double u, unsigned long I) const @+ {
  const unsigned long n = 3; // Degree of cubic spline.
  vector<point> tmp;

  for (size_t i = I-n+1; i != I+2; i++) {
    tmp.push_back(_ctrl_pts[i]);
  }

  long shifter = I - n + 1;
  for (size_t k = 1; k != n+1; k++) {
    for (size_t i = I+1; i != I-n+k; i--) {
      double t1 = (_knot_sqnc[i+n-k]-u)/(_knot_sqnc[i+n-k]-_knot_sqnc[i-1]);
      double t2 = 1.0 - t1;
      tmp[i-shifter] = t1*tmp[i-shifter-1] + t2*tmp[i-shifter];
    }
  }
  return tmp[I-shifter+1];
}

point
cubic_spline::evaluate (const double u) const @+ {
  return evaluate (u, find_index_in_knot_sequence (u));
}

@ @<Methods of |cubic_spline|@>+=
public: @/
point evaluate (const double, unsigned long) const;
point evaluate (const double) const;




@ Knot sequence의 domain knots 범위를 $N-1$개의 등간격으로 나누어 곡선위의
$N$개의 점을 한번에 계산하는 method를 구현한다.  즉, 곡선을 $N-1$개의
작은 선분 조각들로 근사화하는 셈이다.
이 method는 계산할 점의 갯수를 입력인자 |N|으로 받으며, 계산 결과를
|vector<point>| 타입으로 반환한다.

Kernel에서 계산한 $m$차원 공간의 $N$개의 점들, $\bbp_i$는 |pts|에
$$\bbp_0(1),\bbp_0(2),\ldots,\bbp_0(m),\ldots,
\bbp_{N-1}(1),\ldots,\bbp_{N-1}(m)$$
의 순서대로 저장되며, 최종적으로 이 method는 이것을 |vector<point>| 타입의 객체로
만들어 반환한다.

@s buffer_property int

@<Evaluation and derivative of |cubic_spline|@>+=
vector<point>@/
cubic_spline::evaluate_all (const unsigned N) const @+ {
  const unsigned n = 3;
  const unsigned L = static_cast<unsigned>(_knot_sqnc.size() -2*n +1);
  const unsigned m = static_cast<unsigned>(this->dim());

  size_t pts_buffer =
    _mp.create_buffer (mpoi::buffer_property::READ_WRITE,
                       N*m*sizeof(float));

  @<Calculate points on a cubic spline using OpenCL Kernel@>;

  float* pts = new float[N*m];
  _mp.enqueue_read_buffer (pts_buffer, N*m*sizeof(float), pts);

  vector<point> crv (N, point (m));
  for (size_t i=0; i!=N; i++) {
    point pt(m);
    for (size_t j=1; j!=m+1; j++) {
      pt(j) = static_cast<double>(pts[m*i +j -1]);
    }
    crv[i] = pt;
  }

  delete[] pts;
  _mp.release_buffer (pts_buffer);

  return crv;
}

@ @<Methods of |cubic_spline|@>+=
public:@/
vector<point> evaluate_all (const unsigned) const;




@ OpenCL로 작성한 kernel을 이용해서 spline 곡선상의 점들을 한꺼번에 계산한다.
Kernel에서 de Boor 알고리즘을 계산하려면
\beginitems
\item{1.} knot sequence and its cardinality
\item{2.} control points and their cardinality
\item{3.} evaluation abscissa
\item{4.} evaluation abscissa가 속한 knot sequence 구간의 index
\enditems
\noindent 를 모두 넘겨줘야한다.  첫 번째와 두 번째는 kernel의 모든
work item들이 공유하지만, 세 번째와 네 번째는 work item마다 자신의 고유한
값을 갖고 연산을 수행한다.

가장 먼저 수행할 작업은 곡선의 knot sequence와 control points를 표준
라이브러리의 |vector| 타입으로부터 꺼내 단일한 memory block으로 복사하는 일이다.
Knot sequence는 scalar 값이므로 순서대로 복사하고,
$m$ 차원 공간의 control point들도 순서대로 모든 원소들을 복사한다.
$k$개의 control point들, $\bbd_i$가 있다면 하나의 |double|형 배열에 아래와 
같이 저장된다:
$$\bbd_1(1),\bbd_1(2),\ldots,\bbd_1(m),\ldots,\bbd_k(1),\ldots,\bbd_k(m)$$

그 다음 OpenCL device의 memory에 입출력 data를 저장할 buffer object을
생성하고, memory buffer에 입력 data를 복사한다.
(OpenCL kernel은 항상 |void|를 반환한다.)

@<Calculate points on a cubic spline using OpenCL Kernel@>=
const unsigned num_knots = static_cast<unsigned>(_knot_sqnc.size());
const unsigned num_ctrlpts = static_cast<unsigned>(_ctrl_pts.size());

float* knots = new float[num_knots];
float* cp = new float[num_ctrlpts*m];

size_t knots_buffer = _mp.create_buffer (mpoi::buffer_property::READ_ONLY,
                                         num_knots*sizeof(float));
size_t cp_buffer = _mp.create_buffer (mpoi::buffer_property::READ_ONLY,
                                      num_ctrlpts*m*sizeof(float));

for (size_t i = 0; i != num_knots; i++) {
  knots[i] = static_cast<float>(_knot_sqnc[i]);
}
for (size_t i = 0; i != num_ctrlpts; i++) {
  for (size_t j = 0; j != m; j++) {
    cp[i*m +j] = static_cast<float>(_ctrl_pts[i](j+1));
  }
}

_mp.enqueue_write_buffer (knots_buffer, num_knots*sizeof(float), knots);
_mp.enqueue_write_buffer (cp_buffer, num_ctrlpts*m*sizeof(float), cp);

delete[] knots;
delete[] cp;

_mp.set_kernel_argument (_kernel_id, 0, pts_buffer);
_mp.set_kernel_argument (_kernel_id, 1, knots_buffer);
_mp.set_kernel_argument (_kernel_id, 2, cp_buffer);
_mp.set_kernel_argument (_kernel_id, 3, sizeof(unsigned), (void*)&m);
_mp.set_kernel_argument (_kernel_id, 4, sizeof(unsigned), (void*)&L);
_mp.set_kernel_argument (_kernel_id, 5, sizeof(unsigned), (void*)&N);

_mp.enqueue_data_parallel_kernel (_kernel_id, N, 40);


@ 곡선을 계산하는 de Boor 알고리즘의 OpenCL 구현.
Work item별로 따로 사용하는 private memory는 동적 할당을 지원하지 않는다.
따라서 부득이하게 고정된 크기의 배열을 사용하는데,
cubic spline이므로 |n|은 3으로 고정하고, 허용하는 곡선의 최고 차원은 6으로 
설정했다.
이는 OpenCL device의 spec에 따라 더 높이는 것이 가능하다.

이 함수에서 가장 먼저 수행할 작업은 domain knots,
$[u_{n-1},\ldots,u_{L+n-1}]$을 $N-1$개의 등간격으로 각 work item별로 자신이
계산해야 할 $u$ 값을 계산하고, $u$에 대하여
$u_i\in[u_I,u_{I+1}]$을 만족하는 $I$ 값을 계산한다.

OpenCL 디바이스는 계산 유닛(Compute Unit)들로 이루어지고, 계산 유닛은 한 개 
이상의
PE (Processing Element)들로 이루어진다.  디바이스에서의 실제 계산은 PE 안에서
이루어진다.  다수의 PE들이 같은 명령어를 실행한다는 점(SIMT; Single Instruction,
Multiple Threads)을 생각해보면, kernel program
안에 분기문이 들어 있을 때 계산 성능이 저하된다.  따라서 |I|를 계산하는 과정에서
필요한 |if| 문을 그것과 동일한 효과를 내는 연산식으로 대체했음에 유의한다.

@s kernel void
@s global void
@s constant void
@s private void

@(cspline.cl@>=
#define MAX_BUFF_SIZE 30
kernel void evaluate_crv (@/
  @t\idt@>global float* crv,@/
  @t\idt@>constant float* knots,@/
  @t\idt@>constant float* cpts,@/
  @t\idt@>unsigned d, unsigned L, unsigned N@/
  @t\idt@>) @+ {

  private unsigned id = get_global_id(0);
  private const unsigned n = 3;
  private float tmp[MAX_BUFF_SIZE];

  private const float du = (knots[L+n-1] -knots[n-1])/(float)(N-1);
  private float u = knots[n-1] + id*du;

  private unsigned I = n-1;
  for (private unsigned i=n; i != L+n-1; i++) {
    I += (convert_int (sign (u -knots[i]))+1)>>1;
    // If $knots[i]<u$, increment |I|.
  }

  for (private unsigned i=0; i != n+1; i++) {
    for (private unsigned j=0; j!=d; j++) {
      tmp[i*d +j] = cpts[(i+I-n+1)*d +j];
    }
  }

  private unsigned shifter = I-n+1;

  for (private unsigned k=1; k !=n+1; k++) {
    for (private unsigned i=I+1; i !=I-n+k; i--) {
      private float t = (knots[i+n-k] -u)/(knots[i+n-k]-knots[i-1]);

      for (private unsigned j=0; j!=d; j++) {
        tmp[(i-shifter)*d +j] = t*tmp[(i-shifter-1)*d +j]
                              +(1.-t)*tmp[(i-shifter)*d +j];
      }
    }
  }

  for (private unsigned j=0; j!=d; j++) {
    crv[id*d +j] = tmp[n*d +j];
  }
}




@ 어떤 scalar 값이 주어졌을 때, 그것이 knot sequence의 몇 번째 knot과
그 다음 knot 사이에 들어가는 값인지 찾아내는 method를 정의한다.
즉, $u$가 주어지면, $u_i\leq u<u_{i+1}$을 만족하는 인덱스~$i$를 찾는 것이다.
만약 조건을 만족하는 $i$가 없으면, |SIZE_MAX|를반환한다.
이 method는 non-decreasing knot sequence를 가정하며, 만약 $u$가
knot sequence의 마지막 값과 같다면 조건식이 만족되지 않으므로
sequence를 뒤에서부터 거슬러 $u_i\leq u\leq u_{i+1}$을 만족하는 $i$를
찾는다.  이는 knot의 multiplicity가 2 이상일 때에도 대응하기 위함이다.
이 method는 하나의 |double| 타입 인자만 주어지면 객체의 knot sequence에서
해당하는 인덱스를 찾지만, 별도의 knot sequence가 주어지면 주어진 sequence에서
인덱스를 찾는다.

@<Miscellaneous methods of |cubic_spline|@>+=
size_t@/
cubic_spline::find_index_in_sequence (@/
  @t\idt@>const double u,@/
  @t\idt@>const vector<double> sqnc@/
  @t\idt@>) const @+ {

  if (u==sqnc.back()) {
    for (size_t i=sqnc.size()-2; i!=SIZE_MAX; i--) {
      if (sqnc[i] != u) {
        return i;
      }
    }
  }

  for (size_t i = 0; i != sqnc.size()-1; i++) {
    if ((sqnc[i] <= u) && (u < sqnc[i+1])) {
      return i;
    }
  }
  return SIZE_MAX;
}

size_t@/
cubic_spline::find_index_in_knot_sequence (const double u) const @+ {
  return find_index_in_sequence (u, this->_knot_sqnc);
}

@ @<Methods of |cubic_spline|@>+=
protected: @/
size_t find_index_in_sequence (@/
    @t\idt@>const double,@/
    @t\idt@>const vector<double>@/
    @t\idt@>) const;
size_t find_index_in_knot_sequence (const double) const;




@ Spline 곡선의 미분은 동등한 \bezier\ 곡선으로 변환한 후 계산한다.

@<Evaluation and derivative of |cubic_spline|@>+=
point
cubic_spline::derivative (const double u) const @+ {
  @<Check the range of knot value given@>;

  vector<point> splines, bezier_ctrlpt;
  vector<double> knots;
  bezier_control_points (splines, knots); // Equivalent \bezier\ curves.

  unsigned long index = find_index_in_sequence (u, knots);
  for (size_t i = index*3; i <= (index + 1)*3; i++) {
    bezier_ctrlpt.push_back (splines.at(i));
  }
  bezier bezier_curve = bezier (bezier_ctrlpt);

  double delta = knots[index + 1] - knots[index];
  double t = (u - knots[index])/delta; // Change coordinate from b-spline to \bezier.

  point drv (bezier_curve.derivative (t));
  return drv/delta; // Transform the velocity into the u coordinate (b-spline).
}

@ @<Methods of |cubic_spline|@>+=
public: @/
point derivative (const double) const;


@ 만약 주어진 인자 $u$가 knot sequence의 범위를 벗어나면,
|OUT_OF_KNOT_RANGE| 오류코드를 객체에 남기고 모든 원소가 0인 |point| 객체를
반환한다.  객체의 차원은 컨트롤 포인트의 차원과 동일하다.

@<Check the range of knot value given@>=
if ((u < _knot_sqnc.front()) || (_knot_sqnc.back() < u)) {
  _err = OUT_OF_KNOT_RANGE;
  return cagd::point (_ctrl_pts.begin()->dim());
}

@ @<Error codes of |cagd|@>+=
OUT_OF_KNOT_RANGE,




@ Knot의 multiplicity를 찾는 method는 재귀적으로 구현한다.
즉, sequence의 시작점부터 주어진 knot과 같은 knot을 찾을때마다 다시 같은
함수를 호출한다.

@<Miscellaneous methods of |cubic_spline|@>+=
unsigned long
cubic_spline::find_multiplicity (const double u,
                                 const_knot_itr begin
                                 ) const @+ {
  const_knot_itr iter = find (begin, _knot_sqnc.end(), u);
  if (iter == _knot_sqnc.end()) {
    return 0;
  } @+ else {
    return find_multiplicity (u, ++iter) + 1;
  }
}

unsigned long
cubic_spline::find_multiplicity (const double u) const @+{
  return find_multiplicity (u, _knot_sqnc.begin());
}

@ @<Methods of |cubic_spline|@>+=
protected: @/
unsigned long find_multiplicity (const double, const_knot_itr) const;
unsigned long find_multiplicity (const double) const;




@ Knot sequence의 증분값, $\Delta u_i$를 계산하는 간단한 method를 정의한다.
이 프로그램의 많은 부분에서 $\Delta_i=\Delta u_i=u_{i+1}-u_i$를 의미하며, 편의상
$\Delta_{-1}=\Delta_L=0$을 반환하도록 구현한다.
이는 보간 (interpolation) 방정식의 구현을 간단하게 만들어준다.

@<Miscellaneous methods of |cubic_spline|@>+=
double cubic_spline::delta (const long i) const @+ {
  if ((i < 0) || (_knot_sqnc.size()-1) <= i) {
    return 0.;
  } @+ else {
    return _knot_sqnc[i+1] - _knot_sqnc[i];
  }
}

@ @<Methods of |cubic_spline|@>+=
protected: @/
double delta (const long) const;




@ Knot sequence의 양 끝에 곡선의 차수만큼 knot을 추가해서 곡선이 양 끝의
컨트롤 포인트를 지나도록하는 method를 정의한다.

@<Miscellaneous methods of |cubic_spline|@>+=
void
cubic_spline::insert_end_knots () {
  vector<double> newKnots;
  newKnots.push_back (_knot_sqnc[0]);
  newKnots.push_back (_knot_sqnc[0]);

  for (size_t i = 0; i != _knot_sqnc.size(); ++i) {
    newKnots.push_back (_knot_sqnc[i]);
  }

  newKnots.push_back (_knot_sqnc.back());
  newKnots.push_back (_knot_sqnc.back());

  _knot_sqnc.clear();
  for (size_t i = 0; i != newKnots.size(); ++i) {
    _knot_sqnc.push_back (newKnots[i]);
  }
}

@ @<Methods of |cubic_spline|@>+=
protected: @/
void insert_end_knots ();




@ Cubic spline 곡선의 control point들을 주어진 point들로 대치하는 method.
이는 주로 cubic spline interpolation의 계산 결과를 반영하는 것을 염두에 두고 
있어서, 양 끝점들과 중간 점들의 |vector| 타입을 입력으로 받는다.

@<Miscellaneous methods of |cubic_spline|@>+=
void
cubic_spline::set_control_points (@/
  @t\idt@>const point& head,@/
  @t\idt@>const vector<point>& intermediate,@/
  @t\idt@>const point& tail@/
  @t\idt@>) @+ {

  _ctrl_pts.clear();
  size_t n = intermediate.size();
  _ctrl_pts = vector<point> (2+n, point(2));
  _ctrl_pts[0] = head;
  for (size_t i = 0; i != n; i++) {
    _ctrl_pts[i+1] = intermediate[i];
  }
  _ctrl_pts[n+1] = tail;
}

@ @<Methods of |cubic_spline|@>+=
protected: @/
void set_control_points (const point&, const vector<point>&, const point&);




@ Inversion of a tridiagonal matrix.

Cubic spline 곡선의 보간법을 다루기 위하여 먼저 tridiagonal system의 해법을 
설명하고 구현한다.

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
\item{3.} $\phi_{n_1}$과 $\phi_n$을 이용하여 $\phi_{n-1},\ldots,\phi_1$을 계산;
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




@ |cubic_spline|의 보간법에서 사용하기 위한 상수들을 enumeration으로 정의한다.
|parametrization|은 곡선의 knot sequence를 어떻게 생성할 것인지를 기술하기
위한 상수들이다.
각각 uniform parametrization, chord length parametrization,
centripetal parametrization, spline function parametrization을 의미한다.

|end_condition|은 곡선의 end condition을 어떻게 설정할 것인지 나타낸다.
각각 clamped, Bessel, quadratic, not-a-knot, natural, 그리고 끝으로
periodic end condition을 의미한다.

@s parametrization int
@s end_condition int

@<Enumerations of |cubic_spline|@>=
public:@/
enum class parametrization {
  uniform, // uniform parametrization
  chord_length, // chord length parametrization
  centripetal, // centripetal parametrization
  function_spline // spline function, i.e., knot sequence = x coords.
};

enum class end_condition {
  clamped, // claped end condition
  bessel, // Bessel end condition
  quadratic, // quadratic end condition
  not_a_knot, // not-a-knot end condition
  natural, // natural end condition
  periodic // periodic end condition
};




@ Cubic spline 보간은 데이터 포인트, $\bbp_0, \ldots, \bbp_L$이
주어져 있을 때, 그 데이터 포인트들을 지나면서 $C^2$ 연속성 조건을
만족하는 spline curve의 컨트롤 포인트, $\bbd_{-1},\ldots,\bbd_{L+1}$를 찾는
것이다.
주어진 데이터 포인트는 $L+1$개이고, 찾아야하는 컨트롤 포인트는 $L+3$개이므로 이는
부정방정식(under-determined problem)이다.  따라서 문제의 유일해를 구하려면
2개의 구속조건이 더 주어져야하며, 이는 end-condition에 의하여 결정한다.

엄밀하게 말하면, cubic spline 보간은 데이터 포인트 $\bbp_0, \ldots, \bbp_L$
뿐만 아니라
knot sequence, $u_0,\ldots,u_L$, 그리고 각 knot들의 multiplicity가 주어져야
해를 구할 수 있다.
그러나 일반적으로 knot sequence와 multiplicity는 주어지지 않으므로 knot
sequence는 몇 가지 scheme을 선택하도록 해서 그에 따라 생성하고,
knot들의 multiplicity는 곡선이 양 끝점의 data point를 지나갈 수 있도록
$3, 1,\ldots,1,3$을 가정한다.

가장 먼저, 데이터 포인트, 매개화 (parametrization) scheme, 종단 조건
(end condition),
종단 하나 이전의 컨트롤 포인트 ($\bbd_0$와 $\bbd_L$)을 모두 입력으로 받는
일반적인 보간 기능을 |interpolate()| 메쏘드로 구현한다.
이것은 모든 종류의 보간 문제를 해결하는 engine이다.

|interpolate()| 메쏘드는 주어진 데이터 포인트의 갯수가 0이면 knot sequence와
control point를 모두 비워버린 후 바로 반환한다.  데이터 포인트의 갯수가 1이면
trivial solution으로 그 데이터 포인트를 유일한 컨트롤 포인트로, knot sequence는
0을 3개 중첩한 후 반환한다.  그렇지 않을 경우에는 주어진
parametrization scheme따라 knot sequence를 생성하고, $C^2$ cubic spline 보간에
관한 연립방정식을 세운 후, end condition에 맞춰 일부 식을 조작한다.
방정식의 해를 구함으로써 control point들을 구하고, 마지막으로 곡선 양 끝의
knot을 3개 중첩시키면 보간이 끝난다.

사용 편의성을 위해 경우에 따라 몇 가지 불필요한 인자들을 생략한
|interpolate()| 메쏘드들을 정의한다:
\item{1.} 데이터 포인트만 주어지거나, 데이터 포인트와 매개화 scheme이 함께
주어지면 not-a-knot 종단 조건을 가정한다.  매개화 scheme이 주어지지 않을
때에는 가장 범용적인 chord length 매개화를 가정한다.
데이터 포인트가 3점 이상 주어지는 경우, 양 끝에서 하나 이전의 컨트롤 포인트들은
not-a-knot 종단 조건에 의하여 결정되므로 큰 의미는 없지만, 데이터 포인트가 2점
주어지는 경우 그 두 점을 잇는 직선이 얻어질 수 있도록 양 끝의 데이터 포인트를
각각 $1/3$과 $2/3$로 내분하는 점을 계산한 후 engine method에 넘겨준다.

\item{2.} 데이터 포인트와 추가로 두 개의 포인트가 주어지면 clamped end
condition을 가정한다.  매개화 scheme은 주어진 것을 사용하거나, 아니면 chord
length 매개화를 가정한다.


@<Methods for interpolation of |cubic_spline|@>=
void @/
cubic_spline::_interpolate (const vector<point>& p,
		                        parametrization scheme,
                            end_condition cond,
		                        const point& initial, 
                            const point& end
	                          ) @+ {

  _knot_sqnc.clear();
  _ctrl_pts.clear();

  if (p.size() == 0) { // No data point given.

  } else if (p.size() == 1) { // A single data point.  Trivial.
    _knot_sqnc.push_back (0.);
    _knot_sqnc.push_back (0.);
    _knot_sqnc.push_back (0.);

    _ctrl_pts.push_back (p[0]);
    _ctrl_pts.push_back (p[0]);
    _ctrl_pts.push_back (p[0]);

  } else { // More than or equal to 2 points given.
    @<Generate knot sequence according to given parametrization scheme@>;
    @<Setup equations of cubic spline interpolation@>;
    @<Modify equations according to end conditions and solve them@>;
    insert_end_knots ();
  }
}

@ @<Methods of |cubic_spline|@>+=
protected:@/
void _interpolate (const vector<point>&,
                   parametrization,
                   end_condition,
                   const point&, 
                   const point&);


@ 한편, 데이터 포인트들이 주어졌을 때 그것들을 보간하는 cubic spline 곡선을 바로
생성하는 constructor가 있으면 매우 유용할 것이다.  아무런 parametrization
scheme이나 end condition이 주어지지 않으면 chord length parametrization과
not-a-knot end condition을 적용한다.

@<Constructors and destructor of |cubic_spline|@>+=
cubic_spline::cubic_spline (const vector<point>& p,
                            end_condition cond,
                            parametrization scheme
                            )
  @t\idt@>: curve (p), @/
  @t\idt@>_mp ("./cspline.cl"),@/
  @t\idt@>_kernel_id (_mp.create_kernel("evaluate_crv"))@/
{
  point one_third (2./3.*(*(p.begin())) + 1./3.*(p.back()));
  point two_third (1./3.*(*(p.begin())) + 2./3.*(p.back()));
  _interpolate (p, scheme, cond, one_third, two_third);
}

cubic_spline::cubic_spline (const vector<point>& p,
                            const point i, const point e,
                            parametrization scheme 
                            )
  @t\idt@>: curve (p), @/
  @t\idt@>_mp ("./cspline.cl"),@/
  @t\idt@>_kernel_id (_mp.create_kernel("evaluate_crv"))@/
{
  _interpolate (p, scheme, end_condition::clamped, i, e);
}

@ @<Methods of |cubic_spline|@>+=
public:@/
cubic_spline (const vector<point>&, 
              end_condition cond = end_condition::not_a_knot,
              parametrization scheme = parametrization::chord_length);
cubic_spline (const vector<point>&, const point, const point,
              parametrization scheme = parametrization::chord_length);




@ 먼저 parametrization scheme에 따라 knot sequence를 적절하게 배치해야한다.
|cubic_spline| 타입은 uniform, chord length, centripetal, function spline
parametrization을 지원한다.  알려지지 않은 scheme으로 parametrization을 시도하면
|UNKNOWN_PARAMETRIZATION| 오류 코드를 객체 내에 저장하고 반환한다.
보통은 chord length parametrization이나 centripetal parametrization을 사용한다.

@<Generate knot sequence according to given parametrization scheme@>=
switch (scheme) {
  case parametrization::uniform: @+ {
    @<Uniform parametrization of knot sequence@>;
  }
  break;

  case parametrization::chord_length: @+ {
    @<Chord length parametrization of knot sequence@>;
  }
  break;

  case parametrization::centripetal: @+ {
    @<Centripetal parametrization of knot sequence@>;
  }
  break;

  case parametrization::function_spline: @+ {
    @<Function spline parametrization of knot sequence@>;
  }
  break;

default:@/
  _err = UNKNOWN_PARAMETRIZATION;
  return;
}

@ @<Error codes of |cagd|@>+=
UNKNOWN_PARAMETRIZATION,




@ Uniform parametrization: 등간격으로 knot들을 배치한다.
Data point의 갯수가 $L$ 이라면, $i$ 번째 knot $u_i=L$로 설정한다.
이는 data point들 사이의 거리를 고려하지 않기 때문에 point들이 촘촘한 구간에서는
곡선이 천천히, 멀리 떨어진 구간에서는 너무 빨리 움직이는 문제가 있어서 data
point들 사이의 간격들이 균일하지 못하면 곡선의 품질면에서 불리한 knot
sequence를 생성하게 된다.

@<Uniform parametrization of knot sequence@>=
for (size_t i = 0; i != p.size(); i++) {
  _knot_sqnc.push_back (double(i));
}




@ Chord length parametrization: data point, $x_i$들
사이의 거리(chord length)에 비례하여 knot들을 배치한다.
즉, $u_{i+1}-u_i=\Delta_i$이고 $\Vert x_{i+1}-x_i\Vert=\Delta x_i$이면,
$${\Delta_i\over\Delta_{i+1}}=
{\Vert\Delta x_i\Vert\over\Vert\Delta x_{i+1}\Vert}$$
이 되도록 한다.  실제 구현에서는 $u_0=0$이고 $u_L=1$이 되도록 하거나,
또는 $u_0=0$이고 $u_L=L$이 되도록 하는 것이 바람직하다.

@<Chord length parametrization of knot sequence@>=
_knot_sqnc.push_back (0.); // $u_0$
@#
double sum_delta = 0.;
for (size_t i = 0; i != p.size() - 1; i++) {
  double delta = cagd::dist(p[i], p[i+1]); // $\Delta_i$
  sum_delta += delta;
  _knot_sqnc.push_back (sum_delta);
}
if (sum_delta != 0.) { // Normalize knot sequence so that $u_L = 1$.
  for (knot_itr i = _knot_sqnc.begin(); i != _knot_sqnc.end(); i++) {
    *i /= sum_delta;
  }
}




@ Centripetal parametrization: 일반적으로 chord length parametrization이
대부분의 경우 잘 동작하지만, 경우에 따라 우리가 원하는 결과가 잘 얻어지지 않는다.
특히 data point가 뾰족한 corner 근방에 놓여 있을 때, chord length
parametrization은 그 corner 주변이 둥그스름하게 볼록 솟아나는 곡선을 만들어낸다.
그런 경우 corner의 형상을 올바르게 잡아주려면 centripetal parametrization으로
knot sequence를 생성한다.
이는 $u_{i+1}-u_i=\Delta_i$이고 $\Vert x_{i+1}-x_i\Vert=\Delta x_i$일때,
$${\Delta_i\over\Delta_{i+1}}=
\left[{\Vert\Delta x_i\Vert\over\Vert\Delta x_{i+1}\Vert}\right]^{1/2}$$
가 되도록 knot sequence를 잡아주는 것이며, 결과적으로 곡선을 따라 움직이는
point에 가해지는 구심력(centripetal force)의 변화(variation)을 부드럽게
만들어준다.

@<Centripetal parametrization of knot sequence@>=
double sum_delta = 0.;
_knot_sqnc.push_back (sum_delta);
for (size_t i = 0; i != p.size() - 1; i++) {
  double delta = sqrt(cagd::dist(p[i], p[i+1]));
  sum_delta += delta;
  _knot_sqnc.push_back (sum_delta);
}

if (sum_delta != 0.) { // Normalize knot sequence so that $u_L=1$.
  for (size_t i = 0; i != _knot_sqnc.size(); i++) {
    _knot_sqnc[i] /= sum_delta;
  }
}




@ Function spline parametrization: 이는 data point $x_i$의 첫 번째
좌표들을 knot sequence로 설정하는 것이다.  주로 2차원 평면상의 점
$x_i=(u_i,v_i)$들이 있을 때,
$u$ 축에 대한 함수로써의 $v$를 spline interpolation할 때 사용한다.

@<Function spline parametrization of knot sequence@>=
for (size_t i = 0; i != p.size(); i++) {
  _knot_sqnc.push_back (p[i](1));
}




@ Cubic spline 보간의 해를 구하기 위한 방정식을 유도하기 위하여,
데이터 포인트 $\bbp_i$에서의 $C^2$ 연속성 조건을 그림으로 표현하면 아래와 같다.
\medskip
\noindent\centerline{%
\includegraphics{figs/fig-2.mps}}
\medskip
모든 B-spline은 piecewise \bezier\ 곡선으로 표현 가능하다.  위의 그림을 참조하면,
$$\bbp_i=\bbb_{3i};\quad i=0,\ldots,L$$
이고, inner \bezier\ control point, $\bbb_{3i\pm1}$과 $\bbp_i$ 사이의 관계는
곡선의 $C^1$ 연속성 조건에 의하여
$$\bbp_i={\Delta_i\bbb_{3i-1}+\Delta_{i-1}\bbb_{3i+1}
\over\Delta_{i-1}+\Delta_i};\quad i=1,\ldots,L-1$$
이다.  이때, $\Delta_i=\Delta u_i$를 간략하게 쓴 것이다.
이제 $C^2$ 연속성 조건에 의하여 spline의 컨트롤 포인트 $\bbd_i$와 $\bbb_{3i\pm1}$
사이의 관계는
$$\eqalign{
\bbb_{3i-1}&={\Delta_i\bbd_{i-1}+(\Delta_{i-2}+\Delta_{i-1})\bbd_i
\over \Delta_{i-2}+\Delta_{i-1}+\Delta_i};\quad i=2, \ldots, L-1\cr
\bbb_{3i+1}&={(\Delta_i+\Delta_{i+1})\bbd_i+\Delta_{i-1}\bbd_{i+1}
\over \Delta_{i-1}+\Delta_i+\Delta_{i+1}};\quad i=1,\ldots,L-2\cr}
$$
이다.
곡선의 양 끝부분에서는 조금 상황이 다르며
$$\eqalign{
\bbb_2&={\Delta_1\bbd_0+\Delta_0\bbd_1\over\Delta_0+\Delta_1}\cr
\bbb_{3L-2}&={\Delta_{L-1}\bbd_{L-1}+\Delta_{L-2}\bbd_L
  \over\Delta_{L-2}+\Delta_{L-1}}\cr
\bbb_1&=\bbd_0\cr
\bbb_{3L-1}&=\bbd_L\cr}$$
이 된다.  $\bbd_0$와 $\bbd_L$은 end condition에 의하여 결정되거나,
clamped end condition의 경우에는 임의의 값이 주어진다.
주어진 데이터 포인트 $\bbp_i$와 미지수인 컨트롤 포인트 $\bbd_i$ 사이의
관계식을 정리하면,
$$(\Delta_{i-1}+\Delta_i)\bbp_i=
\alpha_i\bbd_{i-1}+\beta_i\bbd_i+\gamma_i\bbd_{i+1}$$
의 형태가 되며,
$$\eqalign{
\alpha_i&={(\Delta_i)^2\over\Delta_{i-2}+\Delta_{i-1}+\Delta_i}\cr
\beta_i&={\Delta_i(\Delta_{i-2}+\Delta_{i-1})
  \over\Delta_{i-2}+\Delta_{i-1}+\Delta_i}
  +{\Delta_{i-1}(\Delta_i+\Delta_{i+1})\over\Delta_{i-1}+\Delta_i
    +\Delta_{i+1}}\cr
\gamma_i&={(\Delta_{i-1})^2\over\Delta_{i-1}+\Delta_i+\Delta_{i+1}}\cr}$$
이다.  이 때, $\Delta_{-1}=\Delta_L=0$이다.

정리하면 cubic spline 보간의 컨트롤 포인트는 방정식
$$\pmatrix{
  1&&&&&&\cr
  \alpha_1&\beta_1&\gamma_1&&&&\cr
  &&&\ddots&&&\cr
  &&&&\alpha_{L-1}&\beta_{L-1}&\gamma_{L-1}\cr
  &&&&&&1\cr}
\pmatrix{\bbd_0\cr\bbd_1\cr\vdots\cr\bbd_{L-1}\cr\bbd_L\cr}
=\pmatrix{\bbr_0\cr\bbr_1\cr\vdots\cr\bbr_{L-1}\cr\bbr_L\cr}
$$
의 해를 구함으로써 얻을 수 있다.  이 때
$$\eqalign{
  \bbr_0&=\bbb_1\cr
  \bbr_i&=(\Delta_{i-1}+\Delta_i)\bbp_i\cr
  \bbr_L&=\bbb_{3L-1}\cr}$$
이다.

@<Setup equations of cubic spline interpolation@>=
vector<double> a;  // $\alpha$, lower diagonal.
vector<double> b;  // $\beta$, diagonal.
vector<double> c;  // $\gamma$, upper diagonal.
vector<point> r;  // ${\bf r}$, right hand side.

unsigned long L = p.size() - 1;

b.push_back (1.0); // First row.
c.push_back (0.0);
r.push_back (initial);

for (size_t i = 1; i != L; i++) {
  double delta_im2 = delta (i-2);
  double delta_im1 = delta (i-1);
  double delta_i = delta (i);
  double delta_ip1 = delta (i+1);

  double alpha_i = delta_i*delta_i/(delta_im2+delta_im1+delta_i);
  double beta_i = delta_i*(delta_im2+delta_im1)/(delta_im2+delta_im1+delta_i)
                 +delta_im1*(delta_i+delta_ip1)/(delta_im1+delta_i+delta_ip1);
  double gamma_i = delta_im1*delta_im1/(delta_im1+delta_i+delta_ip1);

  a.push_back (alpha_i);
  b.push_back (beta_i);
  c.push_back (gamma_i);

  r.push_back ((delta_im1+delta_i)*p[i]);
}

a.push_back (0.);
b.push_back (1.);
r.push_back (end);



@ 앞에서 설명한 바와 같이 cubic spline 보간은 방정식의 갯수보다
미지수의 갯수가 2개 많은 under-constrained system이다.  부족한 조건 2개는 곡선
양 끝단에서 컨트롤 포인트가 만족해야 하는 end condition으로 결정해야하며,
|cubic_spline| 타입은 clamped, Bessel, quadratic,
not-a-knot, natural, 그리고 periodic end condition을 지원한다.
아직은 clamped, not-a-knot, 그리고 periodic end condition만을 구현했다.

@<Modify equations according to end conditions and solve them@>=
switch (cond) {

  case end_condition::not_a_knot: @+ {
    @<Modify equations according to not-a-knot end condition@>;
  }

  case end_condition::clamped: @+ { // No modification required.
    vector<point> x (L+1, point(p[0].dim()));

    if (solve_tridiagonal_system (a, b, c, r, x) != 0) {
      _err = TRIDIAGONAL_NOT_SOLVABLE;
      return;
    }

    set_control_points (p[0], x, p[L]);
  }
  break;

  case end_condition::periodic: @+ {
    @<Modify equations according to periodic end condition@>;

    vector<point> x (L, point(p[0].dim()));

    if (solve_cyclic_tridiagonal_system (a, b, c, r, x) != 0) {
      _err = TRIDIAGONAL_NOT_SOLVABLE;
      return;
    }

    point d_plus (((delta(0)+delta(1))*x[0] +delta(L-1)*x[1])
        /(delta(L-1) +delta(0) +delta(1)));
    point d_minus (((delta(L-2)+delta(L-1))*x[0] +delta(0)*x[L-1])
        /(delta(L-2) +delta(L-1) +delta(0)));

    vector<point> d (L+1, point(p[0].dim()));
    d[0] = d_plus;
    for (size_t i = 1; i != L; i++) {
      d[i] = x[i];
    }
    d[L] = d_minus;

    set_control_points (p[0], d, p[L]);
  }
  break;

default:@/
  _err = UNKNOWN_END_CONDITION;
  return;
}

@ @<Error codes of |cagd|@>+=
TRIDIAGONAL_NOT_SOLVABLE,
UNKNOWN_END_CONDITION,




@ Not-a-knot end condition은 곡선 양 끝에 놓인 각각 2개의 곡선 조각들이 하나의
\bezier\ 곡선이 되도록하는 조건이다.  보간해야 하는 데이터 포인트,
  $\bbp_0,\ldots,\bbp_L$이 있으면, $\bbp_0$과 $\bbp_1$을 연결하는 곡선과
  $\bbp_1$과 $\bbp_2$를 연결하는 곡선이
$\bbp_0$과 $\bbp_2$를 연결하는 한 곡선의 subdivision이 되도록 하는 것이다.
이는 $\bbp_{L-2}$, $\bbp_{L-1}$, $\bbp_L$ 사이에서도 동일하게 주어지는 조건이다.
아래의 그림은 not-a-knot end condition을 만족하는 곡선의 시작 부분을 보여준다.
\medskip
\noindent\centerline{%
\includegraphics{figs/fig-3.mps}}
\medskip
먼저 $\bbp_0$부터 $\bbp_2$까지 하나의 \bezier\ 곡선이 되어야 하는 조건은
de Casteljau 알고리즘으로부터
$$\eqalign{
\bbd_0&=(1-s)\bbp_0+s\bba_-;\quad s={\Delta_0\over\Delta_0+\Delta_1}\cr
\bbb_5&=(1-s)\bba_++s\bbp_2=(1-r)\bbd_1+r\bbd_2;\quad
      r={\Delta_0+\Delta_1\over\Delta_0+\Delta_1+\Delta_2}\cr
\bbd_1&=(1-s)\bba_-+s\bba_+\cr}$$
이므로
$$\eqalign{
\bba_-&={1\over s}\bbd_0-{1-s\over s}\bbp_0\cr
\bba_+&={1\over 1-s}\left\{(1-r)\bbd_1+r\bbd_2\right\}-{s\over 1-s}\bbp_2\cr}
$$
을 세 번째 식에 대입하고 정리하면
$${1-s\over s}\bbd_0+\left({2s-sr-1\over 1-s}\right)\bbd_1+{sr\over 1-s}\bbd_2
={(1-s)^2\over s}\bbp_0+{s^2\over 1-s}\bbp_2\eqno(*)$$
다.

한편, $\bbp_1$에서의 $C^2$ 연속성 조건을 기술하면,
$$\eqalign{
\bbb_2&=s\bbd_1+(1-s)\bbd_0;\cr
\bbb_4&=q\bbd_1+(1-q)\bbd_2;\quad
        q={\Delta_1+\Delta_2\over\Delta_0+\Delta_1+\Delta_2}\cr
\bbp_1&=(1-s)\bbb_2+s\bbb_4\cr
}$$
이므로
$$(1-s)^2\bbd_0+s(1-s+q)\bbd_1+s(1-q)\bbd_2=\bbp_1$$
이다.  이때, $q=1-sr$이므로 $q$를 소거하면
$$(1-s)^2\bbd_0+s(2-s-sr)\bbd_1+s^2r\bbd_2=\bbp_1\eqno(**)$$
이 된다.
$\bbd_2$ 항을 소거하여 tridiagonal matrix 방정식을 얻기 위해
식~$(**)$를 $(**)-(*)\times s(1-s)$로 치환하면,
$$(-3s^2+3s)\bbd_1=-(1-s)^3\bbp_0+\bbp_1-s^3\bbp_2$$
이다.  곡선의 마지막 부분 두 개의 조각에 대해서도 같은 과정을 통하여 방정식을
유도할 수 있다.

정리하면,
$$\displaylines{
\quad\pmatrix{
  0& -3s_i^2+3s_i& &&&&\cr
  1-s_i\over s_i& {s_i\over 1-s_i}(1-r_i)-1& s_ir_i\over 1-s_i&&&&\cr
  &&&\ddots&&&\cr
  &&&&s_fr_f\over 1-s_f& {s_f\over 1-s_f}(1-r_f)-1& 1-s_f\over s_f\cr
  &&&&&-3s_f^2+3s_f& 0\cr}
\pmatrix{
  \bbd_0\cr\bbd_1\cr\vdots\cr\bbd_{L-1}\cr\bbd_L\cr}\hfill\cr
\hfill{}=\pmatrix{
  -(1-s_i)^3\bbp_0+\bbp_1-s_i^3\bbp_2\cr
  {(1-s_i)^2\over s_i}\bbp_0 + {s_i^2\over 1-s_i}\bbp_2\cr
  \vdots\cr
  {s_f^2\over 1-s_f}\bbp_{L-2} + {(1-s_f)^2\over s_f}\bbp_L\cr
  -s_f^3\bbp_{L-2}+\bbp_{L-1}-(1-s_f)^3\bbp_L\cr}\quad\cr}$$
이다.  위의 식에서
$$\eqalign{
s_i&={\Delta_0\over\Delta_0+\Delta_1}\cr
r_i&={\Delta_0+\Delta_1\over\Delta_0+\Delta_1+\Delta_2}\cr
s_f&={\Delta_{L-1}\over\Delta_{L-2}+\Delta_{L-1}}\cr
r_f&={\Delta_{L-2}+\Delta_{L-1}\over\Delta_{L-3}+\Delta_{L-2}+\Delta_{L-1}}\cr}$$
이다.

중간 부분은 앞의 cubic spline 보간에 관한 방정식의 $\alpha_i$, $\beta_i$,
  $\gamma_i$와 $r_i$를 그대로 채워 넣는다.  Not-a-knot end condition은 최소
  3개 이상($2\leq L$)이어야
적용 가능하다.  특히 $L=2$인 경우에는 $s_i=\Delta_0/(\Delta_0+\Delta_1)$,
$s_f=\Delta_1/(\Delta_0+\Delta_1)$, $r_i=r_f=1$이 되어 경계 조건의 방정식은
$$\pmatrix{0&{3\Delta_0\Delta_1\over(\Delta_0+\Delta_1)^2}&\cr
  {\Delta_1\over\Delta_0}& -1& {\Delta_0\over\Delta_1}\cr
  &{3\Delta_0\Delta_1\over(\Delta_0+\Delta_1)^2}&0\cr}
\pmatrix{\bbd_0\cr\bbd_1\cr\bbd_2}=
\pmatrix{-{\Delta_1^3\over(\Delta_0+\Delta_1)^3}\bbp_0
         +\bbp_1-{\Delta_0^3\over(\Delta_0+\Delta_1)^3}\bbp_2\cr
         {\Delta_1^2\over\Delta_0(\Delta_0+\Delta_1)}\bbp_0
         +{\Delta_0^2\over\Delta_1(\Delta_0+\Delta_1)}\bbp_2\cr
         -{\Delta_1^3\over(\Delta_0+\Delta_1)^3}\bbp_0
         +\bbp_1-{\Delta_0^3\over(\Delta_0+\Delta_1)^3}\bbp_2\cr
         }$$
이 된다.

@<Modify equations according to not-a-knot end condition@>=
if (L >= 2) {
  double s_i = delta(0)/(delta(0)+delta(1));
  double r_i = (delta(0)+delta(1))/(delta(0)+delta(1)+delta(2));
  double s_f = delta(L-1)/(delta(L-2)+delta(L-1));
  double r_f = (delta(L-2)+delta(L-1))/(delta(L-3)+delta(L-2)+delta(L-1));

  b[0] = 0.; // First row.
  c[0] = -3*s_i*s_i + 3*s_i;
  r[0] = -(1-s_i)*(1-s_i)*(1-s_i)*p[0] + p[1] - s_i*s_i*s_i*p[2];
@#
  a[0] = (1-s_i)/s_i; // Second row.
  b[1] = s_i/(1-s_i)*(1-r_i)-1;
  c[1] = s_i*r_i/(1-s_i);
  r[1] = (1-s_i)*(1-s_i)/s_i*p[0] + s_i*s_i/(1-s_i)*p[2];
@#
  a[L-2] = s_f*r_f/(1-s_f); // Second to the last row.
  b[L-1] = s_f/(1-s_f)*(1-r_f)-1;
  c[L-1] = (1-s_f)/s_f;
  r[L-1] = s_f*s_f/(1-s_f)*p[L-2] + (1-s_f)*(1-s_f)/s_f*p[L];
@#
  a[L-1] = -3*s_f*s_f + 3*s_f; // Last row.
  b[L] = 0.;
  r[L] = -s_f*s_f*s_f*p[L-2] + p[L-1] - (1-s_f)*(1-s_f)*(1-s_f)*p[L];
}




@ 사람의 보행궤적과 같은 주기적인 운동궤적을 다루기 위해서는 곡선의 시작점과 
끝점이 일치($\bbp_0=\bbp_L$)할 뿐 아니라 그 점에서 2차 미분까지 연속($C^2$ 
    condition)인 곡선이 필요하다.  이 때의 컨트롤 포인트는 방정식
$$\pmatrix{
  \beta_0&\gamma_0&&&&&\alpha_0\cr
  \alpha_1&\beta_1&\gamma_1&&&&\cr
  &&&\ddots&&&\cr
  &&&&\alpha_{L-2}&\beta_{L-2}&\gamma_{L-2}\cr
  \gamma_{L-1}&&&&&\alpha_{L-1}&\beta_{L-1}\cr}
\pmatrix{\bbd_0\cr\bbd_1\cr\vdots\cr\bbd_{L-1}\cr}
=\pmatrix{\bbr_0\cr\bbr_1\cr\vdots\cr\bbr_{L-1}\cr}$$
의 해를 구함으로써 얻을 수 있다.  이 때
$$\bbr_i=(\Delta_{i-1}+\Delta_i)\bbp_i$$
이고,
$$\Delta_0=\Delta_L,\quad\Delta_{-1}=\Delta_{L-1},\quad\Delta_{-2}=\Delta_{L-2}$$
이다.  $\alpha_i$, $\beta_i$, $\gamma_i$, $\bbr_i$의 정의는 앞의 $C^2$
조건으로부터 유도되는 식을 따르는데, 새로운 $\Delta_i$의 정의로 인하여
$\alpha_0$, $\alpha_1$, $\beta_0$, $\beta_1$, $\beta_{L-1}$, $\gamma_0$,
$\gamma_{L-1}$, $\bbr_0$는 새로 계산해야한다.
아래 그림은 $L=5$인 경우의 periodic end condition을 보여준다.
\medskip
\noindent\centerline{%
\includegraphics{figs/fig-4.mps}}
\medskip

@<Modify equations according to periodic end condition@>=
for (size_t i = L-1; i != 0; i--) { // Modify $\alpha$.
  a[i] = a[i-1];
}
a[0] = delta(0)*delta(0)/(delta(L-2)+delta(L-1)+delta(0));
a[1] = delta(1)*delta(1)/(delta(L-1)+delta(0)+delta(1));

b.pop_back(); // Modify $\beta$.
b[0] = delta(0)*(delta(L-2)+delta(L-1))/(delta(L-2)+delta(L-1)+delta(0))
  +delta(L-1)*(delta(0)+delta(1))/(delta(L-1)+delta(0)+delta(1));
b[1] = delta(1)*(delta(L-1)+delta(0))/(delta(L-1)+delta(0)+delta(1))
  +delta(0)*(delta(1)+delta(2))/(delta(0)+delta(1)+delta(2));
b[L-1] = delta(L-1)*(delta(L-3)+delta(L-2))/(delta(L-3)+delta(L-2)+delta(L-1))
  +delta(L-2)*(delta(L-1)+delta(0))/(delta(L-2)+delta(L-1)+delta(0));

c[0] = delta(L-1)*delta(L-1)/(delta(L-1)+delta(0)+delta(1)); // Modify $\gamma$.
c[L-1] = delta(L-2)*delta(L-2)/(delta(L-2)+delta(L-1)+delta(0));

r.pop_back(); // Modify $\bbr$.
r[0] = (delta(L-1)+delta(0))*p[0];




@ {\bf Test: Cubic Spline Interpolation.}

$x=\pi, \pi+1, \ldots, \pi+10$일 때, $y=\sin(x)+3$으로 주어지는 data point,
$$y=3.0000, 2.1585, 2.0907, 2.8589, 3.7568, 3.9589,
    3.2794, 2.3430, 2.0106, 2.5879, 3.5440$$
을 cubic spline으로 보간하는 예제를 보여준다.
End condition은 not-a-knot을 적용한다.

@s high_resolution_clock int
@s duration_cast static_cast
@s milliseconds int

@<Test routines@>+=
print_title ("cubic spline interpolation");
{
  @<Generate example data points@>;
  cubic_spline crv (p, 
                    cubic_spline::end_condition::not_a_knot,
                    cubic_spline::parametrization::function_spline);
@#
  psf file = create_postscript_file ("sine_curve.ps");
  crv.write_curve_in_postscript (file, 100, 1., 1, 2, 40.);
  crv.write_control_polygon_in_postscript (file, 1., 1, 2, 40.);
  crv.write_control_points_in_postscript (file, 1., 1, 2, 40.);
  close_postscript_file (file, true);
@#
  @<Compare the result of interpolation with MATLAB@>;

  cout << crv.description();

  const unsigned steps = 1000;
  vector<double> knots = crv.knot_sequence();
  double du = (knots[knots.size() -3] - knots[2])/double(steps-1);
  double us[steps];
  vector<point> crv_pts_s (steps, point(2));

  for (size_t i=0; i!=steps; i++) {
    us[i] = knots[2] +i*du;
  }

  auto t0 = high_resolution_clock::now();
  for (size_t i=0; i!=steps; i++) {
    crv_pts_s[i] =crv.evaluate (us[i]);
  }
  auto t1 = high_resolution_clock::now();
  cout << "Serial computation : "
       << duration_cast<milliseconds>(t1-t0).count() << " msec\n";

  t0 = high_resolution_clock::now();
  vector<point> crv_pts_p = crv.evaluate_all (steps);
  t1 = high_resolution_clock::now();
  cout << "Parallel computation : "
       << duration_cast<milliseconds>(t1-t0).count() << " msec\n";

  double diff =0.;
  for (size_t i = 0; i != steps; i++) {
    diff += dist (crv_pts_s[i], crv_pts_p[i]);
  }
  cout << "Mean difference between serial and parallel computation = "
       << diff/double(steps) << endl;
}


@ @<Generate example data points@>=
vector<point> p;
for (unsigned i = 0; i != 11; i++) {
  point datum = point ({0, 0});
  datum(1) = static_cast<double>(i) + M_PI;
  datum(2) = sin (datum(1))+3.;
  p.push_back (datum);
}

@ 보간 결과의 정확성을 검증하기 위하여 MATLAB에서 |spline()| 함수를 이용하여
보간한 것과 비교한다. $x=\pi, \pi+.25, \pi+.5, \ldots, \pi+10$에 대하여
cubic spline으로 보간한 함수 $f()$로부터
$y=f(x)$를 계산한 것을 root-mean-square로 상호 비교했다.

@<Compare the result of interpolation with MATLAB@>=
double matlab_bench[] = {
  3.0000, 2.7308, 2.4983, 2.3062, 2.1585, 2.0592, 2.0122, 2.0214,
  2.0907, 2.2211, 2.4018, 2.6190, 2.8589, 3.1075, 3.3501, 3.5715,
  3.7568, 3.8928, 3.9742, 3.9974, 3.9589, 3.8578, 3.7032, 3.5065,
  3.2794, 3.0342, 2.7858, 2.5502, 2.3430, 2.1785, 2.0643, 2.0063,
  2.0106, 2.0804, 2.2073, 2.3802, 2.5879, 2.8193, 3.0632, 3.3085,
  3.5440  };
double interpolated[41];
double u = M_PI;
double err = 0.;
for (size_t i = 0; i != 41; i++) {
  double y = crv.evaluate (u)(2);
  interpolated [i] = y;
  u += 0.25;
  err += (interpolated[i]-matlab_bench[i])*(interpolated[i]-matlab_bench[i]);
}
err /= 41;
err = sqrt (err);
cout << "RMS error of interpolation (compared with MATLAB) = " << err
     << endl;

@ 실행 결과.
\medskip
\centerline{\includegraphics[width=.9\pagewidth]{figs/sine_curve.pdf}}
\medskip
MATLAB에서 |spline()| 함수를 이용하여 같은 데이터를 cubic spline 보간한 것과
결과를 비교하면 다음과 같은 결과가 출력된다.  오차가 $10^{-5}$ 오더로 발생한
것은 MATLAB에서 계산한 결과를 소수점 4째 자리까지 반올림한 것으로 가져왔기
때문이다.

\.{RMS error of interpolation (compared with MATLAB) = 2.29482e-05}


@ 참고로 MATLAB에서 같은 데이터로 cubic spline 보간을 하는 코드와 결과는
다음과 같다.

\.{>> x = pi:1:(pi+10);}

\.{>> y = sin(x)+3;}

\.{>> xx = pi:.25:pi+10;}

\.{>> yy = spline (x, y, xx);}

\.{>> plot (x, y, 'o', xx, yy);}

\.{>> set (gcf, 'PaperPosition', [0 0 10 2]);}

\.{>> set (gcf, 'PaperSize', [10 2]);}

\.{>> saveas (gcf, 'matlab', 'pdf')}
\medskip
\centerline{\includegraphics[width=\pagewidth]{figs/matlab.pdf}}
\medskip


@ {\bf Test: Cubic Spline Interpolation (Degenerate Case).}

단 두개의 데이터 포인트에 대한 cubic spline interpolation을 테스트한다.
$(10,10)$과 $(200,200)$을 연결하는 cubic spline interpolation을 not-a-knot
end condition으로 구한다.  두 개의 데이터 포인트로는 not-a-knot end condition이
성립될 수 없는 degenerate case이며 두 점을 연결하는 직선이 나와야 한다.

@<Test routines@>+=
print_title ("cubic spline interpolation: degenerate case");
{
  vector<point> p;
  p.push_back (point({10, 10}));
  p.push_back (point({200, 200}));
  cubic_spline crv (p);
@#
  psf file = create_postscript_file ("line.ps");
  crv.write_curve_in_postscript (file, 30, 1., 1, 2, 1.);
  crv.write_control_polygon_in_postscript (file, 1., 1, 2, 1.);
  crv.write_control_points_in_postscript (file, 1., 1, 2, 1.);
  close_postscript_file (file, true);
}

@ 실행 결과.
\medskip
\centerline{\includegraphics{figs/line.pdf}}
\medskip



@ {\bf Test: Periodic Cubic Spline Interpolation.}

$$p_i=r(\cos2\pi i/6, \sin2\pi i/6),\quad (i=0,\ldots,6)$$
을 periodic cubic spline으로 보간한다.

@<Test routines@>+=
print_title ("periodic spline interpolation");
{
  vector<point> p;
  double r = 100.;
  cout << "Data points:" << endl;
  for (size_t i = 0; i != 7; i++) {
    p.push_back (point({r*cos(2*M_PI/6*i) +200.,
                        r*sin(2*M_PI/6*i) +200.}));
    cout << " ( " << r*cos(2*M_PI/6*i) +200. << " , " <<
         r*sin(2*M_PI/6*i) +200. << " )" << endl;
  }

  cubic_spline crv (p, cubic_spline::end_condition::periodic, 
                    cubic_spline::parametrization::centripetal);
@#
  psf file = create_postscript_file ("periodic.ps");
  crv.write_curve_in_postscript (file, 200, 1., 1, 2, 1.);
  crv.write_control_polygon_in_postscript (file, 1., 1, 2, 1.);
  crv.write_control_points_in_postscript (file, 1., 1, 2, 1.);
  close_postscript_file (file, true);

  cout << crv.description ();

  const unsigned steps = 1000;
  vector<double> knots = crv.knot_sequence();
  double du = (knots[knots.size() -3] - knots[2])/double(steps-1);
  double us[steps];
  vector<point> crv_pts_s (steps, point(2));

  for (size_t i=0; i!=steps; i++) {
    us[i] = knots[2] +i*du;
  }

  auto t0 = high_resolution_clock::now();
  for (size_t i=0; i!=steps; i++) {
    crv_pts_s[i] =crv.evaluate (us[i]);
  }
  auto t1 = high_resolution_clock::now();
  cout << "Serial computation : "
       << duration_cast<milliseconds>(t1-t0).count() << " msec\n";

  t0 = high_resolution_clock::now();
  vector<point> crv_pts_p = crv.evaluate_all (steps);
  t1 = high_resolution_clock::now();
  cout << "Parallel computation : "
       << duration_cast<milliseconds>(t1-t0).count() << " msec\n";

  double error =0.;
  for (size_t i = 0; i != steps; i++) {
    error += dist (crv_pts_s[i], crv_pts_p[i]);
  }
  cout << "Mean difference between serial and parallel computation = "
       << error/double(steps) << endl;
}

@ 실행 결과.
\medskip
\centerline{\includegraphics{figs/periodic.pdf}}
\medskip




@ $C^2$ cubic spline 곡선은 knot에서 나뉘는 각 조각별로 형상이 같은
\bezier\ 곡선으로 변환할 수 있다.

@<Methods to obtain a |bezier| curve for a segment of |cubic_spline|@>=
void
cubic_spline::bezier_control_points (
    vector<point>& bezier_ctrl_points,
    vector<double>& knot
    ) const @+ {

  bezier_ctrl_points.clear();
  knot.clear();

  @<Create a new knot sequence of which each knot has multiplicity of 1@>;
  @<Check whether the curve can be broken into \bezier\ curves@>;
  @<Calculate \bezier\ control points@>;


}

@ @<Error codes of |cagd|@>+=
UNABLE_TO_BREAK_INTO_BEZIER,


@ 모든 knot들의 multiplicity가 1이 되도록 한다.  Knot sequence를 따라가며 
순증가하는 knot들만 추려낸다.

@<Create a new knot sequence of which each knot has multiplicity of 1@>=
knot.push_back (_knot_sqnc[0]);
for (size_t i = 1; i != _knot_sqnc.size(); i++) {
  if (_knot_sqnc[i] > knot.back()) {
    knot.push_back (_knot_sqnc[i]);
  }
}


@ 모든 knot들의 multiplicity가 1이 되도록 만든 후 knot의 갯수와 control point들의
갯수를 비교함으로써 cubic spline curve를 \bezier\ curve로 변환 가능한지 점검한다.

@<Check whether the curve can be broken into \bezier\ curves@>=
if (knot.size() + 2 != _ctrl_pts.size()) {
  _err = UNABLE_TO_BREAK_INTO_BEZIER;
  return;
}


@ 먼저 필요한 저장공간을 확보한 후, 각 곡선의 segment별로 \bezier\ 컨트롤 
포인트를 계산한다.

@<Calculate \bezier\ control points@>=
for (size_t i = 0; i <= 3*(knot.size() - 1); i++) {
  bezier_ctrl_points.push_back (point ({0.0, 0.0}));
}
@#
bezier_ctrl_points[0] = _ctrl_pts[0]; // Special treatment on the first segment.
bezier_ctrl_points[1] = _ctrl_pts[1];
double delta = knot[2] - knot[0];
bezier_ctrl_points[2] = ((knot[2] - knot[1])*_ctrl_pts[1] +
                         (knot[1] - knot[0])*_ctrl_pts[2])
                        /delta;
@#
for (size_t i = 2; i <= knot.size() - 2; i++) { // Intermediate segments.
  delta = knot[i+1] - knot[i-2];
  bezier_ctrl_points[3*i - 1] = ((knot[i+1] - knot[i])*_ctrl_pts[i] +
                                 (knot[i] - knot[i-2])*_ctrl_pts[i+1])
                                /delta;
  bezier_ctrl_points[3*i - 2] = ((knot[i+1] - knot[i-1])*_ctrl_pts[i] +
                                 (knot[i-1] - knot[i-2])*_ctrl_pts[i+1])
                                /delta;
}
@#
unsigned long L = knot.size() - 1; // Special treatment on the last segment.
delta = knot[L] - knot[L-2];
bezier_ctrl_points[3*L-2] = ((knot[L] - knot[L-1])*_ctrl_pts[L] +
                             (knot[L-1] - knot[L-2])*_ctrl_pts[L+1])
                            /delta;
bezier_ctrl_points[3*L-1] = _ctrl_pts[L+1];
bezier_ctrl_points[3*L] = _ctrl_pts[L+2];
@#
for (size_t i = 1; i <= (knot.size()-2); i++) { // Finally, calculate $b_{3i}$s.
  delta = knot[i+1] - knot[i-1];
  bezier_ctrl_points[3*i] = ((knot[i+1] - knot[i])*bezier_ctrl_points[3*i-1] +
                             (knot[i] - knot[i-1])*bezier_ctrl_points[3*i+1])
                            /delta;
}

@ @<Methods of |cubic_spline|@>+=
protected: @/
void bezier_control_points (vector<point>&, vector<double>&) const;




@ Cubic spline 곡선의 곡률은 먼저 곡선을 \bezier\ 곡선으로 변환한 후,
\bezier\ 곡선의 곡률을 계산함으로써 구한다.

@<Methods to calculate curvature of |cubic_spline|@>=
vector<point>
cubic_spline::signed_curvature (int density) const @+ {
  vector<point> bezier_ctrl_points;
  vector<double> knot;
  vector<point> curvature;
  bezier_control_points (bezier_ctrl_points, knot); // Get equivalent \bezier\ curves.

  for (size_t i = 0; i != (knot.size() - 2); i++) {
    list<point> cpts; // Control points for a section of \bezier\ curve.
    cpts.clear();
    cpts.push_back (bezier_ctrl_points[3*i]);
    cpts.push_back (bezier_ctrl_points[3*i+1]);
    cpts.push_back (bezier_ctrl_points[3*i+2]);
    cpts.push_back (bezier_ctrl_points[3*i+3]);
    bezier segment (cpts);
    vector<point> kappa = segment.signed_curvature (density);

    for (size_t j = 0; j != kappa.size(); j++) {
      curvature.push_back (kappa[j]);
    }
  }
  return curvature;
}

@ @<Methods of |cubic_spline|@>+=
protected: @/
vector<point> signed_curvature (int) const;




@ 먼저 knot insertion을 수행하는 method를 정의한다.
Knot insertion은 새로 삽입된 knot에 의하여 Greville abscissas를 새로 계산하고,
그에 따라 컨트롤 포인트들을 linear interpolation하는 과정이다.

먼저 삽입할 knot이 적절한 범위의 값인지 점검한다.
그리고 새로 삽입하는 knot의 영향을 받지 않는 컨트롤 포인트들을 새로운 
저장공간에 복사한다.
새로 계산해야하는 컨트롤 포인트를 linear interpolation으로 계산하고,
다시 새로운 knot의 영향을 받지 않는 나머지 컨트롤 포인트들을 복사한다.

마지막으로 주어진 knot을 |_knot_sqnc|에 삽입하고,
새로 계산한 컨트롤 포인트들로 |_ctrl_pts|를 대체한다.

@<Methods for knot insertion and removal of |cubic_spline|@>=
void
cubic_spline::insert_knot (const double u) @+ {
  const int n = 3; // Degree of cubic spline.
  @#
  size_t index = find_index_in_knot_sequence (u);
  if (index == SIZE_MAX) {
    _err = OUT_OF_KNOT_RANGE;
  }
  if ((index < n-1) || (int(_knot_sqnc.size())-n < index)) {
    _err = NOT_INSERTABLE_KNOT;
  }

  vector<point> new_ctrl_pts; // construct a new control points

  @<Copy control points for $i = 0, \ldots ,I-d+1$@>;
  @<Construct new control points by piecewise linear interpolation@>;
  @<Copy remaining control points to new control points@>;

  _knot_sqnc.insert (_knot_sqnc.begin()+index+1, u);
  _ctrl_pts.clear ();
  _ctrl_pts = new_ctrl_pts;
}

@ @<Error codes of |cagd|@>+=
NOT_INSERTABLE_KNOT,

@ @<Copy control points for $i = 0, \ldots ,I-d+1$@>=
for (size_t i = 0; i <= index-n+1; i++) {
  new_ctrl_pts.push_back (_ctrl_pts[i]);
}

@ @<Construct new control points by piecewise linear interpolation@>=
for (size_t i = index-n+2; i <= index+1; i++) {
  new_ctrl_pts.push_back (
    _ctrl_pts[i-1]*(_knot_sqnc[i+n-1]-u)/(_knot_sqnc[i+n-1]-_knot_sqnc[i-1])
    + _ctrl_pts[i]*(u - _knot_sqnc[i-1])/(_knot_sqnc[i+n-1]-_knot_sqnc[i-1]));
}

@ @<Copy remaining control points to new control points@>=
for (size_t i = index + 2; i <= _knot_sqnc.size()-n+1; i++) {
  new_ctrl_pts.push_back (_ctrl_pts[i-1]);
}

@ @<Methods of |cubic_spline|@>+=
public: @/
void insert_knot (const double);




@ Knot removal을 구현하기 위하여 및 가지 method를 먼저 정의한다.
|get_blending_ratio()|는 Eck의 알고리즘에서 언급하는 blending ratio를 계산한다.
|bracket()|과 |find_l()|은 Eck의 논문에서 사용하는 notation을 구현한 것이다.

@<Miscellaneous methods of |cubic_spline|@>+=
double
cubic_spline::get_blending_ratio (
    const vector<double>& IGESKnot,
    long v, long r, long i
    ) @+ {

  long beta = 1; // set beta and determine $m_1$ and $m_2$
  long m1 = beta - r + 6 - v;
  if (m1 < 0) {
    m1 = 0;
  }
  long m2 = r - _ctrl_pts.size() + 2 + beta;
  if (m2 < 0) {
    m2 = 0;
  }

  if ((v-1 <= i) && (i <= v-2+m1)) { // special cases to return 0 or 1
    return 0.;
  }
  if ((4-m2 <= i) && (i <= 3)) {
    return 1.;
  }

  double gamma = 0.; // otherwise go through a laborious chore
  for (size_t j = v-1+m1; j <= 4-m2; j++) {
    double brk = bracket (IGESKnot, j+1, 3, r);
    gamma += brk*brk;
  }

  double result = 0.;
  for (size_t j = v-1+m1; j <= i; j++) {
    double brk = bracket(IGESKnot, j+1, 3, r);
    result += brk*brk;
  }

  return result/gamma;
}

double
cubic_spline::bracket (
    const vector<double>& IGESKnot,
    long a, long b, long r
    ) @+ {

  if (a == b+1) {
    return 1./find_l (IGESKnot, a-1, r);
  }

  if (a == b+2) {
    return 1./(1.-find_l (IGESKnot, a-1, r));
  }

  double result = 1./find_l (IGESKnot, a-1, r);
  for (size_t i = a; i <= b; i++) {
    double tmp = find_l (IGESKnot, i, r);
    result *= (1. - tmp)/tmp;
  }
  return result;
}


double
cubic_spline::find_l (
    const vector<double>& IGESKnot,
    long j, long r
    ) @+ {
  return (IGESKnot[r]-IGESKnot[r-4+j])/(IGESKnot[r+j]-IGESKnot[r-4+j]);
}

@ @<Methods of |cubic_spline|@>+=
protected: @/
double get_blending_ratio (const vector<double>&, long, long, long);
double bracket (const vector<double>&, long, long, long);
double find_l (const vector<double>&, long, long);




@ Knot removal을 수행하는 method를 정의한다.  
자세한 알고리즘은 Eck의 논문을 참조한다.

@<Methods for knot insertion and removal of |cubic_spline|@>+=
void
cubic_spline::remove_knot (const double u) @+ {
  vector<double> IGESKnot;
  vector<point> forward;
  vector<point> backward;
  const int k = 4;

  @<Set multiplicity of end knots to order of this curve instead of degree@>;

  size_t r = find_index_in_knot_sequence (u)+1;
  unsigned long v = find_multiplicity (u);

  @<Determine forward control points@>;
  @<Determine backward control points@>;
  @<Blend forward and backward control points@>;

  for (size_t i = r; i <= _knot_sqnc.size()-1; i++) {
    _knot_sqnc[i-1] = _knot_sqnc[i];
  }
  _knot_sqnc.pop_back();
}

@ @<Set multiplicity of end knots to order of this curve instead of degree@>=
IGESKnot.push_back (_knot_sqnc[0]);
for (size_t i = 0; i != _knot_sqnc.size(); ++i) {
  IGESKnot.push_back (_knot_sqnc[i]);
}
IGESKnot.push_back (_knot_sqnc.back());

@ @<Determine forward control points@>=
for (size_t i = 0; i <= r-k+v-1; i++) {
  forward.push_back(_ctrl_pts[i]);
}

for (size_t i = r-k+v; i <= r-1; i++) {
  double l = (IGESKnot[r] - IGESKnot[i])/(IGESKnot[k + i] - IGESKnot[i]);
  forward.push_back(1.0/l*_ctrl_pts[i] + (1.0 - 1.0/l)*forward[i - 1]);
}

for (size_t i = r; i <= _ctrl_pts.size()-2; i++) {
  forward.push_back(_ctrl_pts[i + 1]);
}

@ @<Determine backward control points@>=
for (size_t i = 0; i <= _ctrl_pts.size()-2; i++) {
  backward.push_back (cagd::point (2));
}

for (long i = _ctrl_pts.size()-2; i >= r-1; i--) {
  backward[i] = _ctrl_pts[i + 1];
}

for (long i = r-2; i >= r-k+v-1; i--) {
  double l = (IGESKnot[r]-IGESKnot[i+1])/(IGESKnot[k+i+1]-IGESKnot[i+1]);
  backward[i] = 1./(1.-l)*_ctrl_pts[i+1]+(1.-1./(1.-l))*backward[i+1];
}

for (long i = r-k+v-2; i >= 0; i--) {
  backward[i] = _ctrl_pts[i];
}

@ @<Blend forward and backward control points@>=
for (size_t i = r-k+v-1; i <= r-1; i++) {
  double mu = get_blending_ratio (IGESKnot, v, r, i);
  _ctrl_pts[i] = (1.-mu)*forward[i] + mu*backward[i];
}
for (size_t i = r; i <= _ctrl_pts.size()-2; i++) {
  _ctrl_pts[i] = _ctrl_pts[i+1];
}
_ctrl_pts.pop_back();

@ @<Methods of |cubic_spline|@>+=
public: @/
void remove_knot (const double);




@ PostScript 파일 출력을 위한 함수들은 다음과 같다.
곡선을 계산할 때 입력받는 변수 |dense|는 곡선을 몇 개의 선분 조각으로 근사화할
것인지 나타내므로 실제 계산해야 하는 곡선상의 점들은 그것보다 하나 더 많다.

@<Methods for PostScript output of |cubic_spline|@>=
void
cubic_spline::write_curve_in_postscript (@/
  @t\idt@>psf& ps_file,@/
  @t\idt@>unsigned dense,@/
  @t\idt@>float line_width,@/
  @t\idt@>int x, int y,@/
  @t\idt@>float magnification@/
  @t\idt@>) const @+ {

  ios_base::fmtflags previous_options = ps_file.flags ();
  ps_file.precision (4);
  ps_file.setf (ios_base::fixed, ios_base::floatfield);

  ps_file << "newpath" << endl
          << "[] 0 setdash " << line_width << " setlinewidth" << endl;

  point pt (magnification*evaluate (_knot_sqnc[2], 2));

  ps_file << pt(x) << "\t" << pt(y) << "\t" << "moveto" << endl;

  double incr = (_knot_sqnc[_knot_sqnc.size()-3] -_knot_sqnc[2])/double(dense);
  for (size_t i = 0; i != dense+1; i++) {
    double u = _knot_sqnc[2] + incr*i;
    pt = magnification*evaluate(u);
    ps_file << pt(x) << "\t" << pt(y) << "\t" << "lineto" << endl;
  }

#if 0
  for (size_t i = 2; i < _knot_sqnc.size() - 3; i++) {
    if (_knot_sqnc[i] < _knot_sqnc[i+1]) {
      double knot = _knot_sqnc[i];
      double incr = (_knot_sqnc[i+1]-knot)/double(dense);
      double u = knot;
      for (size_t j = 0; j <= dense; j++) {
        pt = magnification*evaluate(u, i);
	      ps_file << pt(x) << "\t" << pt(y) << "\t" << "lineto" << endl;
	      u += incr;
      }
    }
  }
#endif

  ps_file << "stroke" << endl;
  ps_file.flags (previous_options);
}

void
cubic_spline::write_control_polygon_in_postscript (@/
  @t\idt@>psf& ps_file,
  @t\idt@>float line_width,@/
  @t\idt@>int x, int y,@/
  @t\idt@>float magnification@/
  @t\idt@>) const @+ {

  ios_base::fmtflags previous_options = ps_file.flags();
  ps_file.precision (4);
  ps_file.setf (ios_base::fixed, ios_base::floatfield);

  ps_file << "newpath" << endl
           << "[] 0 setdash " << .5*line_width << " setlinewidth" << endl;

  point pt (magnification*_ctrl_pts[0]);
  ps_file << pt(x) << "\t" << pt(y) << "\t" << "moveto" << endl;

  for (size_t i = 1; i < _ctrl_pts.size(); i++) {
    pt = magnification*_ctrl_pts[i];
    ps_file << pt(x) << "\t" << pt(y) << "\t" << "lineto" << endl;
  }

  ps_file << "stroke" << endl;
  ps_file.flags (previous_options);
}

void
cubic_spline::write_control_points_in_postscript (@/
  @t\idt@>psf& ps_file,@/
  @t\idt@>float line_width,@/
  @t\idt@>int x, int y,@/
  @t\idt@>float magnification@/
  @t\idt@>) const @+ {

  ios_base::fmtflags previous_options = ps_file.flags();
  ps_file.precision (4);
  ps_file.setf( ios_base::fixed, ios_base::floatfield );

  point pt (magnification*_ctrl_pts[0]);
  ps_file << "0 setgray" << endl
          << "newpath" << endl
          << pt(x) << "\t" << pt(y) << "\t"
          << (line_width*3) << "\t" << 0.0 << "\t"
          << 360 << "\t" << "arc" << endl
          << "closepath" << endl
          << "fill stroke" << endl;

  if (_ctrl_pts.size() > 2) {
  for (size_t i = 1; i <= (_ctrl_pts.size() - 2); i++) {
    pt = magnification*_ctrl_pts[i];
    ps_file << "newpath" << endl
            << pt(x) << "\t" << pt(y) << "\t"
            << (line_width*3) << "\t" << 0.0 << "\t"
            << 360 << "\t" << "arc" << endl
            << "closepath" << endl
            << line_width << "\t" << "setlinewidth" << endl
            << "stroke" << endl;
  }
  pt = magnification*_ctrl_pts.back();
  ps_file << "0 setgray" << endl
          << "newpath" << endl
          << pt(x) << "\t" << pt(y) << "\t"
          << (line_width*3) << "\t" << 0.0 << "\t"
          << 360 << "\t" << "arc" << endl
          << "closepath" << endl
          << "fill stroke" << endl;
  }
  ps_file.flags (previous_options);
}

@ @<Methods of |cubic_spline|@>+=
public: @/
void write_curve_in_postscript (@/
  @t\idt@>psf&, unsigned, float, int x=1, int y=1,@/
  @t\idt@>float magnification = 1.0) const;

void write_control_polygon_in_postscript (@/
  @t\idt@>psf&, float, int x=1, int y=1,@/
  @t\idt@>float magnification = 1.0) const;

void write_control_points_in_postscript (@/
  @t\idt@>psf&, float, int x=1, int y=1,@/
  @t\idt@>float magnification = 1.0) const;
