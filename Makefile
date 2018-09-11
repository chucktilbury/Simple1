
PLATNAME := $(shell uname)

OBJS	=	scanner.o \
		parser.o \
		errors.o

OBJS1	=	main.o

TARGET	=	simple

CARGS	=	-Wall
DEBUG	=	-g -DTRACE -DDEBUGGING
HEADERS	=	$(OBJS:.o=.h)
CC		=	clang

ifeq ($(PLATNAME), Linux)
	LIBS	=	-ll -ly
else ifeq ($(PLATNAME), MSYS_NT-6.1)
	LIBS	=	-L/c/MinGW/msys/1.0/lib -lfl -ly
endif

.c.o:
	$(CC) $(CARGS) $(DEBUG) -c $< -o $@

all: $(TARGET)

$(TARGET): $(OBJS) 
	$(CC) $(CARGS) $(DEBUG) $(OBJS) -o $(TARGET) $(LIBS)

parser.c parser.h: parser.y
	bison -vtdo parser.c parser.y

scanner.c: scanner.l parser.h
	flex -oscanner.c scanner.l

parser.o: parser.c
scanner.o: scanner.c parser.h
errors.o: errors.c errors.h

clean:
	-rm -f parser.c scanner.c parser.h parser.output $(OBJS1) $(OBJS) $(TARGET)
