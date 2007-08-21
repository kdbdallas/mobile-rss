CC=arm-apple-darwin-cc
LD=$(CC)
LDFLAGS=-lobjc -framework CoreFoundation -framework Foundation -framework UIKit -framework LayerKit

all:	RSS package

RSS:	src/main.o src/MobileRSS.o
	$(LD) $(LDFLAGS) -o $@ $^

%.o:	%.m
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

%.o:	%.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

%.o:	%.cpp
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

package:
	rm -rf build
	mkdir build
	cp -r ./src/RSS.app ./build
	mv RSS ./build/RSS.app

clean:
	rm -f src/*.o RSS
	rm -rf ./build