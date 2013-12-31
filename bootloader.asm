;----------------------------------------------------------
; Hello World Basic Bootloader
; Pete Lewis 2013 - github.com/PJayB
; Based on http://mikeos.berlios.de/write-your-own-os.html
;----------------------------------------------------------

.386
_TEXT SEGMENT PUBLIC USE16

;----------------------------------------------------------
; Entry point. The BIOS loads this binary blob into address
; 7C0h and begins execution from the first byte. Because 
; this is *also* the header for the filesystem, we have 3
; bytes available to us to jump to our *actual* code
; before the floppy disk filesystem header.
; As part of being a boot descriptor, this binary blob must
; also be exactly 512 bytes long and end in 55AAh.
;----------------------------------------------------------
_entry:

	; Jump over our data headers.
	; Using 'short' forces masm to encode a 2-byte unconditional jump
	jmp		short _init

	; pad 1 byte (3-byte [??] align the next block)
	nop

;----------------------------------------------------------
; 3.5" Floppy Descriptor
;----------------------------------------------------------

OEMLabel			db "GKYPANDA"	; Disk label
BytesPerSector		dw 512			; Bytes per sector
SectorsPerCluster	db 1			; Sectors per cluster
ReservedForBoot		dw 1			; Reserved sectors for boot record
NumberOfFats		db 2			; Number of copies of the FAT
RootDirEntries		dw 224			; Number of entries in root dir
					; (224 * 32 = 7168 = 14 sectors to read)
LogicalSectors		dw 2880			; Number of logical sectors
MediumByte			db 0F0h			; Medium descriptor byte
SectorsPerFat		dw 9			; Sectors per FAT
SectorsPerTrack		dw 18			; Sectors per track (36/cylinder)
Sides				dw 2			; Number of sides/heads
HiddenSectors		dd 0			; Number of hidden sectors
LargeSectors		dd 0			; Number of LBA sectors
DriveNo				dw 0			; Drive No: 0
Signature			db 41			; Drive signature: 41 for floppy
VolumeID			dd 00000000h	; Volume ID: any number
VolumeLabel			db "GEEKYPANDA "; Volume Label: any 11 chars
FileSystem			db "FAT12   "	; File system type: don't change!

;----------------------------------------------------------
; Execution is jumped here from above.
;----------------------------------------------------------
_init:

	; Set up 8k of stack space
	mov		ax, 07C0h
    add     ax, 544
    cli                         ; disable interrupts while changing stack
    mov     ss, ax
	mov		sp, 4096
    sti                         ; restore interrupts

    ; Set data segment to where the BIOS loaded us
    mov     ax, 07C0h
    mov     ds, ax

    ; Print a string! 
    ; We put the address of the string into the String Index register
    ; Then jump to print_string
	lea		si, a_string
	call	print_string

	call	wait_for_keystroke
	call	reboot
    
    ; Shouldn't hit this in theory
_program_loop:
	jmp		_program_loop


;----------------------------------------------------------
; Global data
;----------------------------------------------------------

    ; "Hello, world!\r\n\0"
	a_string    db 'Hello, World!', 10, 13, 0

;----------------------------------------------------------
; Prints a string, starting at memory address ds:si
;----------------------------------------------------------

print_string:
	mov		ah, 0Eh				; set int 10h mode to 'put char teletype'
	xor		bx, bx
_print_loop_start:
	lodsb						; Loads the next byte from si -> al and increments si
	or		al, al				; Test for null terminator
	jz		_print_loop_end		; Jump out if null terminator is hit
	int		10h					; Interrupt signal for printing a character
	jmp		_print_loop_start	; Loop
_print_loop_end:
	ret

;----------------------------------------------------------
; Reboots the machine
;----------------------------------------------------------

reboot:
	mov ax, 0
	int 19h				; Reboot the system
    ret

;----------------------------------------------------------
; Waits for a keypress
;----------------------------------------------------------

wait_for_keystroke:
	mov ax, 0
	int 16h				; Wait for keystroke
    ret

;----------------------------------------------------------
; Jump point for ending the program
;----------------------------------------------------------

_done:
    ret

;----------------------------------------------------------
; The boot sector needs to be 512 bytes long and end in
; 0x55AA
;----------------------------------------------------------

; Relocate the 'origin location' (i.e. offset of the next instruction in this object file's layout)
ORG 510
db 55h, 0AAh

;----------------------------------------------------------
; End the segment block and file
;----------------------------------------------------------
_TEXT ends
end _entry
