/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved.
* This file is part of the Gentee open source project - http://www.gentee.com.
*
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT").
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: defines 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov
*
* Summary: This file provides Windows basic types and some constants.
*
******************************************************************************/

#include "defines.h"
#include "../../genteeapi/gentee.h"
#ifdef LINUX
   #include <unistd.h>
   #include <fcntl.h>
   #include <stdarg.h>
   #include <sys/types.h>
   #include <sys/stat.h>
   #include <sys/times.h>
   #include <dirent.h>
   #include <pthread.h>
   #include <stdio.h>
   //#include <wvstreams/wvstrutils.h>
   #include <string.h>
   #include <errno.h>
#else
   #include "shlobj.h"
#endif

#ifdef WINDOWS
 pvoid  _stdout = INVALID_HANDLE_VALUE;
 pvoid  _stdin = INVALID_HANDLE_VALUE;
#endif

/*-----------------------------------------------------------------------------
*
* ID: os_dircreate 14.12.07
*
* Summary: Create the directory
*
-----------------------------------------------------------------------------*/

uint     STDCALL os_dircreate( pstr name )
{
 #ifdef LINUX
   return mkdir(str_ptr( name ),700);
 #else
   return CreateDirectory( str_ptr( name ), NULL );
 #endif
}

/*-----------------------------------------------------------------------------
*
* ID: os_dirdelete 14.12.07
*
* Summary: Delete the empty directory
*
-----------------------------------------------------------------------------*/

uint     STDCALL os_dirdelete( pstr name )
{
  #ifdef LINUX
   return rmdir(str_ptr( name ));
  #else
   return RemoveDirectory( str_ptr( name ));
  #endif
}

/*-----------------------------------------------------------------------------
*
* ID: os_dirgetcur 14.12.07
*
* Summary: Get the current directory
*
-----------------------------------------------------------------------------*/

pstr   STDCALL os_dirgetcur( pstr name )
{
   #ifdef LINUX
    return str_setlen( name,getcwd( str_ptr( name), 512 ));
   #else
    return str_setlen( name, GetCurrentDirectory( 512,str_ptr( str_reserve( name, 512 ))));
   #endif
}

/*-----------------------------------------------------------------------------
*
* ID: os_dirsetcur 14.12.07
*
* Summary: Set the current directory
*
-----------------------------------------------------------------------------*/

uint  STDCALL os_dirsetcur( pstr name )
{
   #ifdef LINUX
    return chdir( str_ptr( name));
   #else
    return SetCurrentDirectory( str_ptr( name ));
   #endif
}

/*-----------------------------------------------------------------------------
*
* ID: os_dirdeletefull 14.12.07
*
* Summary: Delete the directory with subfolders and files
*
-----------------------------------------------------------------------------*/

uint     STDCALL os_dirdeletefull( pstr name )
{
 #ifdef WINDOWS
   str  stemp;
   WIN32_FIND_DATA  data;
   pvoid            find;

   str_init( &stemp );
   str_printf( &stemp, "%s%c*.*", str_ptr( name ), SLASH );
   find = FindFirstFile( str_ptr( &stemp ), &data );
   if ( find != INVALID_HANDLE_VALUE )
   {
      do {
         if ( data.cFileName[0] == '.' && ( !data.cFileName[1] ||
            ( data.cFileName[1] == '.' && !data.cFileName[2] )))
            continue;

         str_printf( &stemp, "%s%c%s", str_ptr( name ), SLASH, data.cFileName );

         if ( data.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY )
            os_dirdeletefull( &stemp );
         else
            os_filedelete( &stemp );

      } while ( FindNextFile( find, &data ));

      FindClose( find );
   }
   str_delete( &stemp );
 #endif
   return os_dirdelete( name );
}

/*-----------------------------------------------------------------------------
*
* ID: os_fileclose 14.12.07
*
* Summary: Close the file
*
-----------------------------------------------------------------------------*/

uint     STDCALL os_fileclose( uint handle )
{
  #ifdef LINUX
   return close((handle ));
  #else
   return CloseHandle(( pvoid )handle );
  #endif
}

/*-----------------------------------------------------------------------------
*
* ID: os_filefullname 14.12.07
*
* Summary: Get the full name of the file
*
-----------------------------------------------------------------------------*/
/*
pstr  STDCALL os_filefullname( pstr filename, pstr result )
{

   str_reserve( result, 512 );
   //if ( ichar != SLASH )
   //printf("ddddddddddd");
    //result = "DEMO";
    //str_copy(result, "DEMO");
    //return result;
   //if ( str_findch(filename,SLASH) != 0 )
   pubyte dddd = (pubyte)filename;
   if ( dddd[0] == '/' )
   {
      char  cur[512];
      getcwd( cur, 512 );
      chdir( filename );
      basename( filename );
      getcwd( str_ptr( result ), 512 );
      uint iDov = str_len( result );
      //str_setlen(result, strlen( str_ptr( result ) ) );
      str_setlen(result, strlen( (pubyte) result ) );
      str_add( result, "/" );
      str_add( result, filename );
      chdir( cur );
   }
   else
   { //®¦¥â à ¡®â âì ­¥ª®àà¥ªâ­® ¥á«¨ ¢  ¡á®«îâ­®¬ ¯ãâ¨ ¢áâà¥ç îâáï '.' '..'
      str_copy( result, filename );
   }
   return result;

}
*/

pstr  STDCALL os_filefullname( pstr filename, pstr result )
{
   pubyte  ptr;

#ifdef LINUX
   //ubyte       exename[512];
   //ubyte       proname[ 512 ];
   pstr p_drive,p_path,p_fname,p_fext,p_slesh;
   ubyte ffn_drive[FILENAME_MAX+1];
   ubyte ffn_path[PATH_MAX+1];
   ubyte ffn_fname[FILENAME_MAX+1];
   ubyte ffn_fext[FILENAME_MAX+1];


   os_splitpath(str_ptr(filename),ffn_drive,ffn_path,ffn_fname,ffn_fext);
   p_slesh = str_new((pubyte)"/");
   if (strlen(ffn_path)==0)
   {
     char  cur[512];
     getcwd( cur, 512 );
     p_path = str_new(cur);
     str_add(p_path,p_slesh);
   }
   else
     p_path = str_new(ffn_path);

   p_fname = str_new(ffn_fname);
   p_fext = str_new(ffn_fext);

   str_add(result,p_path);

   str_add(result,p_fname);
   str_add(result,p_fext);
   str_destroy(p_path);
   str_destroy(p_slesh);
   str_destroy(p_fname);
   str_destroy(p_fext);
/*   char  cur[512];
   if ( filename[0] != '/' )
   {
      getcwd( cur, 512 );
      chdir( filename );
      basename( filename );
      getcwd( str_ptr( ( pstr )buf ), 512 );
      str_setlen( ( pstr )buf, strlen( str_ptr( ( pstr )buf ) ) );
      str_appendb( buf, '/' );
       str_appendp( buf, filename );
      chdir( cur );
   }
   else
   { //Ìîæåò ðàáîòàòü íåêîððåêòíî åñëè â àáñîëþòíîì ïóòè âñòðå÷àþòñÿ '.' '..'
       str_appendp( buf, filename );
   }
*/
#else
   uint len;
   str_reserve( result, 512 );

   len = GetFullPathName(str_ptr(filename), 512, str_ptr(result), &ptr );
   // äëÿ Windows
   str_setlen(result, len);
#endif
   return result;
}



/*-----------------------------------------------------------------------------
*
* ID: os_filedelete 14.12.07 .
*
* Summary: Delete the file
*
-----------------------------------------------------------------------------*/

uint     STDCALL os_filedelete( pstr name )
{
    #ifdef LINUX
     return remove(str_ptr(name));
    #else
     return DeleteFile( str_ptr( name ));
    #endif
}

uint  STDCALL os_fileopen( pstr name, uint flag )
{
#ifdef LINUX
   int fd;
   fd = open( str_ptr( name ), ( flag & FOP_READONLY ? O_RDONLY : O_RDWR ) |
                    ( flag & FOP_CREATE ? O_CREAT : 0 ) |
                    ( flag & FOP_IFCREATE ? O_TRUNC : 0 ), S_IRWXU );
   if ( fd != -1 && flag & FOP_EXCLUSIVE )
   {
      if ( flock( fd, LOCK_EX ) == -1 )
      {
        	close( fd );
			fd = -1;
      }
   }
   return fd;
#else
   uint ret;

   ret = ( uint )CreateFile( str_ptr( name ), ( flag & FOP_READONLY ? GENERIC_READ :
            GENERIC_READ | GENERIC_WRITE ), ( flag & FOP_EXCLUSIVE ? 0 :
            FILE_SHARE_READ | FILE_SHARE_WRITE ), NULL,
           ( flag & FOP_CREATE ? CREATE_ALWAYS :
              ( flag & FOP_IFCREATE ? OPEN_ALWAYS : OPEN_EXISTING )),
           /*FILE_FLAG_WRITE_THROUGH*/ 0, NULL );
   //printf("Name=%s %i\n", str_ptr( name ), ret );
   return ret == ( uint )INVALID_HANDLE_VALUE ? 0 : ret ;
#endif

}

ulong64  STDCALL os_filepos( uint handle, long64 offset, uint mode )
{

  #ifdef LINUX
   int newset;
   newset = lseek( handle, offset, ( mode == FSET_BEGIN ?
      SEEK_SET : ( mode == FSET_CURRENT ? SEEK_CUR : SEEK_END )));
   if ( newset == offset - 1 )
      return -1;
   return newset;
  #else
   LARGE_INTEGER  li;

   li.QuadPart = offset;

   li.LowPart = SetFilePointer( ( pvoid )handle, li.LowPart, &li.HighPart,
       ( mode == FSET_BEGIN ?
      FILE_BEGIN : ( mode == FSET_CURRENT ? FILE_CURRENT : FILE_END )));
   if ( li.LowPart == MAX_UINT && GetLastError() != NO_ERROR )
      return -1L;
   return li.QuadPart;
  #endif
}

uint   STDCALL os_fileread( uint handle, pubyte data, uint size )
{
  #ifdef LINUX
   uint  cntread;
   cntread = read( handle, data, size );
   if ( cntread == -1 || cntread != size )
      return FALSE;
   return TRUE;
  #else
   uint  read;
   if ( !ReadFile( (pvoid)handle, data, size, &read, NULL ) || read != size )
      return FALSE;
   return read;
  #endif
}

ulong64  STDCALL os_filesize( uint handle )
{
  #ifdef LINUX
   long size, curoff;
   curoff = lseek( handle, 0, SEEK_CUR );
   size = lseek( handle, 0, SEEK_END );
   lseek( handle, curoff, SEEK_SET );
   return size;
  #else
   LARGE_INTEGER  li;
   li.LowPart = GetFileSize( ( pvoid )handle, &li.HighPart );
   if ( li.LowPart == INVALID_FILE_SIZE && GetLastError() != NO_ERROR )
      return -1L;
   return li.QuadPart;
  #endif
}

//--------------------------------------------------------------------------

uint   STDCALL os_filewrite( uint handle, pubyte data, uint size )
{
  #ifdef LINUX
   uint  cntwrite;
   cntwrite = write( handle, data, size );
   if ( cntwrite == -1 || cntwrite != size )
      return FALSE;
   return TRUE;
  #else
   uint  write;
   if ( !WriteFile( ( pvoid )handle, data, size, &write, NULL ) || write != size )
      return FALSE;
   return write;
  #endif
}

/*-----------------------------------------------------------------------------
*
* ID: os_fileexist 14.12.07 .
*
* Summary: If the file or directory exists
*
-----------------------------------------------------------------------------*/

uint STDCALL os_fileexist( pstr name )
{
   return os_getattrib( name ) != 0xFFFFFFFF ? 1 : 0;
}

/*-----------------------------------------------------------------------------
*
* ID: os_getattrib 14.12.07 .
*
* Summary: Get the file or directory attrbutes
*
-----------------------------------------------------------------------------*/

uint  STDCALL os_getattrib( pstr name )
{
    #ifdef LINUX
     struct stat statbuf;
     stat(str_ptr(name),&statbuf);
     return statbuf.st_mode;
    #else
         return GetFileAttributes( str_ptr( name ));
    #endif

}

/*-----------------------------------------------------------------------------
*
* ID: os_tempdir 14.12.07 .
*
* Summary: Get the temp dir
*
-----------------------------------------------------------------------------*/

pstr  STDCALL os_tempdir( pstr name )
{
  #ifdef LINUX
   pstr stemp = os_gettemp();
   uint uLenTempStr  =  str_len(stemp);
   str_copy(name,stemp);
  #else
   str_setlen( name, GetTempPath( 1024, str_reserve( name, 1024 )->data ));
  #endif
  return str_trim( name, SLASH, TRIM_ONE | TRIM_RIGHT );
}

pstr  STDCALL os_gettemp( void )
{
   uint  diskc = 0;
   pstr  temp;
   pstr  ret;
//   ubyte temp[ 512 ];
//   ubyte stemp[ 512 ];

//   str_lenset( dir, 0 );
//   str_isfree( dir, 512 );
/*#ifdef LINUX
   if ( !ggentee.tempfile )
   {
      while( 1 )
      {
         wsprintf( stemp, "/temp/gentee%02X.tmp", ggentee.tempid );
         ggentee.tempfile = file_open( stemp, FOP_CREATE | FOP_EXCLUSIVE );
         if ( ggentee.tempfile = -1 )
            ggentee.tempid++;
         else
            break;
      }
      stemp[ mem_len( stemp ) - 4 ] = 0;
//      wsprintf( stemp, "%s\\gentee%02X", temp, ggentee.tempid );
      mkdir( stemp, 700 );
      ggentee.tempdir = str_new( 0, stemp );
   }
//   str_appendp( dir, str_ptr( ggentee.tempdir ));
#else*/
   if ( !_gentee.tempfile )
   {
      temp = str_new( NULL );
      ret = str_new( NULL );
      os_tempdir( temp );

      while ( 1 )
      {
         str_clear( ret );
         str_printf( ret, "%s\\gentee%02X.tmp", str_ptr( temp ), _gentee.tempid );

         _gentee.tempfile = os_fileopen( ret, FOP_CREATE | FOP_EXCLUSIVE );

         if ( !_gentee.tempfile )
         {
            if ( os_getattrib( ret ) == 0xFFFFFFFF )
               if ( !diskc )
               {
                  str_copyzero( temp, "c:\\temp" );
                  os_dircreate( temp );
                  diskc = 1;
               }
               else
                  msg( MFileopen | MSG_STR, ret );
            _gentee.tempid++;
         }
         else
            break;
      }
      str_setlen( ret, str_len( ret ) - 4 );
      os_dircreate( ret );
      str_copy( &_gentee.tempdir, ret );

      str_destroy( temp );
      str_destroy( ret );
   }
//#endif
   return &_gentee.tempdir;
}

/*-----------------------------------------------------------------------------
*
* ID: os_init 14.12.07 .
*
* Summary: Initializing input and output.
*
-----------------------------------------------------------------------------*/

void   STDCALL os_init( uint param )
{
 #ifdef LINUX
  _gentee.multib = 0;
 #else
   if ( param )  // if ( !GetConsoleWindow( ))
      AllocConsole();
   else
   {
      CPINFO cpinfo;

      GetCPInfo( CP_ACP, &cpinfo );
      _gentee.multib = cpinfo.MaxCharSize > 1 ? 1 : 0;
   }
   if ( _gentee.flags & G_CONSOLE || param )
   {
      _stdout = GetStdHandle( STD_OUTPUT_HANDLE );
      _stdin = GetStdHandle( STD_INPUT_HANDLE );
   }
 #endif
}

/*-----------------------------------------------------------------------------
*
* ID: os_print 14.12.07 .
*
* Summary: Print a text to the console.
*
-----------------------------------------------------------------------------*/

void   STDCALL os_print( pubyte ptr, uint len )
{
   //if (_gentee.print) :  _gentee.print(ptr,len);

  #ifdef LINUX
    write(1,ptr,len);
  #else
   uint    write;
   pubyte  charprn;

   if ( _gentee.flags & G_CHARPRN )
   {
      charprn = ( pubyte )mem_alloc( len + 1 );
      //CharToOem( ptr, charprn );
      ptr = charprn;
   }
   if ( _gentee.flags & G_CONSOLE )
      //WriteFile( _stdout, ptr, len, &write, 0 );
      os_filewrite( _stdout , ptr, len);
   else
   {
      if ( _stdout == INVALID_HANDLE_VALUE )
          os_init( 1 );
      //WriteConsole( _stdout, ptr, len, &write, NULL );
   }
   if ( _gentee.flags & G_CHARPRN )
      mem_free( charprn );
  #endif

}

/*-----------------------------------------------------------------------------
*
* ID: os_getch 14.12.07 .
*
* Summary: Get a character form the console.
*
-----------------------------------------------------------------------------*/

uint    STDCALL os_getchar( void )
{
  #ifdef LINUX
   return getchar();
  #else
   uint  mode, get;
   ubyte input[8];

   if(_gentee.getch)
     return _gentee.getch(0,1);

   if ( _stdin == INVALID_HANDLE_VALUE )
      os_init( 1 );

   GetConsoleMode( _stdin, &mode );
   SetConsoleMode( _stdin, 0 );
   ReadConsole( _stdin, input, 1, &get, NULL );
   SetConsoleMode( _stdin, mode );
//   return _getch();
   return input[0];
  #endif
}

/*-----------------------------------------------------------------------------
*
* ID: os_scan 14.12.07 .
*
* Summary: Get characters form the console.
*
-----------------------------------------------------------------------------*/

uint  STDCALL os_scan( pubyte input, uint len )
{

  #ifdef LINUX
   return read(0,input,len);
  #else
   uint   read;

   if (_gentee.getch)
    return _gentee.getch(input,len);

   if ( _stdin == INVALID_HANDLE_VALUE )
      os_init( 1 );
   ReadConsole( _stdin, input, len, &read, NULL );

   return read;
  #endif
}

/*-----------------------------------------------------------------------------
*
* ID: os_strcmplen 14.12.07 .
*
* Summary: Compare strings
*
-----------------------------------------------------------------------------*/

int   STDCALL os_strcmplen( pubyte one, pubyte two, uint len )
{
 #ifdef LINUX
  int cmp = strcmp(one,two);
  if (cmp < 0)
   return -1;
  if (cmp > 0)
   return 1;
 #else
   int cmp = CompareString( LOCALE_USER_DEFAULT, 0, one, len, two, len );
   if ( cmp == CSTR_LESS_THAN )
      return -1;
   if ( cmp == CSTR_GREATER_THAN )
      return 1;
 #endif
   return 0;
}

/*-----------------------------------------------------------------------------
*
* ID: os_strcmpignlen 14.12.07 .
*
* Summary: Compare strings
*
-----------------------------------------------------------------------------*/

int   STDCALL os_strcmpignlen( pubyte one, pubyte two, uint len )
{
  #ifdef LINUX
  int cmp = strncasecmp(one,two,len);
  if (cmp < 0)
   return -1;
  if (cmp > 0)
   return 1;
  #else
   int cmp = CompareString( LOCALE_USER_DEFAULT, NORM_IGNORECASE, one, len, two, len );

   if ( cmp == CSTR_LESS_THAN )
      return -1;
   if ( cmp == CSTR_GREATER_THAN )
      return 1;
  #endif
   return 0;
}

/*-----------------------------------------------------------------------------
*
* ID: os_ustrcmplen 14.12.07 .
*
* Summary: Compare strings
*
-----------------------------------------------------------------------------*/

int   STDCALL os_ustrcmplen( pushort one, pushort two, uint len )
{
 #ifdef LINUX
  int cmp = strncmp(one,two,len);
  if (cmp < 0)
   return -1;
  if (cmp > 0)
   return 1;
 #else
   int cmp = CompareStringW( LOCALE_USER_DEFAULT, 0, one, len, two, len );
   if ( cmp == CSTR_LESS_THAN )
      return -1;
   if ( cmp == CSTR_GREATER_THAN )
      return 1;
 #endif
   return 0;
}

/*-----------------------------------------------------------------------------
*
* ID: os_strcmpignlen 14.12.07 .
*
* Summary: Compare strings
*
-----------------------------------------------------------------------------*/

int   STDCALL os_ustrcmpignlen( pushort one, pushort two, uint len )
{
  #ifdef WINDOWS
   int cmp = CompareStringW( LOCALE_USER_DEFAULT, NORM_IGNORECASE, one, len, two, len );

   if ( cmp == CSTR_LESS_THAN )
      return -1;
   if ( cmp == CSTR_GREATER_THAN )
      return 1;
  #endif
   return 0;
}

/*-----------------------------------------------------------------------------
*
* ID: os_strcmp 14.12.07 .
*
* Summary: Compare strings
*
-----------------------------------------------------------------------------*/

int   STDCALL os_strcmp( pubyte one, pubyte two )
{
   return os_strcmplen( one, two, -1 );
}

/*-----------------------------------------------------------------------------
*
* ID: os_strcmpign 14.12.07 .
*
* Summary: Compare strings
*
-----------------------------------------------------------------------------*/

int   STDCALL os_strcmpign( pubyte one, pubyte two )
{
   return os_strcmpignlen( one, two, -1 );
}

/*-----------------------------------------------------------------------------
*
* ID: os_strcmp 14.12.07 .
*
* Summary: Compare strings
*
-----------------------------------------------------------------------------*/

int   STDCALL os_ustrcmp( pushort one, pushort two )
{
   return os_ustrcmplen( one, two, -1 );
}

/*-----------------------------------------------------------------------------
*
* ID: os_strcmpign 14.12.07 .
*
* Summary: Compare strings
*
-----------------------------------------------------------------------------*/

int   STDCALL os_ustrcmpign( pushort one, pushort two )
{
   return os_ustrcmpignlen( one, two, -1 );
}

//--------------------------------------------------------------------------

/*
pvoid STDCALL os_alloc( uint size )
{
   return VirtualAlloc( NULL, size, MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE );
}

void STDCALL os_free( pvoid ptr )
{
   VirtualFree( ptr, 0, MEM_RELEASE );
}
 */
//--------------------------------------------------------------------------

uint STDCALL os_time()
{
    #ifdef LINUX
     struct tms tm1;
     return times(&tm1);
    #else
     return GetTickCount();
    #endif
}

pubyte STDCALL os_lower(pubyte pData)
{
    #ifdef LINUX
     return strlower3(pData);
     //return strlower2(pData);
    #else
     return CharLower(pData);
    #endif
}

pubyte STDCALL strlower1(pubyte string1)
{
    pubyte it = string1;
    if (string1)
    {
        while (*it != 0)
        {
            if (!isdigit(*it))
              *it = tolower(*it);
            ++it;
        }
/*
        for (s=string1;*s;++s) {
           if (!isdigit(*s))
             *s=tolower(*s);
        }
    */
    }
    return string1;
}

pvoid STDCALL os_thread(pvoid pfunc,pvoid param)
{
    uint id;

    #ifdef LINUX
      pthread_t thread_id;
      //uint thread_id;
      int rc;
      rc = pthread_create(&thread_id,NULL,pfunc,param);
      return (uint) thread_id;
    #else
      return CreateThread(0,0,pfunc,param,0,&id);
    #endif
}

pubyte   STDCALL os_getexepath( pubyte dir, pubyte name )
{
   uint len;
   //ubyte ptr_Test[512];
  pstr sDir,sName;


#ifdef LINUX
   //Only for linux
//   dir[0] = 0;
//   name[0] = 0;
   len = readlink( "/proc/self/exe", dir, 512 )- 1 ;
   while ( len && dir[ len ] != '/' ) {
        //dir[ len ] = ' ' ;
        len--;
   }
   mem_copyuntilzero( dir + len + 1, name );
#else
   len = GetModuleFileName( 0, dir, 512 ) - 1;
   while ( len && dir[ len ] != '\\' ) len--;
   mem_copyuntilzero( dir + len + 1, name );
#endif
   return dir;
}

#ifdef LINUX
/*
pubyte  STDCALL os_getexename( pubyte buf, uint size )
{
   uint len,lich=0;
   ubyte linkname[64];
   ubyte link_name[512];
   pid_t pid;
   int ret;
   pid= getpid();

   if(snprintf(linkname,sizeof(linkname),"/proc/%i/exe",pid) , 0)
   {
       abort();
   }
   ret = readlink(linkname,link_name,size);
   if (ret == -1) return NULL;
   while ( ret && link_name[ ret ] != '/' ) {
        //dir[ len ] = ' ' ;
        lich++;
   }
   mem_copyuntilzero( buf, link_name+ret-lich );
   //mem_copy(buf,link_name,+(ret-lich));
   return buf;
}
*/
pubyte   STDCALL os_getexename( pubyte dir)
{
   uint len,lich=0;
   ubyte dir2[512];
   //ubyte ptr_Test[512];

   len = readlink( "/proc/self/exe", dir2, 512 )- 1 ;
   while ( len && dir2[ len ] != '/' ) {
        //dir[ len ] = ' ' ;
        lich++;
        len--;
   }
   mem_copyuntilzero( dir, dir2 + len + 1 - lich);
   //print( "dir =%s\n", dir );
   return dir;
}

char * strlower2(char * cstr1)
{
    char * it = cstr1;
    while (*it != 0)
    {
        if (!isdigit(*it))
          *it = tolower(*it);
        ++it;
    }
    return cstr1;
}

void strlower3(char * s)
{
    uint ddd = strlen(s);
    while (*s)
    {
        if (!isdigit(*s))
          *s = tolower(*s);
        s++;
    }
}


void os_splitpath(const char *src, char *drive, char *path, char *file, char *ext)
/*                             , FILE_MAX+1,  PATH_MAX+1, FILE_MAX+1, FILE_MAX+1
                                 drive    :  /path/       name.egon   .tar.gz    */
{
	int len=0;
	const char *ref1;
	if (*src!='/')
	if ((ref1=strchr(src, ':')))
	{
		if (((ref1+1)==strchr(src, '/'))||(!ref1[1]))
		while (src<=ref1)
		{
			if (drive)
			{
				len++;
				if (len<=NAME_MAX)
				{
					*drive=*src;
					drive++;
				}
			}
			if (*src==':')
			{
				src++;
				break;
			}
			src++;
		}
	}
	len=0;
	if ((ref1=rindex(src, '/')))
	while (src<=ref1)
	{
		if (path)
		{
			len++;
			if (len<=PATH_MAX)
			{
				*path=*src;
				path++;
			}
		}
		src++;
	}
	len=0;
	if (!(ref1=rindex(src, '.')))
		ref1=src+strlen(src);
	while (/*(*src)*/(src<ref1))
	{
/*		if (!strchr(src+1, '.'))
			break;*/
		if (!strcasecmp(src, ".tar.gz")) /* I am a bad boy */
			break;
		if (!strcasecmp(src, ".tar.bz2")) /* very bad */
			break;
		if (!strcasecmp(src, ".tar.Z")) /* and this is creepy */
			break;
		if (file)
		{
			len++;
			if (len<=NAME_MAX)
			{
				*file=*src;
				file++;
			}
		}
		src++;
	}
	len=0;
	while (*src)
	{
		if (ext)
		{
			len++;
			if (len<=NAME_MAX)
			{
				*ext=*src;
				ext++;
			}
		}
		src++;
	}
	if (drive)
		*drive=0;
	if (path)
		*path=0;
	if (file)
		*file=0;
	if (ext)
		*ext=0;
}

#endif


void STDCALL os_exitthread(long retcode)
{
    #ifdef LINUX
     pthread_exit((void*)retcode);
    #else
     ExitThread(retcode);
    #endif

}


/*
char * strlwr(char* string)
{
    char * s;

    if (string)
    {
        for (s = string;*s;++s)
         *s = toupper(s*);
    }
    return string;
}
*/
