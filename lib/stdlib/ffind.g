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
* Id: findflags D
* 
* Summary: Flags for searching files.
*
-----------------------------------------------------------------------------*/
   FIND_DIR     = 0x0001    // Search only for directories.
   FIND_FILE    = 0x0002    // Search only for files.
   FIND_RECURSE = 0x0004    // Search in all subdirectories.
   
/*-----------------------------------------------------------------------------
* Id: fdelflags D
* 
* Summary: Flags for delfiles.
*
-----------------------------------------------------------------------------*/
   DELF_RO      = 0x0100    // Delete files with the attribute read-only.
   
//-----------------------------------------------------------------------------   
}

/*-----------------------------------------------------------------------------
* Id: tfinfo T finfo 
* 
* Summary: File information structure. This structure is used by 
           #a(getfileinfo) function and #a(ffind_opfor, foreach ) operator.
*
-----------------------------------------------------------------------------*/

type finfo {
   str       fullname   // The full name of the file or directory.
   str       name       // The name of the file or directory.
   uint      attrib     // File attributes.
   filetime  created    // Creation time.
   filetime  lastwrite  // Last modification time.
   filetime  lastaccess // Last access time.
   uint      sizehi     // High size uint.
   uint      sizelo     // Low size uint.
}

//-----------------------------------------------------------------------------

type fstack {
   finfo  info
   str    path
   uint   find
   uint   ok   
}

/*-----------------------------------------------------------------------------
* Id: ffind T 
* 
* Summary: File search structure. This structure is used in 
           #a(ffind_opfor,foreach ) operator. You must not modify fields of 
           #i(ffind) variable. You must initialize it with #a(ffind_init) 
           method.
*
-----------------------------------------------------------------------------*/

type ffind <index = finfo> {
   stack  deep of fstack    // Hidden data.
   str    initname          // Hidden data.
   str    wildcard          // Hidden data. 
   uint   flag              // Hidden data.
}

//-----------------------------------------------------------------------------

method fstack.delete()
{
   if this.find 
   {
      FindClose( this.find )
      this.find = 0
   }
}

/*-----------------------------------------------------------------------------
* Id: ffind_init F2
*
* Summary: Initializing file search. An object of the #a(ffind) type is used to
           search for files and directories by mask. Before starting the 
           search, you should call the init method. After this it is possible 
           to use the initiated object in the #b(foreach) loop. The #a(tfinfo)
           structure will be returned for each found file.  
*  
* Params: name - The mask for searching files and directories. 
          flag - The combination of the following flags:$$[findflags] 
* 
-----------------------------------------------------------------------------*/

method ffind.init( str name, uint flag )
{
   arr ss of fstack
   this.deep.clear()
   this.flag = flag
   this.initname = name
   this.initname.fdelslash()
   this.wildcard.fnameext( this.initname )
   ss.insert( 0, 1 )
   this.deep.push()
}

func  wfd2finfo( WIN32_FIND_DATA  wfd, finfo fi, str path )
{
   fi.name.copy( &wfd.cFileName )
   ( fi.fullname = path ).faddname( fi.name )
   fi.attrib = wfd.dwFileAttributes
   fi.lastwrite = wfd.ftLastWriteTime
   fi.created = wfd.ftCreationTime
   fi.lastaccess = wfd.ftLastAccessTime
   fi.sizehi = wfd.nFileSizeHigh
   fi.sizelo = wfd.nFileSizeLow
}

operator finfo =( finfo left, finfo right )
{
   left.fullname = right.fullname
   left.name = right.name
   left.attrib = right.attrib
   left.lastwrite = right.lastwrite
   left.created = right.created
   left.lastaccess = right.lastaccess
   left.sizehi = right.sizehi
   left.sizelo = right.sizelo

   return left
}

method finfo ffind.getinfo
{
   return this.deep.top()->finfo   
}

method finfo ffind.found( WIN32_FIND_DATA wfd )
{
   uint  flag = this.flag
   uint  current = this.deep.top()
   
   if !wfd.cFileName[0] : goto next
   
   label again
   current as fstack

   current.ok = 0
   if wfd.cFileName[0] == '.' && ( !wfd.cFileName[1] ||
           ( wfd.cFileName[1] == '.' && !wfd.cFileName[2] ))
   {
      goto next
   }  
   if wfd.dwFileAttributes & $FILE_ATTRIBUTE_DIRECTORY 
   {
       if flag & $FIND_DIR : current.ok = 1
   }
   else : if flag & $FIND_FILE : current.ok = 1
   
   if current.ok
   {     
      //current.ok = sfwildcard( &wfd.cFileName, this.wildcard.ptr())
      str fn
      fn.copy(  &wfd.cFileName )
      current.ok = fn.fwildcard( this.wildcard ) 
   }

   if wfd.dwFileAttributes & $FILE_ATTRIBUTE_DIRECTORY &&
      flag & $FIND_RECURSE
   {
      str   newfld
      uint  find
      
      wfd2finfo( wfd, current.info, current.path )

      newfld = current.info.fullname
      current as this.deep.push()
      current as fstack
      current.path = newfld
      newfld.faddname( "*" )
      
      current.find = FindFirstFile( newfld.ptr(), wfd )
      if current.find != $INVALID_HANDLE_VALUE 
      {
         goto again
      }
      current as this.deep.pop()
      current as fstack
   }
   if current.ok 
   {
      wfd2finfo( wfd, current.info, current.path ) 
      return this.getinfo()
   }

   label next
   if FindNextFile( current.find, wfd ) : goto again

   FindClose( current.find )
   current.find = 0

   if *this.deep > 1 
   {
      current as this.deep.pop()
      current as fstack      
      if ( current.ok ) : this.getinfo()
      else : goto next
   }
   
   return this.getinfo()
}

/*-----------------------------------------------------------------------------
* Id: ffind_opfor F5
*
* Summary: Foreach operator. You can use #b(foreach) operator to look over  
           files in some directory with the specified wildcard. The #a(tfinfo)
           structure will be returned for each found file. You must call 
           #a(ffind_init) before using #b(foreach). #srcg[
|ffind fd
|fd.init( "c:\\*.exe", $FIND_FILE | $FIND_RECURSE )
|foreach finfo cur,fd
|{
|   print( "\( cur.fullname )\n" )
|}]
*  
* Title: foreach var,ffind
*
* Define: foreach variable,ffind {...}
* 
-----------------------------------------------------------------------------*/

method uint ffind.next( fordata fd)
{
   WIN32_FIND_DATA  wfd   
   
   return &this.found( wfd )
}

method uint ffind.first( fordata fd )
{
   WIN32_FIND_DATA  wfd
   str              temp
   uint             start
   
   start = this.deep.top()
   start as fstack
   if !*this.initname 
   {
      start.find = 0
      return &start.info
   }
   ( temp = this.initname ).fdelslash()
   
   if this.flag & $FIND_RECURSE
   {
      temp.fgetdir( temp )
      temp.faddname( "*" )
   }
   start.find = FindFirstFile( temp.ptr(), wfd )
   if start.find == $INVALID_HANDLE_VALUE 
   {
      start.find = 0
      return &start.info
   }
   start.path.fgetdir( temp )
   return &this.found( wfd )
}

method  uint  ffind.eof( fordata fd )
{
   return !this.deep.top()->fstack.find
}

/*-----------------------------------------------------------------------------
* Id: getfileinfo F
*
* Summary: Get information about a file or directory.  
*  
* Params: name - The name of a file or directory. 
          fi - The structure #a(tfinfo) all the information will be written to. 
* 
* Return: It returns 1 if the file is found, it returns 0 otherwise.
*
-----------------------------------------------------------------------------*/

func uint getfileinfo( str name, finfo fi )
{
   ffind fd
   
   fd.init( name, $FIND_DIR | $FIND_FILE )
   foreach finfo cur, fd
   {
      fi = cur            
      return 1
   }
   
   return 0
}

/*-----------------------------------------------------------------------------
* Id: delfiles F
*
* Summary: Deleting files and directories by mask. Directories are deleted
           together with all files and subdirectories. Be really careful while
           using this function. For example, calling
            
|#srcg[delfiles( "c:\\temp", $FIND_DIR | $FIND_FILE | $FIND_RECURSE )]

           will delete all files and directories named temp on the disk N:
           including a search in all directories. In this case temp is
           considered a mask and since the flag $FIND_RECURSE is specified, the
           entire disk C: will be searched. If you just need to delete the
           directory temp with all its subdirectories and files, you should 
           call 

|#srcg[delfiles("c:\\temp", $FIND_DIR )]
           Calling

|#srcg[delfiles( "c:\\temp\\*.tmp", $FIND_FILE )]
            will delete all files in the directory tmp leaving subdirectories. 
*  
* Params: name - The name of mask for searching. 
          flag - Search and delete flags.$$[findflags]$$[fdelflags] 
* 
-----------------------------------------------------------------------------*/

func  delfiles( str name, uint flag )
{
   ffind fd
   
   fd.init( name, flag )
   
   foreach finfo cur, fd
   {
      if cur.attrib & $FILE_ATTRIBUTE_DIRECTORY
      {
         delfiles( cur.fullname + "\\*.*" , flag | $FIND_FILE )
         deletedir( cur.fullname )       
      }
      else
      {
         if flag & $DELF_RO && cur.attrib & $FILE_ATTRIBUTE_READONLY
         {
            setattribnormal( cur.fullname )
         }
         deletefile( cur.fullname )
      }   
   }
}

