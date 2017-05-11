#!/bin/sh
# wrapper for svn+ssh based connections

# set the umask so files are group-wriable
umask 002

# call the 'real' svnserve, also passing in the default repo location
# TODO: set root here
exec /usr/bin/svnserve "$@"
