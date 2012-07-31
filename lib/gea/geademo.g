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

include
{
   $"gea.g" 
}

func uint userfunc( uint code, geaparam param  )
{
   if code < $GEAERR_LAST
   {
      print( "ERROR: ")
   }
   switch code
   {
      case $GEAERR_PATTERN
      {
         print( "Wrong pattern name: \(param.name)\n")     
      }
      case $GEAERR_FILEOPEN
      {
         switch conrequest( "Cannot open file: \(param.name) (Abort|Retry|Ignore)", "Aa|Rr|Ii" )
         {
            case 0 : return $GEA_ABORT
            case 1 : return $GEA_RETRY
            case 2 : return $GEA_IGNORE
         }  
      }
      case $GEAERR_FILEWRITE
      {
         switch conrequest( "Cannot write file: \(param.name) (Abort|Retry)", "Aa|Rr" )
         {
            case 0 : return $GEA_ABORT
            case 1 : return $GEA_RETRY
         }  
      }      
      case $GEAERR_FILEREAD
      {
         switch conrequest( "Cannot read file: \(param.name) (Abort|Retry)", "Aa|Rr" )
         {
            case 0 : return $GEA_ABORT
            case 1 : return $GEA_RETRY
         }  
      }      
      case $GEAERR_TOOBIG
      {
         switch conrequest( "Cannot pack too big file: \(param.name) (Abort|Ignore)", "Aa|Ii" )
         {
            case 0 : return $GEA_ABORT
            case 1 : return $GEA_IGNORE
         }
      }
      case $GEAERR_MANYVOLUMES
      {
         print( "Too many volumes: \(param.name)\n")     
      }      
      case $GEAERR_NOTGEA
      {
         print( "The file \(param.name) is not GEA archive\n")     
      }
      case $GEAERR_WRONGVOLUME
      {
         print( "The file \(param.name) is the wrong GEA volume\n")     
      }
      case $GEAERR_WRONGSIZE
      {
         print( "The GEA file \(param.name) is less then it should be." )
      }
      case $GEAERR_INTERNAL
      {
         print( "The internal error \(param.info) in the file \(param.name)\n")      }
      case $GEAERR_CRC
      {
         print( "The file \(param.info->geafile.name ) has a wrong CRC\n")
      }
      case $GEAMESS_BEGIN
      {
         print( "Creating GEA file: \(param.name)\n")     
      }
      case $GEAMESS_END
      {
         print( "GEA file was created successfully\n")     
      }
      case $GEAMESS_COPY
      {
         print( "Duplicate: \(param.name)\n")     
      }
      case $GEAMESS_ENBEGIN
      {
         print( "Packing: \(param.name)\r")     
      }
      case $GEAMESS_DEBEGIN
      {
         print( "Unpacking: \(param.info->geafile.subfolder)\\\(param.info->geafile.name)\r")     
      }
      case $GEAMESS_WRITEHEAD
      {
         print( "Writing GEA header...\n")     
      }
      case $GEAMESS_DEEND
      {
         print( "\(param.info->geafile.subfolder)\\\(param.info->geafile.name) \(param.info->geafile.compsize) to \(param.info->geafile.size)\n")     
      }
      case $GEAMESS_ENEND
      {
         print( "\(param.name)  \(param.info->geafile.size) to \(param.info->geafile.compsize)      \n")     
      }
      case $GEAMESS_PROCESS
      {
         if param.mode
         {
            print("\(param.info->geafile.name) \(long( param.process + param.done ) * 100L / long( param.info->geafile.size ))% \r")
         }
         else
         {
            print("\(param.name) \(long( param.process + param.done ) * 100L / long( param.info->geafile.size ))% \r")
         }
      }
      case $GEAMESS_WRONGVER
      {
         switch conrequest( "The file \(param.name) has the unsupported GEA format version (Abort|Ignore)", "Aa|Ii" )
         {
            case 0 : return $GEA_ABORT
            case 1 : return $GEA_IGNORE
         }   
      }
      case $GEAMESS_GETVOLUME
      {
/*         uint disktype
         drivename.substr( diskname, 0, 3 )
         disktype = getdrivetype( drivename )
         if disktype == $DRIVE_REMOVABLE || disktype == $DRIVE_CDROM
         {
            if this.mess( $GEAMESS_GETVOLUME, %{ diskname, num + 1 }) ==
                $GEA_ABORT : return 0 
         }*/
         return $GEA_OK         
      }
   }
   if code < $GEAERR_LAST : return 0
   return 1
}

func test<main>
{
   geaeinit  geai
   geae     gpack
   ffind    fd
   geacomp  gc
   
   geai.userfunc = &userfunc
   geai.flags |= $GEAI_IGNORECOPY
   geai.volsize = 100L * 1024L//0L//0x50000L
   geai.pattern = "test.g%02u"
   gpack.create( "c:\\setups\\test.gea", geai )
   fd.init( "c:\\temp\\g\\*.*", $FIND_FILE )
   gc.compmethod = $GEA_STORE//$GEA_PPMD//$GEA_LZGE//$GEA_PPMD
   gc.order = 1
   gc.solid = 1
//   gc.password = "ok"
   foreach cur, fd
   {
      gpack.add( cur.fullname, gc )
   }
   gpack.close()
   
   geadinit geadi
   gead     gunpack
   uint     i
   
   geadi.userfunc = &userfunc
   geadi.geaoff = 0//0x18963
   print("Test GEA archive ================================\n")
   gunpack.open( "c:\\setups\\test.gea", geadi )
//   gunpack.open( "c:\\setups\\disk1.pak", geadi )
   fornum i, *gunpack.fileinfo
   {
      if !gunpack.test( i ) : print("Error testing...\n")
   }

   congetch( "Press any key..." )
}