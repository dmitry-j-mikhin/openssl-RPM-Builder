set -ex

docker run -it --rm \
 -v `realpath .`:/tmp/build \
 centos:7 \
 sh -c \
"yum -y groupinstall 'Development Tools'
 bash /tmp/build/install-openssl_3.sh
 rm -rf /tmp/build/result
 mkdir -p /tmp/build/result
 cp -a -v /root/rpmbuild/* /tmp/build/result
"