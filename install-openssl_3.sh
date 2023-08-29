#!/bin/bash

# Падаем сразу, если возникли какие-то ошибки
set -e
# Выводим, то , что делаем
set -v
mkdir ~/openssl && cd ~/openssl
yum -y install \
    curl \
    which \
    make \
    gcc \
    perl \
    perl-WWW-Curl \
    rpm-build \
    perl-IPC-Cmd

yum -y remove openssl

# Get openssl tarball
curl -O --silent https://www.openssl.org/source/openssl-3.1.2.tar.gz

# SPEC file
cat << 'EOF' > ~/openssl/openssl3.spec
Summary: OpenSSL 3.1.2 for Centos
Name: openssl
Version: %{?version}%{!?version:3.1.2}
Release: 1%{?dist}
Obsoletes: %{name} <= %{version}
Provides: %{name} = %{version}
URL: https://www.openssl.org/
License: GPLv2+

Source: https://www.openssl.org/source/%{name}-%{version}.tar.gz

BuildRequires: make gcc perl perl-WWW-Curl
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
%global openssldir /usr

%description
https://github.com/philyuchkoff/openssl-RPM-Builder
OpenSSL RPM for version 3.1.2 on CentOS

%package devel
Summary: Development files for programs which will use the openssl library
Group: Development/Libraries
Requires: %{name} = %{version}-%{release}

%description devel
OpenSSL RPM for version 3.1.2 on CentOS (development package)

%prep
%setup -q

%build
./config --prefix=%{openssldir} --openssldir=%{openssldir}
make

%install
[ "%{buildroot}" != "/" ] && %{__rm} -rf %{buildroot}
%make_install

mkdir -p %{buildroot}%{_bindir}
mkdir -p %{buildroot}%{_libdir}

%clean
[ "%{buildroot}" != "/" ] && %{__rm} -rf %{buildroot}

%files
%{openssldir}
%defattr(-,root,root)

%files devel
%{openssldir}/include/*
%defattr(-,root,root)

%post -p /sbin/ldconfig

%postun -p /sbin/ldconfig
EOF


mkdir -p /root/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
cp ~/openssl/openssl3.spec /root/rpmbuild/SPECS/openssl.spec

mv openssl-3.1.2.tar.gz /root/rpmbuild/SOURCES
cd /root/rpmbuild/SPECS && \
    rpmbuild \
    -D "version 3.1.2" \
    -ba openssl.spec
