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
* Id: files L "Files"
* 
* Summary: File system functions.
*
* List: *#lng/methods#,file_close,file_getsize,file_gettime,file_open,
        file_read,file_setpos,file_settime,file_write,
        *#lng/funcs#,copyfile,copyfiles,createdir,deletedir,deletefile,delfiles,
        direxist,fileexist,getcurdir,getdrives,getdrivetype,getfileattrib,
        getmodulename,getmodulepath,gettempdir,isequalfiles,movefile,
        setattribnormal,setcurdir,setfileattrib,verifypath,
        *Search and fileinfo functions,tfinfo,ffind,ffind_opfor,ffind_init,
        getfileinfo,
        *@Related Methods,arrstr_read,arrstr_write,buf_read,buf_write,
        buf_writeappend,str_read,str_write,str_writeappend,
* 
-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
* Id: copyfile F
*
* Summary: Copy a file. 
*  
* Params: name - The name of an existing file. 
          newname - A new file name and path. If the file already exists, it /
                    will be overwritten. 
* 
* Return: #lng/retf#
*
-----------------------------------------------------------------------------*/

func uint copyfile( str name, str newname )
{
   return CopyFile( name->buf.data, newname->buf.data, 0 )
}

/*-----------------------------------------------------------------------------
* Id: createdir F
*
* Summary: Create a directory. 
*  
* Params: name - The name of the directory being created.  
* 
* Return: #lng/retf#
*
-----------------------------------------------------------------------------*/

func uint createdir( str name )
{               
   return CreateDirectory( name.ptr(), 0 )
}

/*-----------------------------------------------------------------------------
* Id: deletedir F
*
* Summary: Delete a directory. 
*  
* Params: name - The name of the directory being deleted.  
* 
* Return: #lng/retf#
*
-----------------------------------------------------------------------------*/

func uint deletedir( str name )
{
   return RemoveDirectory( name.ptr() )
}

/*-----------------------------------------------------------------------------
* Id: deletefile F
*
* Summary: Delete a file. 
*  
* Params: name - The name of the file being deleted.  
* 
* Return: #lng/retf#
*
-----------------------------------------------------------------------------*/

func uint deletefile( str name )
{
   return DeleteFile( name.ptr() )
}

/*-----------------------------------------------------------------------------
* Id: getdrivetype F
*
* Summary: Get the type of a disk. 
*  
* Params: drive - The name of a disk with a closing slash. /
                  For example: #b(C:\)   
* 
* Return: Returns one of the following values: $$[drivetypes]
*
-----------------------------------------------------------------------------*/

func uint getdrivetype( str name )
{
   if !&name : return GetDriveType( 0 )
   
   return GetDriveType( name.fappendslash().ptr())
}

/*-----------------------------------------------------------------------------
* Id: getfileattrib F
*
* Summary: Getting file attributes. 
*  
* Params: name - Filename.    
* 
* Return: The function returns file attributes. It returns 0xFFFFFFFF in case 
          of an error.$$[fileattribs]
*
-----------------------------------------------------------------------------*/

func uint getfileattrib( str name )
{
   return GetFileAttributes( name.ptr())
}

/*-----------------------------------------------------------------------------
* Id: setfileattrib F
*
* Summary: Set file attributes. 
*  
* Params: name - Filename.
          attrib - File attributes. $$[fileattribs]     
* 
* Return: #lng/retf#
*
-----------------------------------------------------------------------------*/
         
func uint setfileattrib( str name, uint attrib )
{
   return SetFileAttributes( name.ptr(), attrib )
}

/*-----------------------------------------------------------------------------
* Id: setattribnormal F
*
* Summary: Setting the attribute $FILE_ATTRIBUTE_NORMAL. 
*  
* Params: name - Filename.
* 
* Return: #lng/retf#
*
-----------------------------------------------------------------------------*/
         
func uint setattribnormal( str name )
{
   return setfileattrib( name, $FILE_ATTRIBUTE_NORMAL )
}

/*-----------------------------------------------------------------------------
* Id: fileexist F
*
* Summary: Checking if a file exists. 
*  
* Params: name - Filename.
* 
* Return: The function returns 1, if the specified file exists.
*
-----------------------------------------------------------------------------*/

func uint fileexist( str name )
{
   uint  attr = getfileattrib( name )
   return attr != 0xFFFFFFFF && !(attr & $FILE_ATTRIBUTE_DIRECTORY)
}

/*-----------------------------------------------------------------------------
* Id: direxist F
*
* Summary: Checking if a directory exists. 
*  
* Params: name - Directory name.
* 
* Return: The function returns 1, if the specified directory exists.
*
-----------------------------------------------------------------------------*/

func uint direxist( str name )
{
   uint  attr = getfileattrib( name )
   return attr != 0xFFFFFFFF && attr & $FILE_ATTRIBUTE_DIRECTORY
}

/*-----------------------------------------------------------------------------
* Id: getmodulename F
*
* Summary: Get the file name of the currently running application. 
*  
* Params: dest - The string for getting the name.
* 
* Return: #lng/retpar( dest )
*
-----------------------------------------------------------------------------*/

func str getmodulename( str dest )
{
   uint  i

   dest.reserve( 512 )
   i = GetModuleFileName( 0, dest->buf.data, 511 )
   dest.setlen( i );

   return dest
}

/*-----------------------------------------------------------------------------
* Id: getmodulepath F
*
* Summary: Get the path to the running EXE file. 
*  
* Params: dest - Result string. 
          subfolder - Additional path. This string will be added to the /
                     obtained result. It can be empty. 
* 
* Return: #lng/retpar( dest )
*
-----------------------------------------------------------------------------*/

func str getmodulepath( str dest, str subfolder )
{
   dest.fgetdir( getmodulename( dest ))
   if &subfolder && *subfolder : dest.faddname( subfolder )
   return dest
}

/*-----------------------------------------------------------------------------
* Id: movefile F
*
* Summary: Rename, move a file or a directory. 
*  
* Params: name - The name of an existing file or a directory. 
          newname - A new file name and path. 
* 
* Return: #lng/retf#
*
-----------------------------------------------------------------------------*/

func uint movefile( str name, str newname )
{
   return MoveFile( name->buf.data, newname->buf.data )
}

/*-----------------------------------------------------------------------------
* Id: verifypath F
*
* Summary: Verifying a path and creating all absent directories. 
*  
* Params: name - The name of the path to be verified. 
          dirs - An array for getting all the directories being created. /
                 It can be 0-&gt;arrstr. 
* 
* Return: The function returns 1 if directories have been verified and created
          successfully. In case of an error, the function returns 0 and the 
          last dirs item contains the name where there occurred an error 
          while creating a directory. 
*
-----------------------------------------------------------------------------*/

func uint verifypath( str name, arrstr dirs )
{
   str  fullname drive
   uint i
   arrstr  names
   
   fullname.ffullname( name )
   fullname.fdelslash()
   if dirs : dirs.delete()
   
   if direxist( fullname ) : return 1

   drive.fgetdrive( fullname )
   fullname.del( 0, *drive )
   fullname.split( names, '\', 0 )
   
   fornum i = 0,*names
   {
      drive.faddname( names[i] )
      if !direxist( drive )
      {
         if dirs : dirs[ dirs.expand( 1 ) ] = drive
         if !createdir( drive ) : return 0
      }
   }   
   return 1   
}

/*-----------------------------------------------------------------------------
* Id: getcurdir F
*
* Summary: Getting the current directory. 
*  
* Params: dir - The string for getting the result. 
* 
* Return: #lng/retpar( dir )
*
-----------------------------------------------------------------------------*/

func str  getcurdir( str dir )
{
   dir.clear()
   dir.reserve( 512 )
   GetCurrentDirectory( 512, dir.ptr())
   return dir.setlenptr()   
}

/*-----------------------------------------------------------------------------
* Id: setcurdir F
*
* Summary: Setting the current directory. 
*  
* Params: dir - The name of the new current directory. 
* 
* Return: #lng/retf#
*
-----------------------------------------------------------------------------*/

func uint  setcurdir( str dir )
{
   return SetCurrentDirectory( dir.ptr())
}

/*-----------------------------------------------------------------------------
* Id: gettempdir F
*
* Summary: Get the temporary directory of the application. When this function 
           is called for the first time, in the temporary directory there will 
           be created a directory named genteeXX, where XX is a unique number 
           for this running application. When the application is closed, the 
           directory will be deleted with all its files.  
*  
* Params: dir - The string for getting the result. 
* 
* Return: #lng/retpar( dir )
*
-----------------------------------------------------------------------------*/

func str  gettempdir( str dir )
{
   dir.clear()
   return dir = gettemp( )
}

/*-----------------------------------------------------------------------------
* Id: getdrives F1
*
* Summary: Get the names of available disks. 
*  
* Return: The array (arrstr) of the disk names.
*
-----------------------------------------------------------------------------*/

func arrstr getdrives <result>()
{
   buf  stemp
   
   stemp.reserve( 512 )
   stemp.use = GetLogicalDriveStrings( 512, stemp.ptr())
   stemp.getmultistr( result )   
}


