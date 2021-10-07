PLUGIN=check_nagios_latency
VERSION=`cat VERSION`
DIST_DIR=$(PLUGIN)-$(VERSION)
DIST_FILES=AUTHORS COPYING COPYRIGHT ChangeLog INSTALL Makefile NEWS README TODO VERSION $(PLUGIN) $(PLUGIN).spec $(PLUGIN).1 NAME
SCRIPTS=$(PLUGIN) prepare_rpm.sh

dist: version_check
	rm -rf $(DIST_DIR) $(DIST_DIR).tar.gz
	mkdir $(DIST_DIR)
	cp $(DIST_FILES) $(DIST_DIR)
	tar cfz $(DIST_DIR).tar.gz  $(DIST_DIR)
	tar cfj $(DIST_DIR).tar.bz2 $(DIST_DIR)

install:
	mkdir -p $(DESTDIR)
	install -m 755 $(PLUGIN) $(DESTDIR)
	mkdir -p $(MANDIR)/man1
	install -m 644 $(PLUGIN).1 $(MANDIR)/man1/

version_check:
	VERSION=`cat VERSION`
	grep -q "VERSION\ *=\ *[\'\"]*$(VERSION)" $(PLUGIN)
	grep -q "^%define\ version\ *$(VERSION)" $(PLUGIN).spec
	grep -q -- "- $(VERSION)-" $(PLUGIN).spec
	grep -q "\"$(VERSION)\"" $(PLUGIN).1
	grep -q "$(VERSION)" NEWS
	echo "Version check: OK"

SHFMT= := $(shell command -v shfmt 2> /dev/null)
format:
ifndef SHFMT
	echo "No shfmt installed"
else
# -p POSIX
# -w write to file
# -s simplify
# -i 4 indent with 4 spaces
	shfmt -p -w -s -i 4 $(SCRIPTS)
endif

clean:
	rm -f *~

rpm: dist
	mkdir -p rpmroot/SOURCES rpmroot/BUILD
	cp $(DIST_DIR).tar.gz rpmroot/SOURCES
	rpmbuild --define "_topdir `pwd`/rpmroot" -ba check_nagios_latency.spec

SHUNIT := $(shell command -v shunit2 2> /dev/null || if [ -x /usr/share/shunit2/shunit2 ] ; then echo /usr/share/shunit2/shunit2 ; fi )

test: dist
ifndef SHUNIT
        echo "No shUnit2 installed: see README.md"
        exit 1
else
	echo "Performing unit tests"
        ( export SHUNIT2=$(SHUNIT) && export LC_ALL=C && cd test && ./unit_tests.sh )
endif

.PHONY: install clean test
