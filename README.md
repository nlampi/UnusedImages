UnusedImages
============

Shell script to search an Xcode project for unused images.

Run this script from the root of the XCode project.
This will search .xib, .h, .m, and .plist files for any reference to images in the project.

```
USAGE: unused_images [OPTIONS]

EXAMPLE: ~/scripts/unused_images.sh --debug -o=output.txt

OPTIONS:
-o --output : Use this to output to file. Optionally specify filename
--debug : Prints out debug info
-h --help : Print out help info.
```
