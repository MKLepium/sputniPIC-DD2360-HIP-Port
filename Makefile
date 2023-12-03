# From https://x.momo86.net/?p=29

CXX=g++
CXXFLAGS=-std=c++11 -I./include -O3 -g -Xcompiler -Wall

NVCC=nvcc
ARCH=sm_30
NVCCFLAGS= -I./include -arch=$(ARCH) -std=c++11 -O3 -g -Xcompiler -Wall --compiler-bindir=$(CXX)

# Use an environment variable to switch between CPU and GPU
GPU_FLAG ?= $(if $(USE_GPU),-DUSE_GPU,)

SRCDIR=src
SRCS=$(shell find $(SRCDIR) -name '*.cu' -o -name '*.cpp')

OBJDIR=src
OBJS=$(subst $(SRCDIR),$(OBJDIR), $(SRCS))
OBJS:=$(subst .cpp,.o,$(OBJS))
OBJS:=$(subst .cu,.o,$(OBJS))

BIN := ./bin
TARGET=sputniPIC.out

all: dir $(BIN)/$(TARGET)

dir: ${BIN}
  
${BIN}:
	mkdir -p $(BIN)

$(BIN)/$(TARGET): $(OBJS)
	$(NVCC) $(NVCCFLAGS) $(GPU_FLAG) $+ -o $@

$(SRCDIR)/%.o: $(SRCDIR)/%.cu
	$(NVCC) $(NVCCFLAGS) $(GPU_FLAG) $< -c -o $@

$(OBJDIR)/%.o: $(SRCDIR)/%.cpp
	[ -d $(OBJDIR) ] || mkdir $(OBJDIR)
	$(NVCC) $(CXXFLAGS) $(GPU_FLAG) $< -c -o $@

# compile and run with the GEM_2D.inp input file
run: $(BIN)/$(TARGET)
	$(BIN)/$(TARGET) ./inputfiles/GEM_2D.inp

clean:
	rm -rf $(OBJS)
	rm -rf $(BIN)/$(TARGET)
