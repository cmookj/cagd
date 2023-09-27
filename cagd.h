/*2:*/
#line 187 "cagd.w"

#ifndef __COMPUTER_AIDED_GEOMETRIC_DESIGN_H_
#define __COMPUTER_AIDED_GEOMETRIC_DESIGN_H_

#include <cstddef> 
#include <vector> 
#include <list> 
#include <string> 
#include <cstdarg> 
#include <algorithm> 
#include <cmath> 
#include <exception> 
#include <iostream> 
#include <ostream> 
#include <fstream> 
#include <sstream> 
#include <ios> 
#include <iterator> 
#include <initializer_list> 

#include "mpoi.h"

#if defined (_WIN32) || defined (_WIN64)
#define NOMINMAX
#define M_PI       3.14159265358979323846
#define M_PI_2     1.57079632679489661923
#define M_PI_4     0.785398163397448309616
#endif

using namespace std;


namespace cagd{
const double EPS= 2.2204e-16;

using psf= ofstream;

/*20:*/
#line 4 "point.w"

struct point{
/*21:*/
#line 16 "point.w"

vector<double> _elem;




/*:21*/
#line 6 "point.w"

/*24:*/
#line 52 "point.w"

size_t dimension()const;
size_t dim()const;





/*:24*//*26:*/
#line 110 "point.w"

point()= delete;
point(const point&);
point(initializer_list<double> );
point(const double,const double,const double v3= 0.);
point(const size_t);
point(const size_t,const double*);
virtual~point();





/*:26*//*28:*/
#line 167 "point.w"

void operator= (const point&);
point&operator*= (const double);
point&operator/= (const double);
point&operator+= (const point&);
point&operator-= (const point&);




/*:28*//*32:*/
#line 273 "point.w"

const double&operator()(const size_t&)const;
double&operator()(const size_t&);




/*:32*//*34:*/
#line 297 "point.w"

double dist(const point&)const;




/*:34*//*36:*/
#line 317 "point.w"

string description()const;



/*:36*/
#line 7 "point.w"

};




/*:20*/
#line 224 "cagd.w"

/*40:*/
#line 12 "curve.w"

class curve{
protected:
vector<point> _ctrl_pts;

public:
typedef vector<point> ::iterator ctrlpt_itr;
typedef vector<point> ::const_iterator const_ctrlpt_itr;


/*43:*/
#line 62 "curve.w"

public:
virtual unsigned long dimension()const;
virtual unsigned long dim()const;
virtual unsigned long degree()const= 0;




/*:43*//*45:*/
#line 88 "curve.w"

point ctrl_pts(const size_t&)const;
size_t ctrl_pts_size()const;




/*:45*//*46:*/
#line 98 "curve.w"

virtual void write_curve_in_postscript(
psf&,
unsigned,float,
int x= 1,int y= 1,
float magnification= 1.)const= 0;

virtual void write_control_polygon_in_postscript(
psf&,
float,
int x= 1,int y= 1,
float magnification= 1.)const= 0;

virtual void write_control_points_in_postscript(
psf&,
float,
int x= 1,int y= 1,
float magnification= 1.)const= 0;




/*:46*//*47:*/
#line 123 "curve.w"

public:
virtual point evaluate(const double)const= 0;
virtual point derivative(const double)const= 0;




/*:47*//*49:*/
#line 160 "curve.w"

public:
curve();
curve(const vector<point> &);
curve(const list<point> &);
curve(const curve&);
virtual~curve();




/*:49*//*51:*/
#line 187 "curve.w"

public:
string description()const;




/*:51*//*53:*/
#line 203 "curve.w"

public:
curve&operator= (const curve&);
#line 1 "bezier.w"





/*:53*/
#line 22 "curve.w"

};




/*:40*/
#line 225 "cagd.w"

/*54:*/
#line 12 "bezier.w"

class bezier:public curve{
/*55:*/
#line 25 "bezier.w"

protected:
unsigned long _degree;





/*:55*/
#line 14 "bezier.w"

/*58:*/
#line 66 "bezier.w"

public:
unsigned long degree()const;




/*:58*//*60:*/
#line 102 "bezier.w"

public:
bezier();
bezier(const bezier&);
bezier(vector<point> );
bezier(list<point> );
virtual~bezier();




/*:60*//*62:*/
#line 123 "bezier.w"

public:
bezier&operator= (const bezier&);




/*:62*//*64:*/
#line 164 "bezier.w"

public:
point evaluate(const double)const;
point derivative(const double)const;




/*:64*//*66:*/
#line 223 "bezier.w"

public:
double curvature_at_zero()const;
vector<point> signed_curvature(const unsigned,
const double b= 0.,const double e= 1.)const;




/*:66*//*74:*/
#line 331 "bezier.w"

public:
void subdivision(const double,bezier&,bezier&)const;




/*:74*//*76:*/
#line 368 "bezier.w"

public:
void elevate_degree(unsigned long);


/*:76*//*80:*/
#line 477 "bezier.w"

public:
void reduce_degree(const unsigned long);


/*:80*//*82:*/
#line 586 "bezier.w"

void write_curve_in_postscript(
psf&,unsigned,float,int x= 1,int y= 2,
float magnification= 1.)const;

void write_control_polygon_in_postscript(
psf&,float,int x= 1,int y= 2,
float magnification= 1.)const;

void write_control_points_in_postscript(
psf&,float,int x= 1,int y= 2,
float magnification= 1.)const;
#line 1 "piecewise.w"






/*:82*/
#line 15 "bezier.w"

};




/*:54*/
#line 226 "cagd.w"

/*83:*/
#line 17 "piecewise.w"

class piecewise_bezier_curve:public curve{
protected:
vector<bezier> _curves;

public:
typedef vector<bezier> ::const_iterator const_curve_itr;
typedef vector<bezier> ::iterator curve_itr;

/*86:*/
#line 59 "piecewise.w"

public:
piecewise_bezier_curve();
piecewise_bezier_curve(const piecewise_bezier_curve&);
virtual~piecewise_bezier_curve();




/*:86*//*88:*/
#line 105 "piecewise.w"

public:
size_t count()const;
unsigned long dimension()const;
unsigned long dim()const;
unsigned long degree()const;




/*:88*//*90:*/
#line 124 "piecewise.w"

public:
void push_back(bezier);




/*:90*//*92:*/
#line 142 "piecewise.w"

public:
piecewise_bezier_curve&operator= (const piecewise_bezier_curve&);




/*:92*//*94:*/
#line 167 "piecewise.w"

public:
void elevate_degree(const unsigned long);
void reduce_degree(const unsigned long);




/*:94*//*96:*/
#line 218 "piecewise.w"

public:
point evaluate(const double)const;
point derivative(const double)const;




/*:96*//*98:*/
#line 334 "piecewise.w"

public:
void write_curve_in_postscript(
psf&,unsigned,float,int x= 1,int y= 2,
float magnification= 1.)const;

void write_control_polygon_in_postscript(
psf&,float,int x= 1,int y= 2,
float magnification= 1.)const;

void write_control_points_in_postscript(
psf&,float,int x= 1,int y= 2,
float magnification= 1.)const;




/*:98*/
#line 26 "piecewise.w"

};

/*:83*/
#line 227 "cagd.w"

/*108:*/
#line 11 "cubicspline.w"

class cubic_spline:public curve{
/*109:*/
#line 32 "cubicspline.w"

protected:
vector<double> _knot_sqnc;
mutable mpoi _mp;
size_t _kernel_id;

protected:
typedef vector<double> ::iterator knot_itr;
typedef vector<double> ::const_iterator const_knot_itr;




/*:109*/
#line 13 "cubicspline.w"

/*142:*/
#line 769 "cubicspline.w"

public:
enum class parametrization{
uniform,
chord_length,
centripetal,
function_spline
};

enum class end_condition{
clamped,
bessel,
quadratic,
not_a_knot,
natural,
periodic
};




/*:142*/
#line 14 "cubicspline.w"

/*112:*/
#line 90 "cubicspline.w"

public:
cubic_spline()= delete;
cubic_spline(const cubic_spline&);
cubic_spline(const vector<double> &,const vector<point> &);
virtual~cubic_spline();




/*:112*//*114:*/
#line 119 "cubicspline.w"

public:
unsigned long degree()const;
vector<double> knot_sequence()const;
vector<point> control_points()const;




/*:114*//*116:*/
#line 140 "cubicspline.w"

public:
cubic_spline&operator= (const cubic_spline&);




/*:116*//*118:*/
#line 161 "cubicspline.w"

public:
string description()const;



/*:118*//*120:*/
#line 248 "cubicspline.w"

public:
point evaluate(const double,unsigned long)const;
point evaluate(const double)const;




/*:120*//*122:*/
#line 301 "cubicspline.w"

public:
vector<point> evaluate_all(const unsigned)const;




/*:122*//*126:*/
#line 483 "cubicspline.w"

protected:
size_t find_index_in_sequence(
const double,
const vector<double> 
)const;
size_t find_index_in_knot_sequence(const double)const;




/*:126*//*128:*/
#line 519 "cubicspline.w"

public:
point derivative(const double)const;


/*:128*//*131:*/
#line 555 "cubicspline.w"

protected:
unsigned long find_multiplicity(const double,const_knot_itr)const;
unsigned long find_multiplicity(const double)const;




/*:131*//*133:*/
#line 577 "cubicspline.w"

protected:
double delta(const long)const;




/*:133*//*135:*/
#line 607 "cubicspline.w"

protected:
void insert_end_knots();




/*:135*//*137:*/
#line 636 "cubicspline.w"

protected:
void set_control_points(const point&,const vector<point> &,const point&);




/*:137*//*139:*/
#line 682 "cubicspline.w"

public:
vector<point> bezier_points_from_hermite_form(
const vector<point> &,
const vector<point> &);




/*:139*//*141:*/
#line 748 "cubicspline.w"

public:
vector<point> control_points_from_bezier_form(const vector<point> &);





/*:141*//*144:*/
#line 865 "cubicspline.w"

protected:
void _interpolate(
const vector<point> &,
parametrization,
end_condition,
const point&,const point&);




/*:144*//*146:*/
#line 922 "cubicspline.w"

public:
cubic_spline(const vector<point> &,
end_condition cond= end_condition::not_a_knot,
parametrization scheme= parametrization::centripetal);
cubic_spline(const vector<point> &,const point,const point,
parametrization scheme= parametrization::centripetal);




/*:146*//*155:*/
#line 1504 "cubicspline.w"

protected:
void solve_hform_tridiagonal_system_set_ctrl_pts(
const vector<double> &,
const vector<double> &,
const vector<double> &,
const vector<point> &,
const vector<point> &
);




/*:155*//*170:*/
#line 1970 "cubicspline.w"

protected:
void bezier_control_points(vector<point> &,vector<double> &)const;




/*:170*//*172:*/
#line 2005 "cubicspline.w"

protected:
vector<point> signed_curvature(int)const;




/*:172*//*177:*/
#line 2067 "cubicspline.w"

public:
void insert_knot(const double);




/*:177*//*179:*/
#line 2148 "cubicspline.w"

protected:
double get_blending_ratio(const vector<double> &,long,long,long);
double bracket(const vector<double> &,long,long,long);
double find_l(const vector<double> &,long,long);




/*:179*//*185:*/
#line 2232 "cubicspline.w"

public:
void remove_knot(const double);




/*:185*//*187:*/
#line 2338 "cubicspline.w"

public:
void write_curve_in_postscript(
psf&,unsigned,float,int x= 1,int y= 1,
float magnification= 1.0)const;

void write_control_polygon_in_postscript(
psf&,float,int x= 1,int y= 1,
float magnification= 1.0)const;

void write_control_points_in_postscript(
psf&,float,int x= 1,int y= 1,
float magnification= 1.0)const;
#line 323 "cagd.w"




/*:187*/
#line 15 "cubicspline.w"

};




/*:108*/
#line 228 "cagd.w"

/*5:*/
#line 277 "cagd.w"

psf create_postscript_file(string);
void close_postscript_file(psf&,bool);




/*:5*//*8:*/
#line 111 "math.w"

int invert_tridiagonal(
const vector<double> &,
const vector<double> &,
const vector<double> &,
vector<double> &
);

/*:8*//*11:*/
#line 176 "math.w"

vector<double> multiply(
const vector<double> &,
const vector<double> &);


/*:11*//*13:*/
#line 220 "math.w"

int solve_tridiagonal_system(
const vector<double> &,
const vector<double> &,
const vector<double> &,
const vector<point> &,
vector<point> &);


/*:13*//*18:*/
#line 366 "math.w"

int solve_cyclic_tridiagonal_system(
const vector<double> &,
const vector<double> &,
const vector<double> &,
const vector<point> &,
vector<point> &);

/*:18*//*30:*/
#line 214 "point.w"

point operator*(double,point);
point operator*(point,double);
point operator/(point,double);
point operator+(point,point);
point operator-(point,point);
point operator-(point);




/*:30*//*38:*/
#line 330 "point.w"

double dist(const point&,const point&);




/*:38*//*68:*/
#line 243 "bezier.w"

double signed_area(const point,const point,const point);


/*:68*//*78:*/
#line 385 "bezier.w"

unsigned long factorial(unsigned long);




/*:78*/
#line 229 "cagd.w"

}

#endif




/*:2*/
