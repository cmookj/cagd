PRGM = cagd
CWEB_FILE = cagd.w \
	    point.w \
	    curve.w \
	    bezier.w \
	    piecewise.w \
	    cubicspline.w

TEX_FILE = cagd.tex
TEX_AUX = $(TEX_FILE:.tex=.log) \
	$(TEX_FILE:.tex=.scn) \
	$(TEX_FILE:.tex=.toc) \
	$(TEX_FILE:.tex=.idx)
TARGET_PDF = $(TEX_FILE:.tex=.pdf)

CPP_HEADER = $(PRGM:.w=.h)
CPP_SRC = $(PRGM:.w=.cpp) test.cpp
TARGET_CPP = $(CPP_SRC:.cpp=.o)

all: $(TARGET_PDF) $(CPP_SRC)

$(TARGET_PDF): $(TEX_FILE)
	pdftex $(TEX_FILE); rm $(TEX_AUX) $(TEX_FILE)

$(TEX_FILE): $(CWEB_FILE)
	cweave $(PRGM).w

$(CPP_SRC): $(CWEB_FILE)
	ctangle $(PRGM).w

clean:
	rm $(TEX_AUX) $(TARGET_PDF)
