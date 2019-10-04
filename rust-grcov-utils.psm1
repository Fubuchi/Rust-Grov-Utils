$env:CARGO_INCREMENTAL = 0
$env:RUSTFLAGS = "-Zprofile -Ccodegen-units=1 -Cinline-threshold=0 -Clink-dead-code -Coverflow-checks=off -Zno-landing-pads"
$configFile = "grcov.json"

class GrcovConfig {
  [ValidateNotNullOrEmpty()][string]$output
  [ValidateNotNullOrEmpty()][string]$pattern
}

function New-GrcovConfig () {
  if (Test-Path $configFile) {
    return
  }
  $curDir = Get-Location | Select-Object | ForEach-Object { $_.ProviderPath.Split("\")[-1] }
  $config = [GrcovConfig]@{
    output  = "report"
    pattern = "$curDir*.gc*"
  }
  if ($PSVersionTable.PSVersion.Major -lt 6) {
    $config | ConvertTo-Json | Format-Json | Out-FileUtf8NoBom $configFile
  }
  else {
    $config | ConvertTo-Json | Out-File $configFile
  }
}

function New-GrcovReport() {
  $configs = Get-Config
  Clear-GrcovReport
  if (!(Test-Path $configs.output)) {
    New-Item -ItemType Directory -Force -Path $configs.output
  }
  cargo clean
  cargo test
  $zip = "$($configs.output)/ccov.zip"
  $list = (Get-ChildItem -Path . -Recurse -Filter $configs.pattern | Resolve-Path -Relative) -join ", "
  Invoke-Expression "zip -0 $zip $list"
  grcov $zip -s . -t html --llvm --branch --ignore-not-existing --ignore "/*" -o "$($configs.output)"
  Remove-Item $zip
}

function Clear-GrcovReport () {
  $output = (Get-Config).output
  if (Test-Path $output) {
    Remove-Item "$output/*" -Recurse -ErrorAction Ignore
  }
}

function Get-Config () {
  if (!(Test-Path $configFile)) {
    throw "$configFile not found"
  }
  [GrcovConfig](Get-Content $configFile | Out-String | ConvertFrom-Json)
}


# https://github.com/PowerShell/PowerShell/issues/2736
# no need to use this function if powershell version >= 6
function Format-Json([Parameter(Mandatory, ValueFromPipeline)][String] $json) {
  $indent = 0;
  ($json -Split '\n' |
      ForEach-Object {
        if ($_ -match '[\}\]]') {
          # This line contains  ] or }, decrement the indentation level
          $indent--
        }
        $line = (' ' * $indent * 2) + $_.TrimStart().Replace(':  ', ': ')
        if ($_ -match '[\{\[]') {
          # This line contains [ or {, increment the indentation level
          $indent++
        }
        $line
      }) -Join "`n"
}

# https://gist.github.com/mklement0/8689b9b5123a9ba11df7214f82a673be
# For powershell version < 6
function Out-FileUtf8NoBom {

  [CmdletBinding()]
  param(
    [Parameter(Mandatory, Position = 0)] [string] $LiteralPath,
    [switch] $Append,
    [switch] $NoClobber,
    [AllowNull()] [int] $Width,
    [Parameter(ValueFromPipeline)] $InputObject
  )

  #requires -version 3

  [System.IO.Directory]::SetCurrentDirectory($PWD)
  $LiteralPath = [IO.Path]::GetFullPath($LiteralPath)

  if ($NoClobber -and (Test-Path $LiteralPath)) {
    Throw [IO.IOException] "The file '$LiteralPath' already exists."
  }

  $sw = New-Object IO.StreamWriter $LiteralPath, $Append

  $htOutStringArgs = @{ }
  if ($Width) {
    $htOutStringArgs += @{ Width = $Width }
  }

  try {
    $Input | Out-String -Stream @htOutStringArgs | ForEach-Object { $sw.WriteLine($_) }
  }
  finally {
    $sw.Dispose()
  }
}
