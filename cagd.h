


#ifndef __COMPUTER_AIDED_GEOMETRIC_DESIGN_H_
#define __COMPUTER_AIDED_GEOMETRIC_DESIGN_H_

#include <cstddef>
#include <vector>
#include <list>
#include <string>
#include <cstdarg>
#include <algorithm>
#include <cmath>
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
  
  enum err_code{
    
    
    
    OUTPUT_FILE_OPEN_FAIL,
    
    
    
    
    
    
    
    DEGREE_MISMATCH,
    
    
    
    
    
    
    
    DEGREE_ELEVATION_FAIL,
    
    
    
    
    
    
    
    DEGREE_REDUCTION_FAIL,
    
    
    
    
    
    
    OUT_OF_KNOT_RANGE,
    
    
    
    
    
    
    
    UNKNOWN_PARAMETRIZATION,
    
    
    
    
    
    
    
    TRIDIAGONAL_NOT_SOLVABLE,
    UNKNOWN_END_CONDITION,
    
    
    
    
    
    
    
    UNABLE_TO_BREAK_INTO_BEZIER,
    
    
    
    
    
    NOT_INSERTABLE_KNOT,
    
    
    
    
    NO_ERR
  };
  
  typedef ofstream psf;
  
  
  
  
  struct point{
    
    
    
    vector<double> _elem;
    
    
    
    
    
    
    
    
    
    
    size_t dimension()const;
    size_t dim()const;
    
    
    
    
    
    
    
    
    point()= delete;
    point(const point&);
    point(initializer_list<double> );
    point(const double,const double,const double v3= 0.);
    point(const size_t);
    point(const size_t,const double*);
    virtual~point();
    
    
    
    
    
    
    
    
    void operator= (const point&);
    point&operator*= (const double);
    point&operator/= (const double);
    point&operator+= (const point&);
    point&operator-= (const point&);
    
    
    
    
    
    
    
    const double&operator()(const size_t&)const;
    double&operator()(const size_t&);
    
    
    
    
    
    
    
    double dist(const point&)const;
    
    
    
    
    
    
    
    string description()const;
    
    
    
    
    
    
  };
  
  
  
  
  
  
  
  
  
  
  class curve{
  protected:
    vector<point> _ctrl_pts;
    mutable cagd::err_code _err;
    
  public:
    typedef vector<point> ::iterator ctrlpt_itr;
    typedef vector<point> ::const_iterator const_ctrlpt_itr;
    
    
    
    
    
  public:
    virtual unsigned long dimension()const;
    virtual unsigned long dim()const;
    virtual unsigned long degree()const= 0;
    
    
    
    
    
    
    
    point ctrl_pts(const size_t&)const;
    size_t ctrl_pts_size()const;
    
    
    
    
    
    
    
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
    
    
    
    
  public:
    virtual point evaluate(const double)const= 0;
    virtual point derivative(const double)const= 0;
    
    
    
    
    
    
    
  public:
    curve();
    curve(const vector<point> &);
    curve(const list<point> &);
    curve(const curve&);
    virtual~curve();
    
    
    
    
    
    
    
  public:
    string description()const;
    
    
    
    
    
    
    
  public:
    curve&operator= (const curve&);
    
    
    
    
    
    
    
    
    
  };
  
  
  
  
  
  
  
  
  
  
  class bezier:public curve{
    
    
    
  protected:
    unsigned long _degree;
    
    
    
    
    
    
    
    
    
    
    
  public:
    unsigned long degree()const;
    
    
    
    
    
    
    
  public:
    bezier();
    bezier(const bezier&);
    bezier(vector<point> );
    bezier(list<point> );
    virtual~bezier();
    
    
    
    
    
    
    
  public:
    bezier&operator= (const bezier&);
    
    
    
    
  public:
    point evaluate(const double)const;
    point derivative(const double)const;
    
    
    
    
    
    
    
  public:
    double curvature_at_zero()const;
    vector<point> signed_curvature(const unsigned,
                                   const double b= 0.,const double e= 1.)const;
    
    
    
    
    
    
    
  public:
    void subdivision(const double,bezier&,bezier&)const;
    
    
    
    
    
    
    
  public:
    void elevate_degree(unsigned long);
    
    
    
    
  public:
    void reduce_degree(const unsigned long);
    
    
    
    
    void write_curve_in_postscript(
                                   psf&,unsigned,float,int x= 1,int y= 2,
                                   float magnification= 1.)const;
    
    void write_control_polygon_in_postscript(
                                             psf&,float,int x= 1,int y= 2,
                                             float magnification= 1.)const;
    
    void write_control_points_in_postscript(
                                            psf&,float,int x= 1,int y= 2,
                                            float magnification= 1.)const;
    
    
    
    
    
    
    
    
    
    
  };
  
  
  
  
  
  
  
  
  
  
  class piecewise_bezier_curve:public curve{
  protected:
    vector<bezier> _curves;
    
  public:
    typedef vector<bezier> ::const_iterator const_curve_itr;
    typedef vector<bezier> ::iterator curve_itr;
    
    
    
    
  public:
    piecewise_bezier_curve();
    piecewise_bezier_curve(const piecewise_bezier_curve&);
    virtual~piecewise_bezier_curve();
    
    
    
    
    
    
    
  public:
    size_t count()const;
    unsigned long dimension()const;
    unsigned long dim()const;
    unsigned long degree()const;
    
    
    
    
    
    
    
  public:
    void push_back(bezier);
    
    
    
    
    
    
    
  public:
    piecewise_bezier_curve&operator= (const piecewise_bezier_curve&);
    
    
    
    
    
    
    
  public:
    void elevate_degree(const unsigned long);
    void reduce_degree(const unsigned long);
    
    
    
    
    
    
    
  public:
    point evaluate(const double)const;
    point derivative(const double)const;
    
    
    
    
    
    
    
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
    
    
    
    
    
    
    
  };
  
  
  
  
  
  
  
  class cubic_spline:public curve{
    
    
    
  protected:
    vector<double> _knot_sqnc;
    mutable mpoi _mp;
    size_t _kernel_id;
    
  protected:
    typedef vector<double> ::iterator knot_itr;
    typedef vector<double> ::const_iterator const_knot_itr;
    
    
    
    
    
    
    
    
    
    
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
    
    
    
    
    
    
    
    
    
    
  public:
    cubic_spline()= delete;
    cubic_spline(const cubic_spline&);
    cubic_spline(const vector<double> &,const vector<point> &);
    virtual~cubic_spline();
    
    
    
    
    
    
    
  public:
    unsigned long degree()const;
    vector<double> knot_sequence()const;
    vector<point> control_points()const;
    
    
    
    
    
    
    
  public:
    cubic_spline&operator= (const cubic_spline&);
    
    
    
    
    
    
    
  public:
    string description()const;
    
    
    
    
    
    
    
  public:
    point evaluate(const double,unsigned long)const;
    point evaluate(const double)const;
    
    
    
    
    
    
    
  public:
    vector<point> evaluate_all(const unsigned)const;
    
    
    
    
    
    
    
  protected:
    size_t find_index_in_sequence(
                                  const double,
                                  const vector<double> 
                                  )const;
    size_t find_index_in_knot_sequence(const double)const;
    
    
    
    
    
    
    
  public:
    point derivative(const double)const;
    
    
    
    
    
  protected:
    unsigned long find_multiplicity(const double,const_knot_itr)const;
    unsigned long find_multiplicity(const double)const;
    
    
    
    
    
    
    
  protected:
    double delta(const long)const;
    
    
    
    
    
    
    
  protected:
    void insert_end_knots();
    
    
    
    
    
    
    
  protected:
    void set_control_points(const point&,const vector<point> &,const point&);
    
    
    
    
    
    
    
  protected:
    void _interpolate(const vector<point> &,
                      parametrization,
                      end_condition,
                      const point&,
                      const point&);
    
    
    
    
    
  public:
    cubic_spline(const vector<point> &,
                 end_condition cond= end_condition::not_a_knot,
                 parametrization scheme= parametrization::chord_length);
    cubic_spline(const vector<point> &,const point,const point,
                 parametrization scheme= parametrization::chord_length);
    
    
    
    
    
    
    
  protected:
    void bezier_control_points(vector<point> &,vector<double> &)const;
    
    
    
    
    
    
    
  protected:
    vector<point> signed_curvature(int)const;
    
    
    
    
    
    
    
  public:
    void insert_knot(const double);
    
    
    
    
    
    
    
  protected:
    double get_blending_ratio(const vector<double> &,long,long,long);
    double bracket(const vector<double> &,long,long,long);
    double find_l(const vector<double> &,long,long);
    
    
    
    
    
    
    
  public:
    void remove_knot(const double);
    
    
    
    
    
    
    
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
    
    
    
    
    
    
    
    
    
    
    
    
    
  };
  
  
  
  
  
  
  
  
  
  
  psf create_postscript_file(string);
  void close_postscript_file(psf&,bool);
  
  
  
  
  
  
  
  point operator*(double,point);
  point operator*(point,double);
  point operator/(point,double);
  point operator+(point,point);
  point operator-(point,point);
  point operator-(point);
  
  
  
  
  
  
  
  double dist(const point&,const point&);
  
  
  
  
  
  
  
  double signed_area(const point,const point,const point);
  
  
  
  
  
  unsigned long factorial(unsigned long);
  
  
  
  
  
  
  
  int invert_tridiagonal(
                         const vector<double> &,
                         const vector<double> &,
                         const vector<double> &,
                         vector<double> &
                         );
  
  
  
  
  vector<double> multiply(
                          const vector<double> &,
                          const vector<double> &);
  
  
  
  
  
  int solve_tridiagonal_system(
                               const vector<double> &,
                               const vector<double> &,
                               const vector<double> &,
                               const vector<point> &,
                               vector<point> &);
  
  
  
  
  
  int solve_cyclic_tridiagonal_system(
                                      const vector<double> &,
                                      const vector<double> &,
                                      const vector<double> &,
                                      const vector<point> &,
                                      vector<point> &);
  
  
  
  
}

#endif





