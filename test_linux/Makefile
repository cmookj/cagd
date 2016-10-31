.SUFFIXES: .cpp .o

CC          = g++

SRCS        = ../cagd.cpp
HDRS        = ../cagd.h
OBJS        = cagd.o
TARGET      = libcagd.so

INC         = -I/usr/include/nvidia-370/
LIBS        = -L./ -L/usr/lib/x86_64-linux-gnu/

CFLAGS      = -O2 -g -fPIC -std=c++11

all: $(TARGET) app

$(TARGET): $(OBJS)
	$(CC) --shared -Wl,-soname,$(TARGET) -o $(TARGET) $(CFLAGS) $(LIBS) $(OBJS) -lOpenCL

app:../test.cpp $(TARGET)
	$(CC) $(CFLAGS) ../test.cpp -o test $(INC) $(LIBS) -lcagd -lmpoi -lOpenCL -lm

$(OBJS) : $(SRCS) $(HDRS)
	$(CC) $(CFLAGS) $(INC) -c $<

clean:
	rm -rf $(OBJS) $(TARGET) test.o test core

install:
	cp $(TARGET) /usr/local/lib/
	cp $(HDRS) /usr/local/include/
