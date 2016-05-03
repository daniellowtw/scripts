
sudo apt-get install libtool debhelper dh-reconf
git clone https://code.google.com/p/libnfc/
cd libnfc
git checkout libnfc-1.7.1
git clean -d -f -x
#rm ../libnfc*.deb
git remote|grep -q anonscm||git remote add anonscm git://anonscm.debian.org/collab-maint/libnfc.git
git fetch anonscm
git checkout remotes/anonscm/master debian
git reset
dpkg-buildpackage -uc -us -b
