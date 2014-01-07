##OpenCDK-Libgcrypt-Libgpg-error-for-iOS##

###Overview:###
**OpenCDK**, **libgcrypt**, **libgpg-error** build scripts for iPhoneOS (armv7) and iPhoneSimulator (i386) using official XCode toolchain and SDK from Apple.

Result files will be in created lib/ and include/ directories for i386 and armv7 architectures.
To use those libraries, include the library from lib/ directory and headers from include/.

If you have any problem don't hesitate to contact to me.


####License:####
Under LICENSE file

 
####Install:####

 1. build-libgpg-error
 2. build-libgcrypt
 3. build-opencdk
 5. You have all libraries in lib/ and include/ directories
 

####Output structure:####
Build scripts will create in current folder with additional structure:

  * build/    -configured build files for every library and architecture
  * lib/    	-output libs (merged for all configured architectures)
  * include/	-output headers
  * src/		-source files (extracted from tarballs)
  * tar/		-tarball files
  * usr/		-build files for every configured platform (includes, libs, shares, manuals)


####Patches:####
* libgcrypt\blowfish-arm.S - Cross-compiling under armv7 required missing rules file for arm "blowfish-arm.S", I found it in web (http://code.metager.de/source/xref/gnu/libgcrypt/cipher/blowfish-arm.S) and put it into patches (it will applies automatically)


####Tested versions (without errors) on:####
* OSX	        10.8.5
* Xcode	        5.0
* --
* Libgpg-error  1.12
* Libgcrypt	    1.6.0
* OpenCDK		0.6.6
  

####Usefull tools:####
* **xcrun** - to locate development tools and properties for specyfied platform
 >+ eg: 	Locate C compiler for iPhoneOS: 
		`xcrun find -sdk iphoneos cc`
* **lipo** - to create, merge and operate on files
 >+ eg: 	Merge libraries with different architectures into one universal file: 
		`lipo -create usr.i386/lib/libgmp.a usr.armv7/lib/libgmp.a -output lib/libgmp.a`
* **uname** - print system name
 >+ eg: 	Print actual architecture: 
		`uname -m`

###Thanks to:###
* Cross-Compiling information:
>* <http://tinsuke.wordpress.com/2011/02/17/how-to-cross-compiling-libraries-for-ios-armv6armv7i386/>
>* <https://ghc.haskell.org/trac/ghc/wiki/Building/CrossCompiling/iOS>
>* <http://wiki.osdev.org/GCC_Cross-Compiler>