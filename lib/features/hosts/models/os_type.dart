enum OsType {
  ubuntu,
  debian,
  fedora,
  centos,
  arch,
  alpine,
  linux,
  macos,
  freebsd,
  unknown;

  String? get assetPath => switch (this) {
    OsType.ubuntu  => 'assets/icons/os/ubuntu.png',
    OsType.debian  => 'assets/icons/os/debian.png',
    OsType.fedora  => 'assets/icons/os/fedora.png',
    OsType.centos  => 'assets/icons/os/centos.png',
    OsType.arch    => 'assets/icons/os/arch.png',
    OsType.alpine  => 'assets/icons/os/alpine.png',
    OsType.linux   => 'assets/icons/os/linux.png',
    _              => null,
  };

  String get label => switch (this) {
    OsType.ubuntu  => 'Ubuntu',
    OsType.debian  => 'Debian',
    OsType.fedora  => 'Fedora',
    OsType.centos  => 'CentOS',
    OsType.arch    => 'Arch Linux',
    OsType.alpine  => 'Alpine',
    OsType.linux   => 'Linux',
    OsType.macos   => 'macOS',
    OsType.freebsd => 'FreeBSD',
    OsType.unknown => 'Unknown',
  };

  static OsType fromUname(String uname, String? distroId) {
    final kernel = uname.trim().toLowerCase();
    if (kernel == 'darwin') return OsType.macos;
    if (kernel == 'freebsd') return OsType.freebsd;
    if (kernel != 'linux') return OsType.unknown;
    return _fromDistroId(distroId);
  }

  static OsType _fromDistroId(String? id) {
    switch (id?.toLowerCase().trim()) {
      case 'ubuntu':
        return OsType.ubuntu;
      case 'debian':
        return OsType.debian;
      case 'fedora':
        return OsType.fedora;
      case 'centos':
      case 'rhel':
      case 'rocky':
      case 'almalinux':
        return OsType.centos;
      case 'arch':
      case 'manjaro':
      case 'endeavouros':
        return OsType.arch;
      case 'alpine':
        return OsType.alpine;
      default:
        return OsType.linux;
    }
  }
}
