TARGETS=lib/htmlcup.js test/test.html test/extending-library.html test/primer.html

all: $(TARGETS)

clean:
	rm -f $(TARGETS)
	make -C lib clean

%.html: %.html.coffee
	(sh -c "coffee $< >$@.new" && mv $@.new $@ && touch -r $< $@) || rm -f $@

%.html: %.htmlcup
	(sh -c "coffee $< >$@.new" && mv $@.new $@ && touch -r $< $@) || rm -f $@

lib/htmlcup.js: htmlcup.coffee
	make -C lib htmlcup.js

