sudo apt-get install libssl-dev
sudo gem install fpm

wget https://cache.ruby-lang.org/pub/ruby/2.2/ruby-2.2.3.tar.gz
tar -zxvf ruby-2.2.3.tar.gz
cd ./ruby-2.2.3
./configure --prefix=/usr/local && make && make install DESTDIR=/tmp/installdir

fpm -s dir -t deb -n ruby -v 2.2.3 -C /tmp/installdir \
  -p ruby-2.2.3-2_amd64.deb -d "libstdc++6 (>= 4.4.3)" \
  -d "libc6 (>= 2.6)" -d "libffi6 (>= 3.0.4)" -d "libgdbm3 (>= 1.8.3)" \
  -d "libncurses5 (>= 5.7)" -d "libreadline6 (>= 6.1)" \
  -d "libssl1.0.0 (>= 1.0.0)" -d "zlib1g (>= 1:1.2.2)" \
  usr/local/bin usr/local/lib usr/local/share/man usr/local/include


This is script to package ruby.
Change the version and name acordingly
