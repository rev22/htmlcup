TARGETS= test/test.html test/extending-library.html

all: $(TARGETS)

clean:
	rm -f $(TARGETS)

%.html: %.html.coffee
	(sh -c "coffee $< >$@.new" && mv $@.new $@ && touch -r $< $@) || rm -f $@

%.html: %.htmlcup
	(sh -c "coffee $< >$@.new" && mv $@.new $@ && touch -r $< $@) || rm -f $@

