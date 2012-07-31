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

/*-----------------------------------------------------------------------------
* Id: stringfile L "String - Filename"
* 
* Summary: Filename strings. Methods for working with file names.
*
* List:  *,str_faddname,str_fappendslash,str_fdelslash,str_ffullname,
         str_fgetdir,str_fgetdrive,str_fgetext,str_fgetparts,str_fnameext,
         str_fsetext,str_fsetname,
         str_fsetparts,str_fsplit,str_fwildcard
* 
-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
* Id: str_fappendslash F3
*
* Summary: Adding a slash. Add '\' to the end of a string if it is not there.  
* 
* Return: #lng/retobj#
*
-----------------------------------------------------------------------------*/

method str str.fappendslash()
{
   if !this.islast( '\' ) : this.appendch( '\' )

   return this
}

/*-----------------------------------------------------------------------------
* Id: str_faddname F2
*
* Summary: Adding a name. Add a file name or a directory to a path.  
* 
* Params: name - The name being added. It will be added after a slash.   
* 
* Return: #lng/retobj#
*
-----------------------------------------------------------------------------*/

method str str.faddname( str name )
{
   if *this && *name : this.fappendslash()

   return this += name
}

/*-----------------------------------------------------------------------------
* Id: str_fdelslash F3
*
* Summary: Deleting the final slash. Delete the final '\' if it is there.
* 
* Return: #lng/retobj#
*
-----------------------------------------------------------------------------*/

method str str.fdelslash()
{
   this.trimrsys()
   return this.trim( '\', $TRIM_RIGHT )
}

/*-----------------------------------------------------------------------------
* Id: str_fgetdir F2
*
* Summary: Getting the directory name. The method removes the final name of a
           file or directory. 
* 
* Params: name - Initial filename.   
* 
* Return: #lng/retobj#
*
-----------------------------------------------------------------------------*/

method str str.fgetdir( str name )
{
   uint  len = name.findchr( '\' )
   
   if len >= *name : len = 0
   if &name == &this : this.setlen( len )
   else : this.substr( name, 0, len )

   return this
}

/*-----------------------------------------------------------------------------
* Id: str_ffullname F2
*
* Summary: Getting the full name. The method gets the full path and name 
           of a file. 
* 
* Params: name - Initial filename.   
* 
* Return: #lng/retobj#
*
-----------------------------------------------------------------------------*/

method str str.ffullname( str name )
{
   uint  off
   
   this.reserve( 512 )
   this.setlen( GetFullPathName( name.ptr(), 512, this.ptr(), &off ))
   
   return this
}

/*-----------------------------------------------------------------------------
* Id: str_fgetdrive F2
*
* Summary: Getting the name of a disk. Get the network name 
           (\\computer\share\) or the name of a disk (c:\). 
* 
* Params: name - Initial filename.   
* 
* Return: #lng/retobj#
*
-----------------------------------------------------------------------------*/

method str str.fgetdrive( str name )
{
   uint   i
   
   this.ffullname( name )
   
   if this[ 1 ] == ':'
   {
      i = 2
   }
   elif this[0] == '\' && this[1] == '\'
   {
      i = this.findchnum( '\', 4 )
   }
   this.setlen( i )
      
   return this.fappendslash()
}

/*-----------------------------------------------------------------------------
* Id: str_fsplit F2
*
* Summary: Getting the directory and name of a file. The method splits the full
           path into the name of the final file or directory 
           and the rest of the path.
* 
* Params: dir - The string for getting the directory. 
          name - The string for getting the name of a file or directory. 
*
-----------------------------------------------------------------------------*/

method str.fsplit( str dir, str name )
{
   uint   separ = this.findchr( '\' )
   uint   len = *this
   uint   off

   off = ?( separ >= len, 0, separ + 1 )

   name.copy( this.ptr() + off )
   dir.substr( this, 0, ?( separ && separ < len, separ, 0 ))
}

/*-----------------------------------------------------------------------------
* Id: str_fnameext F2
*
* Summary: Getting the name of a file. Get the name of the filename or
           directory from the full path.
* 
* Params:  name - Initial filename. 
*
-----------------------------------------------------------------------------*/

method str str.fnameext( str name )
{
   uint   separ = name.findchr( '\' )
   uint   off = ?( separ >= *name, 0, separ + 1 )

   return this.copy( name.ptr() + off )
}

/*-----------------------------------------------------------------------------
* Id: str_fgetparts F2
*
* Summary: Getting name components. Get the directory, name and extensions 
           of a file. 
* 
* Params: dir - The string for getting the directory. It can be 0-&gt;str. 
          fname - The string for getting the file name. It can be 0-&gt;str. 
          ext - The string for getting the file extension. It can be 0-&gt;str. 
*
-----------------------------------------------------------------------------*/

method  str.fgetparts( str dir, str fname, str ext )
{
   uint   dot = this.findchr( '.' )
   uint   separ = this.findchr( '\' )
   uint   off

   if ext
   {
      if ( dot > separ || separ >= *this ) && dot < *this
      {
         ext.substr( this, dot + 1, *this - dot - 1 )
      }
      else : ext.clear()
   }
   if fname
   {
      off = ?( separ >= *this, 0, separ + 1 )
      fname.substr( this, off, dot - off )
   }
   if dir
   {
      dir.substr( this, 0, ?( separ && separ < *this, separ, 0 ))
   }
}

/*-----------------------------------------------------------------------------
* Id: str_fsetparts F2
*
* Summary: Compounding or modifying the name. Compound the name of a file 
           out of the path, name and extension. This function can be also used
           to modify the path, name or extension of a file. In this case 
           if some component equals 0-&gt;str, it is left unmodified. 
* 
* Params: dir - Directory. 
          fname - Filename. 
          ext - File extension. 
*
* Return: #lng/retobj#
*
-----------------------------------------------------------------------------*/

method str str.fsetparts( str dir, str fname, str ext )
{
   str  cdir cname cext

   this.fgetparts( cdir, cname, cext )
   this.clear( )

   this = ?( dir, dir, cdir )

   this.faddname( ?( fname, fname, cname ))
 
   if ext || *cext 
   {
      this.appendch( '.' )
      this += ?( ext, ext, cext )
   }
   return this
}

/*-----------------------------------------------------------------------------
* Id: str_fsetext F2
*
* Summary: Modifying the extension. The method gets the file name with a new
           extension.
* 
* Params: name - Initial file name. 
          ext - File extension. 
*
* Return: #lng/retobj#
*
-----------------------------------------------------------------------------*/

method str str.fsetext( str name, str ext )
{
   uint   dot = name.findchr( '.' )
   uint   separ = name.findchr( '\' )
        
   this = name
   if separ < dot || separ >= *name
   {
      this.setlen( dot )
   }
   if ext : this += ".\(ext)"      
   return this
}

/*-----------------------------------------------------------------------------
* Id: str_fsetext_1 FA
*
* Summary: Modifying the extension in the filename.
* 
* Params: ext - File extension. 
*
-----------------------------------------------------------------------------*/

method str str.fsetext( str ext )
{
   return this.fsetext( this, ext )
}

/*-----------------------------------------------------------------------------
* Id: str_fgetext F3
*
* Summary: Get the extension. The method writes the file extension into 
           the result string. 
* 
* Return: The result string with the extension.
*
-----------------------------------------------------------------------------*/

method str str.fgetext< result >
{
   uint   dot = this.findchr( '.' )
   uint   separ = this.findchr( '\' )
        
   if separ < dot || separ >= *this
   {
      result.substr( this, dot + 1, *this - dot - 1 )
   }
}

/*-----------------------------------------------------------------------------
* Id: str_fsetname F2
*
* Summary: Modifying the name of the file. The method modifies the current
           filename. 
* 
* Params: filename - A new filename. 
*
* Return: #lng/retobj#
*
-----------------------------------------------------------------------------*/

method str str.fsetname( str filename )
{
    return this.fgetdir( this ).faddname( filename )
}
      
//--------------------------------------------------------------------------
