/*112:*/
#line 426 "./cubicspline.w"

kernel void evaluate_crv(
global float*crv,
constant float*knots,
constant float*cpts,
unsigned d,unsigned L,unsigned N
){

private unsigned id= get_global_id(0);
private const unsigned n= 3;
private const unsigned MAX_D= 6;
private float tmp[MAX_D*(n+1)];

private const float du= (knots[L+n-1]-knots[n-1])/float(N-1);
private float u= knots[n-1]+id*du;

private unsigned I= n-1;
for(private unsigned i= n;i!=L+n-1;i++){
I+= (convert_int(sign(u-knots[i]))+1)>>1;
#if 0
if(knots[i]<u)I++;
#endif
}

for(private unsigned i= 0;i!=n+1;i++){
for(private unsigned j= 0;j!=d;j++){
tmp[i*d+j]= cpts[(i+I-n+1)*d+j];
}
}

private unsigned shifter= I-n+1;

for(private unsigned k= 1;k!=n+1;k++){
for(private unsigned i= I+1;i!=I-n+k;i--){
private float t= (knots[i+n-k]-u)/(knots[i+n-k]-knots[i-1]);

for(private unsigned j= 0;j!=d;j++){
tmp[(i-shifter)*d+j]= t*tmp[(i-shifter-1)*d+j]
+(1.-t)*tmp[(i-shifter)*d+j];
}
}
}

for(private unsigned j= 0;j!=d;j++){
crv[id*d+j]= tmp[n*d+j];
}
}




/*:112*/
