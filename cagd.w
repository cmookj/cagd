% ---------------------------------------------------------------------------- %
%                                                                              %
%                                 PROGRAM.W                                    %
%                                                                              %
%                                                                              %
% ---------------------------------------------------------------------------- %

% ---------------------------------------------------------------------------- %
%                                                                              %
%                                  IN LIMBO                                    %
%                                                                              %
% ---------------------------------------------------------------------------- %

% This document will be typeset in Korean
\input hangulcweb

% Graphics
\input graphicx

% Definitions of fonts
\font\biglogo=cmss10 scaled\magstep2
\font\authorfont=cmr12
\font\linefont=cmss8
\font\scaps=cmcsc10
\font\logo=cmss10
\font\ninerm=cmr9
\let\mc=\ninerm % medium caps

% Bold math alphabet
\def\bba{{\bf a}}
\def\bbb{{\bf b}}
\def\bbc{{\bf c}}
\def\bbd{{\bf d}}
\def\bbm{{\bf m}}
\def\bbp{{\bf p}}
\def\bbr{{\bf r}}
\def\bbx{{\bf x}}

% Definitions of names
\def\apple{{\mc Apple}}
\def\macosx{{\mc OS X\spacefactor1000}}
\def\windows{{\mc Windows}}
\def\boost{{\mc BOOST\spacefactor1000}}
\def\gsl{{\mc GSL\spacefactor1000}}
\def\llvm{{\mc LLVM\spacefactor1000}}
\def\bezier{B\'ezier}

% Definitions of mathematical notations
\def\trans{^\top}
\def\inv{^{-1}}

% Definitions of useful commands
\def\example{{\bf Example.\ }}
\def\myitem{\item{$\bullet$}}
\def\beginitems{\par\medskip\begingroup\parindent=36pt}
\def\enditems{\endgroup\medskip}

% Definition for current date
\def\today{\ifcase\month\or
	January\or February\or March\or April\or May\or June\or
	July\or August\or September\or October\or November\or December\fi
	\space\number\day, \number\year}

% Definitions for revisiondata and title
\def\years{2015--2017}
\def\title{Computer-Aided Geometric Design}
\def\headertitle{CAGD}

% Definitions for left/right headers, top/bottom of table of contents material
%\def\lheader{\mainfont\the\pageno\kern1pc(\topsecno)\eightrm
%  \qquad\grouptitle\hfill\headertitle}
%\def\rheader{\eightrm\headertitle\hfill\grouptitle\qquad\mainfont
%  (\topsecno)\kern1pc\the\pageno}

\def\topofcontents{\null\vfill
  \centerline{\titlefont \title}
  \vskip15pt
  \centerline{(Last revised on \today)}
  \vfill}
\def\botofcontents{\vfill
  \noindent
  Copyright \copyright\ \years~by Changmook Chun
  \bigskip\noindent
  This document is published by Changmook Chun.  All rights reserved.
  No part of this publication may be reproduced, stored in a retrieval systems,
  or transmitted, in any form or by any means, electronic, mechanical,
  photocopying, recording, or otherwise, without the prior written
  permission of the author.
}

% Print line numbers on the left side of C++ code.
\newcount\linenum \linenum=0
\def\6{\ifmmode\else\par\hangindent\ind em\noindent
  \hbox to 0pt{\hss\global\advance\linenum by 1
    \linefont\the\linenum\hskip 7mm}
  \hangindent\ind em\noindent\kern\ind em\copy\bakk\ignorespaces\fi}


% Modification to CWEBMAC
\secpagedepth=3
\def\9#1#2{\&{#1}::\\{#2}}

% Make title page with a blank page behind it for a printer with a duplex.
% \null\vfill
% \centerline{\titlefont The {\biglogo CLAT} Library}
% \vskip 18pt\centerline{(Last revised on \today)}
% \vskip 24pt
% \centerline{\authorfont Changmook Chun}
% \vfill
% \titletrue\eject\hbox to 0pt{}
% \pageno=0 \titletrue\eject

% Some useful commands.
\def\newline{\vskip\baselineskip}
\def\header#1{\hbox{\tt #1.h}}
\newdimen\argidt \argidt=.5in
\def\idt{\hskip\argidt}


% ---------------------------------------------------------------------------- %

% Format
@s using if
@s std int
@s string int
@s vector int
@s list int
@s ostream int
@s istream int
@s ofstream int
@s namespace int
@s stringstream int


\datethis

@* Introduction.
이 문서는 Gerald Farin의 ``Curves and Surfaces for CAGD: A Practical Guide''
$4^{\rm th}$ edition에 기술되어 있는 알고리즘들을 간략하게 설명하고 구현한다.

가장 먼저 $n$-차원 유클리드 공간에 존재하는 존재하는 점을 기술하기 위한
|point| 타입을 정의한다.  뒤에서 좀 더 자세하게 설명하겠지만, 유클리드 공간의
point는 위치를 나타내는 position vector와 다른 특성을 갖는다.  예를 들면, point
사이의 뺄셈은 정의되지만 덧셈은 물리적으로 의미가 성립되지 않아 정의될 수 없는
것을 들 수 있다.

두 번째로, 추상적인 타입으로 |curve| 타입을 정의한다.
이 타입은 일반적인 곡선에서 필요로 하는 몇 가지 인터페이스를 정의하고,
PostScript 파일 출력을 위한 method들을 갖는다.

|curve| 타입을 base class로 \bezier\ 곡선을 기술하기 위한 |bezier| 타입을
정의한다.  그리고 여러 개의 곡선들을 이어 붙여 사용하기 위한
|piecewise_bezier_curve| 타입을 정의한다.
마지막으로 가장 널리 쓰이는 cubic spline curve를 기술하기 위하여
|cubic_spline| 타입을 정의한다.




@* Namespace.
이 문서에서 기술하는 모든 타입과 유틸리티 함수들은 |cagd| namespace에 정의한다.
연산 결과가 0과 유사할 때 0으로 판별하기 위하여 machine epsilon을
$2.2204\cdot10^{-16}$으로 정의한다.

|cagd| namespace 객체의 method들을 실행하는 도중 오류가 발생할 때에는
오류의 원인을 설명하고 오류의 종류를 구별할 수 있도록 오류 코드를 객체 내에
저장한다.
오류 코드를 정의하기 위하여 enumeration을 정의한다.
앞으로 다른 타입들과 그 각각의 method들을 정의하면서 그것들과 연관된
오류 코드들도 추가로 정의할 것이다.
매우 자명하게도, |NO_ERR|는 method를 성공적으로 수행하고 아무런 오류가 없음을
의미한다.

점이나 곡선과 같은 기하학적 객체를 다룰 때 실행결과를 가장 쉽게 확인하는 방법은
그것들을 2차원 지면상에 실제로 그리는 것이다.  또한 그 결과를 편리하게 활용할
수 있도록 간단한 PostScript 출력을 지원하는 타입과 method들을 구현한다.
이 프로그램에서는 PostScript 파일을 가리키는 타입으로 |psf|를 정의한다.
(실제로는 \CPLUSPLUS/의 |ofstream| 타입에 다른 이름을 붙였을 뿐이다.)

OpenCL을 이용한 병렬연산을 수행할 수 있도록 |mpoi.h| 헤더를 추가한다.

@s cagd int
@s point int
@s curve int
@s bezier int
@s INT int
@s DBL double
@s psf int

@(cagd.h@>=
#ifndef __COMPUTER_AIDED_GEOMETRIC_DESIGN_H_
#define __COMPUTER_AIDED_GEOMETRIC_DESIGN_H_
@#
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
@#
#include "mpoi.h"
@#
#if defined (_WIN32) || defined (_WIN64)
#define NOMINMAX
#define M_PI       3.14159265358979323846
#define M_PI_2     1.57079632679489661923
#define M_PI_4     0.785398163397448309616
#endif

using namespace std;

@#
namespace cagd @+ {
  const double EPS = 2.2204e-16;
  @#
  enum err_code {
    @<Error codes of |cagd|@>@;
    NO_ERR
  };
  @#
  typedef ofstream psf;
  @#
  @<Definition of |point|@>@;
  @<Definition of |curve|@>@;
  @<Definition of |bezier|@>@;
  @<Definition of |piecewise_bezier_curve|@>@;
  @<Definition of |cubic_spline|@>@;
  @<Declaration of |cagd| functions@>@;
}

#endif




@ Implementation of |cagd|.

@(cagd.cpp@>=
#include "cagd.h"
@#
using namespace cagd;
@#
@<Implementation of |cagd| functions@>@;
@<Implementation of |point|@>@;
@<Implementation of |curve|@>@;
@<Implementation of |bezier|@>@;
@<Implementation of |piecewise_bezier_curve|@>@;
@<Implementation of |cubic_spline|@>@;




@ PostScript 파일을 생성하고 닫기 위한 함수를 정의한다.

@s ios_base int

@<Implementation of |cagd| functions@>+=
psf cagd::create_postscript_file (string file_name) @+ {
  psf ps_file;
  ps_file.open (file_name.c_str(), ios_base::out);
  if (!ps_file) {
    exit (-1);
  }
  ps_file << "%!PS-Adobe-3.0" << endl
          << "/Helvetica findfont 10 scalefont setfont" << endl;
  return ps_file;
}

void cagd::close_postscript_file (psf& ps_file, bool with_new_page) @+ {
  if (with_new_page == true) {
    ps_file << "showpage" << endl;
  }
  ps_file.close ();
}

@ @<Declaration of |cagd| functions@>+=
psf create_postscript_file (string);
void close_postscript_file (psf&, bool);




@ Test program.

@(test.cpp@>=
#include <iostream>
#include <iomanip>
#include <chrono>
#include "cagd.h"

using namespace cagd;
using namespace std::chrono;

void print_title(const char*);

void print_title (const char* str) @+ {
  cout << endl << endl;
  char prev = cout.fill ('-');

  cout << ">> " << setw (68) << '-' << endl;
  cout << ">>" << endl;
  cout << ">>  TEST: " << str << endl;
  cout << ">>" << endl;
  cout << ">> " << setw (68) << '-' << endl;
  cout.fill (prev);
}

int main (int argc, char* argv[]) @+ {
  @<Test routines@>;
  return 0;
}




@i math.w
@i point.w
@i curve.w
@i bezier.w
@i piecewise.w
@i cubicspline.w




@* Index.
