SHADER_LANG = glsl330

APP = visualz80

SRCS = \
ext/perfect6502/perfectz80.c \
ext/perfect6502/netlist_sim.c \
ext/sokol/sokol.c \
ext/asmx/src/asmx.c \
ext/asmx/src/asmz80.c \
src/z80/nodenames.c \
src/z80/segdefs.c \
src/asm.c \
src/dummy.c \
src/gfx.c \
src/input.c \
src/main.c \
src/pick.c \
src/sim.c \
src/trace.c \
src/util.c

CXXSRCS = \
src/ui.cc \
src/ui_asm.cc


CXXOBJS = $(CXXSRCS:%.cc=%.o) ext/texteditor/TextEditor.o \
        fips-imgui/imgui/imgui.o \
        fips-imgui/imgui/imgui_demo.o \
        fips-imgui/imgui/imgui_draw.o \
        fips-imgui/imgui/imgui_tables.o \
        fips-imgui/imgui/imgui_widgets.o


OBJS = $(SRCS:%.c=%.o) $(CXXOBJS) ext/sokol/sokol.cc.o

CPPFLAGS = -Iext/asmx/src -Iext/sokol -Isokol -Iext/perfect6502 -Isrc/z80 -Iext -Ifips-imgui/imgui -DASMX_Z80 -DCHIP_Z80

-include config.mak

CXXFLAGS = $(CFLAGS)

all: $(APP)

src/gfx.o: src/gfx.glsl.h
$(CXXOBJS) ext/sokol/sokol.o ext/sokol/sokol.cc.o: CPPFLAGS += -Iext/texteditor -Isokol/util


# in reality, the header is generated via sokol-tools' "sokol-shdc" tool from
# src/gfx.glsl - however that program is such a pain in the ass to compile
# that even the author ships it as binary...
# as we dont wanna run binaries, i prepared output of the tool for different
# glsl versions. see src/gfx.*.h and set SHADER_LANG accordingly if the default
# doesnt work for you.
src/gfx.glsl.h:  src/gfx.$(SHADER_LANG).h
	cp -f $< $@

# sokol.cc is treated special here, because a sokol.c exists that would cause
# make to build sokol.o from the .c file, not the .cc one
ext/sokol/sokol.cc.o: ext/sokol/sokol.cc
	$(CXX) $(CFLAGS) $(CXXFLAGS) $(CPPFLAGS) -c -o $@ $^

$(APP): $(OBJS)
	$(CXX) $(CFLAGS) $(CXXFLAGS) -o $@ $^ -lGL -lXi -lXcursor -lX11 $(LDFLAGS)

clean:
	rm -f $(OBJS) src/gfx.glsl.h $(APP)

.PHONY: clean all
