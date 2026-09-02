# GemStone backend

The files in `src/` are the versioned GemStone source. They use the same
Topaz syntax Jasper exports for a class. WebGS is a version-pinned Git
submodule in `vendor/WebGS`.

To prepare a development stone, install WebGS once and then load SaraNutri
from a checkout on the VM:

```smalltalk
input scripts/install-webgs.topaz
input scripts/load.topaz
```

`SNApi runHttpOnPort: 8888` starts the development API. Verify it locally on
the VM before exposing it through a reverse proxy.

The loaders commit only after every listed source file has been processed. Use
a dedicated deployment user for non-development environments and do not place
credentials in this repository.
