/******************************************************************************
*
* Copyright (C) 2009, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

include : $"..\other\random.g"
include : $"..\gea\filelist.g"

define
{
   tcompTYPE_NONE         = 0x0000  // No compression
   tcompTYPE_MSZIP        = 0x0001  // MSZIP
   tcompTYPE_QUANTUM      = 0x0002  // Quantum
   tcompTYPE_LZX          = 0x0003  // LZX

   CB_MAX_FILENAME          =  256
   CB_MAX_CABINET_NAME      =  256
   CB_MAX_CAB_PATH          =  256
   CB_MAX_DISK_NAME         =  256
   FOLDER_THRESHOLD         =  1000000 // 900000

   // Level
   LZX_HI      = 0
   LZX_NORMAL  = 1
   LZX_LOW     = 2
      
   FCIERR_NONE = 0  
   FCIERR_OPEN_SRC
   FCIERR_READ_SRC
   FCIERR_ALLOC_FAIL 
   FCIERR_TEMP_FILE 
   FCIERR_BAD_COMPR_TYPE 
   FCIERR_CAB_FILE
   FCIERR_USER_ABORT 
   FCIERR_MCI_FAIL 

}

type CCAB {
// LONG
    uint  cb                  // size available for cabinet on this media
    uint  cbFolderThresh      // Thresshold for forcing a new Folder
// UINT
    uint  cbReserveCFHeader   // Space to reserve in CFHEADER
    uint  cbReserveCFFolder   // Space to reserve in CFFOLDER
    uint  cbReserveCFData     // Space to reserve in CFDATA
    int   iCab                // sequential numbers for cabinets
    int   iDisk               // Disk number
//ifndef REMOVE_CHICAGO_M6_HACK
    int   fFailOnIncompressible // TRUE => Fail if a block is incompressible
//endif
    ushort setID                // Cabinet set ID

    reserved   szDisk[ $CB_MAX_DISK_NAME ]    // current disk name
    reserved   szCab[ $CB_MAX_CABINET_NAME ]  // current cabinet name
    reserved   szCabPath[ $CB_MAX_CAB_PATH ]  // path for creating cabinet
} 

type cabinit
{
   uint   volumesize
//   uint   flags
   str    disk
   arrstr exclude
   uint   notify
   uint   level
}

method str str.gettempfile( str dir prefix ) 
{ 
   random rnd 
   
   rnd.init()
   rnd.randseed( 'A', 'Z' ) 
   do 
   { 
      str  name
      uint i 
      fornum i, 6 : name.appendch( rnd.randseed() ) 
      ( this = dir ).faddname( "\( prefix )\( name ).tmp" ) 
   } while fileexist( this )
   
   return this 
}

func uint cab_gettempfile( uint ret, int length, uint pv )
{
   str dir filename
   
   gettempdir( dir )
   filename.gettempfile( dir, "cab_" )
/*   uint i
   do 
   {
      ( filename = dir ).faddname( "cab_\(i++).tmp" )      
   } while fileexist( filename )*/
   if ( *filename + 1 ) < length 
   {
      mcopy( ret, filename.ptr(), *filename + 1 )
      return 1
   }
   return 0 
}                                       

// -----------------------------------------------------------------

func cab_error( cabinfo cabi, str prefix )
{
   str strerr
   
   switch cabi.erf.erfOper
	{
		case $FCIERR_NONE : strerr = "No error"
		case $FCIERR_OPEN_SRC: strerr = "Failure opening file to be stored in cabinet"
		case $FCIERR_READ_SRC: strerr = "Failure reading file to be stored in cabinet"
		case $FCIERR_ALLOC_FAIL:	strerr = "Insufficient memory in FCI"
		case $FCIERR_TEMP_FILE: strerr = "Could not create a temporary file"
		case $FCIERR_BAD_COMPR_TYPE: strerr = "Unknown compression type"
		case $FCIERR_CAB_FILE: strerr = "Could not create cabinet file"
		case $FCIERR_USER_ABORT: strerr = "Client requested abort"
		case $FCIERR_MCI_FAIL: strerr = "Failure compressing data"
		default : strerr = "Unknown error"
	}
   cabi.fncnotify->func( $FLN_ERROR, 
                 "\(prefix) failed: \(cabi.erf.erfOper) [\(strerr)]", cabi )
}

func uint cab_notify( uint code, str param, cabinfo cabi )
{
   return 0
}

func uint cab_sysnotify( uint code, uint param, cabinfo cabi )
{
   str stemp
   
   stemp.copy( param )
   return cabi.fncnotify->func( code, stemp, cabi )
}

// -----------------------------------------------------------------

func uint cab_create( str cabfile, arrstr files, arr flags of uint, cabinit cabini )
{
   CCAB    ccab
   cabinfo cabi
   str  stemp pattern ext
   uint hfci ret
   uint i
   arrstr  exeext = %{ "exe", "dll" }
   
   if !cabini.volumesize : cabini.volumesize = 0xFFFFFFF

   cabi.finish = 0
   cabi.cabsize = 0
   cabi.filesize = 0
   cabi.call = gentee_ptr( 4 ); // GPTR_CALL
    
   cabi.fnctempfile = &cab_gettempfile;
    
   cabi.fncnotify = cabini.notify;
   if !cabi.fncnotify : cabi.fncnotify = &cab_notify;
   cabi.fncsysnotify = &cab_sysnotify;
    
   callback( &cab_gettempfile, 1 )
   
   ccab.cb = cabini.volumesize
	ccab.cbFolderThresh = $FOLDER_THRESHOLD
	ccab.cbReserveCFHeader = 0
	ccab.cbReserveCFFolder = 0
	ccab.cbReserveCFData   = 0
	ccab.iCab = 1
	ccab.iDisk = 0
	ccab.setID = 777

   switch cabini.level
   { 
      case 2  : cabini.level = 15 
      case 1  : cabini.level = 18
      default : cabini.level = 21 
   } 
   cabi.lztype = $tcompTYPE_LZX | ( cabini.level << 8 )   
      
	mcopy( &ccab.szDisk, cabini.disk.ptr(), *cabini.disk + 1 )
   stemp.fnameext( cabfile )
   mcopy( &ccab.szCab, stemp.ptr(), *stemp + 1 )
   cabfile.fgetparts( stemp, pattern, ext )
   stemp.fappendslash()
   mcopy( &ccab.szCabPath, stemp.ptr(), *stemp + 1 )
   pattern += "%i.\(ext)"
   
   cabi.pattern = pattern.ptr()
      
   if !( hfci = gcabe_create( &ccab, &cabi ))
   {
      cab_error( cabi, "FCICreate" )
      goto end
   }

   filelist fl 
   str root folder
 
   fl.addfiles( files, cabini.exclude, flags )
   cabi.summarysize = fl.summarysize
   cabi.fncnotify->func( $FLN_START, "", cabi )
   foreach curfl, fl
   {
      str fullname filename ext
      
      switch curfl.itype
      {
         case $FL_FOLDER
         { 
            folder = curfl.name
            if !gcabe_flushfolder( hfci ) 
            {
               cab_error( cabi, "FCIFlushFolder" )
               goto end
            }
         }
         case $FL_ROOT : root = curfl.name
         case $FL_FILE
         {
            (fullname = root ).faddname( folder ).faddname( curfl.name )
            filename.copy( fullname.ptr() + *root + 1 )
            cabi.fncnotify->func( $FLN_FILEBEGIN, fullname, cabi )
//            ext = filename.fgetext()
            if !gcabe_addfile( hfci, fullname.ptr(), filename.ptr(), 
               /*ext %== exeext[0] || ext %== exeext[1],*/ cabi )
            {
               cab_error( cabi, "FCIAddFile" )
               goto end
            }
            cabi.fncnotify->func( $FLN_FILEEND, fullname, cabi )
         }
      }
   }
   cabi.finish = 1
   if !gcabe_close( hfci )
   {
      cab_error( cabi, "FCIFlushCabinet" )
      goto end
   }
   ret = 1
label end:
   return ret
}
