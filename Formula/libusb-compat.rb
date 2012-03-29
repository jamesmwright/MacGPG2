require 'formula'

class LibusbCompat < Formula
  url 'http://downloads.sourceforge.net/project/libusb/libusb-compat-0.1/libusb-compat-0.1.3/libusb-compat-0.1.3.tar.bz2'
  homepage 'http://www.libusb.org/'
  md5 '570ac2ea085b80d1f74ddc7c6a93c0eb'
  
  depends_on 'pkg-config' => :build
  depends_on 'libusb'
  
  keep_install_names true
  
  def install
    # Otherwise homebrew fails to find libusb.
    dep = Formula.factory 'libusb'
    ENV.prepend 'PKG_CONFIG_PATH', dep.lib+'pkgconfig', ':'
    ENV.prepend 'LDFLAGS', '-headerpad_max_install_names'
    
    system "./configure", "--prefix=#{prefix}", 
           "--enable-static=no", "--disable-dependency-tracking"
    system "make check"
    system "make install"
  end
end

