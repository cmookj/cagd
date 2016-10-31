


#include "cagd.h"

using namespace cagd;




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




double
cagd::signed_area(const point p1,const point p2,const point p3){
  double area;
  area= ((p2(1)-p1(1))*(p3(2)-p1(2))-(p2(2)-p1(2))*(p3(1)-p1(1)))/2.0;
  return area;
}




unsigned long cagd::factorial(unsigned long n){
  if(n<=0){
    return 1UL;
  }else{
    return n*factorial(n-1);
  }
}




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




int cagd::solve_cyclic_tridiagonal_system(
                                          const vector<double> &alpha,
                                          const vector<double> &beta,
                                          const vector<double> &gamma,
                                          const vector<point> &b,
                                          vector<point> &x
                                          ){
  
  size_t n= beta.size();
  vector<double> Einv((n-1)*(n-1),0.);
  
  
  
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
  
  
  
  
  ;
  
  size_t dim= b[0].dim();
  vector<vector<double> > B(dim,vector<double> (n,0.));
  for(size_t i= 0;i!=dim;i++){
    for(size_t j= 0;j!=n;j++){
      B[i][j]= b[j](i+1);
    }
    
    
    
    
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
    
    
    
    
    ;
    
    
    
    vector<double> bhat_fxn(n-1,0.);
    for(size_t j= 0;j!=n-1;j++){
      bhat_fxn[j]= B[i][j];
    }
    bhat_fxn[0]-= alpha[0]*x_n;
    bhat_fxn[n-2]-= gamma[n-2]*x_n;
    
    vector<double> xhat= multiply(Einv,bhat_fxn);
    
    
    
    
    ;
    
    for(size_t j= 0;j!=n-1;j++){
      x[j](i+1)= xhat[j];
    }
    x[n-1](i+1)= x_n;
  }
  
  return 0;
}










size_t point::dimension()const{
  return(this->_elem).size();
}

size_t point::dim()const{
  return(this->_elem).size();
}







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




string point::description()const{
  stringstream buffer;
  buffer<<"( ";
  for(size_t i= 0;i!=dim()-1;i++){
    buffer<<_elem[i]<<", ";
  }
  buffer<<_elem[dim()-1]<<" )"<<endl;
  
  return buffer.str();
}







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




double cagd::dist(const point&pt1,const point&pt2){
  return pt1.dist(pt2);
}

















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







curve&curve::operator= (const curve&crv){
  _ctrl_pts= crv._ctrl_pts;
  _err= crv._err;
  
  return*this;
}

















unsigned long
bezier::degree()const{
  return _degree;
}







bezier::bezier(){}

bezier::bezier(const bezier&src){
  _degree= src._degree;
  _ctrl_pts.clear();
  for(size_t i= 0;i!=src._ctrl_pts.size();++i){
    _ctrl_pts.push_back(src._ctrl_pts[i]);
  }
}

bezier::bezier(vector<point> points){
  _degree= points.size()-1;
  _ctrl_pts.clear();
  for(size_t i= 0;i!=points.size();++i){
    _ctrl_pts.push_back(points[i]);
  }
}

bezier::bezier(list<point> points){
  _degree= points.size()-1;
  _ctrl_pts.clear();
  for(list<point> ::const_iterator i= points.begin();i!=points.end();i++){
    _ctrl_pts.push_back(*i);
  }
}

bezier::~bezier(){
}







bezier&bezier::operator= (const bezier&src){
  _degree= src._degree;
  curve::operator= (src);
  
  return*this;
}







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







void
bezier::subdivision(double t,bezier&left,bezier&right)const{
  double t1= 1.0-t;
  vector<point> points;
  
  
  
  
  right._ctrl_pts.clear();
  right._degree= _degree;
  for(size_t i= 0;i!=_ctrl_pts.size();i++){
    points.push_back(_ctrl_pts[i]);
  }
  
  
  
  for(size_t r= 1;r!=_degree+1;r++){
    for(size_t i= 0;i!=_degree-r+1;i++){
      points[i]= t1*points[i]+t*points[i+1];
    }
  }
  
  
  
  ;
  for(size_t i= 0;i!=(_degree+1);i++){
    right._ctrl_pts.push_back(points[i]);
  }
  
  
  
  ;
  
  
  
  t= 1.0-t;
  t1= 1.0-t1;
  points.clear();
  left._ctrl_pts.clear();
  left._degree= _degree;
  unsigned long index= _degree;
  for(size_t i= 0;i!=_ctrl_pts.size();i++){
    points[index--]= _ctrl_pts[i];
  }
  
  
  
  for(size_t r= 1;r!=_degree+1;r++){
    for(size_t i= 0;i!=_degree-r+1;i++){
      points[i]= t1*points[i]+t*points[i+1];
    }
  }
  
  
  
  ;
  for(size_t i= 0;i!=_degree+1;i++){
    left._ctrl_pts.push_back(points[i]);
  }
  
  
  
  ;
}







void bezier::elevate_degree(unsigned long dgr){
  if(_degree> dgr){
    _err= DEGREE_ELEVATION_FAIL;
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




void bezier::reduce_degree(const unsigned long dgr){
  if(_degree<dgr){
    _err= DEGREE_REDUCTION_FAIL;
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

















piecewise_bezier_curve::piecewise_bezier_curve(){}

piecewise_bezier_curve::piecewise_bezier_curve(const piecewise_bezier_curve&r)
:curve::curve(r),
_curves(r._curves)
{
}

piecewise_bezier_curve::~piecewise_bezier_curve(){}







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







void
piecewise_bezier_curve::push_back(bezier crv){
  _curves.push_back(crv);
}







piecewise_bezier_curve&
piecewise_bezier_curve::operator= (const piecewise_bezier_curve&crv){
  curve::operator= (crv);
  _curves= crv._curves;
  
  return*this;
}







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




cubic_spline::cubic_spline(const vector<point> &p,
                           end_condition cond,
                           parametrization scheme
                           )
:curve(p),
_mp("./cspline.cl"),
_kernel_id(_mp.create_kernel("evaluate_crv"))
{
  point one_third(2./3.*(*(p.begin()))+1./3.*(p.back()));
  point two_third(1./3.*(*(p.begin()))+2./3.*(p.back()));
  _interpolate(p,scheme,cond,one_third,two_third);
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







cubic_spline&cubic_spline::operator= (const cubic_spline&crv){
  curve::operator= (crv);
  _knot_sqnc= crv._knot_sqnc;
  _mp= crv._mp;
  _kernel_id= crv._kernel_id;
  
  return*this;
}







string cubic_spline::description()const{
  stringstream buffer;
  buffer<<curve::description();
  buffer<<"  Knot Scquence:"<<endl;
  for(size_t i= 0;i!=_knot_sqnc.size();i++){
    buffer<<"    "<<_knot_sqnc[i]<<endl;
  }
  
  return buffer.str();
}







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




vector<point>
cubic_spline::evaluate_all(const unsigned N)const{
  const unsigned n= 3;
  const unsigned L= static_cast<unsigned> (_knot_sqnc.size()-2*n+1);
  const unsigned m= static_cast<unsigned> (this->dim());
  
  size_t pts_buffer=
  _mp.create_buffer(mpoi::buffer_property::READ_WRITE,
                    N*m*sizeof(float));
  
  
  
  
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




point
cubic_spline::derivative(const double u)const{
  
  
  
  if((u<_knot_sqnc.front())||(_knot_sqnc.back()<u)){
    _err= OUT_OF_KNOT_RANGE;
    return cagd::point(_ctrl_pts.begin()->dim());
  }
  
  
  
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







void
cubic_spline::_interpolate(const vector<point> &p,
                           parametrization scheme,
                           end_condition cond,
                           const point&initial,
                           const point&end
                           ){
  
  _knot_sqnc.clear();
  _ctrl_pts.clear();
  
  if(p.size()==0){
    
  }else if(p.size()==1){
    _knot_sqnc.push_back(0.);
    _knot_sqnc.push_back(0.);
    _knot_sqnc.push_back(0.);
    
    _ctrl_pts.push_back(p[0]);
    _ctrl_pts.push_back(p[0]);
    _ctrl_pts.push_back(p[0]);
    
  }else{
    
    
    
    switch(scheme){
      case parametrization::uniform:{
        
        
        
        for(size_t i= 0;i!=p.size();i++){
          _knot_sqnc.push_back(double(i));
        }
        
        
        
        
        
        
        ;
      }
        break;
        
      case parametrization::chord_length:{
        
        
        
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
        
        
        
        
        
        
        ;
      }
        break;
        
      case parametrization::centripetal:{
        
        
        
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
        
        
        
        
        
        
        ;
      }
        break;
        
      case parametrization::function_spline:{
        
        
        
        for(size_t i= 0;i!=p.size();i++){
          _knot_sqnc.push_back(p[i](1));
        }
        
        
        
        
        
        
        ;
      }
        break;
        
      default:
        _err= UNKNOWN_PARAMETRIZATION;
        return;
    }
    
    
    
    ;
    
    
    
    vector<double> a;
    vector<double> b;
    vector<double> c;
    vector<point> r;
    
    unsigned long L= p.size()-1;
    
    b.push_back(1.0);
    c.push_back(0.0);
    r.push_back(initial);
    
    for(size_t i= 1;i!=L;i++){
      double delta_im2= delta(i-2);
      double delta_im1= delta(i-1);
      double delta_i= delta(i);
      double delta_ip1= delta(i+1);
      
      double alpha_i= delta_i*delta_i/(delta_im2+delta_im1+delta_i);
      double beta_i= delta_i*(delta_im2+delta_im1)/(delta_im2+delta_im1+delta_i)
      +delta_im1*(delta_i+delta_ip1)/(delta_im1+delta_i+delta_ip1);
      double gamma_i= delta_im1*delta_im1/(delta_im1+delta_i+delta_ip1);
      
      a.push_back(alpha_i);
      b.push_back(beta_i);
      c.push_back(gamma_i);
      
      r.push_back((delta_im1+delta_i)*p[i]);
    }
    
    a.push_back(0.);
    b.push_back(1.);
    r.push_back(end);
    
    
    
    
    
    ;
    
    
    
    switch(cond){
        
      case end_condition::not_a_knot:{
        
        
        
        if(L>=2){
          double s_i= delta(0)/(delta(0)+delta(1));
          double r_i= (delta(0)+delta(1))/(delta(0)+delta(1)+delta(2));
          double s_f= delta(L-1)/(delta(L-2)+delta(L-1));
          double r_f= (delta(L-2)+delta(L-1))/(delta(L-3)+delta(L-2)+delta(L-1));
          
          b[0]= 0.;
          c[0]= -3*s_i*s_i+3*s_i;
          r[0]= -(1-s_i)*(1-s_i)*(1-s_i)*p[0]+p[1]-s_i*s_i*s_i*p[2];
          
          a[0]= (1-s_i)/s_i;
          b[1]= s_i/(1-s_i)*(1-r_i)-1;
          c[1]= s_i*r_i/(1-s_i);
          r[1]= (1-s_i)*(1-s_i)/s_i*p[0]+s_i*s_i/(1-s_i)*p[2];
          
          a[L-2]= s_f*r_f/(1-s_f);
          b[L-1]= s_f/(1-s_f)*(1-r_f)-1;
          c[L-1]= (1-s_f)/s_f;
          r[L-1]= s_f*s_f/(1-s_f)*p[L-2]+(1-s_f)*(1-s_f)/s_f*p[L];
          
          a[L-1]= -3*s_f*s_f+3*s_f;
          b[L]= 0.;
          r[L]= -s_f*s_f*s_f*p[L-2]+p[L-1]-(1-s_f)*(1-s_f)*(1-s_f)*p[L];
        }
        
        
        
        
        
        
        ;
      }
        
      case end_condition::clamped:{
        vector<point> x(L+1,point(p[0].dim()));
        
        if(solve_tridiagonal_system(a,b,c,r,x)!=0){
          _err= TRIDIAGONAL_NOT_SOLVABLE;
          return;
        }
        
        set_control_points(p[0],x,p[L]);
      }
        break;
        
      case end_condition::periodic:{
        
        
        
        for(size_t i= L-1;i!=0;i--){
          a[i]= a[i-1];
        }
        a[0]= delta(0)*delta(0)/(delta(L-2)+delta(L-1)+delta(0));
        a[1]= delta(1)*delta(1)/(delta(L-1)+delta(0)+delta(1));
        
        b.pop_back();
        b[0]= delta(0)*(delta(L-2)+delta(L-1))/(delta(L-2)+delta(L-1)+delta(0))
        +delta(L-1)*(delta(0)+delta(1))/(delta(L-1)+delta(0)+delta(1));
        b[1]= delta(1)*(delta(L-1)+delta(0))/(delta(L-1)+delta(0)+delta(1))
        +delta(0)*(delta(1)+delta(2))/(delta(0)+delta(1)+delta(2));
        b[L-1]= delta(L-1)*(delta(L-3)+delta(L-2))/(delta(L-3)+delta(L-2)+delta(L-1))
        +delta(L-2)*(delta(L-1)+delta(0))/(delta(L-2)+delta(L-1)+delta(0));
        
        c[0]= delta(L-1)*delta(L-1)/(delta(L-1)+delta(0)+delta(1));
        c[L-1]= delta(L-2)*delta(L-2)/(delta(L-2)+delta(L-1)+delta(0));
        
        r.pop_back();
        r[0]= (delta(L-1)+delta(0))*p[0];
        
        
        
        
        
        
        ;
        
        vector<point> x(L,point(p[0].dim()));
        
        if(solve_cyclic_tridiagonal_system(a,b,c,r,x)!=0){
          _err= TRIDIAGONAL_NOT_SOLVABLE;
          return;
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
      }
        break;
        
      default:
        _err= UNKNOWN_END_CONDITION;
        return;
    }
    
    
    
    ;
    insert_end_knots();
  }
}







void
cubic_spline::bezier_control_points(
                                    vector<point> &bezier_ctrl_points,
                                    vector<double> &knot
                                    )const{
  
  bezier_ctrl_points.clear();
  knot.clear();
  
  
  
  
  knot.push_back(_knot_sqnc[0]);
  for(size_t i= 1;i!=_knot_sqnc.size();i++){
    if(_knot_sqnc[i]> knot.back()){
      knot.push_back(_knot_sqnc[i]);
    }
  }
  
  
  
  
  ;
  
  
  
  if(knot.size()+2!=_ctrl_pts.size()){
    _err= UNABLE_TO_BREAK_INTO_BEZIER;
    return;
  }
  
  
  
  
  ;
  
  
  
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
  
  
  
  ;
  
  
}







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







void
cubic_spline::insert_knot(const double u){
  const int n= 3;
  
  size_t index= find_index_in_knot_sequence(u);
  if(index==SIZE_MAX){
    _err= OUT_OF_KNOT_RANGE;
  }
  if((index<n-1)||(int(_knot_sqnc.size())-n<index)){
    _err= NOT_INSERTABLE_KNOT;
  }
  
  vector<point> new_ctrl_pts;
  
  
  
  
  for(size_t i= 0;i<=index-n+1;i++){
    new_ctrl_pts.push_back(_ctrl_pts[i]);
  }
  
  
  
  ;
  
  
  
  for(size_t i= index-n+2;i<=index+1;i++){
    new_ctrl_pts.push_back(
                           _ctrl_pts[i-1]*(_knot_sqnc[i+n-1]-u)/(_knot_sqnc[i+n-1]-_knot_sqnc[i-1])
                           +_ctrl_pts[i]*(u-_knot_sqnc[i-1])/(_knot_sqnc[i+n-1]-_knot_sqnc[i-1]));
  }
  
  
  
  ;
  
  
  
  for(size_t i= index+2;i<=_knot_sqnc.size()-n+1;i++){
    new_ctrl_pts.push_back(_ctrl_pts[i-1]);
  }
  
  
  
  ;
  
  _knot_sqnc.insert(_knot_sqnc.begin()+index+1,u);
  _ctrl_pts.clear();
  _ctrl_pts= new_ctrl_pts;
}




void
cubic_spline::remove_knot(const double u){
  vector<double> IGESKnot;
  vector<point> forward;
  vector<point> backward;
  const int k= 4;
  
  
  
  
  IGESKnot.push_back(_knot_sqnc[0]);
  for(size_t i= 0;i!=_knot_sqnc.size();++i){
    IGESKnot.push_back(_knot_sqnc[i]);
  }
  IGESKnot.push_back(_knot_sqnc.back());
  
  
  
  ;
  
  size_t r= find_index_in_knot_sequence(u)+1;
  unsigned long v= find_multiplicity(u);
  
  
  
  
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
  
  
  
  ;
  
  
  
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
  
  
  
  ;
  
  
  
  for(size_t i= r-k+v-1;i<=r-1;i++){
    double mu= get_blending_ratio(IGESKnot,v,r,i);
    _ctrl_pts[i]= (1.-mu)*forward[i]+mu*backward[i];
  }
  for(size_t i= r;i<=_ctrl_pts.size()-2;i++){
    _ctrl_pts[i]= _ctrl_pts[i+1];
  }
  _ctrl_pts.pop_back();
  
  
  
  ;
  
  for(size_t i= r;i<=_knot_sqnc.size()-1;i++){
    _knot_sqnc[i-1]= _knot_sqnc[i];
  }
  _knot_sqnc.pop_back();
}







void
cubic_spline::write_curve_in_postscript(
                                        psf&ps_file,
                                        unsigned dense,
                                        float line_width,
                                        int x,int y,
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
  
#if 0
  for(size_t i= 2;i<_knot_sqnc.size()-3;i++){
    if(_knot_sqnc[i]<_knot_sqnc[i+1]){
      double knot= _knot_sqnc[i];
      double incr= (_knot_sqnc[i+1]-knot)/double(dense);
      double u= knot;
      for(size_t j= 0;j<=dense;j++){
        pt= magnification*evaluate(u,i);
        ps_file<<pt(x)<<"\t"<<pt(y)<<"\t"<<"lineto"<<endl;
        u+= incr;
      }
    }
  }
#endif
  
  ps_file<<"stroke"<<endl;
  ps_file.flags(previous_options);
}

void
cubic_spline::write_control_polygon_in_postscript(
                                                  psf&ps_file,
                                                  float line_width,
                                                  int x,int y,
                                                  float magnification
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
                                                 psf&ps_file,
                                                 float line_width,
                                                 int x,int y,
                                                 float magnification
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




double cubic_spline::delta(const long i)const{
  if((i<0)||(_knot_sqnc.size()-1)<=i){
    return 0.;
  }else{
    return _knot_sqnc[i+1]-_knot_sqnc[i];
  }
}




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
















