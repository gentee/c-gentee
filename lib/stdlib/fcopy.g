/******************************************************************************
*
* Copyright (C) 2004-2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

define <export> {
/*-----------------------------------------------------------------------------
* Id: fcopyflags D
* 
* Summary: Flags for copyfiles.
*
-----------------------------------------------------------------------------*/
   COPYF_RO        = 0x0100    // Overwrite files with the attribute read-only.
   COPYF_SAVEPATH  = 0x0200    // Keep relative paths while copying files /
                               // from subdirectories.
   COPYF_ASK       = 0x0400    // Prompt before copying files already existing.
   
/*-----------------------------------------------------------------------------
* Id: fcopymode D
* 
* Summary: Mode for copyfiles.
*
-----------------------------------------------------------------------------*/
   COPY_OVER      = 0         // Overwrite.
   COPY_SKIP                  // Skip.
   COPY_NEWER                 // Overwrite if newer.
   COPY_MODIFIED              // Overwrite if modified.
   
/*-----------------------------------------------------------------------------
* Id: fcopymsg D
* 
* Summary: Message codes for copyfiles.
*
-----------------------------------------------------------------------------*/
   COPYN_FOUND    = 1         // The object for copying is found.
   COPYN_NEWDIR               // A directory is created.
   COPYN_ERRDIR               // Cannot create a directory.
   COPYN_ASK                  // Copy request.
   COPYN_ERRFILE              // Error while creating a file.
   COPYN_NEWFILE              // A file was created. 
   COPYN_BEGIN                // Start copying file.
   COPYN_PROCESS              // A file is being copied.
   COPYN_END                  // Copying is over.
   COPYN_ERRWRITE             // Error while writing a file.

/*-----------------------------------------------------------------------------
* Id: fcopyret D
* 
* Summary: Return codes for copyfiles.
*
-----------------------------------------------------------------------------*/
   COPYR_NOTHING  = 0         // Do nothing.
   COPYR_BREAK                // Break copying.
   COPYR_RETRY                // Retry.
   COPYR_SKIP                 // Skip.
   COPYR_OVER                 // Write over.
   COPYR_OVERALL              // Write over all files. 
   COPYR_SKIPALL              // Skip all files. 
//-----------------------------------------------------------------------------
}

/*-----------------------------------------------------------------------------
* Id: isequalfiles F
*
* Summary: Check if files are equal. The function compares two files. 
*  
* Params: left - The name of the first file to be compared.
          right - The name of the second file to be compared. 
* 
* Return: The function returns 1 if the files are equal, otherwise it 
          returns 0.
*
-----------------------------------------------------------------------------*/

func  uint isequalfiles( str left, str right )
{
   file  fleft fright
   uint  lsize result temp size
   buf   lbuf rbuf   
   
   if !fleft.open( left, $OP_READONLY ) : return 0
   lsize = fleft.getsize( )   
   size = 0x8000
   if fright.open( right, $OP_READONLY ) && lsize == fright.getsize()
   {
      while lsize
      {
         temp = min( lsize, size )//300000 )
         lbuf.use = 0
         rbuf.use = 0
         fleft.read( lbuf, temp )
         fright.read( rbuf, temp )
         if mcmp( lbuf.ptr(), rbuf.ptr(), temp ) : break
         lsize -= temp
         size = 0x80000
      }
      if !lsize : result = 1
   }
   fleft.close()
   fright.close()
   return result
}

/*-----------------------------------------------------------------------------
* Id: copyfiles F
*
* Summary: Copying files and directories by mask. 
*  
* Params: src - The names of mask of the files or directories being copied. 
          dir - The directory where files will be copied. 
          flag - The combination of search and copy flags./
                 $$[findflags]$$[fcopyflags]  
          mode - What to do if the file being copied already /
                 exists.$$[fcopymode] 
          proccess - The identifier of the function handling messages. /
                   You can use #b(&defcopyproc) as a default process function.  
* 
* Return: The function returns 1 if the copy operation is successful, 
          otherwise it returns 0. 
*
-----------------------------------------------------------------------------*/

func uint copyfiles( str src, str dir, uint flag, uint mode, uint process )
{
   uint     notifyret
   
   subfunc uint notify( uint code, uint left right )
   {
      if process : notifyret = process->func( code, left, right )
      return notifyret
   }
   
   ffind  fd
   str    destname srcdir temp wcard
   arrstr    dirs 
   uint   i

   src.ffullname( src )
   dir.ffullname( dir )
   srcdir.fgetdir( src )
   wcard.fnameext( src )
   
   fd.init( src, flag )
   
   foreach finfo cur, fd
   {
      if flag & $COPYF_SAVEPATH : temp.copy( cur.fullname.ptr() + *srcdir + 1 )
      else : temp = cur.name
      ( destname = dir ).faddname( temp )
         
      if notify( $COPYN_FOUND, &cur, &destname ) == $COPYR_SKIP : continue
      
      if cur.attrib & $FILE_ATTRIBUTE_DIRECTORY : temp = destname
      else : temp.fgetdir( destname )

      label dirretry      
      if !verifypath( temp, dirs ) 
      {
         notify( $COPYN_ERRDIR, &dirs[*dirs - 1], 0 )
         if notifyret == $COPYR_RETRY : goto dirretry
         if notifyret == $COPYR_BREAK : return 0
      }
      
      foreach str ndir, dirs : notify( $COPYN_NEWDIR, &ndir, 0 )
      
      if cur.attrib & $FILE_ATTRIBUTE_DIRECTORY
      {
         if !( flag & $FIND_RECURSE ) || wcard != "*.*" 
         {
            ( temp = cur.fullname ).faddname( "*.*" )
            copyfiles( temp, destname, flag | $FIND_RECURSE, mode, process )
         }
      }
      else
      {
         uint noexist
         
         if fileexist( destname )
         {
            finfo fi
            
            if mode == $COPY_SKIP : continue

            getfileinfo( destname, fi )
            
            if mode == $COPY_NEWER && 
                CompareFileTime( cur.lastwrite, fi.lastwrite ) <= 0 
            {
               continue
            }
            if mode == $COPY_MODIFIED && fi.sizelo == cur.sizelo && 
               isequalfiles( cur.fullname, destname )
            {
               continue
            }
            if flag & $COPYF_ASK
            {
               notify( $COPYN_ASK, &cur, &fi )
               switch notifyret
               {
                  case $COPYR_BREAK : return 0
                  case $COPYR_SKIP : continue
                  case $COPYR_OVERALL : flag &= ~$COPYF_ASK
                  case $COPYR_SKIPALL 
                  {
                     mode = $COPY_SKIP
                     continue
                  }
               }
            }
            if flag & $COPYF_RO && fi.attrib & $FILE_ATTRIBUTE_READONLY
            {
               setattribnormal( destname )
            }
         }
         else : noexist = 1

         file fsrc fdest
         uint size icopy
         buf   cbuf
         
         label fileretry
         
         if !fsrc.open( cur.fullname, $OP_READONLY ) 
         {
            switch notify( $COPYN_ERRFILE, &cur.fullname, 0 )
            {
               case $COPYR_BREAK : return 0
               case $COPYR_RETRY : goto fileretry
               case $COPYR_SKIP : continue
            }
         }
         
         if !fdest.open( destname, $OP_CREATE ) 
         {
            fsrc.close( )
            switch notify( $COPYN_ERRFILE, &destname, 0 )
            {
               case $COPYR_BREAK : return 0
               case $COPYR_RETRY : goto fileretry
               case $COPYR_SKIP : continue
            }
         }

         if noexist : notify( $COPYN_NEWFILE, &destname, 0 )

         notify( $COPYN_BEGIN, &cur, &destname )
         size = cur.sizelo
         
         uint copied = 0
         while size
         {
            icopy = min( size, 0x80000 )//300000 )
            cbuf.use = 0
            fsrc.read( cbuf, icopy )
            label writeretry
            if !fdest.write( cbuf )
            {
               switch notify( $COPYN_ERRWRITE, &destname, 0 )
               {
                  case $COPYR_BREAK : return 0
                  case $COPYR_RETRY : goto writeretry
                  case $COPYR_SKIP : break
               }
            }
            notify( $COPYN_PROCESS, &destname, 
                    uint( long( copied += icopy ) * 100L / long( cur.sizelo )))
            size -= icopy
         }
         //SetFileTime( hdest, 0->filetime, 0->filetime, cur.lastwrite )
         fdest.settime( cur.lastwrite )
         fdest.close( )
         fsrc.close( )
         setfileattrib( destname, cur.attrib )
         notify( $COPYN_END, &cur, &destname )         
      }
   }
   return 1
}

/*-----------------------------------------------------------------------------
* Id: copyfiles_1 F8
*
* Summary: This is a default process function for #b(copyfiles). You can 
           develop and use your own process function like it. 
*  
* Params: code - The message code.$$[fcopymsg] 
          left - Additional parameter. 
          right - Additional parameter. 
* 
* Return: You should return one of the following values: $$[fcopyret] 
*
-----------------------------------------------------------------------------*/

func uint defcopyproc( uint code, uint left, uint right )
{
   switch code
   {
/*      case $COPYN_FOUND {
         print("FOUND = \( left->finfo.fullname ) to \( right->str )\n")
      }
      case $COPYN_NEWDIR {
         print("NEWDIR = \( left->str )\n")
      }
      case $COPYN_NEWFILE {
         print("NEWFILE = \( left->str )\n")
      }*/      
      case $COPYN_BEGIN {
         print("Copying \( right->str )  0%\r")
      }
      case $COPYN_PROCESS {
         print("Copying \( left->str ) \( right )%\r")
      }
      case $COPYN_END {
         print("Copied  \( right->str ) 100%\n")
      }
      case $COPYN_ERRDIR {
         return ?( conrequest("Cannot create a directory \( left->str )!
Abort [A] | Retry [R] : ", "Aa|Rr" ), $COPYR_RETRY, $COPYR_BREAK )
      }
      case $COPYN_ASK {
         str  edate etime
         str  ndate ntime
         uint ret

         getfiledatetime( right->finfo.lastwrite, edate, etime )
         getfiledatetime( left->finfo.lastwrite, ndate, ntime )
      
         ret = conrequest("File already exists
Existing File: \( right->finfo.fullname )
Size: \( right->finfo.sizelo ) Date: \(edate) Time: \(etime)
     New File: \( left->finfo.fullname )
Size: \( left->finfo.sizelo ) Date: \(ndate) Time: \(ntime)

Overwrite [O] | Skip [S] | Overwrite All [V] | Skip All [K] | Abort [A] : ",
"Oo|Ss|Vv|Kk|Aa" )
         switch ret 
         {
            case 0 : return $COPYR_OVER
            case 1 : return $COPYR_SKIP
            case 2 : return $COPYR_OVERALL
            case 3 : return $COPYR_SKIPALL
            case 4 : return $COPYR_BREAK
         }
      }
      case $COPYN_ERRFILE, $COPYN_ERRWRITE {
         switch conrequest( "Cannot \( ?( code == $COPYN_ERRFILE,"open/create a file","write to a file" )) \( left->str )!
Abort [A] | Retry [R] | Skip [S]: ", "Aa|Rr|Ss" )
         {
            case 0: return $COPYR_BREAK
            case 1: return $COPYR_RETRY
            case 2: return $COPYR_SKIP
         }
      }
   }
   return 0
}
