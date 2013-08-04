TARGETS = htmlcup.js

all: $(TARGETS)

clean:
	rm -rf $(TARGETS)

htmlcup.js: ../htmlcup.coffee
	coffee -o . -c ../htmlcup.coffee
