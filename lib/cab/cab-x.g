#exe=1
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

import "msvcrt"
{
   int  _close( int ) 
   uint _get_errno( uint )
   int  _lseek( int, int, int )
   int  _open( uint, int, int )
   int  _read( int, uint, uint )
   int  remove( uint )
   int  _write( int, uint, uint )
}

define
{
   CB_MAX_FILENAME          =  256
   CB_MAX_CABINET_NAME      =  256
   CB_MAX_CAB_PATH          =  256
   CB_MAX_DISK_NAME         =  256
   FOLDER_THRESHOLD         =  1000000 // 900000
   statusFile      = 0   // Add File to Folder callback
   statusFolder    = 1   // Add Folder to Cabinet callback
   statusCabinet   = 2   // Write out a completed cabinet callback

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

type ERF
{
    int     erfOper
    int     erfType
    uint    fError
} 

type cabinit
{
   uint volumesize
   str  disk
   
   uint fncerror
   uint fncprogress
      
   uint finish    // 1 if finish for progress
   uint cabsize
   uint filesize
}

import "cabinet"
{
   uint FCICreate( uint, uint, uint, uint, uint, uint, uint, uint, uint, uint,
                   uint, uint, uint )
   uint FCIDestroy( uint )
   uint FCIFlushCabinet( uint, uint, uint, uint )
}

import "cab2g.dll"<link>
{  
   uint gcabe_addfile( uint, uint, uint, uint )
   uint gcabe_close( uint )
   uint gcabe_create( CCAB )
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

func uint cab_alloc( uint size )
{
   print("a=\( size )\n")
   return malloc( size )
}

// -----------------------------------------------------------------

func cab_free( uint ptr )
{
   print("0\n")
   if ( ptr ) : mfree( ptr )
}

// -----------------------------------------------------------------

func int cab_open( uint name, int  oflag pmode, uint err pv )
{
   int result

   print("1 \n")
//   print("1 \("".copy( name ))\n")
//   file ff
//   ff.open( "".copy( name ), $OP_ALWAYS )
//   result = ff.handle
   result = _open( name, oflag, pmode)

   if result == -1 : _get_errno( err )
   print("1 \(result) \(err)\n")

   return result
}

// -----------------------------------------------------------------

func uint cab_read( int hf, uint memory cb err userpar )
{
   uint result

   print("2\n")
   result = _read( hf, memory, cb )

   if result != cb : _get_errno( err )

   return result
}

// -----------------------------------------------------------------

func uint cab_write( int hf, uint memory cb err userpar )
{
   uint result

   print("3\n")
   result = _write( hf, memory, cb )

   if result != cb : _get_errno( err )

   return result
}

// -----------------------------------------------------------------

func int cab_close( int hf, uint err userpar )
{
    int result

   print("4\n")
    result = _close( hf )
    if result != 0 : _get_errno( err )

    return result
}

// -----------------------------------------------------------------

func int cab_seek( int hf, int dist seektype, uint err userpar )
{
    int result;

   print("5\n")
    result = _lseek( hf, dist, seektype );

    if result == -1 : _get_errno( err )

    return result
}

// -----------------------------------------------------------------

func int cab_delete( uint name, uint err pv )
{
    int result

   print("6\n")
    result = remove( name )

    if result != 0 : _get_errno( err )

    return result
}

//--------------------------------------------------------------------------

func int cab_placed( CCAB pccab, uint filename, uint size continuation pv )
{
   print("7 cab=\(&pccab ) \("".copy( filename )) \( size ) \(continuation) cabi=\(pv) \( pv->uint )\n")
/*	printf("Placed file '%s' (size %d) on cabinet '%s'\n",
		filename, size, pccab->szCab	);

	if (fContinuation)
		printf("      (Above file is a later segment of a continued file)\n");
*/
	return 0
}

func uint cab_gettempfile( uint ret, int length, uint pv )
{
   str dir filename
   
   print("8\n")
   gettempdir( dir )
//   filename.gettempfile( dir, "cab_" )
   uint i
   do 
   {
      ( filename = dir ).faddname( "cab_\(i++).tmp" )      
   } while fileexist( filename )
   if ( *filename + 1 ) < length 
   {
      mcopy( ret, filename.ptr(), *filename + 1 )
      print("81 \( filename )\n")
      return 1
   }
   return 0
}                                       

// -----------------------------------------------------------------

func cab_error( cabinit cabi, uint code, str prefix )
{
   str strerr
   
   print("9\n")
   if !cabi.fncerror : return
   
   switch code
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
   cabi.fncerror->func( "\(prefix) failed: \(code) [\(strerr)]")
}

// -----------------------------------------------------------------

func uint cab_progress( uint status cb1 cb2 pv )
{
   uint percent cabi
   
   cabi = pv
   cabi as cabinit

   if status == $statusFile && !cabi.finish
	{
      cabi.cabsize += cb2;
      if cabi.filesize : percent = 100 * cabi.cabsize / cabi.filesize
      if cabi.fncprogress : cabi.fncprogress->func( cabi, percent )  
   }
/*	else if (typeStatus == statusFolder)
	{
		int	percentage;

		percentage = get_percentage(cb1, cb2);

		printf("\nCopying folder to cabinet: %d%%      \r", percentage);
	}*/
	return 0;
}


func uint cab_netxcabinet( CCAB pccab, uint cbPrevCab pv )
{
   uint cabi = pv
   str name
   
   cabi as cabinit
   
   name.printf( cabi.disk, %{ pccab.iCab } )
	mcopy( &pccab.szCab, name.ptr(), *name + 1 )
	return 1
}


func uint mycallback( uint idfunc, uint parsize )
{     
   buf  bc = '\h
50            
55            
53            
8B DC         
83 C3 \(byte( parsize * 4 + 0x0C ))      
8B EB         
83 ED \(byte( parsize * 4 ))      
3B EB         
74 08         
8B 03         
50            
83 EB 04      
EB F4         
83 ED 04      
55            
68 \( idfunc )
b8 \( calladdr() )
ff d0         
83 C4 \(byte( ( parsize +2 )* 4 ))      
5B            
5D            
58            
C2 \( parsize * 4 )         
00
'
   uint pmem
   pmem = VirtualAlloc( 0, *bc + 100, 0x3000,  0x40 )
   //print( "mem = \(hex2strl(pmem))\n" )
   mcopy( pmem, bc.ptr(), *bc )      
   return pmem
   
}

// -----------------------------------------------------------------

func uint cab_create( str path cabfile, arrstr files, cabinit cabi )
{
   CCAB ccab
   uint hfci ret
   ERF  erf
   arr  fncid of uint
   arr  fnc of uint
   uint i
   
   fncid = %{ &cab_placed, &cab_alloc, &cab_free,
            &cab_open, &cab_read, &cab_write, &cab_close, 
            &cab_seek, &cab_delete, &cab_gettempfile, &cab_progress,
            &cab_netxcabinet }
   fnc  = %{ 5, 1, 1, 5, 5, 5, 3, 5, 3, 3, 4, 3 }            
   fornum i, *fnc
   { 
//      uint par = fnc[i] 
      fnc[i] = mycallback( fncid[i], fnc[i] )
      print("\(i)=\(fncid[i]) \(fnc[i])\n")
   }
   cabi.finish = 0
   cabi.cabsize = 0
   cabi.filesize = 0
   
   ccab.cb = cabi.volumesize
	ccab.cbFolderThresh = $FOLDER_THRESHOLD
	ccab.cbReserveCFHeader = 0
	ccab.cbReserveCFFolder = 0
	ccab.cbReserveCFData   = 0
	ccab.iCab = 1
	ccab.iDisk = 0
	ccab.setID = 777
   print("0 cab = \( &ccab ) cabi = \(&cabi )\n")
	mcopy( &ccab.szDisk, cabi.disk.ptr(), *cabi.disk + 1 )
   mcopy( &ccab.szCabPath, path.ptr(), *path + 1 )
   mcopy( &ccab.szCab, cabfile.ptr(), *cabfile + 1 )
//	store_cab_name(cab_parms->szCab, cab_parms->iCab);

   hfci = gcabe_create( ccab )
//   hfci = FCICreate( &erf, fnc[0], fnc[1], fnc[2], fnc[3], fnc[4], fnc[5], 
//                     fnc[6], fnc[7], fnc[8], fnc[9], &ccab, &cabi )
   print("问 2\n")
   if !hfci
   {
      cab_error( cabi, erf.erfOper, "FCICreate" )
      goto end
   }
   cabi.finish = 1
   print("问 3\n")
/*   if !FCIFlushCabinet( hfci, 0, fnc[11], fnc[10] )
	{
      print("问 4\n")

      cab_error( cabi, erf.erfOper, "FCIFlushCabinet" )
      goto end
	}
   print("问 5\n")

   FCIDestroy( hfci )*/
   fornum i = 0, *files
   { 
      ffind fd
      
      fd.init( files[i], $FIND_FILE | $FIND_RECURSE )
      foreach cur, fd
      {
         gcabe_addfile( hfci, cur.fullname.ptr(), cur.name.ptr(), 0 )
      }
   }   
   gcabe_close( hfci )
   ret = 1
label end:   
   fornum i = 0, *fnc : freecallback( fnc[i] )
   return ret
}

func main<main>
{
   cabinit cabi
   arrstr  files = %{"c:\\temp\\*.*"} 
 
   cabi.volumesize = 300000
   cabi.disk = "mydisk"
   cab_create( $"c:\\temp\\", "test.cab", files, cabi )
   congetch("Press any key...")   
}