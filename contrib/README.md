This directory contains code that is not directly invloved with the
pattern search algorithms but nevertheless might be found useful for
text handling/processing. Currently it contains:

* `ascii-strings.lisp` aims to provide single-byte strings
  functionality for Unicode-enabled Common Lisp
  implementations. Another goal is to reduce memory footprint and
  boost performance of the string-processing tasks, i.e. `read-line`.

* `scanf.lisp` a simple scanf-like functionality implementation. It is
  not totally compatible with the standard POSIX scanf, however,
  implements a decent subset of its functionality. Can be used as a
  simplier and more robust replacement for extracting data than
  CL-PPCRE. In some cases, it can be used for simple pattern matching.
