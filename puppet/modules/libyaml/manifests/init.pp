class libyaml(
  $autotools_environment = {},
  $file_cache_dir = params_lookup('file_cache_dir', 'global'),
  $prefix = params_lookup('prefix'),
) {
  require build_essential

  $source_filename  = "yaml-0.1.4.tar.gz"
  $source_url = "http://pyyaml.org/download/libyaml/${source_filename}"
  $source_file_path = "${file_cache_dir}/${source_filename}"
  $source_dir_name  = regsubst($source_filename, '^(.+?)\.tar\.gz$', '\1')
  $source_dir_path  = "${file_cache_dir}/${source_dir_name}"

  # Determine if we have an extra environmental variables we need to set
  # based on the operating system.
  if $operatingsystem == 'Darwin' {
    $extra_autotools_environment = {
      "LDFLAGS" => "-Wl,-install_name,@rpath/libyaml.dylib",
    }
  } else {
    $extra_autotools_environment = {}
  }

  # Merge our environments.
  $real_autotools_environment = autotools_merge_environments(
    $autotools_environment, $extra_autotools_environment)

  #------------------------------------------------------------------
  # Compile
  #------------------------------------------------------------------
  wget::fetch { "libyaml":
    source      => $source_url,
    destination => $source_file_path,
  }

  exec { "untar-libyaml":
    command => "tar xvzf ${source_file_path}",
    creates => $source_dir_path,
    cwd     => $file_cache_dir,
    require => Wget::Fetch["libyaml"],
  }

  autotools { "libyaml":
    configure_flags => "--prefix=${prefix} --disable-dependency-tracking",
    cwd             => $source_dir_path,
    environment     => $real_autotools_environment,
    require         => Exec["untar-libyaml"],
  }
}