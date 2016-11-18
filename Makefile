PREFIX ?= /usr/local

CC = gcc
AR = ar

CFLAGS = -std=gnu99 -fPIC -Wall -Wno-unused-parameter -Wno-unused-function -I. -O4

APRILTAG_SRCS := $(shell ls *.c common/*.c)
APRILTAG_HEADERS := $(shell ls *.h common/*.h)
APRILTAG_OBJS := $(APRILTAG_SRCS:%.c=%.o)
TARGETS := libapriltag.a libapriltag.so

.PHONY: all
all: $(TARGETS)
	@$(MAKE) -C example all

.PHONY: install
install: libapriltag.so
	@chmod +x install.sh
	@./install.sh $(PREFIX)/lib libapriltag.so
	@./install.sh $(PREFIX)/include/apriltag $(APRILTAG_HEADERS)
	@sed 's:^prefix=$$:prefix=$(PREFIX):' < apriltag.pc.in > apriltag.pc
	@./install.sh $(PREFIX)/lib/pkgconfig apriltag.pc
	@rm apriltag.pc
	@ldconfig

libapriltag.a: $(APRILTAG_OBJS)
	@echo "   [$@]"
	@$(AR) -cq $@ $(APRILTAG_OBJS)

libapriltag.so: $(APRILTAG_OBJS)
	@echo "   [$@]"
	@$(CC) -fPIC -shared -o $@ $^

%.o: %.c
	@echo "   $@"
	@$(CC) -o $@ -c $< $(CFLAGS)

.PHONY: clean
clean:
	@rm -rf *.o common/*.o $(TARGETS)
	@$(MAKE) -C example clean