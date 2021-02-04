include $(top_srcdir)/build/modmake.rulesam
MODNAME=mod_speechpro_transcribe

mod_LTLIBRARIES = mod_speechpro_transcribe.la
mod_speechpro_transcribe_la_SOURCES  = mod_speechpro_transcribe.c speechpro_glue.cpp
mod_speechpro_transcribe_la_CFLAGS   = $(AM_CFLAGS)
mod_speechpro_transcribe_la_CXXFLAGS = -I speechproapi $(AM_CXXFLAGS) -std=c++11

mod_speechpro_transcribe_la_LIBADD   = $(switch_builddir)/libfreeswitch.la
mod_speechpro_transcribe_la_LDFLAGS  = -avoid-version -module -no-undefined -shared `pkg-config --libs grpc++ grpc`
