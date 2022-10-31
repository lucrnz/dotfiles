# dotnet - https://dotnet.microsoft.com/en-us/download/dotnet/6.0
if test -d "$HOME/.local/share/dotnet"; then
  export PATH="$HOME/.local/share/dotnet:$PATH"
  export DOTNET_ROOT="$HOME/.local/share/dotnet"
  export DOTNET_CLI_TELEMETRY_OPTOUT=1
fi
