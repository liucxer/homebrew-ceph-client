class CephClient < Formula
  desc "Ceph client tools and libraries"
  homepage "https://ceph.com"
  url "https://github.com/ceph/ceph.git", :using => :git, :tag => "v13.2.2", :revision => "02899bfda814146b021136e9d8e80eba494e1126"
  version "mimic-13.2.2"

  depends_on python if MacOS.version <= :snow_leopard

  depends_on "openssl" => :build
  depends_on "cmake" => :build
  depends_on "cython" => :build
  depends_on "leveldb" => :build
  depends_on "nss"
  depends_on "pkg-config" => :build
  depends_on "yasm"

  patch :DATA

  def install
    ENV.prepend_path "PKG_CONFIG_PATH", "#{Formula["nss"].opt_lib}/pkgconfig"
    ENV.prepend_path "PKG_CONFIG_PATH", "#{Formula["openssl"].opt_lib}/pkgconfig"
    system "./do_cmake.sh",
              "-DCMAKE_BUILD_TYPE=Debug",
              "-DCMAKE_C_COMPILER=clang",
              "-DCMAKE_CXX_COMPILER=clang++",
              "-DDIAGNOSTICS_COLOR=always",
              "-DOPENSSL_INCLUDE_DIR=/usr/local/opt/openssl/include",
              "-DWITH_BABELTRACE=OFF",
              "-DWITH_BLUESTORE=OFF",
              "-DWITH_CCACHE=ON",
              "-DWITH_CEPHFS=ON",
              "-DWITH_EMBEDDED=OFF",
              "-DWITH_KRBD=OFF",
              "-DWITH_LIBCEPHFS=OFF",
              "-DWITH_LTTNG=OFF",
              "-DWITH_LZ4=OFF",
              "-DWITH_MANPAGE=ON",
              "-DWITH_RADOSGW=OFF",
              "-DWITH_RDMA=OFF",
              "-DWITH_SPDK=OFF",
              "-DWITH_SYSTEMD=OFF",
              "-DWITH_XFS=OFF"
    system "make", "--directory=build", "rados", "rbd",  "manpages"
    MachO.open("build/bin/rados").linked_dylibs.each do |dylib|
      unless dylib.start_with?("/tmp/")
        next
      end
      MachO::Tools.change_install_name("build/bin/rados", dylib, "#{lib}/#{dylib.split('/')[-1]}")
    end
    MachO.open("build/bin/rbd").linked_dylibs.each do |dylib|
      unless dylib.start_with?("/tmp/")
        next
      end
      MachO::Tools.change_install_name("build/bin/rbd", dylib, "#{lib}/#{dylib.split('/')[-1]}")
    end
    bin.install "build/bin/ceph"
    bin.install "build/bin/rados"
    bin.install "build/bin/rbd"
    lib.install "build/lib/libceph-common.0.dylib"
    lib.install "build/lib/libceph-common.dylib"
    lib.install "build/lib/librados.2.0.0.dylib"
    lib.install "build/lib/librados.2.dylib"
    lib.install "build/lib/librados.dylib"
    lib.install "build/lib/libradosstriper.1.0.0.dylib"
    lib.install "build/lib/libradosstriper.1.dylib"
    lib.install "build/lib/libradosstriper.dylib"
    lib.install "build/lib/librbd.1.12.0.dylib"
    lib.install "build/lib/librbd.1.dylib"
    lib.install "build/lib/librbd.dylib"
    man8.install "build/doc/man/ceph-conf.8"
    man8.install "build/doc/man/ceph.8"
    man8.install "build/doc/man/librados-config.8"
    man8.install "build/doc/man/rados.8"
    man8.install "build/doc/man/rbd-ggate.8"
    man8.install "build/doc/man/rbd-mirror.8"
    man8.install "build/doc/man/rbd-nbd.8"
    man8.install "build/doc/man/rbd-replay-many.8"
    man8.install "build/doc/man/rbd-replay-prep.8"
    man8.install "build/doc/man/rbd-replay.8"
    man8.install "build/doc/man/rbd.8"
    man8.install "build/doc/man/rbdmap.8"
    ENV.prepend_create_path "PYTHONPATH", libexec
    libexec.install "src/pybind/ceph_argparse.py"
    libexec.install "src/pybind/ceph_daemon.py"
    libexec.install "src/pybind/ceph_volume_client.py"
    bin.env_script_all_files(libexec/"bin", :PYTHONPATH => ENV["PYTHONPATH"])
  end

  test do
    system "#{bin}/ceph", "--version"
    system "#{bin}/rbd", "--version"
    system "#{bin}/rados", "--version"
  end
end

__END__
diff --git a/src/include/any.h b/src/include/any.h
index 73e729b495..241e0e6d51 100644
--- a/src/include/any.h
+++ b/src/include/any.h
@@ -15,17 +15,10 @@
#ifndef INCLUDE_STATIC_ANY
#define INCLUDE_STATIC_ANY

-#if __has_include(<any>)
-#include <any>
-namespace ceph {
-  using std::bad_any_cast;
-}
-#else
#include <boost/any.hpp>
namespace ceph {
    using boost::bad_any_cast;
}
-#endif

#include <cstddef>
#include <initializer_list>