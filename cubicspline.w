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
@<Methods for conversion of |cubic_spline|@>@;
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



@*1 Evaluation of Cubic Spline (de Boor Algorithm).
Cubic spline 곡선 위의 점은 잘 알려진바와 같이 de Boor 알고리즘으로 계산한다.
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
  // Change coordinate from b-spline to \bezier.
  double t = (u - knots[index])/delta;

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




@*1 Interpolation of Cubic Spline. 

Cubic spline은 \bezier\ 형식과 Hermite 형식이 있다.
곡선이 지나야 하는 경로점 $\bbx_i$와 그 점에서의 접선벡터 $\bbm_i$, $(i=0,\ldots,L)$이
주어져 있으면, junction \bezier\ 포인트는
$$\bbb_{3i}=\bbx_i,$$
inner \bezier\ 포인트는
$$\eqalign{
\bbb_{3i+1}&=\bbb_{3i}+{\Delta_i\over3}\bbm_i\quad\quad(i=0,\ldots,L-1)\cr
\bbb_{3i-1}&=\bbb_{3i}-{\Delta_{i-1}\over3}\bbm_i\quad\quad(i=1,\ldots,L)\cr
}$$
로 바로 계산 가능하다.  이 때, $\Delta_i=\Delta u_i$ 이다.

@<Methods for conversion of |cubic_spline|@>+=
vector<point>
cubic_spline::bezier_points_from_hermite_form (@/
  @t\idt@>const vector<point>& x,@/
  @t\idt@>const vector<point>& m@/
) @+ {

  if (x.size() == 0) {
    return vector<point>(0, point(0));
  }

  unsigned long L = x.size() - 1;
  vector<point> b(3*L+1, point(x[0].dim()));

  b[0] = x[0];
  for (unsigned long i = 0; i != L; i++) {
    b[3*i+3] = x[i+1];

    double du = _knot_sqnc[i+1] - _knot_sqnc[i];
    b[3*i+1] = b[3*i] + du/3.0*m[i];
    b[3*i+2] = b[3*i+3] - du/3.0*m[i+1];
  }

  return b;
}

@ @<Methods of |cubic_spline|@>+=
public: @/
vector<point> bezier_points_from_hermite_form (@/
  @t\idt@>const vector<point>&,
  const vector<point>&);




@ $C^2$ 연속성 조건을 만족하는 spline 곡선의 \bezier\ 컨트롤 포인트들로부터
B-spline 컨트롤 포인트를 계산할 수 있다.
\medskip
\noindent\centerline{%
\includegraphics{figs/fig-2.mps}}
\medskip
Junction point $\bbp_i$에서의 $C^2$ 연속 조건은
$\Delta=\Delta_{i-2}+\Delta_{i-1}+\Delta_i$라고 정의할 때,
$$\eqalign{
\bbb_{3i-2}&={\Delta_{i-1}+\Delta_i\over\Delta}\bbd_{i-1}
  +{\Delta_{i-2}\over\Delta}\bbd_i,\cr
\bbb_{3i-1}&={\Delta_i\over\Delta}\bbd_{i-1}
  +{\Delta_{i-2}+\Delta_{i-1}\over\Delta}\bbd_i\cr
}$$
이므로 이 두 식을 연립하고 $\bbd_{i-1}$을 소거하면
$$
\bbd_i={(\Delta_{i-1}+\Delta_i)\bbb_{3i-1}-\Delta_i\bbb_{3i-2}
  \over\Delta_{i-1}}
$$
이다. 따라서,
B-spline 컨트롤 포인트 $\bbd_{-1}, \bbd_0, \ldots, \bbd_L, \bbd_{L+1}$는
$$\eqalign{
\bbd_{-1}&=\bbb_0,\cr
\bbd_0&=\bbb_1,\cr
\bbd_i&={(\Delta_{i-1}+\Delta_i)\bbb_{3i-1}-\Delta_i\bbb_{3i-2}
  \over\Delta_{i-1}}\quad (i=1,\ldots,L-1),\cr
\bbd_L&=\bbb_{3L-1},\cr
\bbd_{L+1}&=\bbb_{3L}\cr
}$$
로 주어진다.  아래 그림은 $L=6$인 경우의 예시를 보여준다.
\medskip
\noindent\centerline{%
\includegraphics{figs/fig-5.mps}}
\medskip

@<Methods for conversion of |cubic_spline|@>+=
vector<point>
cubic_spline::control_points_from_bezier_form (const vector<point>& b) @+ {
  const unsigned long L = _knot_sqnc.size() - 1;

  vector<point> d(L+3, b[0].dim());

  d[0] = b[0];
  d[1] = b[1];

  for (size_t i=1; i<L; i++) {
    double delta_im1 = _knot_sqnc[i] - _knot_sqnc[i-1];
    double delta_i = _knot_sqnc[i+1] - _knot_sqnc[i];
    d[i+1] = ((delta_im1+delta_i)*b[3*i-1] -delta_i*b[3*i-2])/delta_im1;
  }

  d[L+1] = b[3*L-1];
  d[L+2] = b[3*L];

  return d;
}

@ @<Methods of |cubic_spline|@>+=
public: @/
vector<point> control_points_from_bezier_form (const vector<point>&);





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
종단에서의 접선벡터 $\bbm_0$와 $\bbm_L$을 모두 입력으로 받는
일반적인 보간 기능을 |_interpolate()| 메쏘드로 구현한다.
이것은 모든 종류의 보간 문제를 해결하는 engine이다.

|_interpolate()| 메쏘드는 주어진 데이터 포인트의 갯수에 따라 특별한 예외처리를
필요로 한다:
\item{1.} 데이터 포인트의 갯수가 0이면 knot sequence와
control point를 모두 비워버린 후 바로 반환한다.
\item{2.} 데이터 포인트의 갯수가 2개 이하 (1 또는 2개)면
trivial solution이다.  Knot sequence는 0,0,0,1,1,1로 설정하고, 
컨트롤 포인트는 첫 번째 데이터 포인트를 3개, 마지막 데이터 포인트를 3개 
중첩한다. 
\item{3.} 데이터 포인트의 갯수가 3개 이상이면 주어진
parametrization scheme따라 knot sequence를 생성하고, $C^2$ cubic spline 보간에
관한 연립방정식을 세운 후, end condition에 맞춰 식을 일부 조작한다.
방정식의 해를 구함으로써 control point들을 구하고, 마지막으로 곡선 양 끝의
knot을 3개 중첩시키면 보간이 끝난다.  (물론 데이터 포인트가 2개만 주어지면,
보간 결과는 그 두 점을 잇는 직선이다.)

@<Methods for interpolation of |cubic_spline|@>=
void cubic_spline::_interpolate (@/
  @t\idt@>const vector<point>& p,@/
	@t\idt@>parametrization scheme,@/
  @t\idt@>end_condition cond,@/
  @t\idt@>const point& m_0,@/
  @t\idt@>const point& m_L@/
	) @+ {

  _knot_sqnc.clear();
  _ctrl_pts.clear();

  if (p.size() == 0) { // No data point given.

  } else if (p.size() < 3) { // One or two waypoints.
    _knot_sqnc = vector<double> (6, 0.0);
    _ctrl_pts = vector<point> (6, p[0]);

    for (size_t i = 3; i!=6; i++) {
      _knot_sqnc[i] = 1.0;
      _ctrl_pts[i] = p.back();
    }

  } else { // More than or equal to 3 points given.
    @<Generate knot sequence according to given parametrization scheme@>;

    if (cond == end_condition::periodic) {
      @<Setup equations for periodic end condition and solve them@>;
    }
    else {
      @<Setup Hermite form equations of cubic spline interpolation@>;
      @<Modify equations according to end conditions and solve them@>;
    }
    insert_end_knots ();
  }
}

@ @<Methods of |cubic_spline|@>+=
protected:@/
void _interpolate (@/
  @t\idt@>const vector<point>&,@/
  @t\idt@>parametrization,@/
  @t\idt@>end_condition,@/
  @t\idt@>const point&, const point&);




@ 한편, 데이터 포인트들이 주어졌을 때 그것들을 보간하는 cubic spline 곡선을 바로
생성하는 constructor가 있으면 매우 유용할 것이다.

\item{1.} Parametrization scheme이 주어지지 않으면 centripetal
parametrization을 적용한다.  이는 주어진 데이터 포인트에 가장 가까운 곡선을
생성한다.

\item{2a.} End condition이 주어지지 않으면 데이터 포인트의 갯수에 따라 각각
다른 end condition을 적용한다.
2--3개의 데이터 포인트만 주어지면 quadratic end condition을,
4개 이상의 데이터 포인트가 주어지면 not-a-knot end condition을 적용한다.

\item{2b.} 데이터 포인트와 추가로 두 개의 포인트가 주어지면 clamped end
condition을 적용한다.

@<Constructors and destructor of |cubic_spline|@>+=
cubic_spline::cubic_spline (@/
  @t\idt@>const vector<point>& p,@/
  @t\idt@>end_condition cond,@/
  @t\idt@>parametrization scheme
  )
  @t\idt@>: curve (p), @/
  @t\idt@>_mp ("./cspline.cl"),@/
  @t\idt@>_kernel_id (_mp.create_kernel("evaluate_crv"))@/
{
  point m_0 (2./3.*(*(p.begin())) + 1./3.*(p.back()));
  point m_L (1./3.*(*(p.begin())) + 2./3.*(p.back()));
  if ((p.size() < 4) && cond == end_condition::not_a_knot) {
    _interpolate (p, scheme, end_condition::quadratic, m_0, m_L);
  }
  else {
    _interpolate (p, scheme, cond, m_0, m_L);
  }
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
              parametrization scheme = parametrization::centripetal);
cubic_spline (const vector<point>&, const point, const point,
              parametrization scheme = parametrization::centripetal);




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




@ Hermite form을 이용한 cubic spline의 보간 방정식.
Hermite form으로 기술한 piecewise cubic spline의 $C^2$ 조건으로부터
보간 방정식을 유도할 수 있다.
$u\in[u_i,u_{i+1}]$에 대하여 Hermite form은
$$\bbx(u)=\bbx_i H^3_0(r) + \bbm_i\Delta_iH^3_1(r)
  +\Delta_i\bbm_{i+1}H^3_2(r) + \bbx_{i+1}H^3_3(r)$$
이다.  이 때, $\Delta_i=u_{i+1}-u_i$이고 local parameter
$r=(u-u_i)/\Delta_i$ 이다.
Hermite polynomial $H_i^3$은
$$\eqalign{
H^3_0(t)&=B^3_0(t)+B^3_1(t),\cr
H^3_1(t)&={1\over3}B^3_1(t),\cr
H^3_2(t)&=-{1\over3}B^3_2(t),\cr
H^3_3(t)&=B^3_2(t)+B^3_3(t)
}$$
이며 Bernstein polynomial, $B_j^3(t)$는
$$B_j^n(t)={n\choose j} t^j(1-t)^{n-j}$$
이다.  Binomial coefficients는
$${n\choose j}=\cases{
{n!\over j!(n-j)!},&if $0\geq j\geq n$;\cr
0,&otherwise
}$$
이다.

$C^2$ 조건은
$$\ddot{\bbx}_+(u_i)=\ddot{\bbx}_-(u_i)$$
이므로 위의 식을 대입하여 정리하면
$$\Delta_i\bbm_{i-1}+2(\Delta_{i-1}+\Delta_i)\bbm_i
  +\Delta_{i-1}\bbm_{i+1}
  =3\left({\Delta_i\Delta\bbx_{i-1}\over\Delta_{i-1}}
          +{\Delta_{i-1}\Delta\bbx_i\over\Delta_i}\right)
\quad(i=1,\ldots,L-1)
$$
이다.
따라서, $\bbm_0$와 $\bbm_L$이 주어지는 clamped end condition을 가정하면
시스템 방정식은
$$\pmatrix{
  1&&&&&&\cr
  \alpha_1 &\beta_1 &\gamma_1 &&&&\cr
  &&&\ddots&&&\cr
  &&&&\alpha_{L-1} &\beta_{L-1} &\gamma_{L-1}\cr
  &&&&&&1\cr}
\pmatrix{
  \bbm_0\cr \bbm_1\cr \vdots\cr \bbm_{L-1}\cr \bbm_L\cr}
=\pmatrix{
  \bbr_0\cr \bbr_1\cr \vdots\cr \bbr_{L-1}\cr \bbr_L\cr}
$$
이 때,
$$\eqalign{
\alpha_i&=\Delta_i,\cr
\beta_i&=2(\Delta_{i-1}+\Delta_i),\cr
\gamma_i&=\Delta_{i-1}\cr
}$$
이고
$$\eqalign{
\bbr_0&=\bbm_0,\cr
\bbr_i&=3\left({\Delta_i\Delta\bbx_{i-1}\over\Delta_{i-1}}
          +{\Delta_{i-1}\Delta\bbx_i\over\Delta_i}\right)
  \quad i=1,\ldots,L-1,\cr
\bbr_L&=\bbm_L\cr
}$$
이다.
첫 번째와 마지막 방정식은 곡선의 종단조건에 따라 달라진다. 이는 다음 마디에서
보다 자세하게 다룬다.

@<Setup Hermite form equations of cubic spline interpolation@>=
unsigned long L = p.size() - 1;

vector<double> a(L, 0.0);    // $\alpha$, lower diagonal.
vector<double> b(L+1, 0.0);  // $\beta$, diagonal.
vector<double> c(L, 0.0);    // $\gamma$, upper diagonal.
vector<point> r(L+1, point(p[0].dim()));  // ${\bf r}$, right hand side.

for (size_t i = 1; i != L; i++) {
  double d_im1 = delta (i-1);
  double d_i = delta (i);

  double alpha_i = d_i;
  double beta_i = 2.0*(d_im1+d_i);
  double gamma_i = d_im1;

  a[i-1] = alpha_i;
  b[i] = beta_i;
  c[i] = gamma_i;

  point r_i = 3.0*(d_i*(p[i]-p[i-1])/d_im1 + d_im1*(p[i+1]-p[i])/d_i);
  r[i] = r_i;
}




@ 종단조건.
앞에서 설명한 바와 같이 cubic spline 보간은 방정식의 갯수보다
미지수의 갯수가 2개 많은 under-constrained system이다.  부족한 조건 2개는 곡선
양 끝단에서 컨트롤 포인트가 만족해야 하는 end condition으로 결정해야하며,
|cubic_spline| 타입은 clamped, Bessel, quadratic,
not-a-knot, natural, 그리고 periodic end condition을 지원한다.

Bessel end condition: $\bbp_0$에서의 접선벡터 $\bbm_0$는 처음 세 점을
보간하는 parabola의 접선벡터와 동일하다.  따라서,
$$\bbr_0=-{2(2\Delta_0+\Delta_1)\over\Delta_0\beta_1}\bbp_0
  + {\beta_1\over2\Delta_0\Delta_1}\bbp_1
  - {2\Delta_0\over\Delta_1\beta_1}\bbp_2$$
이고
$$\bbr_L={2\Delta_{L-1}\over\Delta_{L-2}\beta_{L-1}}\bbp_{L-2}
  -{\beta_{L-1}\over2\Delta_{L-2}\Delta_{L-1}}\bbp_{L-1}
  +{2(2\Delta_{L-1}+\Delta_{L-2})\over\beta_{L-1}\Delta_{L-1}}\bbp_L$$
이다.

Quadratic end condition: 이는 곡선의 마지막 조각이 2차 다항식이 되는 조건이며
$$\eqalign{
\ddot\bbx(u_0)&=\ddot\bbx(u_1),\cr
\ddot\bbx(u_{L-1})&=\ddot\bbx(u_L)\cr
}$$
이다.  따라서 시스템 방정식은
$$\pmatrix{
  1& 1&&&&&\cr
  \alpha_1 &\beta_1 &\gamma_1 &&&&\cr
  &&&\ddots&&&\cr
  &&&&\alpha_{L-1} &\beta_{L-1} &\gamma_{L-1}\cr
  &&&&&1 &1\cr}
\pmatrix{
  \bbm_0\cr \bbm_1\cr \vdots\cr \bbm_{L-1}\cr \bbm_L\cr}
=\pmatrix{
  \bbr_0\cr \bbr_1\cr \vdots\cr \bbr_{L-1}\cr \bbr_L\cr}
$$
이고,
$$\eqalign{
\bbr_0&={2\over\Delta_0}\Delta\bbp_0,\cr
\bbr_L&={2\over\Delta_{L-1}}\Delta\bbp_{L-1}\cr
}$$
이다.

Natural end condition: 이는 곡선의 양 끝에서 곡률이 0이 되는 조건이다. 즉,
$$\ddot\bbx(u_0)=\ddot\bbx(u_L)=0$$
이 되므로 시스템 방정식은
$$\pmatrix{
  2& 1&&&&&\cr
  \alpha_1 &\beta_1 &\gamma_1 &&&&\cr
  &&&\ddots&&&\cr
  &&&&\alpha_{L-1} &\beta_{L-1} &\gamma_{L-1}\cr
  &&&&&1 &2\cr}
\pmatrix{
  \bbm_0\cr \bbm_1\cr \vdots\cr \bbm_{L-1}\cr \bbm_L\cr}
=\pmatrix{
  \bbr_0\cr \bbr_1\cr \vdots\cr \bbr_{L-1}\cr \bbr_L\cr}
$$
이고
$$\eqalign{
\bbr_0&={3\over\Delta_0}\Delta\bbp_0,\cr
\bbr_L&={3\over\Delta_{L-1}}\Delta\bbp_{L-1}\cr
}$$
이다.


{
\def\du#1{\Delta_{#1}}
\def\ndu#1{{\Delta^*_{#1}}}

Not-a-knot end condition: 이는 곡선 양 끝에 놓인 각각 2개의 곡선 조각들이 하나의
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
\bbd_0&=(1-s)\bbp_0+s\bba_-;\quad s={\du0\over\du0+\du1}\cr
\bbb_5&=(1-s)\bba_++s\bbp_2=(1-r)\bbd_1+r\bbd_2;\quad
      r={\du0+\du1\over\du0+\du1+\du2}\cr
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
        q={\du1+\du2\over\du0+\du1+\du2}\cr
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

정리하면 시스템 방정식은
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
s_i&={\du0\over\du0+\du1}\cr
r_i&={\du0+\du1\over\du0+\du1+\du2}\cr
s_f&={\du{L-1}\over\du{L-2}+\du{L-1}}\cr
r_f&={\du{L-2}+\du{L-1}\over\du{L-3}+\du{L-2}+\du{L-1}}\cr}$$
이다.

Hermite form과 \bezier\ 컨트롤 포인트 사이의 관계, 그리고 그림에 표시된
$\bbb_i$와 $\bbd_i$ 사이의 거리 비례 관계로부터
$$\eqalign{
\bbd_0&=\bbp_0+{\du0\over3}\bbm_0,\cr
\bbd_1&={1\over\du0}
  \left\{(\du0+\du1)\left(\bbp_1-{\du0\over3}\bbm_1\right)
    -\du1\left(\bbp_0+{\du0\over3}\bbm_0\right)\right\},\cr
\bbd_2&={1\over\du1}
  \left\{(\du1+\du2)\left(\bbp_2-{\du1\over3}\bbm_2\right)
    -\du2\left(\bbp_1+{\du1\over3}\bbm_1\right)\right\}\cr
}$$
이다.  따라서 위의 연립방정식에서 $\bbd_0$, $\bbd_1$, $\bbd_2$를
이 식들로 치환하고 정리하면 곡선의 첫 번째 두 마디에 대한 not-a-knot 종단 조건은
$$\displaylines{
\quad\pmatrix{
  \du0\du1^2&\du0\du1\du{01}&\cr
  \du0(2\du1-\du2)+2\du1\du{12}\over3\du{012}&
  \du{01}(\du0(\du1-2\du2)+\du1\du{12})
  \over3\du1\du{012}&
  -\du0\du{01}\du{12}\over3\du1\du{012}\cr
}
\pmatrix{\bbm_0\cr\bbm_1\cr\bbm_2\cr}\hfill\cr
\hfill{}=\pmatrix{
 -\du1^2(3\du0+2\du1)\bbp_0
  -(\du0-2\du1)\du{01}^2\bbp_1
  +\du0^3\bbp_2\over\du{01}\cr
 {-\du1^2(\du0(2\du1-\du2)+2\du1\du{12})\bbp_0
  +(\du0^2\du1^2+2\du0\du1^3+\du0^3\du2
    +\du1^3\du{12})\bbp_1
  -\du0^2\du{01}\du{12}\bbp_2\over
  \du0\du1^2\du{012}}
 +{\du1^3\bbp_0+\du0^3\bbp_2\over\du0\du1^2+\du0^2\du1}
  \cr
}\quad\cr}$$
이다.  이 때, $\du{01}=\du0+\du1$, $\du{12}=\du1+\du2$,
$\du{012}=\du0+\du1+\du2$를 의미한다.

곡선의 반대쪽 끝에서도 같은 방법으로 종단조건 방정식을 유도할 수 있다.
연관되는 컨트롤 포인트들은
$$\eqalign{
\bbd_L&=\bbp_L-{\du{L-1}\over3}\bbm_L,\cr
\bbd_{L-1}&={1\over\du{L-1}}
  \left\{(\du{L-2}+\du{L-1})
    \left(\bbp_{L-1}+{\du{L-1}\over3}\bbm_{L-1}\right)
    -\du{L-2}\left(\bbp_L-{\du{L-1}\over3}\bbm_L\right)\right\},\cr
\bbd_{L-2}&={1\over\du{L-2}}
  \left\{(\du{L-3}+\du{L-2})
    \left(\bbp_{L-2}+{\du{L-2}\over3}\bbm_{L-2}\right)
    -\du{L-3}\left(\bbp_{L-1}-{\du{L-2}\over3}\bbm_{L-1}\right)\right\}\cr
}$$
이고, 이를 $\bbd_i$에 대하여 기술한 곡선 마지막 부분의 종단조건 방정식에
대입하면,
$$\displaylines{
\quad\pmatrix{
  \ndu{32}\ndu{1}\ndu{21}\over3\ndu{2}\ndu{321}&
  -\ndu{21}(\ndu{3}(\ndu{2}-2\ndu{1})+\ndu{2}\ndu{21})
    \over3\ndu{2}\ndu{321}&
  \ndu{3}(-2\ndu{2}+\ndu{1})-2\ndu{2}\ndu{21}\over3\ndu{321}\cr
  &\ndu{2}\ndu{1}\ndu{21}&
  \ndu{2}^2\ndu{1}\cr
}
\pmatrix{\bbm_{L-2}\cr\bbm_{L-1}\cr\bbm_L\cr}\hfill\cr
\hfill{}=\pmatrix{
  {-\ndu{32}\ndu{1}^2\ndu{21}\bbp_{L-2}
  +(\ndu{2}^2\ndu{21}^2+\ndu{3}(\ndu{2}^3+\ndu{1}^3))\bbp_{L-1}
  -\ndu{2}^2(\ndu{3}(2\ndu{2}-\ndu{1})+2\ndu{2}\ndu{21})\bbp_L
  \over\ndu{2}^2\ndu{1}\ndu{321}}
  +{\ndu{1}^3\bbp_{L-2}+\ndu{2}^3\bbp_L\over\ndu{2}^2\ndu{1}+\ndu{2}\ndu{1}^2}\cr
  -{\ndu{1}^3\bbp_{L-2}+(2\ndu{2}-\ndu{1})\ndu{21}^2\bbp_{L-1}
    -\ndu{2}^2(2\ndu{2}+3\ndu{1})\bbp_L}\over\ndu{21}\cr
}\quad\cr}$$
이다.  위의 식에서 $\ndu{i}=\du{L-i}$를 의미하고, $\ndu{21}=\ndu2+\ndu1$,
  $\ndu{32}=\ndu3+\ndu2$, $\ndu{321}=\ndu3+\ndu2+\ndu1$이다.


{\bf 참고:} Not-a-knot end condition은 최소 4개 이상($3\leq L$)이어야 적용 가능하다.
왜냐하면, $L=2$인 경우에는 $s_i=\du0/(\du0+\du1)$,
$s_f=\du1/(\du0+\du1)$, $r_i=r_f=1$이 되어 시스템 방정식은
$$\pmatrix{0&{3\du0\du1\over(\du0+\du1)^2}&\cr
  {\du1\over\du0}& -1& {\du0\over\du1}\cr
  &{3\du0\du1\over(\du0+\du1)^2}&0\cr}
\pmatrix{\bbd_0\cr\bbd_1\cr\bbd_2\cr}=
\pmatrix{-{\du1^3\over(\du0+\du1)^3}\bbp_0
         +\bbp_1-{\du0^3\over(\du0+\du1)^3}\bbp_2\cr
         {\du1^2\over\du0(\du0+\du1)}\bbp_0
         +{\du0^2\over\du1(\du0+\du1)}\bbp_2\cr
         -{\du1^3\over(\du0+\du1)^3}\bbp_0
         +\bbp_1-{\du0^3\over(\du0+\du1)^3}\bbp_2\cr
         }$$
이 되며, 죄측 행렬은 rank가 2에 불과한 underconstrained system을
의미하기 때문이다.
}

@<Modify equations according to end conditions and solve them@>=
switch (cond) {
  case end_condition::clamped: @/
    b[0] = 1.0; // First row.
    c[0] = 0.0;
    r[0] = m_0;

    a[L-1] = 0.0; // Last row.
    b[L] = 1.0;
    r[L] = m_L;

  break;

  case end_condition::bessel: @/
    b[0] = 1.0;
    c[0] = 0.0;
    r[0] = -2*(2*delta(0)+delta(1))/(delta(0)*b[1])*p[0]
         +b[1]/(2*delta(0)*delta(1))*p[1]
         -2*delta(0)/(delta(1)*b[1])*p[2];

    a[L-1] = 0.0;
    b[L] = 1.0;
    r[L] = 2*delta(L-1)/(delta(L-2)*b[L-1])*p[L-2]
         -b[L-1]/(2*delta(L-2)*delta(L-1))*p[L-1]
         +2*(2*delta(L-1)+delta(L-2))/(b[L-1]*delta(L-1))*p[L];
  break;

  case end_condition::not_a_knot: @/
  {
    double d0 = delta(0);
    double d1 = delta(1);
    double d2 = delta(2);

    double d01 = d0 + d1;
    double d12 = d1 + d2;

    double d012 = d0 + d1 + d2;

    b[0] = d0*pow(d1,2);
    c[0] = d0*d1*d01;
    r[0] = (p[2]*pow(d0,3) -p[1]*(d0-2*d1)*pow(d01,2)
         -p[0]*pow(d1,2)*(3*d0+2*d2))/d01;

    a[0] = (d0*(2*d1-d2)+2*d1*d12)/(3*d012);
    b[1] = (d01)*(d0*(d1-2*d2) +d1*d12) /(3*d1*d012);
    c[1] = -d0*d01*d12 /(3*d1*d012);
    r[1] = (-p[2]*pow(d0,2)*d01*d12
            -p[0]*pow(d1,2)*(d0*(2*d1-d2) +2*d1*d12)
            +p[1]*(pow(d0*d1,2) +2*d0*pow(d1,3)+pow(d0,3)*d2 +pow(d1,3)*d12))
         /(d0*pow(d1,2)*d012)
         +(p[2]*pow(d0,3)+p[0]*pow(d1,3))/(d0*d1*d01);

    d1 = delta(L-1);
    d2 = delta(L-2);
    double d3 = delta(L-3);

    d12 = d1 + d2;
    double d23 = d2 + d3;

    double d123 = d1 + d2 + d3;

    a[L-2] = d23*d1*d12/(3*d2*d123);
    b[L-1] = -d12*(d3*(d2-2*d1)+d2*d12)/(3*d2*d123);
    c[L-1] = (d3*(-2*d2+d1)-2*d2*d12)/(3*d123);
    r[L-1] = (-p[L-2]*d23*pow(d1,2)*d12
              -p[L]*pow(d2,2)*(d3*(2*d2-d1)+2*d2*d12)
              +p[L-1]*(pow(d2,2)*pow(d12,2)+d3*(pow(d2,3)+pow(d1,3))))
             /(pow(d2,2)*d1*d123)
             +(pow(d2,3)*p[L]+pow(d1,3)*p[L-2])/(d1*d2*d12);

    a[L-1] = d2*d1*d12;
    b[L] = pow(d2,2)*d1;
    r[L] = (-p[L-2]*pow(d1,3)-p[L-1]*(2*d2-d1)*pow(d12,2)
            +p[L]*pow(d2,2)*(2*d2+3*d1))/d12;
  }
  break;

  case end_condition::quadratic: @/
    b[0] = 1.0;
    c[0] = 1.0;
    r[0] = 2/delta(0)*(p[1]-p[0]);

    a[L-1] = 1.0;
    b[L] = 1.0;
    r[L] = 2/delta(L-1)*(p[L]-p[L-1]);
  break;

  case end_condition::natural: @/
     b[0] = 2.0;
     c[0] = 1.0;
     r[0] = 3/delta(0)*(p[1]-p[0]);

     a[L-1] = 1.0;
     b[L] = 2.0;
     r[L] = 3/delta(L-1)*(p[L]-p[L-1]);
  break;

default:@/
  _err = UNKNOWN_END_CONDITION;
  return;
}
solve_hform_tridiagonal_system_set_ctrl_pts (a, b, c, r, p);

@ @<Error codes of |cagd|@>+=
TRIDIAGONAL_NOT_SOLVABLE, @/
UNKNOWN_END_CONDITION,




@ Hermite form을 이용한 tridiagonal system 방정식을 풀면
컨트롤 포인트가 아니라 $\bbm_i$들을 결과로 얻는다.  따라서 Hermite form을
\bezier\ form을 거쳐 B-spline form으로 변경하여 컨트롤 포인트를 얻는다.

@<Methods for interpolation of |cubic_spline|@>+=
void
cubic_spline::solve_hform_tridiagonal_system_set_ctrl_pts (@/
  @t\idt@>const vector<double>& a,@/
  @t\idt@>const vector<double>& b,@/
  @t\idt@>const vector<double>& c,@/
  @t\idt@>const vector<point>& r,@/
  @t\idt@>const vector<point>& p@/
  ) @+ {

  unsigned long L = p.size() - 1;
  vector<point> m (L+1, point(p[0].dim()));

  if (solve_tridiagonal_system (a, b, c, r, m) != 0) {
    _err = TRIDIAGONAL_NOT_SOLVABLE;
    return;
  }

  vector<point> bp = bezier_points_from_hermite_form (p, m);
  vector<point> d = control_points_from_bezier_form (bp);

  _ctrl_pts = d;
}

@ @<Methods of |cubic_spline|@>+=
protected:@/
void solve_hform_tridiagonal_system_set_ctrl_pts (@/
  const vector<double>&,
  const vector<double>&,
  const vector<double>&,@/
  const vector<point>&,
  const vector<point>&
);




@ 사람의 보행궤적과 같은 주기적인 운동궤적을 다루기 위해서는 곡선의 시작점과
끝점이 일치($\bbp_0=\bbp_L$)할 뿐 아니라 그 점에서 2차 미분까지 연속($C^2$
condition)인 곡선이 필요하다.
이 마디에서는 Hermite form이 아니라 B-spline의 컨트롤 포인트로부터
데이터 포인트 $\bbp_i$에서의 $C^2$ 연속성 조건을 기술한다.
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

{\it Note: periodic이 아닌 일반 곡선의 양 끝부분에서는 조금 상황이 다르며
$$\eqalign{
\bbb_2&={\Delta_1\bbd_0+\Delta_0\bbd_1\over\Delta_0+\Delta_1}\cr
\bbb_{3L-2}&={\Delta_{L-1}\bbd_{L-1}+\Delta_{L-2}\bbd_L
  \over\Delta_{L-2}+\Delta_{L-1}}\cr
\bbb_1&=\bbd_0\cr
\bbb_{3L-1}&=\bbd_L\cr}$$
이 된다.  $\bbd_0$와 $\bbd_L$은 end condition에 의하여 결정되거나,
clamped end condition의 경우에는 임의의 값이 주어진다.}

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
이다.

Periodic cubic spline 곡선의 컨트롤 포인트는 방정식
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
한 가지 주의할 점은, 위의 방정식의 해가 바로 periodic cubic spline 곡선의 
컨트롤 포인트는 아니다.  Cubic spline 곡선의 컨트롤 포인트는 곡선의 
양 끝점을 포함한다.  따라서 위의 그림을 예로 들면 곡선의 컨트롤 포인트는 
$\bbp_0$, $\bbd_+$, $\bbd_1$, $\bbd_2$, $\bbd_3$, $\bbd_4$,
$\bbd_-$, $\bbp_5$다.

@<Setup equations for periodic end condition and solve them@>=
unsigned long L = p.size() - 1;

vector<double> a(L, 0.0);  // $\alpha$, lower diagonal.
vector<double> b(L, 0.0);  // $\beta$, diagonal.
vector<double> c(L, 0.0);  // $\gamma$, upper diagonal.
vector<point> r(L, p[0].dim());  // ${\bf r}$, right hand side.

a[0] = delta(0)*delta(0)/(delta(L-2)+delta(L-1)+delta(0));
b[0] = delta(0)*(delta(L-2)+delta(L-1))/(delta(L-2)+delta(L-1)+delta(0))
  +delta(L-1)*(delta(0)+delta(1))/(delta(L-1)+delta(0)+delta(1));
c[0] = delta(L-1)*delta(L-1)/(delta(L-1)+delta(0)+delta(1));

for (size_t i = 1; i != L; i++) {
  double delta_im2 = delta (i-2);
  double delta_im1 = delta (i-1);
  double delta_i = delta (i);
  double delta_ip1 = delta (i+1);

  double alpha_i = delta_i*delta_i/(delta_im2+delta_im1+delta_i);
  double beta_i = delta_i*(delta_im2+delta_im1)/(delta_im2+delta_im1+delta_i)
                 +delta_im1*(delta_i+delta_ip1)/(delta_im1+delta_i+delta_ip1);
  double gamma_i = delta_im1*delta_im1/(delta_im1+delta_i+delta_ip1);

  a[i] = alpha_i;
  b[i] = beta_i;
  c[i] = gamma_i;

  r[i] = (delta_im1+delta_i)*p[i];
}

a[1] = delta(1)*delta(1)/(delta(L-1)+delta(0)+delta(1));
b[1] = delta(1)*(delta(L-1)+delta(0))/(delta(L-1)+delta(0)+delta(1))
  +delta(0)*(delta(1)+delta(2))/(delta(0)+delta(1)+delta(2));

b[L-1] = delta(L-1)*(delta(L-3)+delta(L-2))/(delta(L-3)+delta(L-2)+delta(L-1))
  +delta(L-2)*(delta(L-1)+delta(0))/(delta(L-2)+delta(L-1)+delta(0));
c[L-1] = delta(L-2)*delta(L-2)/(delta(L-2)+delta(L-1)+delta(0));

r[0] = (delta(L-1)+delta(0))*p[0];

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
7개의 경로점
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

  double err =0.;
  for (size_t i = 0; i != steps; i++) {
    err += dist (crv_pts_s[i], crv_pts_p[i]);
  }
  cout << "Mean difference between serial and parallel computation = "
       << err/double(steps) << endl;
}

@ 실행 결과.
\medskip
\centerline{\includegraphics{figs/periodic.pdf}}
\medskip




@ $C^2$ cubic spline 곡선은 knot에서 나뉘는 각 조각별로 형상이 같은
\bezier\ 곡선으로 변환할 수 있다.

@<Methods for conversion of |cubic_spline|@>+=
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




@*1 Knot Insertion and Removal.
먼저 knot insertion을 수행하는 method를 정의한다.
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
cubic_spline::get_blending_ratio (@/
    @t\idt@>const vector<double>& IGESKnot,
    long v, long r, long i@/
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




@*1 Output to PostScript File.
PostScript 파일 출력을 위한 함수들은 다음과 같다.
곡선을 계산할 때 입력받는 변수 |dense|는 곡선을 몇 개의 선분 조각으로 근사화할
것인지 나타내므로 실제 계산해야 하는 곡선상의 점들은 그것보다 하나 더 많다.

@<Methods for PostScript output of |cubic_spline|@>=
void
cubic_spline::write_curve_in_postscript (@/
  @t\idt@>psf& ps_file, unsigned dense, float line_width, int x, int y,
  float magnification@/
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

  ps_file << "stroke" << endl;
  ps_file.flags (previous_options);
}

void
cubic_spline::write_control_polygon_in_postscript (@/
  @t\idt@>psf& ps_file, float line_width, int x, int y, float magnification@/
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
  @t\idt@>psf& ps_file, float line_width, int x, int y, float magnification@/
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
