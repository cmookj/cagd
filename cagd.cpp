/*3:*/
#line 239 "cagd.w"

#include "cagd.h"

using namespace cagd;

/*4:*/
#line 258 "cagd.w"

psf cagd::create_postscript_file(string file_name){
psf ps_file;
ps_file.open(file_name.c_str(),ios_base::out);
if(!ps_file){
exit(-1);
}
ps_file<<"%!PS-Adobe-3.0"<<endl
<<"/Helvetica findfont 10 scalefont setfont"<<endl;
return ps_file;
}

void cagd::close_postscript_file(psf&ps_file,bool with_new_page){
if(with_new_page==true){
ps_file<<"showpage"<<endl;
}
ps_file.close();
}

/*:4*//*7:*/
#line 58 "math.w"

int cagd::invert_tridiagonal(
const vector<double> &alpha,
const vector<double> &beta,
const vector<double> &gamma,
vector<double> &inverse
){

size_t n= beta.size();

vector<double> theta(n+1,0.);
theta[0]= 1.;
theta[1]= beta[0];

for(size_t i= 2;i!=n+1;i++){
theta[i]= beta[i-1]*theta[i-1]-gamma[i-2]*alpha[i-2]*theta[i-2];
}

if(theta[n]==0.)return-1;

vector<double> phi(n+1,0.);
phi[n]= 1.;
phi[n-1]= beta[n-1];

for(size_t i= n-1;i!=0;i--){
phi[i-1]= beta[i-1]*phi[i]-gamma[i-1]*alpha[i-1]*phi[i+1];
}

for(size_t i= 0;i!=n;i++){
for(size_t j= 0;j!=n;j++){
double elem= 0.;
if(i<j){
double prod= 1.;
for(size_t k= i;k!=j;k++){
prod*= gamma[k];
}
elem= pow(-1,i+j)*prod*theta[i]*phi[j+1]/theta[n];
}else if(i==j){
elem= theta[i]*phi[j+1]/theta[n];
}else{
double prod= 1.;
for(size_t k= j;k!=i;k++){
prod*= alpha[k];
}
elem= pow(-1,i+j)*prod*theta[j]*phi[i+1]/theta[n];
}
inverse[i*n+j]= elem;
}
}

return 0;
}

/*:7*//*10:*/
#line 161 "math.w"

vector<double> cagd::multiply(
const vector<double> &mat,
const vector<double> &vec
){
size_t n= vec.size();
vector<double> mv(n,0.);
for(size_t i= 0;i!=n;i++){
for(size_t k= 0;k!=n;k++){
mv[i]+= mat[i*n+k]*vec[k];
}
}
return mv;
}

/*:10*//*12:*/
#line 191 "math.w"

int cagd::solve_tridiagonal_system(
const vector<double> &l,
const vector<double> &d,
const vector<double> &u,
const vector<point> &b,
vector<point> &x
){

size_t n= d.size();
vector<double> Ainv(n*n,0.);

if(cagd::invert_tridiagonal(l,d,u,Ainv)!=0)return-1;

for(size_t i= 1;i!=b[0].dim()+1;i++){
vector<double> r(n,0.);
for(size_t k= 0;k!=n;k++){
r[k]= b[k](i);
}

vector<double> xi= cagd::multiply(Ainv,r);
for(size_t k= 0;k!=n;k++){
x[k](i)= xi[k];
}
}

return 0;
}

/*:12*//*14:*/
#line 283 "math.w"

int cagd::solve_cyclic_tridiagonal_system(
const vector<double> &alpha,
const vector<double> &beta,
const vector<double> &gamma,
const vector<point> &b,
vector<point> &x
){

size_t n= beta.size();
vector<double> Einv((n-1)*(n-1),0.);
/*15:*/
#line 315 "math.w"

vector<double> l= vector<double> (n-2,0.);
vector<double> d= vector<double> (n-1,0.);
vector<double> u= vector<double> (n-2,0.);
for(size_t j= 0;j!=n-2;j++){
l[j]= alpha[j+1];
d[j]= beta[j];
u[j]= gamma[j];
}
d[n-2]= beta[n-2];

if(invert_tridiagonal(l,d,u,Einv)!=0)return-1;


/*:15*/
#line 294 "math.w"
;

size_t dim= b[0].dim();
vector<vector<double> > B(dim,vector<double> (n,0.));
for(size_t i= 0;i!=dim;i++){
for(size_t j= 0;j!=n;j++){
B[i][j]= b[j](i+1);
}

/*16:*/
#line 340 "math.w"

double x_n_den= beta[n-1]
-gamma[n-1]*(alpha[0]*Einv[0]+gamma[n-2]*Einv[n-2])
-alpha[n-1]*(alpha[0]*Einv[(n-2)*(n-1)]+gamma[n-2]*Einv[(n-1)*(n-1)-1]);

double E1b= 0.;
double Enb= 0.;
for(size_t j= 0;j!=n-1;j++){
E1b+= Einv[j]*B[i][j];
Enb+= Einv[(n-2)*(n-1)+j]*B[i][j];
}
double x_n_num= B[i][n-1]-gamma[n-1]*E1b-alpha[n-1]*Enb;
double x_n= x_n_num/x_n_den;


/*:16*/
#line 303 "math.w"
;
/*17:*/
#line 355 "math.w"

vector<double> bhat_fxn(n-1,0.);
for(size_t j= 0;j!=n-1;j++){
bhat_fxn[j]= B[i][j];
}
bhat_fxn[0]-= alpha[0]*x_n;
bhat_fxn[n-2]-= gamma[n-2]*x_n;

vector<double> xhat= multiply(Einv,bhat_fxn);


/*:17*/
#line 304 "math.w"
;

for(size_t j= 0;j!=n-1;j++){
x[j](i+1)= xhat[j];
}
x[n-1](i+1)= x_n;
}

return 0;
}

/*:14*//*67:*/
#line 235 "bezier.w"

double
cagd::signed_area(const point p1,const point p2,const point p3){
double area;
area= ((p2(1)-p1(1))*(p3(2)-p1(2))-(p2(2)-p1(2))*(p3(1)-p1(1)))/2.0;
return area;
}

/*:67*//*77:*/
#line 376 "bezier.w"

unsigned long cagd::factorial(unsigned long n){
if(n<=0){
return 1UL;
}else{
return n*factorial(n-1);
}
}

/*:77*/
#line 244 "cagd.w"

/*22:*/
#line 29 "point.w"

/*23:*/
#line 43 "point.w"

size_t point::dimension()const{
return(this->_elem).size();
}

size_t point::dim()const{
return(this->_elem).size();
}

/*:23*/
#line 30 "point.w"

/*25:*/
#line 78 "point.w"

point::point(const point&src)
:_elem(src._elem)
{}

point::point(initializer_list<double> v)
:_elem(vector<double> (v.begin(),v.end()))
{}

point::point(const double v1,const double v2,const double v3)
:_elem(vector<double> (3))
{
_elem[0]= v1;
_elem[1]= v2;
_elem[2]= v3;
}

point::point(const size_t n)
:_elem(vector<double> (n,0.))
{}

point::point(const size_t n,const double*v)
:_elem(vector<double> (n,0.))
{
for(size_t i= 0;i!=n;i++){
_elem[i]= v[i];
}
}

point::~point(){
}

/*:25*/
#line 31 "point.w"

/*27:*/
#line 129 "point.w"

void point::operator= (const point&src){
_elem= src._elem;
}

point&point::operator*= (const double s){
size_t sz= this->dim();
for(size_t i= 0;i!=sz;i++){
(this->_elem[i])*= s;
}
return*this;
}

point&point::operator/= (const double s){
if(s==0.)return*this;
size_t sz= this->dim();
for(size_t i= 0;i!=sz;i++){
(this->_elem[i])/= s;
}
return*this;
}

point&point::operator+= (const point&pt){
size_t sz_min= min(this->dim(),pt.dim());
for(size_t i= 0;i!=sz_min;i++){
(this->_elem[i])+= pt._elem[i];
}
return*this;
}

point&point::operator-= (const point&pt){
size_t sz_min= min(this->dim(),pt.dim());
for(size_t i= 0;i!=sz_min;i++){
(this->_elem[i])-= pt._elem[i];
}
return*this;
}

/*:27*//*31:*/
#line 259 "point.w"

const double&point::operator()(const size_t&i)const{
size_t size= _elem.size();
if((i<1)||(size<i)){
return _elem[0];
}else{
return _elem[i-1];
}
}

double&point::operator()(const size_t&i){
return const_cast<double&> (static_cast<const point&> (*this)(i));
}

/*:31*/
#line 32 "point.w"

/*33:*/
#line 284 "point.w"

double
point::dist(const point&pt)const{
if(this->dim()!=pt.dim())return-1.;

size_t n= this->dim();
double sum= 0.0;
for(size_t i= 0;i!=n;i++){
sum+= (_elem[i]-pt._elem[i])*(_elem[i]-pt._elem[i]);
}
return std::sqrt(sum);
}

/*:33*//*35:*/
#line 305 "point.w"

string point::description()const{
stringstream buffer;
buffer<<"( ";
for(size_t i= 0;i!=dim()-1;i++){
buffer<<_elem[i]<<", ";
}
buffer<<_elem[dim()-1]<<" )"<<endl;

return buffer.str();
}

/*:35*/
#line 33 "point.w"

/*29:*/
#line 184 "point.w"

point cagd::operator*(double s,point pt){
return pt*= s;
}

point cagd::operator*(point pt,double s){
return pt*= s;
}

point cagd::operator/(point pt,double s){
return pt/= s;
}

point cagd::operator+(point pt1,point pt2){
return pt1+= pt2;
}

point cagd::operator-(point pt1,point pt2){
return pt1-= pt2;
}

point cagd::operator-(point pt1){
size_t sz= pt1.dim();
cagd::point negated(sz);
for(size_t i= 0;i!=sz;i++){
negated._elem[i]= -pt1._elem[i];
}
return negated;
}

/*:29*//*37:*/
#line 325 "point.w"

double cagd::dist(const point&pt1,const point&pt2){
return pt1.dist(pt2);
}

/*:37*/
#line 34 "point.w"





/*:22*/
#line 245 "cagd.w"

/*41:*/
#line 33 "curve.w"

/*42:*/
#line 47 "curve.w"

unsigned long
curve::dimension()const{
if(_ctrl_pts.size()> 0){
return _ctrl_pts.begin()->dim();
}else{
return 0;
}
}

unsigned long
curve::dim()const{
return dimension();
}

/*:42*/
#line 34 "curve.w"

/*44:*/
#line 74 "curve.w"

point curve::ctrl_pts(const size_t&i)const{
size_t size= _ctrl_pts.size();
if((i<1)||(size<i)){
return _ctrl_pts[0];
}else{
return _ctrl_pts[i];
}
}

size_t curve::ctrl_pts_size()const{
return _ctrl_pts.size();
}

/*:44*/
#line 35 "curve.w"

/*48:*/
#line 133 "curve.w"

curve::curve(){
}

curve::curve(const vector<point> &pts)
:_ctrl_pts(pts)
{
}

curve::curve(const list<point> &pts)
:_ctrl_pts(vector<point> (pts.size(),pts.begin()->dim()))
{
list<point> ::const_iterator pt(pts.begin());
for(size_t i= 0;i!=pts.size();i++){
_ctrl_pts[i]= *pt;
pt++;
}
}

curve::curve(const curve&src)
:_ctrl_pts(src._ctrl_pts)
{
}

curve::~curve(){
}

/*:48*/
#line 36 "curve.w"

/*50:*/
#line 173 "curve.w"

string curve::description()const{
stringstream buffer;
buffer<<"----------------------------"<<endl;
buffer<<"    Description of Curve    "<<endl;
buffer<<"----------------------------"<<endl;
buffer<<"  Dimension of curve: "<<dim()<<endl;
buffer<<"  Control points: "<<endl;
for(size_t i= 0;i!=_ctrl_pts.size();i++){
buffer<<"    "<<_ctrl_pts[i].description();
}
return buffer.str();
}

/*:50*/
#line 37 "curve.w"

/*52:*/
#line 196 "curve.w"

curve&curve::operator= (const curve&crv){
_ctrl_pts= crv._ctrl_pts;

return*this;
}

/*:52*/
#line 38 "curve.w"





/*:41*/
#line 246 "cagd.w"

/*56:*/
#line 44 "bezier.w"

/*57:*/
#line 60 "bezier.w"

unsigned long
bezier::degree()const{
return _degree;
}

/*:57*/
#line 45 "bezier.w"

/*59:*/
#line 77 "bezier.w"

bezier::bezier(){}

bezier::bezier(const bezier&src){
_degree= src._degree;
_ctrl_pts= src._ctrl_pts;
}

bezier::bezier(vector<point> points){
_degree= points.size()-1;
_ctrl_pts= points;
}

bezier::bezier(list<point> points){
_degree= points.size()-1;
_ctrl_pts= vector<point> (points.size(),*points.begin());
list<point> ::const_iterator iter= points.begin();
for(size_t i= 0;iter!=points.end();iter++,i++){
_ctrl_pts[i]= *iter;
}
}

bezier::~bezier(){
}

/*:59*/
#line 46 "bezier.w"

/*61:*/
#line 115 "bezier.w"

bezier&bezier::operator= (const bezier&src){
_degree= src._degree;
curve::operator= (src);

return*this;
}

/*:61*/
#line 47 "bezier.w"

/*63:*/
#line 133 "bezier.w"

point
bezier::evaluate(const double t)const{
vector<point> coeff;
for(size_t i= 0;i!=_ctrl_pts.size();++i){
coeff.push_back(_ctrl_pts[i]);
}
double t1= 1.0-t;
for(size_t r= 1;r!=_degree+1;r++){
for(size_t i= 0;i!=_degree-r+1;i++){
coeff[i]= t1*coeff[i]+t*coeff[i+1];
}
}
return coeff[0];
}

point
bezier::derivative(const double t)const{
vector<point> coeff;
for(size_t i= 0;i!=_ctrl_pts.size()-1;++i){
coeff.push_back(_degree*(_ctrl_pts[i+1]-_ctrl_pts[i]));
}
double t1= 1.0-t;
for(size_t r= 1;r!=_degree;r++){
for(size_t i= 0;i!=_degree-r;i++){
coeff[i]= t1*coeff[i]+t*coeff[i+1];
}
}
return coeff[0];
}

/*:63*//*65:*/
#line 185 "bezier.w"

double
bezier::curvature_at_zero()const{
double dist= cagd::dist(_ctrl_pts[0],_ctrl_pts[1]);
return 2.0*(_degree-1)*
cagd::signed_area(_ctrl_pts[0],_ctrl_pts[1],_ctrl_pts[2])
/(_degree*dist*dist*dist);
}

vector<point> 
bezier::signed_curvature(const unsigned density,
const double b,
const double e
)const{



double delta= (e-b)/density;
unsigned half= density/2;
vector<point> kappa;

for(size_t i= 0;i<=density;i++){
double t= b+i*delta;
bezier left(*this);
bezier right(*this);
if(i<=half){
subdivision(t,left,right);
double h= right.curvature_at_zero();
kappa.push_back(point({t,h}));
}else{
subdivision(t,left,right);
double h= left.curvature_at_zero();
kappa.push_back(point({t,std::fabs(-h)}));
}
}
return kappa;
}

/*:65*/
#line 48 "bezier.w"

/*69:*/
#line 269 "bezier.w"

void
bezier::subdivision(double t,bezier&left,bezier&right)const{
double t1= 1.0-t;
vector<point> points;

/*70:*/
#line 285 "bezier.w"

right._ctrl_pts.clear();
right._degree= _degree;
for(size_t i= 0;i!=_ctrl_pts.size();i++){
points.push_back(_ctrl_pts[i]);
}
/*71:*/
#line 296 "bezier.w"

for(size_t r= 1;r!=_degree+1;r++){
for(size_t i= 0;i!=_degree-r+1;i++){
points[i]= t1*points[i]+t*points[i+1];
}
}

/*:71*/
#line 291 "bezier.w"
;
for(size_t i= 0;i!=(_degree+1);i++){
right._ctrl_pts.push_back(points[i]);
}

/*:70*/
#line 275 "bezier.w"
;
/*72:*/
#line 309 "bezier.w"

t= 1.0-t;
t1= 1.0-t1;
points.clear();
left._ctrl_pts.clear();
left._degree= _degree;
unsigned long index= _degree;
for(size_t i= 0;i!=_ctrl_pts.size();i++){
points[index--]= _ctrl_pts[i];
}
/*73:*/
#line 324 "bezier.w"

for(size_t r= 1;r!=_degree+1;r++){
for(size_t i= 0;i!=_degree-r+1;i++){
points[i]= t1*points[i]+t*points[i+1];
}
}

/*:73*/
#line 319 "bezier.w"
;
for(size_t i= 0;i!=_degree+1;i++){
left._ctrl_pts.push_back(points[i]);
}

/*:72*/
#line 276 "bezier.w"
;
}

/*:69*/
#line 49 "bezier.w"

/*75:*/
#line 345 "bezier.w"

void bezier::elevate_degree(unsigned long dgr){
if(_degree> dgr){
throw std::runtime_error{"degree elevation failure"};
return;
}
if(_degree==dgr){
return;
}
_degree++;
point backup_point= _ctrl_pts[0];
unsigned long counter= 1;
for(size_t i= 1;i!=_ctrl_pts.size();++i){
point tmp_point= backup_point;
backup_point= _ctrl_pts[i];
double ratio= double(counter)/double(_degree);
_ctrl_pts[i]= ratio*tmp_point+(1.0-ratio)*backup_point;
counter++;
}
_ctrl_pts.push_back(backup_point);
return elevate_degree(dgr);
}

/*:75*//*79:*/
#line 423 "bezier.w"

void bezier::reduce_degree(const unsigned long dgr){
if(_degree<dgr){
throw std::runtime_error{"degree reduction failure"};
return;
}
if(_degree==dgr){
return;
}

vector<point> l2r;
l2r.push_back(_ctrl_pts[0]);
unsigned long counter= 1;
for(size_t i= 1;i!=_ctrl_pts.size()-1;++i){
l2r.push_back((double(_degree)*_ctrl_pts[i]-double(counter)*(l2r.back()))
/double(_degree-counter));
counter++;
}

vector<point> r2l_reversed;
r2l_reversed.push_back(_ctrl_pts.back());
counter= _degree;
for(size_t i= _ctrl_pts.size()-2;i!=0;--i){
r2l_reversed.push_back((double(_degree)*(_ctrl_pts[i])
-double(_degree-counter)*r2l_reversed.front())/double(counter));
counter--;
}
vector<point> r2l;
size_t r2l_reversed_size= r2l_reversed.size();
for(size_t i= 0;i!=r2l_reversed_size;i++){
r2l.push_back(r2l_reversed.back());
r2l_reversed.pop_back();
}

point backup1= _ctrl_pts[0];
point backup2= _ctrl_pts.back();
_ctrl_pts.clear();
_ctrl_pts.push_back(backup1);

for(size_t i= 1;i<=_degree-2;++i){
unsigned long combi= 0;
for(size_t j= 0;j<=i;++j){
combi+= cagd::factorial(2*_degree)/
(cagd::factorial(2*j)*cagd::factorial(2*(_degree-j)));
}
double lambda= double(combi)/std::pow(2.,2*_degree-1);
_ctrl_pts.push_back((1.0-lambda)*l2r[i]+lambda*r2l[i]);
}

_ctrl_pts.push_back(backup2);
_degree--;
return reduce_degree(dgr);
}

/*:79*/
#line 50 "bezier.w"

/*81:*/
#line 488 "bezier.w"

void
bezier::write_curve_in_postscript(
psf&ps_file,
unsigned step,
float line_width,
int x,int y,
float magnification
)const{

ios_base::fmtflags previous_options= ps_file.flags();
ps_file.precision(4);
ps_file.setf(ios_base::fixed,ios_base::floatfield);
ps_file<<"newpath"<<endl
<<"[] 0 setdash "<<line_width<<" setlinewidth"<<endl;
point pt= magnification*evaluate(0);
ps_file<<pt(x)<<"\t"<<pt(y)<<"\t"
<<"moveto"<<endl;
for(size_t i= 1;i<=step;i++){
double t= double(i)/double(step);
pt= magnification*evaluate(t);
ps_file<<pt(x)<<"\t"<<pt(y)<<"\t"
<<"lineto"<<endl;
}
ps_file<<"stroke"<<endl;
ps_file.flags(previous_options);
}

void
bezier::write_control_polygon_in_postscript(
psf&ps_file,
float line_width,
int x,int y,
float magnification
)const{

ios_base::fmtflags previous_options= ps_file.flags();
ps_file.precision(4);
ps_file.setf(ios_base::fixed,ios_base::floatfield);
ps_file<<"newpath"<<endl;
ps_file<<"[] 0 setdash "<<.5*line_width<<" setlinewidth"<<endl;
point pt= magnification*_ctrl_pts[0];
ps_file<<pt(x)<<"\t"<<pt(y)<<"\t"
<<"moveto"<<endl;
for(size_t i= 1;i!=_ctrl_pts.size();++i){
pt= magnification*_ctrl_pts[i];
ps_file<<pt(x)<<"\t"<<pt(y)<<"\t"
<<"lineto"<<endl;
}
ps_file<<"stroke"<<endl;
ps_file.flags(previous_options);
}

void
bezier::write_control_points_in_postscript(
psf&ps_file,
float line_width,
int x,int y,
float magnification
)const{

ios_base::fmtflags previous_options= ps_file.flags();
ps_file.precision(4);
ps_file.setf(ios_base::fixed,ios_base::floatfield);

ps_file<<"0 setgray"<<endl;
ps_file<<"newpath"<<endl;

point pt= magnification*_ctrl_pts[0];
ps_file<<pt(x)<<"\t"<<pt(y)<<"\t";
ps_file<<(line_width*3)<<"\t"<<0.0<<"\t"<<360<<"\t"
<<"arc"<<endl;
ps_file<<"closepath"<<endl;
ps_file<<"fill stroke"<<endl;

if(_ctrl_pts.size()> 2){
for(size_t i= 1;i!=_ctrl_pts.size()-1;++i){
ps_file<<"newpath"<<endl;
pt= magnification*_ctrl_pts[i];
ps_file<<pt(x)<<"\t"<<pt(y)<<"\t";
ps_file<<(line_width*3)<<"\t"<<0.0<<"\t"<<360<<"\t"
<<"arc"<<endl;
ps_file<<"closepath"<<endl;
ps_file<<line_width<<"\t"<<"setlinewidth"<<endl;
ps_file<<"stroke"<<endl;
}
ps_file<<"0 setgray"<<endl;
ps_file<<"newpath"<<endl;
pt= magnification*_ctrl_pts.back();
ps_file<<pt(x)<<"\t"<<pt(y)<<"\t";
ps_file<<(line_width*3)<<"\t"<<0.0<<"\t"<<360<<"\t"
<<"arc"<<endl;
ps_file<<"closepath"<<endl;
ps_file<<"fill stroke"<<endl;
}
ps_file.flags(previous_options);
}

/*:81*/
#line 51 "bezier.w"





/*:56*/
#line 247 "cagd.w"

/*84:*/
#line 33 "piecewise.w"

/*85:*/
#line 48 "piecewise.w"

piecewise_bezier_curve::piecewise_bezier_curve(){}

piecewise_bezier_curve::piecewise_bezier_curve(const piecewise_bezier_curve&r)
:curve::curve(r),
_curves(r._curves)
{
}

piecewise_bezier_curve::~piecewise_bezier_curve(){}

/*:85*/
#line 34 "piecewise.w"

/*87:*/
#line 74 "piecewise.w"

size_t
piecewise_bezier_curve::count()const{
return _curves.size();
}

unsigned long
piecewise_bezier_curve::dimension()const{
if(_curves.size()!=0){
return _curves.begin()->dimension();
}else{
return 0;
}
}

unsigned long
piecewise_bezier_curve::dim()const{
return dimension();
}

unsigned long
piecewise_bezier_curve::degree()const{
unsigned long dgr= 0;
for(const_curve_itr crv= _curves.begin();crv!=_curves.end();crv++){
if(crv->degree()> dgr){
dgr= crv->degree();
}
}
return dgr;
}

/*:87*/
#line 35 "piecewise.w"

/*89:*/
#line 118 "piecewise.w"

void
piecewise_bezier_curve::push_back(bezier crv){
_curves.push_back(crv);
}

/*:89*/
#line 36 "piecewise.w"

/*91:*/
#line 133 "piecewise.w"

piecewise_bezier_curve&
piecewise_bezier_curve::operator= (const piecewise_bezier_curve&crv){
curve::operator= (crv);
_curves= crv._curves;

return*this;
}

/*:91*/
#line 37 "piecewise.w"

/*93:*/
#line 152 "piecewise.w"

void
piecewise_bezier_curve::elevate_degree(const unsigned long dgr){
for(curve_itr crv= _curves.begin();crv!=_curves.end();crv++){
crv->elevate_degree(dgr);
}
}

void
piecewise_bezier_curve::reduce_degree(const unsigned long dgr){
for(curve_itr crv= _curves.begin();crv!=_curves.end();crv++){
crv->reduce_degree(dgr);
}
}

/*:93*/
#line 38 "piecewise.w"

/*95:*/
#line 182 "piecewise.w"

point
piecewise_bezier_curve::evaluate(const double u)const{

if(_curves.size()==0)return cagd::point(2);

double max_u= static_cast<double> (_curves.size());
if((u<0.)||(max_u<u))return cagd::point(dimension());

size_t index;
if(u==max_u){
index= static_cast<long> (u)-1;
}else{
index= static_cast<long> (std::floor(u));
}

return _curves[index].evaluate(u);
}

point
piecewise_bezier_curve::derivative(const double u)const{
if(_curves.size()==0)return cagd::point(2);

double max_u= static_cast<double> (_curves.size());
if((u<0.)||(max_u<u))return cagd::point(dimension());

size_t index;
if(u==max_u){
index= static_cast<long> (u)-1;
}else{
index= static_cast<long> (std::floor(u));
}

return _curves[index].derivative(u);
}

/*:95*/
#line 39 "piecewise.w"

/*97:*/
#line 228 "piecewise.w"

void
piecewise_bezier_curve::write_curve_in_postscript(
psf&ps_file,
unsigned step,
float line_width,
int x,int y,
float magnification
)const{

ios_base::fmtflags previous_options= ps_file.flags();
ps_file.precision(4);
ps_file.setf(ios_base::fixed,ios_base::floatfield);

for(const_curve_itr crv= _curves.begin();crv!=_curves.end();crv++){
ps_file<<"newpath"<<endl
<<"[] 0 setdash "<<line_width<<" setlinewidth"<<endl;

point pt= magnification*(crv->evaluate(0));
ps_file<<pt(x)<<"\t"<<pt(y)<<"\t"<<"moveto"<<endl;

for(size_t i= 1;i<=step;i++){
double t= double(i)/double(step);
pt= magnification*(crv->evaluate(t));
ps_file<<pt(x)<<"\t"<<pt(y)<<"\t"<<"lineto"<<endl;
}
ps_file<<"stroke"<<endl;
}
ps_file.flags(previous_options);
}

void
piecewise_bezier_curve::write_control_polygon_in_postscript(
psf&ps_file,
float line_width,
int x,int y,
float magnification
)const{

ios_base::fmtflags previous_options= ps_file.flags();
ps_file.precision(4);
ps_file.setf(ios_base::fixed,ios_base::floatfield);

for(const_curve_itr crv= _curves.begin();crv!=_curves.end();crv++){
ps_file<<"newpath"<<endl;
ps_file<<"[] 0 setdash "<<.5*line_width<<" setlinewidth"<<endl;

point pt= magnification*(crv->ctrl_pts(0));
ps_file<<pt(x)<<"\t"<<pt(y)<<"\t"<<"moveto"<<endl;

for(size_t i= 1;i!=crv->ctrl_pts_size();++i){
pt= magnification*(crv->ctrl_pts(i));
ps_file<<pt(x)<<"\t"<<pt(y)<<"\t"<<"lineto"<<endl;
}
ps_file<<"stroke"<<endl;
}
ps_file.flags(previous_options);
}

void
piecewise_bezier_curve::write_control_points_in_postscript(
psf&ps_file,
float line_width,
int x,int y,
float magnification
)const{

ios_base::fmtflags previous_options= ps_file.flags();
ps_file.precision(4);
ps_file.setf(ios_base::fixed,ios_base::floatfield);

for(const_curve_itr crv= _curves.begin();crv!=_curves.end();crv++){
ps_file<<"0 setgray"<<endl;
ps_file<<"newpath"<<endl;

point pt= magnification*(crv->ctrl_pts(0));
ps_file<<pt(x)<<"\t"<<pt(y)<<"\t";
ps_file<<(line_width*3)<<"\t"<<0.0<<"\t"<<360<<"\t"
<<"arc"<<endl;
ps_file<<"closepath"<<endl;
ps_file<<"fill stroke"<<endl;

if(crv->ctrl_pts_size()> 2){
for(size_t i= 1;i!=crv->ctrl_pts_size()-1;++i){
ps_file<<"newpath"<<endl;
pt= magnification*(crv->ctrl_pts(i));
ps_file<<pt(x)<<"\t"<<pt(y)<<"\t";
ps_file<<(line_width*3)<<"\t"<<0.0<<"\t"<<360<<"\t"
<<"arc"<<endl;
ps_file<<"closepath"<<endl;
ps_file<<line_width<<"\t"<<"setlinewidth"<<endl;
ps_file<<"stroke"<<endl;
}
ps_file<<"0 setgray"<<endl;
ps_file<<"newpath"<<endl;
pt= magnification*(crv->ctrl_pts(crv->ctrl_pts_size()-1));
ps_file<<pt(x)<<"\t"<<pt(y)<<"\t";
ps_file<<(line_width*3)<<"\t"<<0.0<<"\t"<<360<<"\t"
<<"arc"<<endl;
ps_file<<"closepath"<<endl;
ps_file<<"fill stroke"<<endl;
}
}
ps_file.flags(previous_options);
}

/*:97*/
#line 40 "piecewise.w"





/*:84*/
#line 248 "cagd.w"

/*110:*/
#line 47 "cubicspline.w"

/*111:*/
#line 67 "cubicspline.w"

cubic_spline::cubic_spline(const cubic_spline&src)
:curve(src),
_knot_sqnc(src._knot_sqnc),
_mp(src._mp),
_kernel_id(src._kernel_id)
{
}

cubic_spline::cubic_spline(const vector<double> &knots,
const vector<point> &pts
)
:curve(pts),
_mp("./cspline.cl"),
_knot_sqnc(knots),
_kernel_id(_mp.create_kernel("evaluate_crv"))
{
}

cubic_spline::~cubic_spline(){
}

/*:111*//*145:*/
#line 891 "cubicspline.w"

cubic_spline::cubic_spline(
const vector<point> &p,
end_condition cond,
parametrization scheme
)
:curve(p),
_mp("./cspline.cl"),
_kernel_id(_mp.create_kernel("evaluate_crv"))
{
point m_0(2./3.*(*(p.begin()))+1./3.*(p.back()));
point m_L(1./3.*(*(p.begin()))+2./3.*(p.back()));
if((p.size()<4)&&cond==end_condition::not_a_knot){
_interpolate(p,scheme,end_condition::quadratic,m_0,m_L);
}
else{
_interpolate(p,scheme,cond,m_0,m_L);
}
}

cubic_spline::cubic_spline(const vector<point> &p,
const point i,const point e,
parametrization scheme
)
:curve(p),
_mp("./cspline.cl"),
_kernel_id(_mp.create_kernel("evaluate_crv"))
{
_interpolate(p,scheme,end_condition::clamped,i,e);
}

/*:145*/
#line 48 "cubicspline.w"

/*113:*/
#line 103 "cubicspline.w"

unsigned long
cubic_spline::degree()const{
return 3;
}

vector<double> 
cubic_spline::knot_sequence()const{
return _knot_sqnc;
}

vector<point> 
cubic_spline::control_points()const{
return _ctrl_pts;
}

/*:113*/
#line 49 "cubicspline.w"

/*115:*/
#line 130 "cubicspline.w"

cubic_spline&cubic_spline::operator= (const cubic_spline&crv){
curve::operator= (crv);
_knot_sqnc= crv._knot_sqnc;
_mp= crv._mp;
_kernel_id= crv._kernel_id;

return*this;
}

/*:115*/
#line 50 "cubicspline.w"

/*117:*/
#line 149 "cubicspline.w"

string cubic_spline::description()const{
stringstream buffer;
buffer<<curve::description();
buffer<<"  Knot Scquence:"<<endl;
for(size_t i= 0;i!=_knot_sqnc.size();i++){
buffer<<"    "<<_knot_sqnc[i]<<endl;
}

return buffer.str();
}

/*:117*/
#line 51 "cubicspline.w"

/*119:*/
#line 222 "cubicspline.w"

point
cubic_spline::evaluate(const double u,unsigned long I)const{
const unsigned long n= 3;
vector<point> tmp;

for(size_t i= I-n+1;i!=I+2;i++){
tmp.push_back(_ctrl_pts[i]);
}

long shifter= I-n+1;
for(size_t k= 1;k!=n+1;k++){
for(size_t i= I+1;i!=I-n+k;i--){
double t1= (_knot_sqnc[i+n-k]-u)/(_knot_sqnc[i+n-k]-_knot_sqnc[i-1]);
double t2= 1.0-t1;
tmp[i-shifter]= t1*tmp[i-shifter-1]+t2*tmp[i-shifter];
}
}
return tmp[I-shifter+1];
}

point
cubic_spline::evaluate(const double u)const{
return evaluate(u,find_index_in_knot_sequence(u));
}

/*:119*//*121:*/
#line 270 "cubicspline.w"

vector<point> 
cubic_spline::evaluate_all(const unsigned N)const{
const unsigned n= 3;
const unsigned L= static_cast<unsigned> (_knot_sqnc.size()-2*n+1);
const unsigned m= static_cast<unsigned> (this->dim());

size_t pts_buffer= 
_mp.create_buffer(mpoi::buffer_property::READ_WRITE,
N*m*sizeof(float));

/*123:*/
#line 332 "cubicspline.w"

const unsigned num_knots= static_cast<unsigned> (_knot_sqnc.size());
const unsigned num_ctrlpts= static_cast<unsigned> (_ctrl_pts.size());

float*knots= new float[num_knots];
float*cp= new float[num_ctrlpts*m];

size_t knots_buffer= _mp.create_buffer(mpoi::buffer_property::READ_ONLY,
num_knots*sizeof(float));
size_t cp_buffer= _mp.create_buffer(mpoi::buffer_property::READ_ONLY,
num_ctrlpts*m*sizeof(float));

for(size_t i= 0;i!=num_knots;i++){
knots[i]= static_cast<float> (_knot_sqnc[i]);
}
for(size_t i= 0;i!=num_ctrlpts;i++){
for(size_t j= 0;j!=m;j++){
cp[i*m+j]= static_cast<float> (_ctrl_pts[i](j+1));
}
}

_mp.enqueue_write_buffer(knots_buffer,num_knots*sizeof(float),knots);
_mp.enqueue_write_buffer(cp_buffer,num_ctrlpts*m*sizeof(float),cp);

delete[]knots;
delete[]cp;

_mp.set_kernel_argument(_kernel_id,0,pts_buffer);
_mp.set_kernel_argument(_kernel_id,1,knots_buffer);
_mp.set_kernel_argument(_kernel_id,2,cp_buffer);
_mp.set_kernel_argument(_kernel_id,3,sizeof(unsigned),(void*)&m);
_mp.set_kernel_argument(_kernel_id,4,sizeof(unsigned),(void*)&L);
_mp.set_kernel_argument(_kernel_id,5,sizeof(unsigned),(void*)&N);

_mp.enqueue_data_parallel_kernel(_kernel_id,N,40);


/*:123*/
#line 281 "cubicspline.w"
;

float*pts= new float[N*m];
_mp.enqueue_read_buffer(pts_buffer,N*m*sizeof(float),pts);

vector<point> crv(N,point(m));
for(size_t i= 0;i!=N;i++){
point pt(m);
for(size_t j= 1;j!=m+1;j++){
pt(j)= static_cast<double> (pts[m*i+j-1]);
}
crv[i]= pt;
}

delete[]pts;
_mp.release_buffer(pts_buffer);

return crv;
}

/*:121*//*127:*/
#line 496 "cubicspline.w"

point
cubic_spline::derivative(const double u)const{
/*129:*/
#line 527 "cubicspline.w"

if((u<_knot_sqnc.front())||(_knot_sqnc.back()<u)){
throw std::runtime_error{"out of knot range"};
}


/*:129*/
#line 499 "cubicspline.w"
;

vector<point> splines,bezier_ctrlpt;
vector<double> knots;
bezier_control_points(splines,knots);

unsigned long index= find_index_in_sequence(u,knots);
for(size_t i= index*3;i<=(index+1)*3;i++){
bezier_ctrlpt.push_back(splines.at(i));
}
bezier bezier_curve= bezier(bezier_ctrlpt);

double delta= knots[index+1]-knots[index];

double t= (u-knots[index])/delta;

point drv(bezier_curve.derivative(t));
return drv/delta;
}

/*:127*/
#line 52 "cubicspline.w"

/*143:*/
#line 828 "cubicspline.w"

void cubic_spline::_interpolate(
const vector<point> &p,
parametrization scheme,
end_condition cond,
const point&m_0,
const point&m_L
){

_knot_sqnc.clear();
_ctrl_pts.clear();

if(p.size()==0){

}else if(p.size()<3){
_knot_sqnc= vector<double> (6,0.0);
_ctrl_pts= vector<point> (6,p[0]);

for(size_t i= 3;i!=6;i++){
_knot_sqnc[i]= 1.0;
_ctrl_pts[i]= p.back();
}

}else{
/*147:*/
#line 939 "cubicspline.w"

switch(scheme){
case parametrization::uniform:{
/*148:*/
#line 973 "cubicspline.w"

for(size_t i= 0;i!=p.size();i++){
_knot_sqnc.push_back(double(i));
}




/*:148*/
#line 942 "cubicspline.w"
;
}
break;

case parametrization::chord_length:{
/*149:*/
#line 989 "cubicspline.w"

_knot_sqnc.push_back(0.);

double sum_delta= 0.;
for(size_t i= 0;i!=p.size()-1;i++){
double delta= cagd::dist(p[i],p[i+1]);
sum_delta+= delta;
_knot_sqnc.push_back(sum_delta);
}
if(sum_delta!=0.){
for(knot_itr i= _knot_sqnc.begin();i!=_knot_sqnc.end();i++){
*i/= sum_delta;
}
}




/*:149*/
#line 947 "cubicspline.w"
;
}
break;

case parametrization::centripetal:{
/*150:*/
#line 1020 "cubicspline.w"

double sum_delta= 0.;
_knot_sqnc.push_back(sum_delta);
for(size_t i= 0;i!=p.size()-1;i++){
double delta= sqrt(cagd::dist(p[i],p[i+1]));
sum_delta+= delta;
_knot_sqnc.push_back(sum_delta);
}

if(sum_delta!=0.){
for(size_t i= 0;i!=_knot_sqnc.size();i++){
_knot_sqnc[i]/= sum_delta;
}
}




/*:150*/
#line 952 "cubicspline.w"
;
}
break;

case parametrization::function_spline:{
/*151:*/
#line 1043 "cubicspline.w"

for(size_t i= 0;i!=p.size();i++){
_knot_sqnc.push_back(p[i](1));
}




/*:151*/
#line 957 "cubicspline.w"
;
}
break;

default:
throw std::runtime_error{"unknown parametrization"};
}


/*:147*/
#line 852 "cubicspline.w"
;

if(cond==end_condition::periodic){
/*156:*/
#line 1595 "cubicspline.w"

unsigned long L= p.size()-1;

vector<double> a(L,0.0);
vector<double> b(L,0.0);
vector<double> c(L,0.0);
vector<point> r(L,p[0].dim());

a[0]= delta(0)*delta(0)/(delta(L-2)+delta(L-1)+delta(0));
b[0]= delta(0)*(delta(L-2)+delta(L-1))/(delta(L-2)+delta(L-1)+delta(0))
+delta(L-1)*(delta(0)+delta(1))/(delta(L-1)+delta(0)+delta(1));
c[0]= delta(L-1)*delta(L-1)/(delta(L-1)+delta(0)+delta(1));

for(size_t i= 1;i!=L;i++){
double delta_im2= delta(i-2);
double delta_im1= delta(i-1);
double delta_i= delta(i);
double delta_ip1= delta(i+1);

double alpha_i= delta_i*delta_i/(delta_im2+delta_im1+delta_i);
double beta_i= delta_i*(delta_im2+delta_im1)/(delta_im2+delta_im1+delta_i)
+delta_im1*(delta_i+delta_ip1)/(delta_im1+delta_i+delta_ip1);
double gamma_i= delta_im1*delta_im1/(delta_im1+delta_i+delta_ip1);

a[i]= alpha_i;
b[i]= beta_i;
c[i]= gamma_i;

r[i]= (delta_im1+delta_i)*p[i];
}

a[1]= delta(1)*delta(1)/(delta(L-1)+delta(0)+delta(1));
b[1]= delta(1)*(delta(L-1)+delta(0))/(delta(L-1)+delta(0)+delta(1))
+delta(0)*(delta(1)+delta(2))/(delta(0)+delta(1)+delta(2));

b[L-1]= delta(L-1)*(delta(L-3)+delta(L-2))/(delta(L-3)+delta(L-2)+delta(L-1))
+delta(L-2)*(delta(L-1)+delta(0))/(delta(L-2)+delta(L-1)+delta(0));
c[L-1]= delta(L-2)*delta(L-2)/(delta(L-2)+delta(L-1)+delta(0));

r[0]= (delta(L-1)+delta(0))*p[0];

vector<point> x(L,point(p[0].dim()));

if(solve_cyclic_tridiagonal_system(a,b,c,r,x)!=0){
throw std::runtime_error{"tirdiagonal system not solvable"};
}

point d_plus(((delta(0)+delta(1))*x[0]+delta(L-1)*x[1])
/(delta(L-1)+delta(0)+delta(1)));
point d_minus(((delta(L-2)+delta(L-1))*x[0]+delta(0)*x[L-1])
/(delta(L-2)+delta(L-1)+delta(0)));

vector<point> d(L+1,point(p[0].dim()));
d[0]= d_plus;

for(size_t i= 1;i!=L;i++){
d[i]= x[i];
}
d[L]= d_minus;

set_control_points(p[0],d,p[L]);




/*:156*/
#line 855 "cubicspline.w"
;
}
else{
/*152:*/
#line 1116 "cubicspline.w"

unsigned long L= p.size()-1;

vector<double> a(L,0.0);
vector<double> b(L+1,0.0);
vector<double> c(L,0.0);
vector<point> r(L+1,point(p[0].dim()));

for(size_t i= 1;i!=L;i++){
double d_im1= delta(i-1);
double d_i= delta(i);

double alpha_i= d_i;
double beta_i= 2.0*(d_im1+d_i);
double gamma_i= d_im1;

a[i-1]= alpha_i;
b[i]= beta_i;
c[i]= gamma_i;

point r_i= 3.0*(d_i*(p[i]-p[i-1])/d_im1+d_im1*(p[i+1]-p[i])/d_i);
r[i]= r_i;
}




/*:152*/
#line 858 "cubicspline.w"
;
/*153:*/
#line 1374 "cubicspline.w"

switch(cond){
case end_condition::clamped:
b[0]= 1.0;
c[0]= 0.0;
r[0]= m_0;

a[L-1]= 0.0;
b[L]= 1.0;
r[L]= m_L;

break;

case end_condition::bessel:
b[0]= 1.0;
c[0]= 0.0;
r[0]= -2*(2*delta(0)+delta(1))/(delta(0)*b[1])*p[0]
+b[1]/(2*delta(0)*delta(1))*p[1]
-2*delta(0)/(delta(1)*b[1])*p[2];

a[L-1]= 0.0;
b[L]= 1.0;
r[L]= 2*delta(L-1)/(delta(L-2)*b[L-1])*p[L-2]
-b[L-1]/(2*delta(L-2)*delta(L-1))*p[L-1]
+2*(2*delta(L-1)+delta(L-2))/(b[L-1]*delta(L-1))*p[L];
break;

case end_condition::not_a_knot:
{
double d0= delta(0);
double d1= delta(1);
double d2= delta(2);

double d01= d0+d1;
double d12= d1+d2;

double d012= d0+d1+d2;

b[0]= d0*pow(d1,2);
c[0]= d0*d1*d01;
r[0]= (p[2]*pow(d0,3)-p[1]*(d0-2*d1)*pow(d01,2)
-p[0]*pow(d1,2)*(3*d0+2*d2))/d01;

a[0]= (d0*(2*d1-d2)+2*d1*d12)/(3*d012);
b[1]= (d01)*(d0*(d1-2*d2)+d1*d12)/(3*d1*d012);
c[1]= -d0*d01*d12/(3*d1*d012);
r[1]= (-p[2]*pow(d0,2)*d01*d12
-p[0]*pow(d1,2)*(d0*(2*d1-d2)+2*d1*d12)
+p[1]*(pow(d0*d1,2)+2*d0*pow(d1,3)+pow(d0,3)*d2+pow(d1,3)*d12))
/(d0*pow(d1,2)*d012)
+(p[2]*pow(d0,3)+p[0]*pow(d1,3))/(d0*d1*d01);

d1= delta(L-1);
d2= delta(L-2);
double d3= delta(L-3);

d12= d1+d2;
double d23= d2+d3;

double d123= d1+d2+d3;

a[L-2]= d23*d1*d12/(3*d2*d123);
b[L-1]= -d12*(d3*(d2-2*d1)+d2*d12)/(3*d2*d123);
c[L-1]= (d3*(-2*d2+d1)-2*d2*d12)/(3*d123);
r[L-1]= (-p[L-2]*d23*pow(d1,2)*d12
-p[L]*pow(d2,2)*(d3*(2*d2-d1)+2*d2*d12)
+p[L-1]*(pow(d2,2)*pow(d12,2)+d3*(pow(d2,3)+pow(d1,3))))
/(pow(d2,2)*d1*d123)
+(pow(d2,3)*p[L]+pow(d1,3)*p[L-2])/(d1*d2*d12);

a[L-1]= d2*d1*d12;
b[L]= pow(d2,2)*d1;
r[L]= (-p[L-2]*pow(d1,3)-p[L-1]*(2*d2-d1)*pow(d12,2)
+p[L]*pow(d2,2)*(2*d2+3*d1))/d12;
}
break;

case end_condition::quadratic:
b[0]= 1.0;
c[0]= 1.0;
r[0]= 2/delta(0)*(p[1]-p[0]);

a[L-1]= 1.0;
b[L]= 1.0;
r[L]= 2/delta(L-1)*(p[L]-p[L-1]);
break;

case end_condition::natural:
b[0]= 2.0;
c[0]= 1.0;
r[0]= 3/delta(0)*(p[1]-p[0]);

a[L-1]= 1.0;
b[L]= 2.0;
r[L]= 3/delta(L-1)*(p[L]-p[L-1]);
break;

default:
throw std::runtime_error{"unknown end condition"};
}
solve_hform_tridiagonal_system_set_ctrl_pts(a,b,c,r,p);


/*:153*/
#line 859 "cubicspline.w"
;
}
insert_end_knots();
}
}

/*:143*//*154:*/
#line 1481 "cubicspline.w"

void
cubic_spline::solve_hform_tridiagonal_system_set_ctrl_pts(
const vector<double> &a,
const vector<double> &b,
const vector<double> &c,
const vector<point> &r,
const vector<point> &p
){

unsigned long L= p.size()-1;
vector<point> m(L+1,point(p[0].dim()));

if(solve_tridiagonal_system(a,b,c,r,m)!=0){
throw std::runtime_error{"tridiagonal system not solvable"};
}

vector<point> bp= bezier_points_from_hermite_form(p,m);
vector<point> d= control_points_from_bezier_form(bp);

_ctrl_pts= d;
}

/*:154*/
#line 53 "cubicspline.w"

/*138:*/
#line 656 "cubicspline.w"

vector<point> 
cubic_spline::bezier_points_from_hermite_form(
const vector<point> &x,
const vector<point> &m
){

if(x.size()==0){
return vector<point> (0,point(0));
}

unsigned long L= x.size()-1;
vector<point> b(3*L+1,point(x[0].dim()));

b[0]= x[0];
for(unsigned long i= 0;i!=L;i++){
b[3*i+3]= x[i+1];

double du= _knot_sqnc[i+1]-_knot_sqnc[i];
b[3*i+1]= b[3*i]+du/3.0*m[i];
b[3*i+2]= b[3*i+3]-du/3.0*m[i+1];
}

return b;
}

/*:138*//*140:*/
#line 726 "cubicspline.w"

vector<point> 
cubic_spline::control_points_from_bezier_form(const vector<point> &b){
const unsigned long L= _knot_sqnc.size()-1;

vector<point> d(L+3,b[0].dim());

d[0]= b[0];
d[1]= b[1];

for(size_t i= 1;i<L;i++){
double delta_im1= _knot_sqnc[i]-_knot_sqnc[i-1];
double delta_i= _knot_sqnc[i+1]-_knot_sqnc[i];
d[i+1]= ((delta_im1+delta_i)*b[3*i-1]-delta_i*b[3*i-2])/delta_im1;
}

d[L+1]= b[3*L-1];
d[L+2]= b[3*L];

return d;
}

/*:140*//*166:*/
#line 1893 "cubicspline.w"

void
cubic_spline::bezier_control_points(
vector<point> &bezier_ctrl_points,
vector<double> &knot
)const{

bezier_ctrl_points.clear();
knot.clear();

/*167:*/
#line 1912 "cubicspline.w"

knot.push_back(_knot_sqnc[0]);
for(size_t i= 1;i!=_knot_sqnc.size();i++){
if(_knot_sqnc[i]> knot.back()){
knot.push_back(_knot_sqnc[i]);
}
}


/*:167*/
#line 1903 "cubicspline.w"
;
/*168:*/
#line 1924 "cubicspline.w"

if(knot.size()+2!=_ctrl_pts.size()){
throw std::runtime_error{"unable to break into bezier curves"};
}


/*:168*/
#line 1904 "cubicspline.w"
;
/*169:*/
#line 1933 "cubicspline.w"

for(size_t i= 0;i<=3*(knot.size()-1);i++){
bezier_ctrl_points.push_back(point({0.0,0.0}));
}

bezier_ctrl_points[0]= _ctrl_pts[0];
bezier_ctrl_points[1]= _ctrl_pts[1];
double delta= knot[2]-knot[0];
bezier_ctrl_points[2]= ((knot[2]-knot[1])*_ctrl_pts[1]+
(knot[1]-knot[0])*_ctrl_pts[2])
/delta;

for(size_t i= 2;i<=knot.size()-2;i++){
delta= knot[i+1]-knot[i-2];
bezier_ctrl_points[3*i-1]= ((knot[i+1]-knot[i])*_ctrl_pts[i]+
(knot[i]-knot[i-2])*_ctrl_pts[i+1])
/delta;
bezier_ctrl_points[3*i-2]= ((knot[i+1]-knot[i-1])*_ctrl_pts[i]+
(knot[i-1]-knot[i-2])*_ctrl_pts[i+1])
/delta;
}

unsigned long L= knot.size()-1;
delta= knot[L]-knot[L-2];
bezier_ctrl_points[3*L-2]= ((knot[L]-knot[L-1])*_ctrl_pts[L]+
(knot[L-1]-knot[L-2])*_ctrl_pts[L+1])
/delta;
bezier_ctrl_points[3*L-1]= _ctrl_pts[L+1];
bezier_ctrl_points[3*L]= _ctrl_pts[L+2];

for(size_t i= 1;i<=(knot.size()-2);i++){
delta= knot[i+1]-knot[i-1];
bezier_ctrl_points[3*i]= ((knot[i+1]-knot[i])*bezier_ctrl_points[3*i-1]+
(knot[i]-knot[i-1])*bezier_ctrl_points[3*i+1])
/delta;
}

/*:169*/
#line 1905 "cubicspline.w"
;
}


/*:166*/
#line 54 "cubicspline.w"

/*171:*/
#line 1980 "cubicspline.w"

vector<point> 
cubic_spline::signed_curvature(int density)const{
vector<point> bezier_ctrl_points;
vector<double> knot;
vector<point> curvature;
bezier_control_points(bezier_ctrl_points,knot);

for(size_t i= 0;i!=(knot.size()-2);i++){
list<point> cpts;
cpts.clear();
cpts.push_back(bezier_ctrl_points[3*i]);
cpts.push_back(bezier_ctrl_points[3*i+1]);
cpts.push_back(bezier_ctrl_points[3*i+2]);
cpts.push_back(bezier_ctrl_points[3*i+3]);
bezier segment(cpts);
vector<point> kappa= segment.signed_curvature(density);

for(size_t j= 0;j!=kappa.size();j++){
curvature.push_back(kappa[j]);
}
}
return curvature;
}

/*:171*/
#line 55 "cubicspline.w"

/*173:*/
#line 2026 "cubicspline.w"

void
cubic_spline::insert_knot(const double u){
const int n= 3;

size_t index= find_index_in_knot_sequence(u);
if(index==SIZE_MAX){
throw std::runtime_error{"out of knot range"};
}
if((index<n-1)||(int(_knot_sqnc.size())-n<index)){
throw std::runtime_error{"not insertable knot"};
}

vector<point> new_ctrl_pts;

/*174:*/
#line 2050 "cubicspline.w"

for(size_t i= 0;i<=index-n+1;i++){
new_ctrl_pts.push_back(_ctrl_pts[i]);
}

/*:174*/
#line 2041 "cubicspline.w"
;
/*175:*/
#line 2055 "cubicspline.w"

for(size_t i= index-n+2;i<=index+1;i++){
new_ctrl_pts.push_back(
_ctrl_pts[i-1]*(_knot_sqnc[i+n-1]-u)/(_knot_sqnc[i+n-1]-_knot_sqnc[i-1])
+_ctrl_pts[i]*(u-_knot_sqnc[i-1])/(_knot_sqnc[i+n-1]-_knot_sqnc[i-1]));
}

/*:175*/
#line 2042 "cubicspline.w"
;
/*176:*/
#line 2062 "cubicspline.w"

for(size_t i= index+2;i<=_knot_sqnc.size()-n+1;i++){
new_ctrl_pts.push_back(_ctrl_pts[i-1]);
}

/*:176*/
#line 2043 "cubicspline.w"
;

_knot_sqnc.insert(_knot_sqnc.begin()+index+1,u);
_ctrl_pts.clear();
_ctrl_pts= new_ctrl_pts;
}

/*:173*//*180:*/
#line 2160 "cubicspline.w"

void
cubic_spline::remove_knot(const double u){
vector<double> IGESKnot;
vector<point> forward;
vector<point> backward;
const int k= 4;

/*181:*/
#line 2183 "cubicspline.w"

IGESKnot.push_back(_knot_sqnc[0]);
for(size_t i= 0;i!=_knot_sqnc.size();++i){
IGESKnot.push_back(_knot_sqnc[i]);
}
IGESKnot.push_back(_knot_sqnc.back());

/*:181*/
#line 2168 "cubicspline.w"
;

size_t r= find_index_in_knot_sequence(u)+1;
unsigned long v= find_multiplicity(u);

/*182:*/
#line 2190 "cubicspline.w"

for(size_t i= 0;i<=r-k+v-1;i++){
forward.push_back(_ctrl_pts[i]);
}

for(size_t i= r-k+v;i<=r-1;i++){
double l= (IGESKnot[r]-IGESKnot[i])/(IGESKnot[k+i]-IGESKnot[i]);
forward.push_back(1.0/l*_ctrl_pts[i]+(1.0-1.0/l)*forward[i-1]);
}

for(size_t i= r;i<=_ctrl_pts.size()-2;i++){
forward.push_back(_ctrl_pts[i+1]);
}

/*:182*/
#line 2173 "cubicspline.w"
;
/*183:*/
#line 2204 "cubicspline.w"

for(size_t i= 0;i<=_ctrl_pts.size()-2;i++){
backward.push_back(cagd::point(2));
}

for(long i= _ctrl_pts.size()-2;i>=r-1;i--){
backward[i]= _ctrl_pts[i+1];
}

for(long i= r-2;i>=r-k+v-1;i--){
double l= (IGESKnot[r]-IGESKnot[i+1])/(IGESKnot[k+i+1]-IGESKnot[i+1]);
backward[i]= 1./(1.-l)*_ctrl_pts[i+1]+(1.-1./(1.-l))*backward[i+1];
}

for(long i= r-k+v-2;i>=0;i--){
backward[i]= _ctrl_pts[i];
}

/*:183*/
#line 2174 "cubicspline.w"
;
/*184:*/
#line 2222 "cubicspline.w"

for(size_t i= r-k+v-1;i<=r-1;i++){
double mu= get_blending_ratio(IGESKnot,v,r,i);
_ctrl_pts[i]= (1.-mu)*forward[i]+mu*backward[i];
}
for(size_t i= r;i<=_ctrl_pts.size()-2;i++){
_ctrl_pts[i]= _ctrl_pts[i+1];
}
_ctrl_pts.pop_back();

/*:184*/
#line 2175 "cubicspline.w"
;

for(size_t i= r;i<=_knot_sqnc.size()-1;i++){
_knot_sqnc[i-1]= _knot_sqnc[i];
}
_knot_sqnc.pop_back();
}

/*:180*/
#line 56 "cubicspline.w"

/*186:*/
#line 2244 "cubicspline.w"

void
cubic_spline::write_curve_in_postscript(
psf&ps_file,unsigned dense,float line_width,int x,int y,
float magnification
)const{

ios_base::fmtflags previous_options= ps_file.flags();
ps_file.precision(4);
ps_file.setf(ios_base::fixed,ios_base::floatfield);

ps_file<<"newpath"<<endl
<<"[] 0 setdash "<<line_width<<" setlinewidth"<<endl;

point pt(magnification*evaluate(_knot_sqnc[2],2));

ps_file<<pt(x)<<"\t"<<pt(y)<<"\t"<<"moveto"<<endl;

double incr= (_knot_sqnc[_knot_sqnc.size()-3]-_knot_sqnc[2])/double(dense);
for(size_t i= 0;i!=dense+1;i++){
double u= _knot_sqnc[2]+incr*i;
pt= magnification*evaluate(u);
ps_file<<pt(x)<<"\t"<<pt(y)<<"\t"<<"lineto"<<endl;
}

ps_file<<"stroke"<<endl;
ps_file.flags(previous_options);
}

void
cubic_spline::write_control_polygon_in_postscript(
psf&ps_file,float line_width,int x,int y,float magnification
)const{

ios_base::fmtflags previous_options= ps_file.flags();
ps_file.precision(4);
ps_file.setf(ios_base::fixed,ios_base::floatfield);

ps_file<<"newpath"<<endl
<<"[] 0 setdash "<<.5*line_width<<" setlinewidth"<<endl;

point pt(magnification*_ctrl_pts[0]);
ps_file<<pt(x)<<"\t"<<pt(y)<<"\t"<<"moveto"<<endl;

for(size_t i= 1;i<_ctrl_pts.size();i++){
pt= magnification*_ctrl_pts[i];
ps_file<<pt(x)<<"\t"<<pt(y)<<"\t"<<"lineto"<<endl;
}

ps_file<<"stroke"<<endl;
ps_file.flags(previous_options);
}

void
cubic_spline::write_control_points_in_postscript(
psf&ps_file,float line_width,int x,int y,float magnification
)const{

ios_base::fmtflags previous_options= ps_file.flags();
ps_file.precision(4);
ps_file.setf(ios_base::fixed,ios_base::floatfield);

point pt(magnification*_ctrl_pts[0]);
ps_file<<"0 setgray"<<endl
<<"newpath"<<endl
<<pt(x)<<"\t"<<pt(y)<<"\t"
<<(line_width*3)<<"\t"<<0.0<<"\t"
<<360<<"\t"<<"arc"<<endl
<<"closepath"<<endl
<<"fill stroke"<<endl;

if(_ctrl_pts.size()> 2){
for(size_t i= 1;i<=(_ctrl_pts.size()-2);i++){
pt= magnification*_ctrl_pts[i];
ps_file<<"newpath"<<endl
<<pt(x)<<"\t"<<pt(y)<<"\t"
<<(line_width*3)<<"\t"<<0.0<<"\t"
<<360<<"\t"<<"arc"<<endl
<<"closepath"<<endl
<<line_width<<"\t"<<"setlinewidth"<<endl
<<"stroke"<<endl;
}
pt= magnification*_ctrl_pts.back();
ps_file<<"0 setgray"<<endl
<<"newpath"<<endl
<<pt(x)<<"\t"<<pt(y)<<"\t"
<<(line_width*3)<<"\t"<<0.0<<"\t"
<<360<<"\t"<<"arc"<<endl
<<"closepath"<<endl
<<"fill stroke"<<endl;
}
ps_file.flags(previous_options);
}

/*:186*/
#line 57 "cubicspline.w"

/*125:*/
#line 455 "cubicspline.w"

size_t
cubic_spline::find_index_in_sequence(
const double u,
const vector<double> sqnc
)const{

if(u==sqnc.back()){
for(size_t i= sqnc.size()-2;i!=SIZE_MAX;i--){
if(sqnc[i]!=u){
return i;
}
}
}

for(size_t i= 0;i!=sqnc.size()-1;i++){
if((sqnc[i]<=u)&&(u<sqnc[i+1])){
return i;
}
}
return SIZE_MAX;
}

size_t
cubic_spline::find_index_in_knot_sequence(const double u)const{
return find_index_in_sequence(u,this->_knot_sqnc);
}

/*:125*//*130:*/
#line 537 "cubicspline.w"

unsigned long
cubic_spline::find_multiplicity(const double u,
const_knot_itr begin
)const{
const_knot_itr iter= find(begin,_knot_sqnc.end(),u);
if(iter==_knot_sqnc.end()){
return 0;
}else{
return find_multiplicity(u,++iter)+1;
}
}

unsigned long
cubic_spline::find_multiplicity(const double u)const{
return find_multiplicity(u,_knot_sqnc.begin());
}

/*:130*//*132:*/
#line 568 "cubicspline.w"

double cubic_spline::delta(const long i)const{
if((i<0)||(_knot_sqnc.size()-1)<=i){
return 0.;
}else{
return _knot_sqnc[i+1]-_knot_sqnc[i];
}
}

/*:132*//*134:*/
#line 587 "cubicspline.w"

void
cubic_spline::insert_end_knots(){
vector<double> newKnots;
newKnots.push_back(_knot_sqnc[0]);
newKnots.push_back(_knot_sqnc[0]);

for(size_t i= 0;i!=_knot_sqnc.size();++i){
newKnots.push_back(_knot_sqnc[i]);
}

newKnots.push_back(_knot_sqnc.back());
newKnots.push_back(_knot_sqnc.back());

_knot_sqnc.clear();
for(size_t i= 0;i!=newKnots.size();++i){
_knot_sqnc.push_back(newKnots[i]);
}
}

/*:134*//*136:*/
#line 618 "cubicspline.w"

void
cubic_spline::set_control_points(
const point&head,
const vector<point> &intermediate,
const point&tail
){

_ctrl_pts.clear();
size_t n= intermediate.size();
_ctrl_pts= vector<point> (2+n,point(2));
_ctrl_pts[0]= head;
for(size_t i= 0;i!=n;i++){
_ctrl_pts[i+1]= intermediate[i];
}
_ctrl_pts[n+1]= tail;
}

/*:136*//*178:*/
#line 2078 "cubicspline.w"

double
cubic_spline::get_blending_ratio(
const vector<double> &IGESKnot,
long v,long r,long i
){

long beta= 1;
long m1= beta-r+6-v;
if(m1<0){
m1= 0;
}
long m2= r-_ctrl_pts.size()+2+beta;
if(m2<0){
m2= 0;
}

if((v-1<=i)&&(i<=v-2+m1)){
return 0.;
}
if((4-m2<=i)&&(i<=3)){
return 1.;
}

double gamma= 0.;
for(size_t j= v-1+m1;j<=4-m2;j++){
double brk= bracket(IGESKnot,j+1,3,r);
gamma+= brk*brk;
}

double result= 0.;
for(size_t j= v-1+m1;j<=i;j++){
double brk= bracket(IGESKnot,j+1,3,r);
result+= brk*brk;
}

return result/gamma;
}

double
cubic_spline::bracket(
const vector<double> &IGESKnot,
long a,long b,long r
){

if(a==b+1){
return 1./find_l(IGESKnot,a-1,r);
}

if(a==b+2){
return 1./(1.-find_l(IGESKnot,a-1,r));
}

double result= 1./find_l(IGESKnot,a-1,r);
for(size_t i= a;i<=b;i++){
double tmp= find_l(IGESKnot,i,r);
result*= (1.-tmp)/tmp;
}
return result;
}


double
cubic_spline::find_l(
const vector<double> &IGESKnot,
long j,long r
){
return(IGESKnot[r]-IGESKnot[r-4+j])/(IGESKnot[r+j]-IGESKnot[r-4+j]);
}

/*:178*/
#line 58 "cubicspline.w"





/*:110*/
#line 249 "cagd.w"





/*:3*/
