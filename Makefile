CC=/usr/local/bin/arm-apple-darwin-gcc
CXX=/usr/local/bin/arm-apple-darwin-g++
CFLAGS=-fsigned-char
LDFLAGS=-lobjc -ObjC -mmacosx-version-min=10.1 -framework CoreFoundation -framework Foundation -framework UIKit -framework LayerKit -framework OfficeImport -framework WebCore -framework CoreGraphics -lsqlite3 -framework GraphicsServices -framework CoreSurface -framework Celestial
LD=$(CC)

all:	RSS RSSDaemon badgeUpdate package

RSS:	source/main.o source/RSS.o source/EyeCandy.o source/Feeds.o source/ItemView.o source/FMDatabase/FMDatabase.o source/FMDatabase/FMDatabaseAdditions.o source/FMDatabase/FMResultSet.o source/Settings.o source/FeedList.o source/EditorKeyboard.o source/UIView-Color.o source/FeedTextField.o source/FeedTable.o source/QuickAdd.o source/FeedTableCell.o source/Import.o source/FeedView.o source/ThreadProcesses.o
	$(LD) $(LDFLAGS) -o $@ $^
	
RSSDaemon:	source/daemon/main.o source/daemon/RSSDaemon.o source/daemon/Feeds.o source/daemon/FMDatabase/FMDatabase.o source/daemon/FMDatabase/FMDatabaseAdditions.o source/daemon/FMDatabase/FMResultSet.o
	$(LD) $(LDFLAGS) -o $@ $^

badgeUpdate:	source/badgeUpdate/main.o source/badgeUpdate/badgeUpdate.o source/badgeUpdate/FMDatabase/FMDatabase.o source/badgeUpdate/FMDatabase/FMDatabaseAdditions.o source/badgeUpdate/FMDatabase/FMResultSet.o
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
	mv RSSDaemon ./build/RSS.app/
	mv badgeUpdate ./build/RSS.app/
	rm -rf ./build/RSS.app/.svn
	rm -rf ./build/RSS.app/.DS_Store

clean:
	rm -f source/*.o RSS RSSDaemon badgeUpdate
	rm -rf ./build
