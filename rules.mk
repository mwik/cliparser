# Makefile rules for CLI Parser
# $Id: rules.mk 77 2009-03-20 08:11:11Z henry $

# Copyright (c) 2008-2009, Henry Kwok
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of the project nor the names of its contributors 
#       may be used to endorse or promote products derived from this software 
#       without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY HENRY KWOK ''AS IS'' AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL HENRY KWOK BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Define a root build directory based on the platform
ifeq ("$(OUTDIR)", "")
  OUTDIR = .
endif

ifeq ("$(PLATFORM)", "")
  # Without a platform defined, just use local directory
  BUILDDIR = .
  OBJDIR   = .
  BINDIR   = .
  LIBDIR   = .
else
  ifeq ("$(DEBUG)", "TRUE")
    BUILDDIR = $(OUTDIR)/$(SRC_BASE)/build/$(PLATFORM)_dbg
  else
    BUILDDIR = $(OUTDIR)/$(SRC_BASE)/build/$(PLATFORM)
  endif
  # Define the object, binary, and library directory
  OBJDIR = $(BUILDDIR)/obj/$(MODULE)
  BINDIR = $(BUILDDIR)/bin
  LIBDIR = $(BUILDDIR)/lib
endif

# Update compilation flags based on DEBUG
ifeq ("$(DEBUG)", "TRUE")
  CFLAGS += $(ETCFLAGS) -Wall -g -Werror -O0
else
  CFLAGS += $(ETCFLAGS) -Wall -Werror -O2
endif

# Add a bunch of default include path
SRC_INC += -I. -I../inc \
	   -I$(SRC_BASE)/inc \
	   -I$(SRC_BASE)/pool/inc \
	   -I$(SRC_BASE)/queue/inc \
	   -I$(SRC_BASE)/heap/inc \
	   -I$(SRC_BASE)/timer/inc \
	   -I$(SRC_BASE)/fsm/inc
SRC_OBJ = $(patsubst %.c,$(OBJDIR)/%.o,$(SRC_FILES))
SRC_DEP = $(patsubst %.c,$(OBJDIR)/%.d,$(SRC_FILES))

# Include the list of dependency files
-include $(SRC_DEP)

# Implicit rule to compile all source files
$(OBJDIR)/%.o:%.c
	@echo "  DEP     $<..."
	$(CC) $(CFLAGS) -MM $(SRC_INC) -MF $(patsubst %.o,%.d,$@) -MT $@ $< 
	@echo "  COMPILE $<..."
	$(CC) -c $(CFLAGS) $(SRC_INC) $< -o $@
ifneq ("$(LIBRARY)", "")
	@echo "  ARCHIVE $(notdir $@)..."
	$(AR) rcs $(LIBDIR)/$(LIBRARY) $@
endif

all: lib bin

dir: $(OBJDIR)

lib: dir $(SRC_OBJ)

bin: dir $(BINDIR)/$(SRC_BIN)

$(OBJDIR):
	@echo "  MKDIR obj/$(notdir $@)..."
	mkdir -p $@

# Build test programs
ifneq ("$(SRC_BIN)", "")
$(BINDIR)/$(SRC_BIN): $(SRC_OBJ) $(patsubst %,../../%,$(AR_LIST))
	@echo "  LINK    $(notdir $@)..."
	$(CC) $(SRC_OBJ) $(patsubst %,../../%,$(AR_LIST)) -o $(BINDIR)/$(SRC_BIN) $(SRC_LIB)
endif


clean: local_clean
	rm -f $(SRC_BIN) *.o $(SRC_BIN).exe 
	rm -f *.d

local_clean: