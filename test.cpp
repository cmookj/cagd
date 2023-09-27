/*6:*/
#line 286 "cagd.w"

#include <iostream> 
#include <iomanip> 
#include <chrono> 
#include "cagd.h"

using namespace cagd;
using namespace std::chrono;

void print_title(const char*);

void print_title(const char*str){
cout<<endl<<endl;
char prev= cout.fill('-');

cout<<">> "<<setw(68)<<'-'<<endl;
cout<<">>"<<endl;
cout<<">>  TEST: "<<str<<endl;
cout<<">>"<<endl;
cout<<">> "<<setw(68)<<'-'<<endl;
cout.fill(prev);
}

int main(int argc,char*argv[]){
/*9:*/
#line 130 "math.w"

print_title("inversion of a tridiagonal matrix");
{
vector<double> alpha(3,0.);
alpha[0]= 3.;alpha[1]= 2.;alpha[2]= 1.;

vector<double> beta(4,0.);
beta[0]= 1.;beta[1]= 4.;beta[2]= 3.;beta[3]= 3.;

vector<double> gamma(3,0.);
gamma[0]= 4.;gamma[1]= 1.;gamma[2]= 4.;

vector<double> inv(4*4,0.);
cagd::invert_tridiagonal(alpha,beta,gamma,inv);

for(size_t i= 0;i!=4;i++){
for(size_t j= 0;j!=4;j++){
cout<<inv[i*4+j]<<"  ";
}
cout<<endl;
}
}


/*:9*//*19:*/
#line 404 "math.w"

print_title("cyclic tridiagonal system");
{
vector<double> alpha(7,1.);
vector<double> beta(7,2.);
vector<double> gamma(7,1.);

vector<point> b(7,point(2));
b[0]= point({1.,7.});
b[1]= point({2.,6.});
b[2]= point({3.,5.});
b[3]= point({4.,4.});
b[4]= point({5.,3.});
b[5]= point({6.,2.});
b[6]= point({7.,1.});

vector<point> x(7,point(2));

solve_cyclic_tridiagonal_system(alpha,beta,gamma,b,x);

cout<<"x = "<<endl;
for(size_t i= 0;i!=7;i++){
cout<<"[  "<<x[i](1)<<" ,  "<<x[i](2)<<"  ]"<<endl;
}
}
#line 1 "point.w"
/*:19*//*39:*/
#line 339 "point.w"

print_title("operations on point type");
{
point p0(3);
cout<<"Dimension of p0 = "<<p0.dim()<<" : ";
for(size_t i= 0;i!=p0.dim();i++){
cout<<p0(i+1)<<"  ";
}
cout<<"\n\n";

point p1({1.,2.,3.});
cout<<"Dimension of p1 = "<<p1.dim()<<" : ";
for(size_t i= 0;i!=p1.dim();i++){
cout<<p1(i+1)<<"  ";
}
cout<<"\n\n";

point p2({2.,4.,6.});
point p3= .5*p1+.5*p2;
cout<<"p3 = .5(1,2,3) + .5(2,4,6) = ";
for(size_t i= 0;i!=p3.dim();i++){
cout<<p3(i+1)<<"  ";
}
cout<<"\n\n";

cout<<"Distance from p0 to p1 = "<<dist(p0,p1)<<"\n";
cout<<"  (It should be 3.741657387)\n\n";
}
#line 1 "curve.w"
/*:39*//*99:*/
#line 363 "piecewise.w"

print_title("piecewise bezier curve");
{
piecewise_bezier_curve curves;
vector<point> ctrl_pts;

/*100:*/
#line 397 "piecewise.w"

ctrl_pts= {
point({183,416}),point({184,415}),point({185,413}),
point({186,412}),point({186,411}),point({186,409}),
point({184,405}),point({180,401})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({180,401}),point({176,397}),point({172,394}),
point({154,359}),point({140,333}),point({126,312})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({126,312}),point({103,278}),point({79,252}),point({53,235})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({53,235}),point({46,230}),point({42,228}),point({37,231})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({37,231}),point({37,223}),point({39,236}),point({43,243}),
point({45,246}),point({62,266}),point({76,288}),point({89,313})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({89,313}),point({102,339}),point({115,369}),point({127,404})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({127,404}),point({117,400}),point({107,395}),point({97,392})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({97,392}),point({86,388}),point({81,386}),point({74,386}),
point({67,388}),point({57,394})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({57,394}),point({46,399}),point({41,403}),point({42,406}),
point({43,407}),point({44,407})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({44,407}),point({46,408}),point({50,409}),point({68,409}),
point({81,410}),point({94,413})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({94,413}),point({106,416}),point({115,419}),
point({123,425}),point({127,428}),point({135,439}),
point({139,441}),point({143,441})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({143,441}),point({148,441}),point({156,438}),
point({169,429}),point({175,423}),point({183,416})
};
curves.push_back(bezier(ctrl_pts));


/*:100*/
#line 369 "piecewise.w"
;
/*101:*/
#line 469 "piecewise.w"

ctrl_pts= {
point({545,226}),point({547,225}),point({550,223}),
point({554,217}),point({555,215}),point({555,211}),
point({547,208}),point({532,206})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({532,206}),point({517,204}),point({501,203}),point({482,203})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({482,203}),point({460,203}),point({430,217}),point({392,247})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({392,247}),point({329,299}),point({265,366}),point({230,410})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({230,410}),point({230,349}),point({230,288}),point({230,227})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({230,227}),point({230,215}),point({228,204}),point({224,193})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({224,193}),point({219,178}),point({211,171}),
point({196,171}),point({190,176}),point({174,201}),
point({169,208}),point({169,209})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({169,209}),point({160,217}),point({152,226}),
point({135,243}),point({131,248}),point({131,250})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({131,250}),point({133,252}),point({135,253}),
point({140,253}),point({149,251}),point({163,246})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({163,246}),point({170,243}),point({175,242}),
point({188,242}),point({192,247}),point({192,258})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({192,258}),point({192,342}),point({192,426}),point({192,509})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({192,509}),point({192,515}),point({192,519}),point({189,525}),
point({186,526}),point({175,526}),point({166,523}),point({154,517})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({154,517}),point({143,511}),point({134,508}),point({124,508}),
point({117,510}),point({107,512})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({107,512}),point({98,515}),point({93,518}),point({93,520})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({93,520}),point({93,522}),point({95,523}),point({103,526}),
point({107,527}),point({110,527})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({110,527}),point({122,530}),point({134,534}),point({154,541}),
point({165,545}),point({180,552}),point({183,555}),point({188,560})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({188,560}),point({192,566}),point({196,568}),point({204,568}),
point({213,562}),point({241,537}),point({248,529}),point({248,524})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({248,524}),point({248,521}),point({246,517}),point({238,506}),
point({235,502}),point({235,501})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({235,501}),point({231,481}),point({230,457}),point({230,437})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({230,437}),point({232.5,433}),point({235,429})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({235,429}),point({256,452}),point({280,486}),point({295,515})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({295,515}),point({295,519}),point({296,523}),point({298,530}),
point({301,531}),point({312,531}),point({321,528}),point({334,520})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({334,520}),point({347,512}),point({354,505}),point({354,499})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({354,499}),point({354,496}),point({351,493}),point({340,487}),
point({335,484}),point({330,482})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({330,482}),point({304,461}),point({274,437}),point({243,416})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({243,416}),point({283,370}),point({342,325}),point({413,283})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({413,283}),point({456,262}),point({523,235}),point({545,226})
};
curves.push_back(bezier(ctrl_pts));

/*:101*/
#line 370 "piecewise.w"
;
/*102:*/
#line 620 "piecewise.w"

ctrl_pts= {
point({245,638}),point({249,633}),point({251,625}),point({251,614})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({251,614}),point({251,603}),point({247,597}),point({240,597})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({240,597}),point({219,608}),point({164,651}),point({151,666})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({151,666}),point({152,667}),point({153,667}),point({155,668}),
point({156,668}),point({157,668})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({157,668}),point({189,668}),point({224,655}),point({245,638})
};
curves.push_back(bezier(ctrl_pts));


/*:102*/
#line 371 "piecewise.w"
;
/*103:*/
#line 648 "piecewise.w"

ctrl_pts= {
point({535,598}),point({537,596}),point({539,593}),point({539,585}),
point({537,581}),point({529,568}),point({526,564}),point({526,564})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({526,564}),point({526,507}),point({526,451}),point({526,394})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({526,394}),point({527,379}),point({528,364}),point({529,348})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({529,348}),point({528,331}),point({521,312}),point({510,307})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({510,307}),point({502,307}),point({496,313}),point({489,334}),
point({488,344}),point({487,357})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({487,357}),point({459,356}),point({418,352}),point({408,347})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({408,347}),point({408,335}),point({404,330}),point({396,330})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({396,330}),point({382,336}),point({369,360}),point({366,377})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({366,377}),point({367,390}),point({371,421}),point({372,440})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({372,440}),point({372,435}),point({372,439}),point({372,554})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({372,554}),point({372,564}),point({360,594}),point({355,603}),
point({353,617}),point({358,617})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({358,617}),point({365,617}),point({372,615}),point({385,607}),
point({392,603}),point({398,600})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({398,600}),point({417,603}),point({443,609}),point({463,613})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({463,613}),point({470,618}),point({480,629}),point({487,632})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({487,632}),point({499,627}),point({520,611}),point({535,598})
};
curves.push_back(bezier(ctrl_pts));

/*:103*/
#line 372 "piecewise.w"
;
/*104:*/
#line 728 "piecewise.w"

ctrl_pts= {
point({487,378}),point({487,444}),point({487,510}),point({487,576})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({487,576}),point({487,583}),point({486,587}),point({484,594}),
point({480,597}),point({473,597})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({473,597}),point({454,596}),point({428,590}),point({408,584})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({408,584}),point({408,553}),point({408,523}),point({408,492})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({408,492}),point({420,494}),point({447,504}),point({464,507})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({464,507}),point({475,507}),point({481,504}),point({481,489}),
point({471,482}),point({450,478})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({450,478}),point({436,475}),point({422,473}),point({408,473})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({408,473}),point({408,438}),point({408,403}),point({408,368})
};
curves.push_back(bezier(ctrl_pts));

ctrl_pts= {
point({408,368}),point({432,372}),point({462,376}),point({487,378})
};
curves.push_back(bezier(ctrl_pts));


/*:104*/
#line 373 "piecewise.w"
;

psf file= create_postscript_file("untouched.ps");
curves.write_curve_in_postscript(file,100,1.);
curves.write_control_polygon_in_postscript(file,1.);
curves.write_control_points_in_postscript(file,1.);
close_postscript_file(file,true);

unsigned long deg= curves.degree();
curves.elevate_degree(deg);
file= create_postscript_file("degree_elevated.ps");
curves.write_curve_in_postscript(file,100,1.);
curves.write_control_polygon_in_postscript(file,1.);
curves.write_control_points_in_postscript(file,1.);
close_postscript_file(file,true);

curves.reduce_degree(3);
file= create_postscript_file("degree_reduced.ps");
curves.write_curve_in_postscript(file,100,1.);
curves.write_control_polygon_in_postscript(file,1.);
curves.write_control_points_in_postscript(file,1.);
close_postscript_file(file,true);
}

/*:99*//*157:*/
#line 1671 "cubicspline.w"

print_title("cubic spline interpolation");
{
/*158:*/
#line 1722 "cubicspline.w"

vector<point> p;
for(unsigned i= 0;i!=11;i++){
point datum= point({0,0});
datum(1)= static_cast<double> (i)+M_PI;
datum(2)= sin(datum(1))+3.;
p.push_back(datum);
}

/*:158*/
#line 1674 "cubicspline.w"
;
cubic_spline crv(p,
cubic_spline::end_condition::not_a_knot,
cubic_spline::parametrization::function_spline);

psf file= create_postscript_file("sine_curve.ps");
crv.write_curve_in_postscript(file,100,1.,1,2,40.);
crv.write_control_polygon_in_postscript(file,1.,1,2,40.);
crv.write_control_points_in_postscript(file,1.,1,2,40.);
close_postscript_file(file,true);

/*159:*/
#line 1736 "cubicspline.w"

double matlab_bench[]= {
3.0000,2.7308,2.4983,2.3062,2.1585,2.0592,2.0122,2.0214,
2.0907,2.2211,2.4018,2.6190,2.8589,3.1075,3.3501,3.5715,
3.7568,3.8928,3.9742,3.9974,3.9589,3.8578,3.7032,3.5065,
3.2794,3.0342,2.7858,2.5502,2.3430,2.1785,2.0643,2.0063,
2.0106,2.0804,2.2073,2.3802,2.5879,2.8193,3.0632,3.3085,
3.5440};
double interpolated[41];
double u= M_PI;
double err= 0.;
for(size_t i= 0;i!=41;i++){
double y= crv.evaluate(u)(2);
interpolated[i]= y;
u+= 0.25;
err+= (interpolated[i]-matlab_bench[i])*(interpolated[i]-matlab_bench[i]);
}
err/= 41;
err= sqrt(err);
cout<<"RMS error of interpolation (compared with MATLAB) = "<<err
<<endl;

/*:159*/
#line 1685 "cubicspline.w"
;

cout<<crv.description();

const unsigned steps= 1000;
vector<double> knots= crv.knot_sequence();
double du= (knots[knots.size()-3]-knots[2])/double(steps-1);
double us[steps];
vector<point> crv_pts_s(steps,point(2));

for(size_t i= 0;i!=steps;i++){
us[i]= knots[2]+i*du;
}

auto t0= high_resolution_clock::now();
for(size_t i= 0;i!=steps;i++){
crv_pts_s[i]= crv.evaluate(us[i]);
}
auto t1= high_resolution_clock::now();
cout<<"Serial computation : "
<<duration_cast<milliseconds> (t1-t0).count()<<" msec\n";

t0= high_resolution_clock::now();
vector<point> crv_pts_p= crv.evaluate_all(steps);
t1= high_resolution_clock::now();
cout<<"Parallel computation : "
<<duration_cast<milliseconds> (t1-t0).count()<<" msec\n";

double diff= 0.;
for(size_t i= 0;i!=steps;i++){
diff+= dist(crv_pts_s[i],crv_pts_p[i]);
}
cout<<"Mean difference between serial and parallel computation = "
<<diff/double(steps)<<endl;
}


/*:157*//*162:*/
#line 1799 "cubicspline.w"

print_title("cubic spline interpolation: degenerate case");
{
vector<point> p;
p.push_back(point({10,10}));
p.push_back(point({200,200}));
cubic_spline crv(p);

psf file= create_postscript_file("line.ps");
crv.write_curve_in_postscript(file,30,1.,1,2,1.);
crv.write_control_polygon_in_postscript(file,1.,1,2,1.);
crv.write_control_points_in_postscript(file,1.,1,2,1.);
close_postscript_file(file,true);
}

/*:162*//*164:*/
#line 1826 "cubicspline.w"

print_title("periodic spline interpolation");
{
vector<point> p;
double r= 100.;
cout<<"Data points:"<<endl;
for(size_t i= 0;i!=7;i++){
p.push_back(point({r*cos(2*M_PI/6*i)+200.,
r*sin(2*M_PI/6*i)+200.}));
cout<<" ( "<<r*cos(2*M_PI/6*i)+200.<<" , "<<
r*sin(2*M_PI/6*i)+200.<<" )"<<endl;
}

cubic_spline crv(p,cubic_spline::end_condition::periodic,
cubic_spline::parametrization::centripetal);

psf file= create_postscript_file("periodic.ps");
crv.write_curve_in_postscript(file,200,1.,1,2,1.);
crv.write_control_polygon_in_postscript(file,1.,1,2,1.);
crv.write_control_points_in_postscript(file,1.,1,2,1.);
close_postscript_file(file,true);

cout<<crv.description();

const unsigned steps= 1000;
vector<double> knots= crv.knot_sequence();
double du= (knots[knots.size()-3]-knots[2])/double(steps-1);
double us[steps];
vector<point> crv_pts_s(steps,point(2));

for(size_t i= 0;i!=steps;i++){
us[i]= knots[2]+i*du;
}

auto t0= high_resolution_clock::now();
for(size_t i= 0;i!=steps;i++){
crv_pts_s[i]= crv.evaluate(us[i]);
}
auto t1= high_resolution_clock::now();
cout<<"Serial computation : "
<<duration_cast<milliseconds> (t1-t0).count()<<" msec\n";

t0= high_resolution_clock::now();
vector<point> crv_pts_p= crv.evaluate_all(steps);
t1= high_resolution_clock::now();
cout<<"Parallel computation : "
<<duration_cast<milliseconds> (t1-t0).count()<<" msec\n";

double err= 0.;
for(size_t i= 0;i!=steps;i++){
err+= dist(crv_pts_s[i],crv_pts_p[i]);
}
cout<<"Mean difference between serial and parallel computation = "
<<err/double(steps)<<endl;
}

/*:164*/
#line 310 "cagd.w"
;
return 0;
}




#line 1 "math.w"
/*:6*/
