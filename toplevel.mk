# Toplevel make rules
# $Id: toplevel.mk 132 2009-05-07 09:33:05Z henry $
#
# This file is the top-level make rules for all targets. Each target
# is uniquely defined by (BS or MS, platform); e.g. (BS, simulation).
# For each target, there should be a Makefile.[target]. Each target
# top-level Makefile should have the following variables:
#
# PLATFORM - Define a target string; e.g. bs_sim
#
# MODULE_LIST - A list of module directories. Each module directory
#     will produce a [module].a library; e.g. tlv.a.
#
# BIN_LIST - A list of application directories. Each directory will
#     produce an application binary.
#
# TEST_LIST - A list of test program directories. Each directory will
#     produce a  test program. This variable is optional. But usually,
#     each module will have its own test programs.
#
# To add a new target, simply create a Makefile.[target] with the
# variables listed above. The last line should be "include toplevel.mk".
# Also, create a target in mac/Makefile.
#

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

ifeq ("$(OUTDIR)", "")
OUTDIR = .
endif

ifeq ("$(DEBUG)", "TRUE")
BUILDDIR = $(OUTDIR)/build/$(PLATFORM)_dbg
else
BUILDDIR = $(OUTDIR)/build/$(PLATFORM)
endif

DIR_LIST = $(patsubst %,%.PHONY,$(MODULE_LIST) $(BIN_LIST) $(LIB_LIST))

CLEAN_LIST = $(patsubst %,%.PHONY_CLEAN,$(MODULE_LIST))

$(BUILDDIR):
	@echo "MKDIR $@"
	mkdir -p $(BUILDDIR)/obj $(BUILDDIR)/bin $(BUILDDIR)/lib

$(DIR_LIST):
	@echo "MAKE $(basename $@)"
	$(MAKE) PLATFORM=$(PLATFORM) MODULE=$(basename $@) DEBUG="$(DEBUG)" LIBRARY=$(LIBRARY) -C $(basename $@)/src all

$(TEST_LIST):
	@echo "MAKE TEST $(dir $@):$(notdir $@)..."
	$(MAKE) PLATFORM=$(PLATFORM) MODULE=$(dir $@) DEBUG="$(DEBUG)" -C $(dir $@)src -f Makefile.$(notdir $@) all

$(CLEAN_LIST):
	@echo "CLEAN $(basename $@)"
	$(MAKE) PLATFORM=$(PLATFORM) MODULE=$(basename $@) DEBUG="$(DEBUG)" LIBRARY=$(LIBRARY) -C $(basename $@)/src clean

bin: $(BUILDDIR) $(DIR_LIST)

all: bin $(TEST_LIST)

NIGHTLY_DIR = ./scripts/nightly
NIGHTLY_UNIT_TEST = env PYTHONPATH=$(NIGHTLY_DIR)/sql_driver $(NIGHTLY_DIR)/unit_tests/nightly_run.py

tests: all
	$(NIGHTLY_UNIT_TEST) --bin-dir=$(BUILDDIR)/bin $(notdir $(TEST_LIST))

tests_logged: all
	$(NIGHTLY_UNIT_TEST) --user=root --project=CLI_Parser --target=$(PLATFORM) --bin-dir=$(BUILDDIR)/bin $(TEST_LIST)

clean: $(CLEAN_LIST)
	@echo "CLEAN $(notdir $(BUILDDIR))"
	rm -fr $(BUILDDIR)
