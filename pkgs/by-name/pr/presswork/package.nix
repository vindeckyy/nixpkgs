{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  avahi,
  maintainers,
}:

let
  version = "0.1.0";
in

rustPlatform.buildRustPackage {
  pname = "presswork";
  inherit version;

  src = fetchFromGitHub {
    owner = "vindeckyy";
    repo = "presswork";
    rev = "v${version}";
    hash = "sha256-dLSYJLv6LitBfuHKpglHQ8um+3/+C+cboObuOhZiEho=";
  };

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = "${src}/Cargo.lock";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ avahi ];

  checkFlags = [ "--workspace" ];

  postInstall = ''
    make install DESTDIR=$out PROFILE=release USER=root GROUP=root \
      SYSCONFDIR=/etc/cups SPOOLDIR=/var/spool/cups LOGDIR=/var/log/cups \
      CACHEDIR=/var/cache/cups RUNDIR=/run/cups

    mkdir -p $out/lib
    ln -s ../usr/lib/systemd $out/lib/systemd
  '';

  meta = {
    description = "Memory-safe CUPS 2.x-compatible print spooler and IPP scheduler in Rust";
    longDescription = ''
      presswork is a drop-in replacement for the CUPS scheduler (cupsd):
      the same IPP wire protocol, config files, spool layout, and
      filter/backend contracts, implemented in Rust with unsafe code
      confined to a single audited FFI crate.
    '';
    homepage = "https://github.com/vindeckyy/presswork";
    changelog = "https://github.com/vindeckyy/presswork/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.asl20 or lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "cupsd";
    maintainers = with maintainers; [ vindeckyy ];
  };
}
