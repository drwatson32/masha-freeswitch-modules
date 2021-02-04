include $(top_srcdir)/build/modmake.rulesam
MODNAME=mod_yandex_transcribe

mod_LTLIBRARIES = mod_yandex_transcribe.la
mod_yandex_transcribe_la_SOURCES  = mod_yandex_transcribe.c yandex_glue.cpp
mod_yandex_transcribe_la_CFLAGS   = $(AM_CFLAGS)
mod_yandex_transcribe_la_CXXFLAGS = -I cloudapi $(AM_CXXFLAGS) -std=c++11

mod_yandex_transcribe_la_LIBADD   = $(switch_builddir)/libfreeswitch.la
mod_yandex_transcribe_la_LDFLAGS  = -avoid-version -module -no-undefined -shared `pkg-config --libs grpc++ grpc`
