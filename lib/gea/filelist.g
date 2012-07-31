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
   FL_FILES     = 0x0001  // Seek just files
   FL_RECURSIVE = 0x0002  // Recursive search
   FL_EMPTYFLD  = 0x0004  // Empty folders
   
   FL_BLOCKSIZE = 1000000
   
   FL_ROOT = 1
   FL_FOLDER
   FL_FILE
}

/* Block
   uint count of items
   [ 
      byte   type
      short  size
      строка 
   ]
*/

type flinfo
{
   uint itype
   str  name
} 

type filelist< index = flinfo>
{
   uint flags
   uint files           // Count of files
   long summarysize
   uint bcount          // Count block - 1
   uint off             // current offset in the block
   str  root            // current root
   str  folder          // current folder
   arr  block of uint
   // Для foreach
   uint iblock          // Текущий блок
   uint icur            // Текущий элемент
   uint eof
   flinfo fl
}

method filelist.newblock
{
   uint i = .block.expand(1)
   
   .block[ i ] = malloc( $FL_BLOCKSIZE )
   .block[ i ]->uint = 0
   .bcount = *.block - 1
   .off = sizeof( uint )       
}

method filelist filelist.init()
{
   this.newblock()
   return this
}

method filelist filelist.delete()
{
   uint i
   fornum i, *this.block : mfree( this.block[ i ] )
   
   return this
}

method uint str.isexclude( arrstr exclude )
{
   if *exclude 
   {
       foreach cure, exclude
       {
          if this.fwildcard( cure ) : return 1
       }
   }
   return 0
}

method filelist.additem( uint itype, str value )
{
   uint start
   uint ptr size = *value + 1 
   
   if itype == $FL_FILE 
   {
      str folder
      
      folder.fgetdir( value )
      if folder %!= this.folder : this.additem( $FL_FOLDER, folder )
      start = *this.folder + 1  
      this.files++  
   }
   elif itype == $FL_FOLDER
   {
      start = *this.root + ?( *value > *this.root, 1, 0 ) 
      this.folder = value
   }
   
   if .off + size + 16 > $FL_BLOCKSIZE : this.newblock()
   
   
   ptr = .block[ .bcount ] + .off
         
//   print("Add=\(itype) \( value )\n")
   ptr->ubyte = itype
   size -= start
   ( ptr + 1 )->ushort = size
   mcopy( ptr + 3, value.ptr() + start, size )
   .off += size + 3  
   .block[ .bcount ]->uint = .block[ .bcount ]->uint + 1
}

method uint filelist.adddir( str src, arrstr exclude, uint flags )
{
   str   wildcard dirsearch dirname = src 
   ffind fd fdfile
   uint  hasdirs
   
   if direxist( dirname )
   {
      hasdirs = 1 
      dirname.faddname( "*.*" )
      dirsearch = dirname
      flags |= $FL_RECURSIVE      
   }
   else : dirsearch.fgetdir( src ).faddname( "*.*" )
   
   wildcard.fnameext( dirname )
   
   fd.init( dirsearch, $FIND_DIR ) 
   foreach cur, fd
   {
      str stemp
      
      hasdirs = 2
      if cur.name.isexclude( exclude ) : continue
      if cur.name.fwildcard( wildcard )
      { 
         this.adddir( cur.fullname, exclude, flags | $FL_RECURSIVE )
      }
      elif flags & $FL_RECURSIVE
      { 
         this.adddir( ( stemp = cur.fullname ).faddname( wildcard ), exclude, flags )
      }
   }      
   fdfile.init( dirname, $FIND_FILE ) 
   foreach curf, fdfile
   {
      if curf.name.isexclude( exclude ) : continue
      this.summarysize += long( curf.sizelo )
//      print("\(this.summarysize) \(cur.fullname)\n")
      this.additem( $FL_FILE, curf.fullname )
   }
   if hasdirs == 1 && flags & $FL_EMPTYFLD
   {
      fdfile.init( dirsearch, $FIND_FILE ) 
      foreach curf, fdfile
      {
         hasdirs = 0
         break
      }
      if hasdirs : this.additem( $FL_FOLDER, src )
   }      
   return 1   
}

method uint filelist.addfiles( arrstr src exclude, arr aflags of uint )
{
   uint icur
   uint recurse
   
   foreach cursrc, src
   {
      ffind fd
      uint  dir
      
      if !*cursrc : continue
//      wcard.fnameext( cursrc )
      .root.fgetdir( cursrc )  
      .additem( $FL_ROOT, .root )
      .folder = .root
//      .folder.clear()
      if *aflags > icur
      {
         this.flags = aflags[ icur ]
         recurse = ?( this.flags & $FL_RECURSIVE, $FIND_RECURSE, 0 ) 
      } 
      icur++
      if this.flags & $FL_FILES
      {
         uint recok = recurse
         
         if recok
         {
            str rdir
            
            rdir.fgetdir( cursrc )
            if *rdir > 1 && rdir[1] == ':' && cursrc.findch('*') >= *cursrc &&
               cursrc.findch('?') >= *cursrc : recok = 0
         }
         
         fd.init( cursrc, $FIND_FILE | recok ) 
         foreach cur, fd
         {
            if cur.name.isexclude( exclude ) : continue
            this.summarysize += long( cur.sizelo )
//            print("\(this.summarysize) \(cur.fullname)\n")
            this.additem( $FL_FILE, cur.fullname )
         }
         continue
      }
      this.adddir( cursrc, exclude, this.flags )
   }
   return this.files
}

method uint filelist.eof( fordata fd )
{
   return .eof
}

method uint filelist.first( fordata fd )
{  
   uint off
   
   .iblock = 0
   .icur = 0
   fd.icur = sizeof( uint )
   if !( .block[ .iblock ]->uint )
   {
      .eof = 1
      return 0
   }
   .eof = 0
   off = .block[ .iblock ] + fd.icur
   this.fl.itype = off->ubyte
   this.fl.name.copy( off + 3, (off + 1)->ushort - 1 ) 
   fd.icur += (off + 1)->ushort + 3
   return &this.fl
}

method uint filelist.next( fordata fd )
{
   uint off
   
   .icur++
   if .icur == .block[.iblock]->uint
   { 
      .iblock++
      if .iblock > .bcount
      { 
         .eof = 1
         return 0
      } 
      .icur++
      fd.icur = sizeof( uint )
   }
   off = .block[ .iblock ] + fd.icur
   this.fl.itype = off->ubyte
   this.fl.name.copy( off + 3, (off + 1)->ushort - 1 ) 
   fd.icur += (off + 1)->ushort + 3 
   return &this.fl
}

