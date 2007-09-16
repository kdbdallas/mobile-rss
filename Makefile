CC=arm-apple-darwin-cc
LD=$(CC)
LDFLAGS=-lobjc -framework CoreFoundation -framework Foundation -framework UIKit -framework LayerKit -framework OfficeImport -framework WebCore -framework CoreGraphics

all:	RSS package

RSS:	source/main.o source/RSS.o source/EyeCandy.o source/SettingsView.o source/Feeds.o source/ItemView.o source/toolBar.o source/EditorKeyboard.o
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
	cp -r ./source/RSS.app ./build
	mv RSS ./build/RSS.app

clean:
	rm -f source/*.o RSS
	rm -rf ./build
