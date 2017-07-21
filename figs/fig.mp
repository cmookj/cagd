prologues := 3;
outputtemplate := "%j-%c.mps";
outputformat := "eps";

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Macro: mark_circle
%
%  Description: Draws a circle filled with color specified.
%
%  Arguments
%   - z : center of the circle
%   - s : diameter of the circle
%   - a : gray level of the fill color (0: black, 1: white)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
def mark_circle (expr z, s, a) =
  begingroup
    save p; path p;
    p = fullcircle scaled s;
    fill (p shifted z) withcolor a*white;
    draw (p shifted z);
  endgroup
enddef;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Macro: mark_square
%
%  Description: Draws a square filled with color specified.
%
%  Arguments
%   - z : center of the square
%   - s : length of an edge of the square
%   - a : gray level of the fill color (0: black, 1: white)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
def mark_square (expr z, s, a) =
  begingroup
    save p; path p;
    p = (-.5s, -.5s)--(.5s, -.5s)--(.5s, .5s)--(-.5s, .5s)--cycle;
    fill (p shifted z) withcolor a*white;
    draw (p shifted z);
  endgroup
enddef;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Macro: mark_ex
%
%  Description: Draws an ex after filling a square with color specified.
%
%  Arguments
%   - z : center of the square
%   - s : length of an edge of the square
%   - a : gray level of the fill color (0: black, 1: white)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
def mark_ex (expr z, s, a) =
  begingroup
    save p; path p;
    numeric b;  b = .5;
    picture ex;
    ex := image (
      p = (-s, -s)--(s, -s)--(s, s)--(-s, s)--cycle;
      fill p withcolor a*white;
      draw (-b*s, -b*s)--(b*s, b*s);
      draw (b*s, -b*s)--(-b*s, b*s);
      );
    draw ex shifted z;
  endgroup
enddef;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Figure 1
%
%  Subdivision of Bezier curve.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
beginfig(1);
  numeric u, c;
  pair b[][];

  u = 2cm;
  c = 0.6;

  % Parameter axis
  z0 = (1.5u, 0);
  z1 = (3.2u, 0);
  z2 = c[z0,z1];
  pickup defaultpen;
  draw z0--z1;
  for i=0 upto 1:
    draw z[i]--(z[i] shifted (0,.05u));
  endfor
  draw (z2 shifted (0,-.05u))--(z2 shifted (0,.05u));
  pickup pencircle scaled 1pt;
  draw z0--z2;
  label.bot (btex $0$ etex, z0 shifted (0,-.05u));
  label.bot (btex $1$ etex, z1 shifted (0,-.05u));
  label.bot (btex $c$ etex, z2 shifted (0,-.05u));

  % Bezier control polygon
  b0 0 = (u,u);
  b1 0 = (3u,3u);
  b2 0 = (5u,2.5u);
  b3 0 = (5.1u,u);

  % Points by de Casteljau algorithm
  pickup defaultpen;
  for n=1 upto 3:
    for i=0 upto (3-n):
      b[i][n] = c[b[i][n-1],b[i+1][n-1]];
      draw b[i][n-1]--b[i+1][n-1];
    endfor
  endfor

  % Bezier curve
  draw b0 0..controls b1 0 and b2 0..b3 0;

  % Bezier curve subdivided
  pickup pencircle scaled 1pt;
  draw b0 0..controls b0 1 and b0 2..b0 3;

  % Draw circles
  mark_circle (b0 0, .05u, 0);
  mark_circle (b1 0, .05u, 1);
  mark_circle (b2 0, .05u, 1);
  mark_circle (b3 0, .05u, 0);

  mark_circle (b0 0, .04u, 0);
  mark_circle (b0 1, .04u, 1);
  mark_circle (b0 2, .04u, 1);
  mark_circle (b0 3, .04u, 0);

  % Label
  label.lrt (btex ${\bf c}_0$ etex, b0 0);
  label.ulft (btex ${\bf c}_1={\bf b}_0^1$ etex, b0 1);
  label.ulft (btex ${\bf c}_2={\bf b}_0^2$ etex, b0 2);
  label.llft (btex ${\bf c}_3={\bf b}_0^3$ etex, b0 3);

  label.urt (btex ${\bf b}_1^1$ etex, b1 1);
  label.rt (btex ${\bf b}_2^1$ etex, b2 1);

  label.rt (btex ${\bf b}_1^2$ etex, b1 2);

  label.lft (btex ${\bf b}_0$ etex, b0 0);
  label.ulft (btex ${\bf b}_1$ etex, b1 0);
  label.rt (btex ${\bf b}_2$ etex, b2 0);
  label.rt (btex ${\bf b}_3$ etex, b3 0);

  % Draw arrow
  pickup defaultpen;
  drawarrow (z2 shifted (0, 0.2u)){dir 80}..{dir 50}(b0 2 shifted (0,-.8u));
endfig;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Figure 2
%
%  C2 cubic spline
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
beginfig (2);
  numeric u;  u = 1.5cm;

  % Knot interval
  numeric delta[];
  delta[-3] = 3;
  delta[-2] = 2;
  delta[-1] = 2.5;
  delta0 = 3;
  delta1 = 2.5;
  delta2 = 2;

  % Control points
  pair d[];
  d[-2] = (u, -3u);
  d[-1] = (0, 0);
  d0 = (2u, 4u);
  d1 = (6u, 3.5u);
  d2 = (9u, u);

  % Bezier control points
  pair b[];
  numeric sum[];
  sum[-2] = delta[-3]+delta[-2]+delta[-1];
  sum[-1] = delta[-2]+delta[-1]+delta0;
  sum0 = delta[-1]+delta0+delta1;
  sum1 = delta0+delta1+delta2;

  b[-4] = ((delta[-3]+delta[-2])/sum[-2])[d[-2],d[-1]];
  b[-2] = (delta[-2]/sum[-1])[d[-1],d0];
  b[-1] = ((delta[-2]+delta[-1])/sum[-1])[d[-1],d0];
  b1 = (delta[-1]/sum0)[d0,d1];
  b2 = ((delta[-1]+delta0)/sum0)[d0,d1];
  b4 = (delta0/sum1)[d1,d2];

  b[-3] = (delta[-2]/(delta[-2]+delta[-1]))[b[-4],b[-2]];
  b0 = (delta[-1]/(delta[-1]+delta0))[b[-1],b1];
  b3 = (delta0/(delta0+delta1))[b2,b4];

  % Draw control polygon
  pickup defaultpen;
  draw d[-1]--d0--d1;
  draw b[-3]--b[-2]--b[-1]--b0;
  draw b0--b1--b2--b3;

  % Draw Bezier curves
  pickup pencircle scaled 1pt;
  draw b[-3]..controls b[-2] and b[-1]..b0;
  draw b0..controls b1 and b2..b3;

  % Mark control points
  pickup defaultpen;
  for i = -1 upto 1:
    mark_square (d[i], .05u, 1);
  endfor;

  for i = -3 upto 3:
    mark_circle (b[i], .03u, 0);
  endfor;

  % Label control points
  label.lft (btex ${\bf d}_{i-1}$ etex, d[-1]);
  label.top (btex ${\bf d}_i$ etex, d0);
  label.urt (btex ${\bf d}_{i+1}$ etex, d1);

  label.rt (btex ${\bf p}_{i-1}={\bf b}_{3(i-1)}$ etex, b[-3]);
  label.lrt (btex ${\bf p}_i={\bf b}_{3i}$ etex, b0);
  label.bot (btex ${\bf p}_{i+1}={\bf b}_{3(i+1)}$ etex, b3);

  label.lft (btex ${\bf b}_{3i-2}$ etex, b[-2]);
  label.lft (btex ${\bf b}_{3i-1}$ etex, b[-1]);

  label.top (btex ${\bf b}_{3i+1}$ etex, b1);
  label.top (btex ${\bf b}_{3i+2}$ etex, b2);

  % Label knot interval
  numeric theta;
  theta := angle (d0-d[-1]);
  label.lft (btex $\Delta_{i-2}$ etex rotated theta, .5[d[-1],b[-2]]);
  label.lft (btex $\Delta_{i-1}$ etex rotated theta, .5[b[-2],b[-1]]);
  label.lft (btex $\Delta_i$ etex rotated theta, .5[b[-1],d0]);

  theta := angle (d1-d0);
  label.top (btex $\Delta_{i-1}$ etex rotated theta, .5[d0,b1]);
  label.top (btex $\Delta_i$ etex rotated theta, .5[b1,b2]);
  label.top (btex $\Delta_{i+1}$ etex rotated theta, .5[b2,d1]);

  theta := angle (b1-b[-1]);
  label.top (btex $\Delta_{i-1}:\Delta_i$ etex rotated theta, b0 shifted (0,-.25u));
endfig;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Figure 3
%
%  Not-a-Knot end condition
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
beginfig(3);
  numeric u;  u = 2.5cm;

  % Knot sequence
  numeric delta[];
  delta0 = 1;
  delta1 = 1.2;
  delta2 = 1.4;
  delta3 = 1.2;

  % Auxiliary control points
  pair aminus, aplus;
  aminus = (1u, .5u);
  aplus = (1.2u, 2u);

  % Control points
  pair d[], b[];
  d[-1] = (3u,0);
  b0 = d[-1];

  numeric r;
  r = delta0/(delta0 + delta1);

  d0 = r[d[-1],aminus];
  b1 = d0;

  d1 = r[aminus,aplus];
  b2 = r[b1,d1];

  b6 = (3.2u,3u);
  b5 = r[aplus,b6];
  b4 = r[d1,b5];
  b3 = r[b2,b4];

  d2 = ((delta0 + delta1 + delta2)/(delta0 + delta1))[d1,b5];

  % Draw control polygon
  pickup defaultpen;
  for i = -1 upto 1:
    draw d[i]--d[i+1];
  endfor;

  draw d[-1]--aminus--aplus--b6;

  for i = -1 upto 2:
    mark_square (d[i], .025u, 1);
  endfor;

  mark_ex (aminus, .025u, 1);
  mark_ex (aplus, .025u, 1);

  for i = 0 upto 6:
    mark_circle (b[i], .015u, 0);
  endfor;

  for i = 0 upto 5:
    draw b[i]--b[i+1];
  endfor;

  % Draw Bezier curve
  draw b0..controls aminus and aplus..b6;

  % Draw Bezier curves
  pickup pencircle scaled 1pt;
  for i = 0 upto 1:
    draw b[3i]..controls b[3i+1] and b[3i+2]..b[3i+3];
  endfor;

  % Mark labels
  label.llft (btex ${\bf a}_-$ etex, aminus);
  label.ulft (btex ${\bf a}_+$ etex, aplus);

  label.lrt (btex ${\bf b}_0={\bf d}_{-1}={\bf p}_0$ etex, b0);
  label.lft (btex ${\bf d}_1$ etex, d1);
  label.top (btex ${\bf d}_2$ etex, d2);

  label.bot (btex ${\bf b}_1$ etex, b1);
  label.llft (btex ${\bf b}_2$ etex, b2);
  label.rt (btex ${\bf b}_3={\bf p}_1$ etex, b3);
  label.ulft (btex ${\bf b}_4$ etex, b4);
  label.ulft (btex ${\bf b}_5$ etex, b5);
  label.rt (btex ${\bf b}_6={\bf p}_2$ etex, b6);

  numeric theta;
  theta := angle (b0 - aminus);
  label.bot (btex $\Delta_0$ etex rotated theta, .5[b0,b1]);
  label.bot (btex $\Delta_1$ etex rotated theta, .5[aminus,b1]);

  theta := angle (aplus - aminus);
  label.lft (btex $\Delta_0$ etex rotated theta, .5[aminus,d1]);
  label.lft (btex $\Delta_1$ etex rotated theta, .5[d1,aplus]);

  theta := angle (b6 - aplus);
  label.top (btex $\Delta_0$ etex rotated theta, .5[aplus,b5]);
  label.top (btex $\Delta_1$ etex rotated theta, .5[b5,b6]);

  theta := angle (b1 - d1);
  label.bot (btex $\Delta_0$ etex rotated theta, .2[b2,b1]);
  label.bot (btex $\Delta_1$ etex rotated theta, .5[d1,b2]);

  theta := angle (b5 - d1);
  label.top (btex $\Delta_0$ etex rotated theta, .5[d1,b4]);
  label.top (btex $\Delta_1$ etex rotated theta, .3[b4,b5]);
  label.top (btex $\Delta_2$ etex rotated theta, .5[b5,d2]);

  theta := angle (b4 - b2);
  label.lft (btex $\Delta_0:\Delta_1$ etex rotated theta, b3);
  % label.lft (btex $\Delta_1$ etex rotated theta, .5[b3,b4]);


endfig;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Figure 4
%
%  Periodic spline
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
beginfig(4);
  numeric u;  u = 3cm;

  % Knot sequence
  numeric delta[];
  delta0 = 1;
  delta1 = 1.2;
  delta2 = 1.4;
  delta3 = 1.2;
  delta4 = 1.3;
  delta[-1] = delta4;
  delta[-2] = delta3;
  delta5 = delta0;

  % Control points
  pair d[], b[];
  d0 = (.5u, 2.5u);
  d1 = (2u, 2u);
  d2 = (1.5u, .3u);
  d3 = (0, 0);
  d4 = (-.7u, 1.7u);
  d5 = d0;

  % Bezier control points
  for i = 0 upto 4:
    b[3i+1] =
        (delta[i-1]/(delta[i-1]+delta[i]+delta[i+1]))[d[i],d[i+1]];
    b[3i+2] =
        ((delta[i-1]+delta[i])/(delta[i-1]+delta[i]+delta[i+1]))[d[i],d[i+1]];
  endfor;
  b[-1] = b[3*4+2];
  b[3*4+3] = b[0];

  for i = 0 upto 4:
    b[3i] = (delta[i-1]/(delta[i-1]+delta[i]))[b[3i-1],b[3i+1]];
  endfor;

  % Draw control polygon
  pickup defaultpen;
  for i = 0 upto 4:
    draw d[i]--d[i+1];
    draw b[3i-1]--b[3i+1];
  endfor;

  % Draw curve
  pickup pencircle scaled 2pt;
  for i = 0 upto 4:
    draw b[3i]..controls b[3i+1] and b[3i+2]..b[3i+3];
  endfor;

  % Draw markers
  pickup defaultpen;
  for i = 0 upto 4:
    mark_square (d[i], .05u, 1);
    mark_circle (b[3i], .05u, 0);
    mark_circle (b[3i+1], .04u, 1);
    mark_circle (b[3i+2], .04u, 1);
  endfor;

  % Labels
  label.top  (btex ${\bf d}_0={\bf d}_5 (L=5)$ etex, d[0] shifted (0,.05u));
  label.rt   (btex ${\bf d}_1$ etex, d[1]);
  label.lrt  (btex ${\bf d}_2$ etex, d[2]);
  label.llft (btex ${\bf d}_3$ etex, d[3]);
  label.lft  (btex ${\bf d}_4$ etex, d[4]);

  label.urt  (btex ${\bf d}_+$ etex, b1);
  label.ulft (btex ${\bf d}_-$ etex, b14);

  label.bot  (btex ${\bf p}_0={\bf p}_5$ etex, b[0] shifted (0,-.05u));

  pair offsetv;
  offsetv = (.1u,0);

  numeric sfactor;
  sfactor = 0.6;

  numeric theta[];

  theta0 = angle (d1 - d0);
  label (btex $\Delta_{-1}=\Delta_{L-1}$ etex scaled sfactor rotated theta0,
      .5[d0, b1] shifted (offsetv rotated (theta0+90)));
  label (btex $\Delta_0$ etex scaled sfactor rotated theta0,
      .5[b1, b2] shifted (offsetv rotated (theta0+90)));
  label (btex $\Delta_1$ etex scaled sfactor rotated theta0,
      .5[b2, d1] shifted (offsetv rotated (theta0+90)));

  theta1 = angle (d5 - d4);
  label (btex $\Delta_{-2}=\Delta_{L-2}$ etex scaled sfactor rotated theta1,
      .5[d4, b13] shifted (offsetv rotated (theta1+90)));
  label (btex $\Delta_{-1}=\Delta_{L-1}$ etex scaled sfactor rotated theta1,
      .5[b13, b14] shifted (offsetv rotated (theta1+90)));
  label (btex $\Delta_0$ etex scaled sfactor rotated theta1,
      .5[b14, d5] shifted (offsetv rotated (theta1+90)));

endfig;




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Figure 5
%
%  Cubic B-Spline curve with its control polygon.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
beginfig(5);
  numeric u;  u = 1.2cm;

	% Knot sequence
	numeric delta[];
	delta0 = 2;
	delta1 = 1.5;
	delta2 = 1.5;
	delta3 = 1.5;
	delta4 = 1.5;
	delta5 = 1.5;

	% B-spline control points
	pair d[];
	d[-1] = (5.4u, .5u);
	d0 = (4.5u, 0);
	d1 = (0, 0);
	d2 = (0, 2u);
	d3 = (1.8u, 3u);
	d4 = (4.5u, 3u);
	d5 = (6.2u, u);
	d6 = (9u, u);
	d7 = (9u, 2u);

	% Bezier control points
	pair b[];
	b0 = d[-1];
	b1 = d0;
	b2 = (delta0/(delta0+delta1))[d0,d1];

	b16 = (delta4/(delta4+delta5))[d5,d6];
	b17 = d6;
	b18 = d7;

	for i=2 upto 5:
		b[3i-2]=(delta[i-2]/(delta[i-2]+delta[i-1]+delta[i]))[d[i-1],d[i]];
		b[3i-1]=((delta[i-2]+delta[i-1])/(delta[i-2]+delta[i-1]+delta[i]))
			[d[i-1],d[i]];
	endfor;

	for i=1 upto 5:
		b[3i]=(delta[i-1]/(delta[i-1]+delta[i]))[b[3i-1],b[3i+1]];
	endfor;

  % Draw Bezier control polygon
  pickup defaultpen;
  for i = 0 upto 5:
    draw b[3i]--b[3i+1]--b[3i+2]--b[3i+3];
		% mark_circle (b[3i], .05u, 1);
    % mark_circle (b[3i+1], .04u, 1);
    % mark_circle (b[3i+2], .04u, 1);
  endfor;
	% mark_circle (b[18], .04u, 0);

	% Draw B-spline control polygon
	for i = -1 upto 6:
		draw d[i]--d[i+1];
		% mark_square (d[i], .05u, 1);
	endfor;
	% mark_square (d7, .05u, 1);

	% Mark control points
	for i = 0 upto 18:
		mark_circle (b[i], 0.05u, 1);
	endfor;

	for i = -1 upto 7:
		mark_square (d[i], 0.05u, 1);
	endfor;

  % Draw curve
  pickup pencircle scaled 2pt;
  for i = 0 upto 5:
    draw b[3i]..controls b[3i+1] and b[3i+2]..b[3i+3];
  endfor;

  % Labels
  label.lrt (btex ${\bf b}_0={\bf d}_{-1}$ etex, d[-1]);
	label.lrt (btex ${\bf b}_1={\bf d}_0$ etex, d0);
	label.bot (btex ${\bf d}_1$ etex, d1);
	label.lft (btex ${\bf d}_2$ etex, d2);
	label.top (btex ${\bf d}_3$ etex, d3);
	label.top (btex ${\bf d}_4$ etex, d4);
	label.bot (btex ${\bf d}_5$ etex, d5);
	label.rt  (btex ${\bf b}_{17}={\bf d}_6$ etex, d6);
	label.rt  (btex ${\bf b}_{18}={\bf d}_7$ etex, d7);

	label.llft(btex ${\bf b}_2$ etex, b2);
	label.urt (btex ${\bf b}_3$ etex, b3);
	label.lft (btex ${\bf b}_4$ etex, b4);
	label.lft (btex ${\bf b}_5$ etex, b5);
	label.rt  (btex ${\bf b}_6$ etex, b6);
	% label.ulft(btex ${\bf b}_7$ etex, b7);
	% label.ulft(btex ${\bf b}_8$ etex, b8);
	% label.lrt (btex ${\bf b}_9$ etex, b9);
	% label.top (btex ${\bf b}_{10}$ etex, b10);
	% label.top (btex ${\bf b}_{11}$ etex, b11);
	% label.llft(btex ${\bf b}_{12}$ etex, b12);
	% label.rt  (btex ${\bf b}_{13}$ etex, b13);
	% label.lft (btex ${\bf b}_{14}$ etex, b14);
	% label.urt (btex ${\bf b}_{15}$ etex, b15);
	% label.bot (btex ${\bf b}_{16}$ etex, b16);


  % label.rt   (btex ${\bf d}_1$ etex, d[1]);
  % label.lrt  (btex ${\bf d}_2$ etex, d[2]);
  % label.llft (btex ${\bf d}_3$ etex, d[3]);
  % label.lft  (btex ${\bf d}_4$ etex, d[4]);

  % label.bot  (btex ${\bf p}_0={\bf p}_5$ etex, b[0] shifted (0,-.05u));

  % pair offsetv;
  % offsetv = (.1u,0);

  % numeric sfactor;
  % sfactor = 0.6;

  % numeric theta[];

  % theta0 = angle (d1 - d0);
  % label (btex $\Delta_{-1}=\Delta_{L-1}$ etex scaled sfactor rotated theta0,
  %     .5[d0, b1] shifted (offsetv rotated (theta0+90)));
  % label (btex $\Delta_0$ etex scaled sfactor rotated theta0,
  %     .5[b1, b2] shifted (offsetv rotated (theta0+90)));
  % label (btex $\Delta_1$ etex scaled sfactor rotated theta0,
  %     .5[b2, d1] shifted (offsetv rotated (theta0+90)));

  % theta1 = angle (d5 - d4);
  % label (btex $\Delta_{-2}=\Delta_{L-2}$ etex scaled sfactor rotated theta1,
  %     .5[d4, b13] shifted (offsetv rotated (theta1+90)));
  % label (btex $\Delta_{-1}=\Delta_{L-1}$ etex scaled sfactor rotated theta1,
  %     .5[b13, b14] shifted (offsetv rotated (theta1+90)));
  % label (btex $\Delta_0$ etex scaled sfactor rotated theta1,
  %     .5[b14, d5] shifted (offsetv rotated (theta1+90)));

endfig;

end
