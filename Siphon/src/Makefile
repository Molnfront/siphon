CC=arm-apple-darwin-gcc
CXX=arm-apple-darwin-g++
LD=$(CC)

PRODUCT_NAME = Siphon
PRODUCT_APP=$(PRODUCT_NAME).app
BUILT_PRODUCTS_DIR = ../dist

APP_ABS=$(BUILT_PRODUCTS_DIR)/$(PRODUCT_APP)

LDFLAGS= -Wall \
	-framework CoreFoundation \
	-framework Foundation \
	-framework UIKit \
	-framework LayerKit \
	-framework GraphicsServices \
	-framework WebCore \
	-framework CoreGraphics \
	-framework AudioToolbox  \
	-framework iTunesStore \
	-framework Message  \
	-framework Celestial \
	-framework MobileMusicPlayer \
	-framework WebKit \
	-framework AddressBookUI \
	-framework AddressBook \
	-lobjc \
	-lssl -lcrypto \
	-L../pjsip/lib \
	-lresample-arm-apple-darwin \
	-lsrtp-arm-apple-darwin \
	-lpjsua-arm-apple-darwin \
	-lpjsip-simple-arm-apple-darwin \
	-lpjsip-ua-arm-apple-darwin \
	-lpjsip-arm-apple-darwin \
	-lpjmedia-arm-apple-darwin \
	-lpjnath-arm-apple-darwin \
	-lpjlib-util-arm-apple-darwin \
	-lpj-arm-apple-darwin
	
CFLAGS= -O2 \
	-I../pjsip/include \
	-DPJ_DARWINOS=1 \
	-DOPEN=1


TARGET=Siphon
VERSION=2.0

YOUTUBE_RESOURCES = \
	History.png HistorySelected.png \
	More.png MoreSelected.png \
	MostViewed.png MostViewedSelected.png \
	TopRated.png TopRatedSelected.png

RESOURCES = icon.png Dial.png DialSelected.png

INFOPLIST_FILE=Info.plist

LANGUAGES=$(wildcard *.lproj)

SOURCES=\
	main.m \
	Siphon.m \
	AccountView.m \
	PhoneView.m \
	ring.c \
	call.c \
	dtmf.c


OBJECTS= \
	$(patsubst %.c,%.o,$(filter %.c,$(SOURCES))) \
	$(patsubst %.m,%.o,$(filter %.m,$(SOURCES)))

all:	$(TARGET)

$(TARGET): $(OBJECTS)
	mkdir -p $(APP_ABS)
	$(LD) $(LDFLAGS) -o $(APP_ABS)/$@ $^
	cp $(RESOURCES) $(INFOPLIST_FILE) $(APP_ABS)/
	for i in $(YOUTUBE_RESOURCES); do \
		ln -s /Applications/YouTube.app/$$i $(APP_ABS)/$$i; \
	done
	for i in $(LANGUAGES); do \
		mkdir -p $(APP_ABS)/$$i; \
		cp $$i/Localizable.strings $(APP_ABS)/$$i; \
	done
	mkdir -p $(APP_ABS)/skins
	cp skins/*.png $(APP_ABS)/skins/


%.o:	%.m
	$(CC) -Wall -c $(CFLAGS) $(CPPFLAGS) $< -o $@

%.o:	%.c
	$(CC) -Wall -c $(CFLAGS) $(CPPFLAGS) $< -o $@

clean:
	rm -rf *.o *~ $(APP_ABS)

