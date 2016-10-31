@* Generic Curve.
|curve| 타입은 컨트롤 포인트에 의하여 모양과 특성이 결정되는 일반적인 곡선을
의미한다.  따라서 데이타 멤버로 |_ctrl_pts|를 갖는다.

한편, 그래픽스 객체를 다루는 경우 가장 쉽고 직관적인 디버깅 방법은 객체를
시각화하는 것이다.
|curve| 타입은 PostScript 파일 출력을 위한 data member와 method들을 정의한다.

@s ctrlpt_itr int
@s const_ctrlpt_itr int

@<Definition of |curve|@>=
class curve {
protected: @/
  vector<point> _ctrl_pts;
  mutable cagd::err_code _err;

public: @/
  typedef vector<point>::iterator ctrlpt_itr;
  typedef vector<point>::const_iterator const_ctrlpt_itr;

@#
  @<Methods of |curve|@>@;
};




@ |curve| 타입에는 PostScript 파일 출력을 위한 method들과
주어진 parameter에 대응하는 곡선의 값과 미분값을 계산하기 위한 method들의
인터페이스를 정의한다.  인터페이스는 pure virtual function으로 정의하므로
구현은 없다.

@<Implementation of |curve|@>=
@<Properties of |curve|@>@;
@<Access control points of |curve|@>@;
@<Constructor and destructor of |curve|@>@;
@<Methods for debugging of |curve|@>@;
@<Operators of |curve|@>@;




@ |curve| 타입 객체의 property들 중, 차원을 반환하는 method는 컨트롤 포인트의
차원에 의하여 결정된다.  하지만 곡선의 차수는 아직 정의할 수 없으므로 pure virtual
function으로 둔다.

@<Properties of |curve|@>=
unsigned long
curve::dimension () const @+ {
  if (_ctrl_pts.size() > 0) {
    return _ctrl_pts.begin() -> dim();
  } @+ else {
    return 0;
  }
}

unsigned long
curve::dim () const @+ {
  return dimension ();
}

@ @<Methods of |curve|@>+=
public: @/
virtual unsigned long dimension () const;
virtual unsigned long dim () const;
virtual unsigned long degree () const =0;




@ |curve|의 컨트롤 포인트에 접근하기 위한 method를 정의한다.
이 method는 인자 0이 주어졌을 때, 첫 번째 컨트롤 포인트를 반환한다.

@<Access control points of |curve|@>=
point curve::ctrl_pts (const size_t& i) const @+ {
  size_t size = _ctrl_pts.size();
  if ((i < 1) || (size < i)) {
    return _ctrl_pts[0];
  } @+ else {
    return _ctrl_pts[i];
  }
}

size_t curve::ctrl_pts_size () const @+ {
  return _ctrl_pts.size();
}

@ @<Methods of |curve|@>+=
point ctrl_pts (const size_t&) const;
size_t ctrl_pts_size () const;




@ 곡선, control polygon, control point 들을 PostScript 파일로 출력하는 함수들의
인터페이스는 pure virtual function으로 정의한다.

@<Methods of |curve|@>=
virtual void write_curve_in_postscript (@/
  @t\idt@>psf&,@/
  @t\idt@>unsigned, float,@/
  @t\idt@>int x=1, int y=1,@/
  @t\idt@>float magnification = 1.) const =0;

virtual void write_control_polygon_in_postscript (@/
  @t\idt@>psf&,@/
  @t\idt@>float,@/
  @t\idt@>int x=1, int y=1,@/
  @t\idt@>float magnification = 1.) const =0;

virtual void write_control_points_in_postscript (@/
  @t\idt@>psf&,@/
  @t\idt@>float,@/
  @t\idt@>int x=1, int y=1,@/
  @t\idt@>float magnification = 1.) const =0;

@ @<Error codes of |cagd|@>+=
OUTPUT_FILE_OPEN_FAIL,




@ 곡선 위에 있는 점의 위치와 미분을 계산하는 함수들도 pure virtual function으로
정의한다.

@<Methods of |curve|@>+=
public:@/
virtual point evaluate (const double) const =0;
virtual point derivative (const double) const =0;




@ Constructor와 destructor에 특별한 것은 없다.

@<Constructor and destructor of |curve|@>=
curve::curve () @+ {
}

curve::curve (const vector<point>& pts)
  @t\idt@>: _ctrl_pts (pts)
{
}

curve::curve(const list<point> &pts)
  @t\idt@>: _ctrl_pts(vector<point>(pts.size(), pts.begin()->dim()))
{
  list<point>::const_iterator pt(pts.begin());
  for (size_t i=0; i!=pts.size(); i++) {
    _ctrl_pts[i]=*pt;
    pt++;
  }
}

curve::curve (const curve& src)
  @t\idt@>: _ctrl_pts (src._ctrl_pts)
{
}

curve::~curve () @+ {
}

@ @<Methods of |curve|@>+=
public:@/
curve ();
curve (const vector<point>&);
curve (const list<point>&);
curve (const curve&);
virtual ~curve ();




@ Debugging을 위해 |curve| 타입 객체의 정보를 출력하는 method를 정의한다.

@<Methods for debugging of |curve|@>=
string curve::description () const @+ {
  stringstream buffer;
  buffer << "----------------------------" << endl;
  buffer << "    Description of Curve    " << endl;
  buffer << "----------------------------" << endl;
  buffer << "  Dimension of curve: " << dim() << endl;
  buffer << "  Control points: " << endl;
  for (size_t i = 0; i != _ctrl_pts.size(); i++) {
    buffer << "    " << _ctrl_pts[i].description();
  }
  return buffer.str();
}

@ @<Methods of |curve|@>+=
public: @/
string description () const;




@ Assignment operator.

@<Operators of |curve|@>=
curve& curve::operator= (const curve& crv) @+ {
  _ctrl_pts = crv._ctrl_pts;
  _err = crv._err;

  return *this;
}

@ @<Methods of |curve|@>+=
public:@/
curve& operator= (const curve&);
