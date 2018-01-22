# Copyright (C) 2013-2015 Dr. Alistair Ward
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

%define package		%name-%version
%define tarBall		%package.tar.gz
%define _sharedir	%prefix/share
%define _docdir		%_sharedir/doc/%name
%define _mandir		%_sharedir/man

Summary:	Calculates file-size frequency-distribution.
Name:		fishfood
Version:	0.0.1.8
Release:	1
License:	GPLv3
# From '/usr/share/doc/packages/rpm/GROUPS'.
Group:		Applications/File
Source0:	https://functionalley.eu/Downloads/sdist/%tarBall
URL:		https://functionalley.eu
Prefix:		/usr
BuildRequires:	haskell-platform

%description
Counts the number of files in a set of bins, each of which holds only those files which fall within a specific size-interval.

%prep
# N.B.: CWD has changed to %_builddir
echo 'package="%package", prefix="%prefix", _builddir="%_builddir", buildroot="%buildroot"'
(cd $OLDPWD && cabal sdist) && tar -zxf $OLDPWD/dist/%tarBall	# Make a source-distribution & unpack it into the build-directory.
cd '%package/' && cabal configure --user --prefix='%prefix' --docdir='%_docdir'	# Tell cabal to use the user's personal package-database, to generate an appropriate "Paths" module, & where to place the documentation.

%build
cd '%package/' && cabal build	# Descend into the source-distribution and build according to the previously established configuration.

%install
cd '%package/'	# Descend into the build-directory.
cabal copy --destdir='%buildroot'	# Install the built package in the target-directory.
mkdir -p -- '%buildroot%_docdir' && mv 'changelog.markdown' 'copyright' 'README.markdown' '%buildroot%_docdir/'	# 'LICENSE' has already been copied by cabal.
mkdir -p -- '%buildroot%_mandir' && mv 'man/man1' '%buildroot%_mandir/'
rm -rf -- '%buildroot%prefix/lib/'	# The library isn't a deliverable.

%clean
rm -rf -- '%_builddir/%package/' '%buildroot/'	# Only the '.rpm' is required.

%files
%attr(0755, root, root)		%prefix/bin/%name
%attr(0644, root, root)	%doc	%_docdir/changelog.markdown
%attr(0644, root, root)	%doc	%_docdir/copyright
%attr(0644, root, root)	%doc	%_docdir/LICENSE
%attr(0644, root, root)	%doc	%_docdir/README.markdown
%attr(0644, root, root)	%doc	%_mandir/man1/%name.1.gz

%changelog
* Tue Jul 16 2013	Alistair Ward	<fishfood@functionalley.eu>	0.0.0.2-1
First cut.

