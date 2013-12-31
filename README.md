Hello, World! Bootloader
========================

An x86-64 assembly listing for a bootable executable that prints 'Hello, World!'.


PREREQUISITES
-------------

- MASM32   : http://www.masm32.com/
- CDRTOOLS : http://www.smithii.com/cdrtools
- DD       : http://www.chrysocome.net/dd

BUILD INSTRUCTIONS
------------------

These executables can be found in the MASM32 'bin' folder.

    > ml.exe /c /nologo /Fo bootloader.obj bootloader.asm
    > link16.exe /TINY /NOLOGO bootloader.obj,bootloader.com,bootloader.map,"",""


PACKAGING INSTRUCTIONS
----------------------
You can create a bootable CD image from the output. Bootable CDs work by emulating a bootable floppy disk, so we need to create a bootable floppy image first, then create an ISO out of that. You can burn this or mount it in an emulator.

Create a blank 1.44MB floppy image: 
(You only need to do this once.)

    > fsutil file createnew bootloader.flp 1440000

Make an empty directory (which would contain the files on our CD ISO if we had any):
(You only need to do this once.)

    > mkdir tmp

Use DD to blit our 512B bootstrapper to the start of the floppy image:

    > dd if=bootloader.com of=bootloader.flp seek=0 skip=0 bs=512 count=1

Create an ISO image from our 1.44MB floppy image and the empty tmp dir:

    > mkisofs -o bootloader.iso -b bootloader.flp tmp
