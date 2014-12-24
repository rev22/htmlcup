TARGETS=htmlcup.js test/test.html test/extending-library.html test/primer.html

all: $(TARGETS)

clean:
	rm -f $(TARGETS)


%.html: %.html.coffee
	(sh -c "coffee $< >$@.new" && mv $@.new $@ && touch -r $< $@) || rm -f $@

%.js: %.coffee
	coffee -bc $<


lib/coffee-script.js: ../reflective-coffeescript/extras/coffee-script.js
	cp -av $< $@
