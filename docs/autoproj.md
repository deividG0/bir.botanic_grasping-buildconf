# Overview of an autoproj file in buildconf

## Autoproj configuration structure

- manifest
  - In the manifest file include the package set corresponding to your projects
  - In the  layout section specifies what to build

```yaml
    package_sets:
      - github: Brazilian-Institute-of-Robotics/bir.ros-package_set
        private: true
      - github: Brazilian-Institute-of-Robotics/bir.<package_name>-package_set
        private: true

    layout:
      - <package_name>
      - desktop_full
```

- [overrides.yml](overrides.d/overrides.yml):
  - Override branch information for specific packages.
  - Most people leave this to the default, unless they want to use a feature from an experimental branch.

- [bootstrap.sh](bootstrap.sh)
  - Include the build conf for your workspace

  ```yaml
    BOOTSTRAP_URL=git@github.com:Brazilian-Institute-of-Robotics/<package_name>-buildconf.git
  ```

## Config files

There are various file that influence your build:

- `*.yml` files:
  - Are simple 'key: value' pairs in the YAML format to set config options. This list is limited to what autoproj knows.

- `*.rb`   files:
  - Are ruby scripts that can influence any part of the autoproj program, without modifying autoproj itself.
  - This is only for advanced users that understand ruby and the internals of autoproj.

### Configuration options

- `config.yml`: Save build configuration. You should not change it manually. If you need to change an option, run an autoproj operation with `--reconfigure`, as for instance

 ```sh
    autoproj build --reconfigure
 ```

### Influencing Autoproj ruby code

- `init.rb`: Write in this file customization code that will get executed before autoproj is loaded.

- `overrides.rb`: Write in this file customization code that will get executed after autoproj loaded.

### Configuration of your autoproj build

- `CMake` :
  - Since everything is CMake based, environment variables such as
`CMAKE_PREFIX_PATH` are always picked up. You can set them
in `init.rb` too, which will copy them to your `env.sh` script.

  - Because of cmake's aggressive caching behaviour, manual options given to cmake will be overriden by autoproj later on. To make such options permanent, add

```rb
  package('package_name').define "OPTION", "VALUE"
```

in overrides.rb. For instance, to set CMAKE_BUILD_TYPE for the rtt
package, do

```rb
  package('rtt').define "CMAKE_BUILD_TYPE", "Debug"
```