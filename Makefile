PREFIX = /usr/local

all: validicitytool

validicitytool: bin/validicitytool.dart
	pub run pubspec_extract
	dart2native -o $@ $^

.PHONY: install
install: validicitytool
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	cp $< $(DESTDIR)$(PREFIX)/bin/$<

.PHONY: uninstall
uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/validicitytool

.PHONY: clean
clean:
	rm -f validicitytool
	touch bin/validicitytool.dart
