CC=arm-apple-darwin-gcc
CXX=arm-apple-darwin-g++
LD=$(CC)
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
	$(LD) $(LDFLAGS) -o ../Siphon.app/$@ $^

%.o:	%.m
	$(CC) -Wall -c $(CFLAGS) $(CPPFLAGS) $< -o $@

%.o:	%.c
	$(CC) -Wall -c $(CFLAGS) $(CPPFLAGS) $< -o $@

clean:
	rm -rf *.o *~ ../Siphon.app/$(TARGET)

