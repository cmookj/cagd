/*6:*/
#line 292 "./cagd.w"

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
cout<<
"================================================================================\n"<<
"                                                                                \n"<<
"                     T E S T  :  C A G D    L I B R A R Y                       \n"<<
"                                                                                \n"<<
"================================================================================\n\n";

/*26:*/
#line 339 "./point.w"

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
#line 1 "./curve.w"
/*:26*//*90:*/
#line 363 "./piecewise.w"

print_title("piecewise bezier curve");
{
piecewise_bezier_curve curves;
vector<point> ctrl_pts;

/*91:*/
#line 397 "./piecewise.w"

ctrl_pts.push_back(point({183,416}));
ctrl_pts.push_back(point({184,415}));
ctrl_pts.push_back(point({185,413}));
ctrl_pts.push_back(point({186,412}));
ctrl_pts.push_back(point({186,411}));
ctrl_pts.push_back(point({186,409}));
ctrl_pts.push_back(point({184,405}));
ctrl_pts.push_back(point({180,401}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({180,401}));
ctrl_pts.push_back(point({176,397}));
ctrl_pts.push_back(point({172,394}));
ctrl_pts.push_back(point({154,359}));
ctrl_pts.push_back(point({140,333}));
ctrl_pts.push_back(point({126,312}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({126,312}));
ctrl_pts.push_back(point({103,278}));
ctrl_pts.push_back(point({79,252}));
ctrl_pts.push_back(point({53,235}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({53,235}));
ctrl_pts.push_back(point({46,230}));
ctrl_pts.push_back(point({42,228}));
ctrl_pts.push_back(point({37,231}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({37,231}));
ctrl_pts.push_back(point({37,223}));
ctrl_pts.push_back(point({39,236}));
ctrl_pts.push_back(point({43,243}));
ctrl_pts.push_back(point({45,246}));
ctrl_pts.push_back(point({62,266}));
ctrl_pts.push_back(point({76,288}));
ctrl_pts.push_back(point({89,313}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({89,313}));
ctrl_pts.push_back(point({102,339}));
ctrl_pts.push_back(point({115,369}));
ctrl_pts.push_back(point({127,404}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({127,404}));
ctrl_pts.push_back(point({117,400}));
ctrl_pts.push_back(point({107,395}));
ctrl_pts.push_back(point({97,392}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({97,392}));
ctrl_pts.push_back(point({86,388}));
ctrl_pts.push_back(point({81,386}));
ctrl_pts.push_back(point({74,386}));
ctrl_pts.push_back(point({67,388}));
ctrl_pts.push_back(point({57,394}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({57,394}));
ctrl_pts.push_back(point({46,399}));
ctrl_pts.push_back(point({41,403}));
ctrl_pts.push_back(point({42,406}));
ctrl_pts.push_back(point({43,407}));
ctrl_pts.push_back(point({44,407}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({44,407}));
ctrl_pts.push_back(point({46,408}));
ctrl_pts.push_back(point({50,409}));
ctrl_pts.push_back(point({68,409}));
ctrl_pts.push_back(point({81,410}));
ctrl_pts.push_back(point({94,413}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({94,413}));
ctrl_pts.push_back(point({106,416}));
ctrl_pts.push_back(point({115,419}));
ctrl_pts.push_back(point({123,425}));
ctrl_pts.push_back(point({127,428}));
ctrl_pts.push_back(point({135,439}));
ctrl_pts.push_back(point({139,441}));
ctrl_pts.push_back(point({143,441}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({143,441}));
ctrl_pts.push_back(point({148,441}));
ctrl_pts.push_back(point({156,438}));
ctrl_pts.push_back(point({169,429}));
ctrl_pts.push_back(point({175,423}));
ctrl_pts.push_back(point({183,416}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();


/*:91*/
#line 369 "./piecewise.w"
;
/*92:*/
#line 517 "./piecewise.w"

ctrl_pts.push_back(point({545,226}));
ctrl_pts.push_back(point({547,225}));
ctrl_pts.push_back(point({550,223}));
ctrl_pts.push_back(point({554,217}));
ctrl_pts.push_back(point({555,215}));
ctrl_pts.push_back(point({555,211}));
ctrl_pts.push_back(point({547,208}));
ctrl_pts.push_back(point({532,206}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({532,206}));
ctrl_pts.push_back(point({517,204}));
ctrl_pts.push_back(point({501,203}));
ctrl_pts.push_back(point({482,203}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({482,203}));
ctrl_pts.push_back(point({460,203}));
ctrl_pts.push_back(point({430,217}));
ctrl_pts.push_back(point({392,247}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({392,247}));
ctrl_pts.push_back(point({329,299}));
ctrl_pts.push_back(point({265,366}));
ctrl_pts.push_back(point({230,410}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({230,410}));
ctrl_pts.push_back(point({230,349}));
ctrl_pts.push_back(point({230,288}));
ctrl_pts.push_back(point({230,227}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({230,227}));
ctrl_pts.push_back(point({230,215}));
ctrl_pts.push_back(point({228,204}));
ctrl_pts.push_back(point({224,193}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({224,193}));
ctrl_pts.push_back(point({219,178}));
ctrl_pts.push_back(point({211,171}));
ctrl_pts.push_back(point({196,171}));
ctrl_pts.push_back(point({190,176}));
ctrl_pts.push_back(point({174,201}));
ctrl_pts.push_back(point({169,208}));
ctrl_pts.push_back(point({169,209}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({169,209}));
ctrl_pts.push_back(point({160,217}));
ctrl_pts.push_back(point({152,226}));
ctrl_pts.push_back(point({135,243}));
ctrl_pts.push_back(point({131,248}));
ctrl_pts.push_back(point({131,250}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({131,250}));
ctrl_pts.push_back(point({133,252}));
ctrl_pts.push_back(point({135,253}));
ctrl_pts.push_back(point({140,253}));
ctrl_pts.push_back(point({149,251}));
ctrl_pts.push_back(point({163,246}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({163,246}));
ctrl_pts.push_back(point({170,243}));
ctrl_pts.push_back(point({175,242}));
ctrl_pts.push_back(point({188,242}));
ctrl_pts.push_back(point({192,247}));
ctrl_pts.push_back(point({192,258}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({192,258}));
ctrl_pts.push_back(point({192,342}));
ctrl_pts.push_back(point({192,426}));
ctrl_pts.push_back(point({192,509}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({192,509}));
ctrl_pts.push_back(point({192,515}));
ctrl_pts.push_back(point({192,519}));
ctrl_pts.push_back(point({189,525}));
ctrl_pts.push_back(point({186,526}));
ctrl_pts.push_back(point({175,526}));
ctrl_pts.push_back(point({166,523}));
ctrl_pts.push_back(point({154,517}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({154,517}));
ctrl_pts.push_back(point({143,511}));
ctrl_pts.push_back(point({134,508}));
ctrl_pts.push_back(point({124,508}));
ctrl_pts.push_back(point({117,510}));
ctrl_pts.push_back(point({107,512}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({107,512}));
ctrl_pts.push_back(point({98,515}));
ctrl_pts.push_back(point({93,518}));
ctrl_pts.push_back(point({93,520}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({93,520}));
ctrl_pts.push_back(point({93,522}));
ctrl_pts.push_back(point({95,523}));
ctrl_pts.push_back(point({103,526}));
ctrl_pts.push_back(point({107,527}));
ctrl_pts.push_back(point({110,527}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({110,527}));
ctrl_pts.push_back(point({122,530}));
ctrl_pts.push_back(point({134,534}));
ctrl_pts.push_back(point({154,541}));
ctrl_pts.push_back(point({165,545}));
ctrl_pts.push_back(point({180,552}));
ctrl_pts.push_back(point({183,555}));
ctrl_pts.push_back(point({188,560}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({188,560}));
ctrl_pts.push_back(point({192,566}));
ctrl_pts.push_back(point({196,568}));
ctrl_pts.push_back(point({204,568}));
ctrl_pts.push_back(point({213,562}));
ctrl_pts.push_back(point({241,537}));
ctrl_pts.push_back(point({248,529}));
ctrl_pts.push_back(point({248,524}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({248,524}));
ctrl_pts.push_back(point({248,521}));
ctrl_pts.push_back(point({246,517}));
ctrl_pts.push_back(point({238,506}));
ctrl_pts.push_back(point({235,502}));
ctrl_pts.push_back(point({235,501}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({235,501}));
ctrl_pts.push_back(point({231,481}));
ctrl_pts.push_back(point({230,457}));
ctrl_pts.push_back(point({230,437}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({230,437}));
ctrl_pts.push_back(point({232.5,433}));
ctrl_pts.push_back(point({235,429}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({235,429}));
ctrl_pts.push_back(point({256,452}));
ctrl_pts.push_back(point({280,486}));
ctrl_pts.push_back(point({295,515}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({295,515}));
ctrl_pts.push_back(point({295,519}));
ctrl_pts.push_back(point({296,523}));
ctrl_pts.push_back(point({298,530}));
ctrl_pts.push_back(point({301,531}));
ctrl_pts.push_back(point({312,531}));
ctrl_pts.push_back(point({321,528}));
ctrl_pts.push_back(point({334,520}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({334,520}));
ctrl_pts.push_back(point({347,512}));
ctrl_pts.push_back(point({354,505}));
ctrl_pts.push_back(point({354,499}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({354,499}));
ctrl_pts.push_back(point({354,496}));
ctrl_pts.push_back(point({351,493}));
ctrl_pts.push_back(point({340,487}));
ctrl_pts.push_back(point({335,484}));
ctrl_pts.push_back(point({330,482}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({330,482}));
ctrl_pts.push_back(point({304,461}));
ctrl_pts.push_back(point({274,437}));
ctrl_pts.push_back(point({243,416}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({243,416}));
ctrl_pts.push_back(point({283,370}));
ctrl_pts.push_back(point({342,325}));
ctrl_pts.push_back(point({413,283}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({413,283}));
ctrl_pts.push_back(point({456,262}));
ctrl_pts.push_back(point({523,235}));
ctrl_pts.push_back(point({545,226}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();


/*:92*/
#line 370 "./piecewise.w"
;
/*93:*/
#line 772 "./piecewise.w"

ctrl_pts.push_back(point({245,638}));
ctrl_pts.push_back(point({249,633}));
ctrl_pts.push_back(point({251,625}));
ctrl_pts.push_back(point({251,614}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({251,614}));
ctrl_pts.push_back(point({251,603}));
ctrl_pts.push_back(point({247,597}));
ctrl_pts.push_back(point({240,597}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({240,597}));
ctrl_pts.push_back(point({219,608}));
ctrl_pts.push_back(point({164,651}));
ctrl_pts.push_back(point({151,666}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({151,666}));
ctrl_pts.push_back(point({152,667}));
ctrl_pts.push_back(point({153,667}));
ctrl_pts.push_back(point({155,668}));
ctrl_pts.push_back(point({156,668}));
ctrl_pts.push_back(point({157,668}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({157,668}));
ctrl_pts.push_back(point({189,668}));
ctrl_pts.push_back(point({224,655}));
ctrl_pts.push_back(point({245,638}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();


/*:93*/
#line 371 "./piecewise.w"
;
/*94:*/
#line 816 "./piecewise.w"

ctrl_pts.push_back(point({535,598}));
ctrl_pts.push_back(point({537,596}));
ctrl_pts.push_back(point({539,593}));
ctrl_pts.push_back(point({539,585}));
ctrl_pts.push_back(point({537,581}));
ctrl_pts.push_back(point({529,568}));
ctrl_pts.push_back(point({526,564}));
ctrl_pts.push_back(point({526,564}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({526,564}));
ctrl_pts.push_back(point({526,507}));
ctrl_pts.push_back(point({526,451}));
ctrl_pts.push_back(point({526,394}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({526,394}));
ctrl_pts.push_back(point({527,379}));
ctrl_pts.push_back(point({528,364}));
ctrl_pts.push_back(point({529,348}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({529,348}));
ctrl_pts.push_back(point({528,331}));
ctrl_pts.push_back(point({521,312}));
ctrl_pts.push_back(point({510,307}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({510,307}));
ctrl_pts.push_back(point({502,307}));
ctrl_pts.push_back(point({496,313}));
ctrl_pts.push_back(point({489,334}));
ctrl_pts.push_back(point({488,344}));
ctrl_pts.push_back(point({487,357}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({487,357}));
ctrl_pts.push_back(point({459,356}));
ctrl_pts.push_back(point({418,352}));
ctrl_pts.push_back(point({408,347}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({408,347}));
ctrl_pts.push_back(point({408,335}));
ctrl_pts.push_back(point({404,330}));
ctrl_pts.push_back(point({396,330}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({396,330}));
ctrl_pts.push_back(point({382,336}));
ctrl_pts.push_back(point({369,360}));
ctrl_pts.push_back(point({366,377}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({366,377}));
ctrl_pts.push_back(point({367,390}));
ctrl_pts.push_back(point({371,421}));
ctrl_pts.push_back(point({372,440}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({372,440}));
ctrl_pts.push_back(point({372,435}));
ctrl_pts.push_back(point({372,439}));
ctrl_pts.push_back(point({372,554}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({372,554}));
ctrl_pts.push_back(point({372,564}));
ctrl_pts.push_back(point({360,594}));
ctrl_pts.push_back(point({355,603}));
ctrl_pts.push_back(point({353,617}));
ctrl_pts.push_back(point({358,617}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({358,617}));
ctrl_pts.push_back(point({365,617}));
ctrl_pts.push_back(point({372,615}));
ctrl_pts.push_back(point({385,607}));
ctrl_pts.push_back(point({392,603}));
ctrl_pts.push_back(point({398,600}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({398,600}));
ctrl_pts.push_back(point({417,603}));
ctrl_pts.push_back(point({443,609}));
ctrl_pts.push_back(point({463,613}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({463,613}));
ctrl_pts.push_back(point({470,618}));
ctrl_pts.push_back(point({480,629}));
ctrl_pts.push_back(point({487,632}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({487,632}));
ctrl_pts.push_back(point({499,627}));
ctrl_pts.push_back(point({520,611}));
ctrl_pts.push_back(point({535,598}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();


/*:94*/
#line 372 "./piecewise.w"
;
/*95:*/
#line 948 "./piecewise.w"

ctrl_pts.push_back(point({487,378}));
ctrl_pts.push_back(point({487,444}));
ctrl_pts.push_back(point({487,510}));
ctrl_pts.push_back(point({487,576}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({487,576}));
ctrl_pts.push_back(point({487,583}));
ctrl_pts.push_back(point({486,587}));
ctrl_pts.push_back(point({484,594}));
ctrl_pts.push_back(point({480,597}));
ctrl_pts.push_back(point({473,597}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({473,597}));
ctrl_pts.push_back(point({454,596}));
ctrl_pts.push_back(point({428,590}));
ctrl_pts.push_back(point({408,584}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({408,584}));
ctrl_pts.push_back(point({408,553}));
ctrl_pts.push_back(point({408,523}));
ctrl_pts.push_back(point({408,492}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({408,492}));
ctrl_pts.push_back(point({420,494}));
ctrl_pts.push_back(point({447,504}));
ctrl_pts.push_back(point({464,507}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({464,507}));
ctrl_pts.push_back(point({475,507}));
ctrl_pts.push_back(point({481,504}));
ctrl_pts.push_back(point({481,489}));
ctrl_pts.push_back(point({471,482}));
ctrl_pts.push_back(point({450,478}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({450,478}));
ctrl_pts.push_back(point({436,475}));
ctrl_pts.push_back(point({422,473}));
ctrl_pts.push_back(point({408,473}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({408,473}));
ctrl_pts.push_back(point({408,438}));
ctrl_pts.push_back(point({408,403}));
ctrl_pts.push_back(point({408,368}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();

ctrl_pts.push_back(point({408,368}));
ctrl_pts.push_back(point({432,372}));
ctrl_pts.push_back(point({462,376}));
ctrl_pts.push_back(point({487,378}));

curves.push_back(bezier(ctrl_pts));
ctrl_pts.clear();


/*:95*/
#line 373 "./piecewise.w"
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

/*:90*//*132:*/
#line 778 "./cubicspline.w"

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


/*:132*//*142:*/
#line 1052 "./cubicspline.w"

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




/*:142*//*159:*/
#line 1707 "./cubicspline.w"

print_title("cubic spline interpolation");
{
/*160:*/
#line 1758 "./cubicspline.w"

vector<point> p;
for(unsigned i= 0;i!=11;i++){
point datum= point({0,0});
datum(1)= static_cast<double> (i)+M_PI;
datum(2)= sin(datum(1))+3.;
p.push_back(datum);
}

/*:160*/
#line 1710 "./cubicspline.w"
;
cubic_spline crv(p,
cubic_spline::end_condition::not_a_knot,
cubic_spline::parametrization::function_spline);

psf file= create_postscript_file("sine_curve.ps");
crv.write_curve_in_postscript(file,100,1.,1,2,40.);
crv.write_control_polygon_in_postscript(file,1.,1,2,40.);
crv.write_control_points_in_postscript(file,1.,1,2,40.);
close_postscript_file(file,true);

/*161:*/
#line 1772 "./cubicspline.w"

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

/*:161*/
#line 1721 "./cubicspline.w"
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


/*:159*//*164:*/
#line 1836 "./cubicspline.w"

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

/*:164*//*166:*/
#line 1863 "./cubicspline.w"

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

double error= 0.;
for(size_t i= 0;i!=steps;i++){
error+= dist(crv_pts_s[i],crv_pts_p[i]);
}
cout<<"Mean difference between serial and parallel computation = "
<<error/double(steps)<<endl;
}

/*:166*/
#line 323 "./cagd.w"
;
return 0;
}




#line 1 "./point.w"
/*:6*/
