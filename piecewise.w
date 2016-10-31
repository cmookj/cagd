@q ************************************************************************** @>
@q                                                                            @>
@q            P I E C E W I S E    B E Z I E R    C U R V E                   @>
@q                                                                            @>
@q ************************************************************************** @>

@* Piecewise B\'ezier Curve.
여러개의 \bezier\ curve들을 모아 한번에 다루기 위한 타입이다.
|bezier| 타입 객체들을 저장하기 위한 |vector<bezier>| 타입의 데이타 멤버와
몇 가지 method들을 갖는다.
그리고 |vector|에 들어있는 객체들에 접근하기 위한 iterator의
타입을 선언한다.

@s const_curve_itr int
@s curve_itr int

@<Definition of |piecewise_bezier_curve|@>=
class piecewise_bezier_curve : public curve {
protected: @/
  vector<bezier> _curves;

public: @/
  typedef vector<bezier>::const_iterator const_curve_itr;
  typedef vector<bezier>::iterator curve_itr;
@#
  @<Methods of |piecewise_bezier_curve|@>@;
};

@ |piecewise_bezier_curve| 타입의 method들은 다음과 같다.

@s piecewise_bezier_curve int

@<Implementation of |piecewise_bezier_curve|@>=
@<Constructors and destructor of |piecewise_bezier_curve|@>@;
@<Properties of |piecewise_bezier_curve|@>@;
@<Modification of |piecewise_bezier_curve|@>@;
@<Operators of |piecewise_bezier_curve|@>@;
@<Degree elevation and reduction of |piecewise_bezier_curve|@>@;
@<Evaluation and derivative of |piecewise_bezier_curve|@>@;
@<PostScript output of |piecewise_bezier_curve|@>@;




@ |piecewise_bezier_curve| 타입은 default constructor와 copy constructor를
갖는다.

@<Constructors and destructor of |piecewise_bezier_curve|@>=
piecewise_bezier_curve::piecewise_bezier_curve () @+ {}

piecewise_bezier_curve::piecewise_bezier_curve (const piecewise_bezier_curve& r)
  : curve::curve (r),
    _curves (r._curves)
{
}

piecewise_bezier_curve::~piecewise_bezier_curve () @+ {}

@ @<Methods of |piecewise_bezier_curve|@>+=
public: @/
piecewise_bezier_curve ();
piecewise_bezier_curve (const piecewise_bezier_curve&);
virtual ~piecewise_bezier_curve ();




@ |piecewise_bezier_curve| 타입 객체의 몇 가지 property들을 정의한다.
객체가 포함하는 \bezier\ 곡선이 모두 같은 차수를 갖는 것은 아니므로,
|piecewise_bezier_curve| 타입 객체의 차수는 그것이 갖고 있는 \bezier\ 곡선들 중
가장 높은 차수로 정의한다.  그러나 차원은 모든 곡선들에 대하여 동일하므로,
편의상 첫 번째 곡선의 차원을 반환한다.

@<Properties of |piecewise_bezier_curve|@>=
size_t
piecewise_bezier_curve::count () const @+ {
  return _curves.size();
}

unsigned long
piecewise_bezier_curve::dimension () const @+ {
  if (_curves.size() != 0) {
    return _curves.begin() -> dimension();
  } @+ else {
    return 0;
  }
}

unsigned long
piecewise_bezier_curve::dim () const @+ {
  return dimension ();
}

unsigned long
piecewise_bezier_curve::degree () const @+ {
  unsigned long dgr = 0;
  for (const_curve_itr crv = _curves.begin(); crv != _curves.end(); crv++) {
    if (crv -> degree() > dgr) {
      dgr = crv -> degree();
    }
  }
  return dgr;
}

@ @<Methods of |piecewise_bezier_curve|@>+=
public: @/
size_t count() const;
unsigned long dimension () const;
unsigned long dim () const;
unsigned long degree () const;




@ |piecewise_bezier_curve| 타입 객체에 |bezier| 타입 객체를 추가하는
method를 정의한다.

@<Modification of |piecewise_bezier_curve|@>=
void
piecewise_bezier_curve::push_back (bezier crv) @+ {
  _curves.push_back (crv);
}

@ @<Methods of |piecewise_bezier_curve|@>+=
public: @/
void push_back (bezier);




@ Operators of |piecewise_bezier_curve|.

@<Operators of |piecewise_bezier_curve|@>=
piecewise_bezier_curve& 
piecewise_bezier_curve::operator= (const piecewise_bezier_curve& crv) @+ {
  curve::operator= (crv);
  _curves = crv._curves;

  return *this;
}

@ @<Methods of |piecewise_bezier_curve|@>+=
public:@/
piecewise_bezier_curve& operator= (const piecewise_bezier_curve&);




@ |piecewise_bezier_curve| 타입 객체에 포함되어 있는 모든 곡선들의 차수를
높이거나 낮추는 method를 정의한다.

@<Degree elevation and reduction of |piecewise_bezier_curve|@>=
void
piecewise_bezier_curve::elevate_degree (const unsigned long dgr) @+ {
  for (curve_itr crv = _curves.begin(); crv != _curves.end(); crv++) {
    crv -> elevate_degree (dgr);
  }
}

void
piecewise_bezier_curve::reduce_degree (const unsigned long dgr) @+ {
  for (curve_itr crv = _curves.begin(); crv != _curves.end(); crv++) {
    crv -> reduce_degree (dgr);
  }
}

@ @<Methods of |piecewise_bezier_curve|@>+=
public: @/
void elevate_degree (const unsigned long);
void reduce_degree (const unsigned long);




@ |piecewise_bezier_curve| 타입의 evaluation과 derivative를 구하는 method를
정의한다.  먼저 주어진 인자 $u$의 값을 보고 몇 번째 |bezier| 곡선에서 값을
구할지 결정한다.
|piecewise_bezier_curve| 객체에 \bezier\ 곡선이 $n$개 포함되어 있다면,
$0\leq u\leq n$이어야 한다.  만약 객체 내에 곡선이 하나도 없거나, $u$가
적절한 범위 밖의 값으로 주어지면 0을 반환한다.

@<Evaluation and derivative of |piecewise_bezier_curve|@>=
point
piecewise_bezier_curve::evaluate (const double u) const @+ {

  if (_curves.size() == 0) return cagd::point(2);

  double max_u = static_cast<double>(_curves.size());
  if ((u < 0.) || (max_u < u)) return cagd::point(dimension ());

  size_t index;
  if (u == max_u) {
    index = static_cast<long>(u)-1;
  } @+ else {
    index = static_cast<long>(std::floor (u));
  }

  return _curves[index].evaluate (u);
}

point
piecewise_bezier_curve::derivative (const double u) const @+ {
  if (_curves.size() == 0) return cagd::point(2);

  double max_u = static_cast<double>(_curves.size());
  if ((u < 0.) || (max_u < u)) return cagd::point(dimension ());

  size_t index;
  if (u == max_u) {
    index = static_cast<long>(u)-1;
  } @+ else {
    index = static_cast<long>(std::floor (u));
  }

  return _curves[index].derivative (u);
}

@ @<Methods of |piecewise_bezier_curve|@>+=
public: @/
point evaluate (const double) const;
point derivative (const double) const;




@ |piecewise_bezier_curve| 타입의 PostScript 출력을 위한 method들이다.

@<PostScript output of |piecewise_bezier_curve|@>=
void
piecewise_bezier_curve::write_curve_in_postscript (@/
  @t\idt@>psf& ps_file,@/
  @t\idt@>unsigned step,@/
  @t\idt@>float line_width,@/
  @t\idt@>int x, int y,@/
  @t\idt@>float magnification@/
  @t\idt@>) const @+ {

  ios_base::fmtflags previous_options = ps_file.flags();
  ps_file.precision(4);
  ps_file.setf (ios_base::fixed, ios_base::floatfield);

  for (const_curve_itr crv = _curves.begin(); crv != _curves.end(); crv++) {
    ps_file << "newpath" << endl
            << "[] 0 setdash " << line_width << " setlinewidth" << endl;

    point pt = magnification*(crv->evaluate (0));
    ps_file << pt(x) << "\t" << pt(y) << "\t" << "moveto" << endl;

    for (size_t i = 1; i <= step; i++) {
      double t = double(i)/double(step);
      pt = magnification*(crv->evaluate (t));
      ps_file << pt(x) << "\t" << pt(y) << "\t" << "lineto" << endl;
    }
    ps_file << "stroke" << endl;
  }
  ps_file.flags (previous_options);
}

void
piecewise_bezier_curve::write_control_polygon_in_postscript (@/
  @t\idt@>psf& ps_file,@/
  @t\idt@>float line_width,@/
  @t\idt@>int x, int y,@/
  @t\idt@>float magnification@/
  @t\idt@>) const @+ {

  ios_base::fmtflags previous_options = ps_file.flags();
  ps_file.precision(4);
  ps_file.setf (ios_base::fixed, ios_base::floatfield);

  for (const_curve_itr crv = _curves.begin(); crv != _curves.end(); crv++) {
    ps_file << "newpath" << endl;
    ps_file << "[] 0 setdash " << .5*line_width << " setlinewidth" << endl;

    point pt = magnification*(crv->ctrl_pts(0));
    ps_file << pt(x) << "\t" << pt(y) << "\t" << "moveto" << endl;

    for (size_t i = 1; i != crv->ctrl_pts_size(); ++i) {
      pt = magnification*(crv->ctrl_pts(i));
      ps_file << pt(x) << "\t" << pt(y) << "\t" << "lineto" << endl;
    }
    ps_file << "stroke" << endl;
  }
  ps_file.flags (previous_options);
}

void
piecewise_bezier_curve::write_control_points_in_postscript (@/
  @t\idt@>psf& ps_file,@/
  @t\idt@>float line_width,@/
  @t\idt@>int x, int y,@/
  @t\idt@>float magnification@/
  @t\idt@>) const @+ {

  ios_base::fmtflags previous_options = ps_file.flags();
  ps_file.precision(4);
  ps_file.setf (ios_base::fixed, ios_base::floatfield);

  for (const_curve_itr crv = _curves.begin(); crv != _curves.end(); crv++) {
    ps_file << "0 setgray" << endl;
    ps_file << "newpath" << endl;

    point pt = magnification*(crv->ctrl_pts(0));
    ps_file << pt(x) << "\t" << pt(y) << "\t";
    ps_file << (line_width*3) << "\t" << 0.0 << "\t" << 360 << "\t"
             << "arc" << endl;
    ps_file << "closepath" << endl;
    ps_file << "fill stroke" << endl;

    if (crv->ctrl_pts_size() > 2) @+ {
      for (size_t i = 1; i != crv->ctrl_pts_size() - 1; ++i) {
        ps_file << "newpath" << endl;
        pt = magnification*(crv->ctrl_pts(i));
        ps_file << pt(x) << "\t" << pt(y) << "\t";
        ps_file << (line_width*3) << "\t" << 0.0 << "\t" << 360 << "\t"
                 << "arc" << endl;
        ps_file << "closepath" << endl;
        ps_file << line_width << "\t" << "setlinewidth" << endl;
        ps_file << "stroke" << endl;
      }
      ps_file << "0 setgray" << endl;
      ps_file << "newpath" << endl;
      pt = magnification*(crv->ctrl_pts(crv->ctrl_pts_size()-1));
      ps_file << pt(x) << "\t" << pt(y) << "\t";
      ps_file << (line_width*3) << "\t" << 0.0 << "\t" << 360 << "\t"
               << "arc" << endl;
      ps_file << "closepath" << endl;
      ps_file << "fill stroke" << endl;
    }
  }
  ps_file.flags (previous_options);
}

@ @<Methods of |piecewise_bezier_curve|@>+=
public: @/
void write_curve_in_postscript (@/
  @t\idt@>psf&, unsigned, float, int x = 1, int y = 2,@/
  @t\idt@>float magnification = 1.) const;

void write_control_polygon_in_postscript (@/
  @t\idt@>psf&, float, int x = 1, int y = 2,@/
  @t\idt@>float magnification = 1.) const;

void write_control_points_in_postscript (@/
  @t\idt@>psf&, float, int x = 1, int y = 2,@/
  @t\idt@>float magnification = 1.) const;




@ Test of |piecewise_bezier_curve| type.
|piecewise_bezier_curve| 객체를 통한 |bezier| 곡선의 생성과 조작을 보여준다.
Traditional Chinese character 중 하나를 골라 글자의 외곽선을 여러개의
\bezier\ 곡선으로 근사화한다.  곡선의 차수는 3차부터 7차까지 다양하게 섞여 있다.
\bezier\ 곡선들을 하나의 |piecewise_bezier_curve| 객체로 묶은 후,
원래 형상을 PostScript 파일로 기술한다.
그 다음에 |piecewise_bezier_curve| 객체의 차수, 즉 그것을 구성하는
\bezier\ 곡선들 중 가장 높은 차수에 맞춰 degree elevation을
수행하고 결과를 다른 PostScript 파일에 기술한다.
마지막으로 모든 곡선 조각들을 다시 3차 \bezier\ 곡선으로 차수를 낮춘 후, 또 다른
PostScript 파일에 기술한다.

@<Test routines@>+=
print_title ("piecewise bezier curve");
{
  piecewise_bezier_curve curves;
  vector<point> ctrl_pts;

  @<Build-up 3rd brush@>;
  @<Build-up 2nd, 4th, and 5th brush@>;
  @<Build-up 1st brush@>;
  @<Build-up 6th, 7th, 8th, and 9th brush (outer part)@>;
  @<Build-up 6th, 7th, 8th, and 9th brush (inner part)@>;
@#
  psf file = create_postscript_file ("untouched.ps"); // Draw original outline.
  curves.write_curve_in_postscript (file, 100, 1.);
  curves.write_control_polygon_in_postscript (file, 1.);
  curves.write_control_points_in_postscript (file, 1.);
  close_postscript_file (file, true);
@#
  unsigned long deg = curves.degree (); // Degree elevation.
  curves.elevate_degree (deg);
  file = create_postscript_file ("degree_elevated.ps");
  curves.write_curve_in_postscript (file, 100, 1.);
  curves.write_control_polygon_in_postscript (file, 1.);
  curves.write_control_points_in_postscript (file, 1.);
  close_postscript_file (file, true);
@#
  curves.reduce_degree (3); // Degree reduction.
  file = create_postscript_file ("degree_reduced.ps");
  curves.write_curve_in_postscript (file, 100, 1.);
  curves.write_control_polygon_in_postscript (file, 1.);
  curves.write_control_points_in_postscript (file, 1.);
  close_postscript_file (file, true);
}

@ @<Build-up 3rd brush@>=
ctrl_pts.push_back (point ({183, 416})); // 1st curve
ctrl_pts.push_back (point ({184, 415}));
ctrl_pts.push_back (point ({185, 413}));
ctrl_pts.push_back (point ({186, 412}));
ctrl_pts.push_back (point ({186, 411}));
ctrl_pts.push_back (point ({186, 409}));
ctrl_pts.push_back (point ({184, 405}));
ctrl_pts.push_back (point ({180, 401}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({180, 401})); // 2nd curve
ctrl_pts.push_back (point ({176, 397}));
ctrl_pts.push_back (point ({172, 394}));
ctrl_pts.push_back (point ({154, 359}));
ctrl_pts.push_back (point ({140, 333}));
ctrl_pts.push_back (point ({126, 312}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({126, 312})); // 3rd curve
ctrl_pts.push_back (point ({103, 278}));
ctrl_pts.push_back (point ({79, 252}));
ctrl_pts.push_back (point ({53, 235}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({53, 235})); // 4th curve
ctrl_pts.push_back (point ({46, 230}));
ctrl_pts.push_back (point ({42, 228}));
ctrl_pts.push_back (point ({37, 231}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({37, 231})); // 5th curve
ctrl_pts.push_back (point ({37, 223}));
ctrl_pts.push_back (point ({39, 236}));
ctrl_pts.push_back (point ({43, 243}));
ctrl_pts.push_back (point ({45, 246}));
ctrl_pts.push_back (point ({62, 266}));
ctrl_pts.push_back (point ({76, 288}));
ctrl_pts.push_back (point ({89, 313}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({89, 313})); // 6th curve
ctrl_pts.push_back (point ({102, 339}));
ctrl_pts.push_back (point ({115, 369}));
ctrl_pts.push_back (point ({127, 404}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({127, 404})); // 7th curve
ctrl_pts.push_back (point ({117, 400}));
ctrl_pts.push_back (point ({107, 395}));
ctrl_pts.push_back (point ({97, 392}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({97, 392})); // 8th curve
ctrl_pts.push_back (point ({86, 388}));
ctrl_pts.push_back (point ({81, 386}));
ctrl_pts.push_back (point ({74, 386}));
ctrl_pts.push_back (point ({67, 388}));
ctrl_pts.push_back (point ({57, 394}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({57, 394})); // 9th curve
ctrl_pts.push_back (point ({46, 399}));
ctrl_pts.push_back (point ({41, 403}));
ctrl_pts.push_back (point ({42, 406}));
ctrl_pts.push_back (point ({43, 407}));
ctrl_pts.push_back (point ({44, 407}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({44, 407})); // 10th curve
ctrl_pts.push_back (point ({46, 408}));
ctrl_pts.push_back (point ({50, 409}));
ctrl_pts.push_back (point ({68, 409}));
ctrl_pts.push_back (point ({81, 410}));
ctrl_pts.push_back (point ({94, 413}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({94, 413})); // 11th curve
ctrl_pts.push_back (point ({106, 416}));
ctrl_pts.push_back (point ({115, 419}));
ctrl_pts.push_back (point ({123, 425}));
ctrl_pts.push_back (point ({127, 428}));
ctrl_pts.push_back (point ({135, 439}));
ctrl_pts.push_back (point ({139, 441}));
ctrl_pts.push_back (point ({143, 441}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({143, 441})); // 12th curve
ctrl_pts.push_back (point ({148, 441}));
ctrl_pts.push_back (point ({156, 438}));
ctrl_pts.push_back (point ({169, 429}));
ctrl_pts.push_back (point ({175, 423}));
ctrl_pts.push_back (point ({183, 416}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();


@ @<Build-up 2nd, 4th, and 5th brush@>=
ctrl_pts.push_back (point ({545, 226})); // 13th curve
ctrl_pts.push_back (point ({547, 225}));
ctrl_pts.push_back (point ({550, 223}));
ctrl_pts.push_back (point ({554, 217}));
ctrl_pts.push_back (point ({555, 215}));
ctrl_pts.push_back (point ({555, 211}));
ctrl_pts.push_back (point ({547, 208}));
ctrl_pts.push_back (point ({532, 206}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({532, 206})); // 14th curve
ctrl_pts.push_back (point ({517, 204}));
ctrl_pts.push_back (point ({501, 203}));
ctrl_pts.push_back (point ({482, 203}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({482, 203})); // 15th curve
ctrl_pts.push_back (point ({460, 203}));
ctrl_pts.push_back (point ({430, 217}));
ctrl_pts.push_back (point ({392, 247}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({392, 247})); // 16th curve
ctrl_pts.push_back (point ({329, 299}));
ctrl_pts.push_back (point ({265, 366}));
ctrl_pts.push_back (point ({230, 410}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({230, 410})); // 18th curve
ctrl_pts.push_back (point ({230, 349}));
ctrl_pts.push_back (point ({230, 288}));
ctrl_pts.push_back (point ({230, 227}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({230, 227})); // 19th curve
ctrl_pts.push_back (point ({230, 215}));
ctrl_pts.push_back (point ({228, 204}));
ctrl_pts.push_back (point ({224, 193}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({224, 193})); // 20th curve
ctrl_pts.push_back (point ({219, 178}));
ctrl_pts.push_back (point ({211, 171}));
ctrl_pts.push_back (point ({196, 171}));
ctrl_pts.push_back (point ({190, 176}));
ctrl_pts.push_back (point ({174, 201}));
ctrl_pts.push_back (point ({169, 208}));
ctrl_pts.push_back (point ({169, 209}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({169, 209})); // 21st curve
ctrl_pts.push_back (point ({160, 217}));
ctrl_pts.push_back (point ({152, 226}));
ctrl_pts.push_back (point ({135, 243}));
ctrl_pts.push_back (point ({131, 248}));
ctrl_pts.push_back (point ({131, 250}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({131, 250})); // 22nd curve
ctrl_pts.push_back (point ({133, 252}));
ctrl_pts.push_back (point ({135, 253}));
ctrl_pts.push_back (point ({140, 253}));
ctrl_pts.push_back (point ({149, 251}));
ctrl_pts.push_back (point ({163, 246}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({163, 246})); // 23rd curve
ctrl_pts.push_back (point ({170, 243}));
ctrl_pts.push_back (point ({175, 242}));
ctrl_pts.push_back (point ({188, 242}));
ctrl_pts.push_back (point ({192, 247}));
ctrl_pts.push_back (point ({192, 258}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({192, 258})); // 24th curve
ctrl_pts.push_back (point ({192, 342}));
ctrl_pts.push_back (point ({192, 426}));
ctrl_pts.push_back (point ({192, 509}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({192, 509})); // 25th curve
ctrl_pts.push_back (point ({192, 515}));
ctrl_pts.push_back (point ({192, 519}));
ctrl_pts.push_back (point ({189, 525}));
ctrl_pts.push_back (point ({186, 526}));
ctrl_pts.push_back (point ({175, 526}));
ctrl_pts.push_back (point ({166, 523}));
ctrl_pts.push_back (point ({154, 517}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({154, 517})); // 26th curve
ctrl_pts.push_back (point ({143, 511}));
ctrl_pts.push_back (point ({134, 508}));
ctrl_pts.push_back (point ({124, 508}));
ctrl_pts.push_back (point ({117, 510}));
ctrl_pts.push_back (point ({107, 512}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({107, 512})); // 27th curve
ctrl_pts.push_back (point ({98, 515}));
ctrl_pts.push_back (point ({93, 518}));
ctrl_pts.push_back (point ({93, 520}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({93, 520})); // 28th curve
ctrl_pts.push_back (point ({93, 522}));
ctrl_pts.push_back (point ({95, 523}));
ctrl_pts.push_back (point ({103, 526}));
ctrl_pts.push_back (point ({107, 527}));
ctrl_pts.push_back (point ({110, 527}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({110, 527})); // 29th curve
ctrl_pts.push_back (point ({122, 530}));
ctrl_pts.push_back (point ({134, 534}));
ctrl_pts.push_back (point ({154, 541}));
ctrl_pts.push_back (point ({165, 545}));
ctrl_pts.push_back (point ({180, 552}));
ctrl_pts.push_back (point ({183, 555}));
ctrl_pts.push_back (point ({188, 560}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({188, 560})); // 30th curve
ctrl_pts.push_back (point ({192, 566}));
ctrl_pts.push_back (point ({196, 568}));
ctrl_pts.push_back (point ({204, 568}));
ctrl_pts.push_back (point ({213, 562}));
ctrl_pts.push_back (point ({241, 537}));
ctrl_pts.push_back (point ({248, 529}));
ctrl_pts.push_back (point ({248, 524}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({248, 524})); // 31st curve
ctrl_pts.push_back (point ({248, 521}));
ctrl_pts.push_back (point ({246, 517}));
ctrl_pts.push_back (point ({238, 506}));
ctrl_pts.push_back (point ({235, 502}));
ctrl_pts.push_back (point ({235, 501}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({235, 501})); // 32nd curve
ctrl_pts.push_back (point ({231, 481}));
ctrl_pts.push_back (point ({230, 457}));
ctrl_pts.push_back (point ({230, 437}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({230, 437})); // 33rd curve
ctrl_pts.push_back (point ({232.5, 433}));
ctrl_pts.push_back (point ({235, 429}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({235, 429})); // 34th curve
ctrl_pts.push_back (point ({256, 452}));
ctrl_pts.push_back (point ({280, 486}));
ctrl_pts.push_back (point ({295, 515}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({295, 515})); // 35th curve
ctrl_pts.push_back (point ({295, 519}));
ctrl_pts.push_back (point ({296, 523}));
ctrl_pts.push_back (point ({298, 530}));
ctrl_pts.push_back (point ({301, 531}));
ctrl_pts.push_back (point ({312, 531}));
ctrl_pts.push_back (point ({321, 528}));
ctrl_pts.push_back (point ({334, 520}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({334, 520})); // 36th curve
ctrl_pts.push_back (point ({347, 512}));
ctrl_pts.push_back (point ({354, 505}));
ctrl_pts.push_back (point ({354, 499}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({354, 499})); // 37th curve
ctrl_pts.push_back (point ({354, 496}));
ctrl_pts.push_back (point ({351, 493}));
ctrl_pts.push_back (point ({340, 487}));
ctrl_pts.push_back (point ({335, 484}));
ctrl_pts.push_back (point ({330, 482}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({330, 482})); // 38th curve
ctrl_pts.push_back (point ({304, 461}));
ctrl_pts.push_back (point ({274, 437}));
ctrl_pts.push_back (point ({243, 416}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({243, 416})); // 39th curve
ctrl_pts.push_back (point ({283, 370}));
ctrl_pts.push_back (point ({342, 325}));
ctrl_pts.push_back (point ({413, 283}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({413, 283})); // 40th curve
ctrl_pts.push_back (point ({456, 262}));
ctrl_pts.push_back (point ({523, 235}));
ctrl_pts.push_back (point ({545, 226}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();


@ @<Build-up 1st brush@>=
ctrl_pts.push_back (point ({245, 638})); // 41st curve
ctrl_pts.push_back (point ({249, 633}));
ctrl_pts.push_back (point ({251, 625}));
ctrl_pts.push_back (point ({251, 614}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({251, 614})); // 42nd curve
ctrl_pts.push_back (point ({251, 603}));
ctrl_pts.push_back (point ({247, 597}));
ctrl_pts.push_back (point ({240, 597}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({240, 597})); // 43rd curve
ctrl_pts.push_back (point ({219, 608}));
ctrl_pts.push_back (point ({164, 651}));
ctrl_pts.push_back (point ({151, 666}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({151, 666})); // 44th curve
ctrl_pts.push_back (point ({152, 667}));
ctrl_pts.push_back (point ({153, 667}));
ctrl_pts.push_back (point ({155, 668}));
ctrl_pts.push_back (point ({156, 668}));
ctrl_pts.push_back (point ({157, 668}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({157, 668})); // 45th curve
ctrl_pts.push_back (point ({189, 668}));
ctrl_pts.push_back (point ({224, 655}));
ctrl_pts.push_back (point ({245, 638}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();


@ @<Build-up 6th, 7th, 8th, and 9th brush (outer part)@>=
ctrl_pts.push_back (point ({535, 598})); // 46th curve
ctrl_pts.push_back (point ({537, 596}));
ctrl_pts.push_back (point ({539, 593}));
ctrl_pts.push_back (point ({539, 585}));
ctrl_pts.push_back (point ({537, 581}));
ctrl_pts.push_back (point ({529, 568}));
ctrl_pts.push_back (point ({526, 564}));
ctrl_pts.push_back (point ({526, 564}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({526, 564})); // 47th curve
ctrl_pts.push_back (point ({526, 507}));
ctrl_pts.push_back (point ({526, 451}));
ctrl_pts.push_back (point ({526, 394}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({526, 394})); // 48th curve
ctrl_pts.push_back (point ({527, 379}));
ctrl_pts.push_back (point ({528, 364}));
ctrl_pts.push_back (point ({529, 348}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({529, 348})); // 49th curve
ctrl_pts.push_back (point ({528, 331}));
ctrl_pts.push_back (point ({521, 312}));
ctrl_pts.push_back (point ({510, 307}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({510, 307})); // 50th curve
ctrl_pts.push_back (point ({502, 307}));
ctrl_pts.push_back (point ({496, 313}));
ctrl_pts.push_back (point ({489, 334}));
ctrl_pts.push_back (point ({488, 344}));
ctrl_pts.push_back (point ({487, 357}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({487, 357})); // 51st curve
ctrl_pts.push_back (point ({459, 356}));
ctrl_pts.push_back (point ({418, 352}));
ctrl_pts.push_back (point ({408, 347}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({408, 347})); // 52nd curve
ctrl_pts.push_back (point ({408, 335}));
ctrl_pts.push_back (point ({404, 330}));
ctrl_pts.push_back (point ({396, 330}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({396, 330})); // 53rd curve
ctrl_pts.push_back (point ({382, 336}));
ctrl_pts.push_back (point ({369, 360}));
ctrl_pts.push_back (point ({366, 377}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({366, 377})); // 54th curve
ctrl_pts.push_back (point ({367, 390}));
ctrl_pts.push_back (point ({371, 421}));
ctrl_pts.push_back (point ({372, 440}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({372, 440})); // 55th curve
ctrl_pts.push_back (point ({372, 435}));
ctrl_pts.push_back (point ({372, 439}));
ctrl_pts.push_back (point ({372, 554}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({372, 554})); // 56th curve
ctrl_pts.push_back (point ({372, 564}));
ctrl_pts.push_back (point ({360, 594}));
ctrl_pts.push_back (point ({355, 603}));
ctrl_pts.push_back (point ({353, 617}));
ctrl_pts.push_back (point ({358, 617}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({358, 617})); // 57th curve
ctrl_pts.push_back (point ({365, 617}));
ctrl_pts.push_back (point ({372, 615}));
ctrl_pts.push_back (point ({385, 607}));
ctrl_pts.push_back (point ({392, 603}));
ctrl_pts.push_back (point ({398, 600}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({398, 600})); // 58th curve
ctrl_pts.push_back (point ({417, 603}));
ctrl_pts.push_back (point ({443, 609}));
ctrl_pts.push_back (point ({463, 613}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({463, 613})); // 59th curve
ctrl_pts.push_back (point ({470, 618}));
ctrl_pts.push_back (point ({480, 629}));
ctrl_pts.push_back (point ({487, 632}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({487, 632})); // 60th curve
ctrl_pts.push_back (point ({499, 627}));
ctrl_pts.push_back (point ({520, 611}));
ctrl_pts.push_back (point ({535, 598}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();


@ @<Build-up 6th, 7th, 8th, and 9th brush (inner part)@>=
ctrl_pts.push_back (point ({487, 378})); // 61st curve
ctrl_pts.push_back (point ({487, 444}));
ctrl_pts.push_back (point ({487, 510}));
ctrl_pts.push_back (point ({487, 576}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({487, 576})); // 62nd curve
ctrl_pts.push_back (point ({487, 583}));
ctrl_pts.push_back (point ({486, 587}));
ctrl_pts.push_back (point ({484, 594}));
ctrl_pts.push_back (point ({480, 597}));
ctrl_pts.push_back (point ({473, 597}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({473, 597})); // 63rd curve
ctrl_pts.push_back (point ({454, 596}));
ctrl_pts.push_back (point ({428, 590}));
ctrl_pts.push_back (point ({408, 584}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({408, 584})); // 64th curve
ctrl_pts.push_back (point ({408, 553}));
ctrl_pts.push_back (point ({408, 523}));
ctrl_pts.push_back (point ({408, 492}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({408, 492})); // 65th curve
ctrl_pts.push_back (point ({420, 494}));
ctrl_pts.push_back (point ({447, 504}));
ctrl_pts.push_back (point ({464, 507}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({464, 507})); // 66th curve
ctrl_pts.push_back (point ({475, 507}));
ctrl_pts.push_back (point ({481, 504}));
ctrl_pts.push_back (point ({481, 489}));
ctrl_pts.push_back (point ({471, 482}));
ctrl_pts.push_back (point ({450, 478}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({450, 478})); // 67th curve
ctrl_pts.push_back (point ({436, 475}));
ctrl_pts.push_back (point ({422, 473}));
ctrl_pts.push_back (point ({408, 473}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({408, 473})); // 68th curve
ctrl_pts.push_back (point ({408, 438}));
ctrl_pts.push_back (point ({408, 403}));
ctrl_pts.push_back (point ({408, 368}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();

ctrl_pts.push_back (point ({408, 368})); // 69th curve
ctrl_pts.push_back (point ({432, 372}));
ctrl_pts.push_back (point ({462, 376}));
ctrl_pts.push_back (point ({487, 378}));

curves.push_back (bezier (ctrl_pts));
ctrl_pts.clear ();


@ 예제 실행 결과.  첫 번째 그림은 traditional chinese 문자 중 하나를 골라
외곽선을 여러개의 \bezier\ 곡선으로 근사화한 것이다.
검은색 점은 각 곡선의 끝점을 나타내며, 흰 점은 중간의 컨트롤 포인트를,
가느다란 직선은 컨트롤 폴리곤을 나타낸다.  곡선의 차수는
3차부터 7차까지 다양하게 사용했다.
\medskip
\noindent\centerline{%
\includegraphics[width=.9\pagewidth]{figs/untouched.pdf}}

@ 아래 그림은 모든 곡선의 차수를 가장 차수가 높은 \bezier\ 곡선 조각의
차수에 맞춰 올린 것이다.
곡선의 차수를 올리더라도 곡선의 형상은 변화하지 않는다.
\medskip
\noindent\centerline{%
\includegraphics[width=.9\pagewidth]{figs/degree_elevated.pdf}}

@ 아래 그림은 다시 모든 곡선의 차수를 3차로 낮춘 것이다.
곡선의 형상 변화를 최소화하는 컨트롤 포인트를 구했지만 완벽하게 동일한
모양을 얻은 것은 아니다.  특히 곡선의 컨트롤 폴리곤이
매우 들쭉 날쭉한 것에 유의해야 한다.  만약 곡선을 시간에 따라 애니메이션으로
그린다면 불규칙하게 배치된 컨트롤 포인트들이 문제를 일으킬 것이다.
따라서 \bezier\ 곡선의 차수를 낮추는 알고리즘을
로봇이나 기구의 동작 궤적에 적용할 때에는 각별한 주의가 필요하다.
\medskip
\noindent\centerline{%
\includegraphics[width=.9\pagewidth]{figs/degree_reduced.pdf}}
\medskip
