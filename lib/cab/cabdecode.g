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

define
{
   FDIERROR_NONE = 0
   FDIERROR_CABINET_NOT_FOUND
   FDIERROR_NOT_A_CABINET
   FDIERROR_UNKNOWN_CABINET_VERSION
   FDIERROR_CORRUPT_CABINET
   FDIERROR_ALLOC_FAIL
   FDIERROR_BAD_COMPR_TYPE
   FDIERROR_MDI_FAIL
   FDIERROR_TARGET_FILE
   FDIERROR_RESERVE_MISMATCH
   FDIERROR_WRONG_CABINET
   FDIERROR_USER_ABORT
}

type FDINOTIFICATION
{
    uint      cb
    uint      psz1
    uint      psz2
    uint      psz3
    uint      pv
    uint      hf
    ushort    date
    ushort    time
    ushort    attribs
    ushort    setID
    ushort    iCabinet
    ushort    iFolder
    uint      fdie
}

type FDICABINETINFO 
{
    uint        cbCabinet              // Total length of cabinet file
    ushort      cFolders               // Count of folders in cabinet
    ushort      cFiles                 // Count of files in cabinet
    ushort      setID                  // Cabinet set ID
    ushort      iCabinet               // Cabinet number in set (0 based)
    uint        fReserve               // TRUE => RESERVE present in cabinet
    uint        hasprev                // TRUE => Cabinet is chained prev
    uint        hasnext                // TRUE => Cabinet is chained next
}

type decabinfo
{
   ERF            erf
   FDICABINETINFO fdic
   uint     call
   uint     islist
   uint     fncnotify
   uint     fncsysnotify
   uint     hf
   str      destfile
   uint     percent
   uint     cursize
   uint     fileinfo
   str      nextvolume
   str      destdir
   uint     param
}


func uint decab_notify( uint code, str param, decabinfo decab )
{
   return 0
}

func uint decab_sysnotify( uint code, uint param, decabinfo decab )
{
   str      stemp
   filetime lft
   uint     fdin
   
   fdin as param->FDINOTIFICATION
   switch code
   {
      case $FLN_NEXTVOLUME
      { 
         if !*decab.nextvolume : decab.nextvolume.copy( fdin.psz1 )
       }
      case $FLN_FILEBEGIN
      {
         uint item 
         
         if decab.islist
         {  
            uint files = decab.fileinfo
            files as arr of finfo
            item as files[ files.expand(1) ]
         }
         else : item = decab.fileinfo
         
         item as finfo
        
         item.fullname.copy( fdin.psz1 )
         item.name.fnameext( item.fullname )
         item.attrib = fdin.attribs
         item.sizelo = fdin.cb
         DosDateTimeToFileTime( fdin.date, fdin.time, lft )
         LocalFileTimeToFileTime( lft, item.lastwrite )
         if decab.islist : return 0
         ( decab.destfile = decab.destdir ).faddname( item.fullname )
         return decab.fncnotify->func( $FLN_FILEBEGIN, decab.destfile, decab )
      }
      case $FLN_FILEEND
      {
         file fi
         
         setattribnormal( decab.destfile )
         fi.open( decab.destfile, 0 )
         fi.settime( decab.fileinfo->finfo.lastwrite )
         fi.close()     
         setfileattrib( decab.destfile, fdin.attribs )
         decab.fncnotify->func( $FLN_FILEEND, decab.destfile, decab )
         return 1
      }
      default : stemp.copy( param )
   }
   return decab.fncnotify->func( code, stemp, decab )
}


func decab_error( decabinfo decab, str prefix )
{
   str strerr
   
   switch decab.erf.erfOper
	{
   	case $FDIERROR_NONE: strerr =  "No error"
		case $FDIERROR_CABINET_NOT_FOUND:	strerr =  "Cabinet not found"
		case $FDIERROR_NOT_A_CABINET:	strerr =  "Not a cabinet"
		case $FDIERROR_UNKNOWN_CABINET_VERSION:	strerr =  "Unknown cabinet version"
		case $FDIERROR_CORRUPT_CABINET: strerr =  "Corrupt cabinet"
		case $FDIERROR_ALLOC_FAIL: strerr =  "Memory allocation failed"
		case $FDIERROR_BAD_COMPR_TYPE:	strerr =  "Unknown compression type"
		case $FDIERROR_MDI_FAIL:	strerr =  "Failure decompressing data"
		case $FDIERROR_TARGET_FILE:	strerr =  "Failure writing to target file"
		case $FDIERROR_RESERVE_MISMATCH
      {
         strerr =  "Cabinets in set have different RESERVE sizes"
      }
		case $FDIERROR_WRONG_CABINET
      {
         strerr =  "Cabinet strerr = ed on fdintNEXT_CABINET is incorrect"
      }
		case $FDIERROR_USER_ABORT:	strerr =  "User aborted"
		default : strerr = "Unknown error"
	}
   decab.fncnotify->func( $FLN_ERROR, 
                 "\(prefix) failed: \(decab.erf.erfOper) [\(strerr)]", decab )
}

func uint cab_decodeinit( str cabfile, decabinfo decab )
{
   uint hfdi ret
   str  path name
   
   decab.fncsysnotify = &decab_sysnotify;
   decab.call = gentee_ptr( 4 ); // GPTR_CALL
  
   if !( hfdi = gcabd_create( &decab ))
   {
      decab_error( decab, "FDICreate" )
      return 0
   }
   if !gcabd_iscabinet( hfdi, cabfile.ptr(), &decab )
   {
      decab.fncnotify->func( $FLN_NOTVALID, cabfile, decab )
      goto end
   } 
   path.fgetdir( cabfile ).fappendslash()
   name.fnameext( cabfile )
   do 
   {
      if !gcabd_copy( hfdi, name.ptr(), path.ptr(), &decab )
      {
         decab_error( decab, "FDICopy" )
         goto end
      }
      name = decab.nextvolume
      decab.nextvolume.clear()
   } while *name
   ret = 1
label end
   gcabd_destroy( hfdi )
   return ret  
}


func uint cab_list( str cabfile, arr files of finfo, uint notify )
{
   decabinfo decab

   decab.fncnotify = ?( notify, notify, &decab_notify )
   decab.islist = 1
   decab.fileinfo = &files 

   return cab_decodeinit( cabfile, decab )     
}

func uint cab_decode( str cabfile destdir, uint notify param )
{
   decabinfo decab
   finfo     fi

   decab.destdir = destdir
   decab.fileinfo = &fi
   decab.param = param
   decab.fncnotify = ?( notify, notify, &decab_notify )

   return cab_decodeinit( cabfile, decab )     
}

func uint cab_decode( str cabfile destdir, uint notify )
{
   return cab_decode( cabfile, destdir, notify, 0 )
}