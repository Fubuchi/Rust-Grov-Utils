# Rust-Grov-Utils

Powershell module to help work with rust grcov local more easily. If you use grcov only for CI tool, you don't need this module.

## Prerequisite - Windows side

- [Rustup](https://rustup.rs/)
- [Grcov](https://github.com/mozilla/grcov)
- [zip](http://infozip.sourceforge.net/) (use [scoop](https://github.com/lukesampson/scoop) to install)
- [WSL](https://github.com/microsoft/WSL) (to install lcov for converting test report to html)

## Prerequisite - WSL side (use the package manager shipped with your distro of choice to install)

- [LCOV](https://github.com/linux-test-project/lcov): converting test report
- [Jq](https://github.com/stedolan/jq): read json file

## Install

- Clone this repo and copy the folder to `~/Documents/WindowsPowerShell/Modules` or `~/Documents/PowerShell/Modules` if you are using PowerShell 6
- Add this line to your powershell profile ps1 file : `Import-Module Rust-Grcov-Utils`
- Add this function to your `.bashrc` or `.zshrc` in WSL

  ```bash
  grcov_genhtml() {
    if [ ! -f grcov.json ]; then
      echo "grcov.json not found"
      return
    fi
    local output=$(cat grcov.json | jq -r ".output")
    genhtml -o $output --show-details --highlight --ignore-errors source --legend $output/lcov.info
    rm $output/lcov.info
  }
  ```

## Usage

- When imported, the module set 2 environtment variables to make `cargo test` produce {project_name}\*.gc\* file, which require for generate test report
- In powershell, go to root project folder, run `New-ProjectConfig` to generate module cofig for the first time. The config file include the output folder for test report and default pattern to find test result file, default pattern is {root_folder}\*.gc\*
- In powershell, run `New-GrcovReport` to generate report file `lcov.info` in report folder
- In WSL, go to root project folder, run `grcov_genhtml` to generate html report in report folder, this function will delete the `lcov.info` file once it done
