# GemStone backend

The files in `src/` are the versioned GemStone source. They use the same
Topaz syntax Jasper exports for a class.

To load a checkout into the development stone, run Topaz on the VM from this
directory after logging in as a development user:

```smalltalk
input scripts/load.topaz
```

The loader commits only after every listed source file has been processed.
Use a dedicated deployment user for non-development environments and do not
place credentials in this repository.
