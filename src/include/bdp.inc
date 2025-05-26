%ifndef _BDP_INC_HBHH78JKJG0997HHHGJK_INCLUDED
%define _BDP_INC_HBHH78JKJG0997HHHGJK_INCLUDED

bits 16

    ;;
    ;; Disk description table
    ;;

OEMLabel                db 'DISKBOOT'
BytesPerSector          dw 512
SectorsPerCluster       db 1
ReservedForBoot         dw 1
NumberOfFats            db 2
RootDirEntries          dw 0E0h

LogicalSectors          dw 2880
MediumByte              db 0F0h
SectorsPerFat           dw 9
SectorsPerTrack         dw 18
Sides                   dw 2
HiddenSectors           dd 0
LargeSectors            dd 0

DriveNo                 db 0
                        db 0    ; reserved
Signature               db 29h
VolumeID                dd 12h, 34h, 56h, 78h
VolumeLabel             db 'FUCK YOU   '
FileSystem              db 'FAT12   '

%endif
