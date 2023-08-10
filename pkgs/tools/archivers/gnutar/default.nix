{ lib, stdenv, fetchurl, autoreconfHook, acl, libintl }:

# Note: this package is used for bootstrapping fetchurl, and thus
# cannot use fetchpatch! All mutable patches (generated by GitHub or
# cgit) that are needed here should be included directly in Nixpkgs as
# files.

stdenv.mkDerivation rec {
  pname = "gnutar";
  version = "1.35";

  src = fetchurl {
    url = "mirror://gnu/tar/tar-${version}.tar.xz";
    sha256 = "sha256-TWL/NzQux67XSFNTI5MMfPlKz3HDWRiCsmp+pQ8+3BY=";
  };

  # avoid retaining reference to CF during stdenv bootstrap
  configureFlags = lib.optionals stdenv.isDarwin [
    "gt_cv_func_CFPreferencesCopyAppValue=no"
    "gt_cv_func_CFLocaleCopyCurrent=no"
    "gt_cv_func_CFLocaleCopyPreferredLanguages=no"
  ];

  # gnutar tries to call into gettext between `fork` and `exec`,
  # which is not safe on darwin.
  # see http://article.gmane.org/gmane.os.macosx.fink.devel/21882
  postPatch = lib.optionalString stdenv.isDarwin ''
    substituteInPlace src/system.c --replace '_(' 'N_('
  '';

  outputs = [ "out" "info" ];

  nativeBuildInputs = lib.optional stdenv.isDarwin autoreconfHook;
  # Add libintl on Darwin specifically as it fails to link (or skip)
  # NLS on it's own:
  #  "_libintl_textdomain", referenced from:
  #    _main in tar.o
  #  ld: symbol(s) not found for architecture x86_64
  buildInputs = lib.optional stdenv.isLinux acl ++ lib.optional stdenv.isDarwin libintl;

  # May have some issues with root compilation because the bootstrap tool
  # cannot be used as a login shell for now.
  FORCE_UNSAFE_CONFIGURE = lib.optionalString (stdenv.hostPlatform.system == "armv7l-linux" || stdenv.isSunOS) "1";

  preConfigure = if stdenv.isCygwin then ''
    sed -i gnu/fpending.h -e 's,include <stdio_ext.h>,,'
  '' else null;

  doCheck = false; # fails
  doInstallCheck = false; # fails

  meta = {
    description = "GNU implementation of the `tar' archiver";
    longDescription = ''
      The Tar program provides the ability to create tar archives, as
      well as various other kinds of manipulation.  For example, you
      can use Tar on previously created archives to extract files, to
      store additional files, or to update or list files which were
      already stored.

      Initially, tar archives were used to store files conveniently on
      magnetic tape.  The name "Tar" comes from this use; it stands
      for tape archiver.  Despite the utility's name, Tar can direct
      its output to available devices, files, or other programs (using
      pipes), it can even access remote devices or files (as
      archives).
    '';
    homepage = "https://www.gnu.org/software/tar/";

    license = lib.licenses.gpl3Plus;

    maintainers = [ ];
    mainProgram = "tar";
    platforms = lib.platforms.all;

    priority = 10;
  };
}
