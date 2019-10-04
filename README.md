# Rust-Grov-Utils

Powershell module to help work with rust grcov local more easily. If you use grcov only for CI tool, you don't need this module.

## Prerequisite

- [Rustup](https://rustup.rs/) (nightly toolchain is required)
- [Grcov](https://github.com/mozilla/grcov) : version must be 0.5.4+
- [zip](http://infozip.sourceforge.net/) (using [scoop](http://infozip.sourceforge.net/) to install)

## Install

- Clone this repo and copy the folder to `~/Documents/WindowsPowerShell/Modules` or `~/Documents/PowerShell/Modules` if you are using PowerShell 6
- Add this line to your powershell profile ps1 file : `Import-Module Rust-Grcov-Utils`

## Usage

- When imported, the module set 2 environtment variables to make `cargo test` produce `{project_name}*.gc*` file, which required for generate test report
- In powershell, go to root project folder, run `New-ProjectConfig` to generate module cofig for the first time. The config file include the output folder for test report and default pattern to find test result file, default pattern is `{root_folder}*.gc*`
- In powershell, run `New-GrcovReport` to generate report file in report folder
