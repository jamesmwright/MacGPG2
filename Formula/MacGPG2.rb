require 'formula'

class Macgpg2 < Formula
  url 'ftp://ftp.gnupg.org/gcrypt/gnupg/gnupg-2.0.30.tar.bz2'
  homepage 'http://www.gnupg.org/'
  sha1 'a9f024588c356a55e2fd413574bfb55b2e18794a'
  
  depends_on 'libgcrypt'

  depends_on 'libiconv'
  depends_on 'gettext'
  depends_on 'pth'
  depends_on 'libusb-compat'
  depends_on 'libgpg-error'
  depends_on 'libassuan'
  depends_on 'curl'
  depends_on 'libksba'
  depends_on 'zlib'
  depends_on 'adns'
  
  keep_install_names true
  
  def patches
    { :p1 => ["#{HOMEBREW_PREFIX}/Library/Formula/Patches/gnupg2/other.patch",
              "#{HOMEBREW_PREFIX}/Library/Formula/Patches/gnupg2/socket.patch",
              "#{HOMEBREW_PREFIX}/Library/Formula/Patches/gnupg2/gpg-agent.patch",
              "#{HOMEBREW_PREFIX}/Library/Formula/Patches/gnupg2/gpg-agent-sha-2.patch",
              "#{HOMEBREW_PREFIX}/Library/Formula/Patches/gnupg2/MacGPG2VersionString.patch",
              "#{HOMEBREW_PREFIX}/Library/Formula/Patches/gnupg2/passphrase-fd.patch",
              "#{HOMEBREW_PREFIX}/Library/Formula/Patches/gnupg2/exec_write_stderr.patch",
              "#{HOMEBREW_PREFIX}/Library/Formula/Patches/gnupg2/pcsc-wrapper.patch",
              "#{HOMEBREW_PREFIX}/Library/Formula/Patches/gnupg2/install_gpgsplit.patch",
              "#{HOMEBREW_PREFIX}/Library/Formula/Patches/gnupg2/gpg-zip.patch",
              "#{HOMEBREW_PREFIX}/Library/Formula/Patches/gnupg2/options.skel.patch"] }
  end

  def install
    (var+'run').mkpath

    # Make sure that deployment target is 10.6+ so the lib works
    # on 10.6 and up not only on host system os x version.
    ENV.universal_binary if ARGV.build_universal?
    ENV.macosxsdk("10.6")
    
    # so we don't use Clang's internal stdint.h
    ENV['gl_cv_absolute_stdint_h'] = "#{MacOS.sdk_path}/usr/include/stdint.h"
    
    # It's necessary to add the -rpath to the LDFLAGS, otherwise
    # programs can't link to libraries using @rpath.
    ENV.prepend 'LDFLAGS', '-headerpad_max_install_names'
    ENV.prepend 'LDFLAGS', "-Wl,-rpath,@loader_path/../lib -Wl,-rpath,#{HOMEBREW_PREFIX}/lib"

    ENV.append 'LDFLAGS', '-lresolv'
    
    
    final_install_directory = "/usr/local/MacGPG2"
    
        
    system "./configure", "--prefix=#{prefix}",
                          "--disable-maintainer-mode",
                          "--disable-dependency-tracking",
                          "--enable-symcryptrun",
                          "--enable-standard-socket",
                          "--with-pinentry-pgm=#{final_install_directory}/libexec/pinentry-mac.app/Contents/MacOS/pinentry-mac",
                          "--with-agent-pgm=#{final_install_directory}/bin/gpg-agent",
                          "--with-scdaemon-pgm=#{final_install_directory}/libexec/scdaemon",
                          "--with-dirmngr-pgm=#{final_install_directory}/bin/dirmngr", # It's not possible to disable it, so at least have the right path. 
                          "--with-libgpg-error-prefix=#{HOMEBREW_PREFIX}",
                          "--with-libgcrypt-prefix=#{HOMEBREW_PREFIX}",
                          "--with-libassuan-prefix=#{HOMEBREW_PREFIX}",
                          "--with-ksba-prefix=#{HOMEBREW_PREFIX}",
                          "--with-pth-prefix=#{HOMEBREW_PREFIX}",
                          "--with-zlib=#{HOMEBREW_PREFIX}",
                          "--with-libiconv-prefix=#{HOMEBREW_PREFIX}",
                          "--with-libintl-prefix=#{HOMEBREW_PREFIX}",
                          "--with-libcurl=#{HOMEBREW_PREFIX}",
                          "--with-adns=#{HOMEBREW_PREFIX}"
                         
    system "make"
    system "make check"
    system "make install"
    
    
    # Homebrew doesn't like touching libexec for some reason.
    # That's why we have to manually symlink.
    # Also uninstalling wouldn't take care of libexec, so I've pachted keg.rb
    Pathname.new("#{HOMEBREW_PREFIX}/libexec/gnupg-pcsc-wrapper").make_relative_symlink("#{prefix}/libexec/gnupg-pcsc-wrapper")
    Pathname.new("#{HOMEBREW_PREFIX}/libexec/gpg2keys_curl").make_relative_symlink("#{prefix}/libexec/gpg2keys_curl")
    Pathname.new("#{HOMEBREW_PREFIX}/libexec/gpg2keys_finger").make_relative_symlink("#{prefix}/libexec/gpg2keys_finger")
    Pathname.new("#{HOMEBREW_PREFIX}/libexec/gpg2keys_hkp").make_relative_symlink("#{prefix}/libexec/gpg2keys_hkp")
    Pathname.new("#{HOMEBREW_PREFIX}/libexec/gpg2keys_ldap").make_relative_symlink("#{prefix}/libexec/gpg2keys_ldap")
    Pathname.new("#{HOMEBREW_PREFIX}/libexec/scdaemon").make_relative_symlink("#{prefix}/libexec/scdaemon")
  end
end

