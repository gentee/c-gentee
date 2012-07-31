/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: exe 24.10.06 0.0.A.
*
* Author: Alexey Krivonogov
*
******************************************************************************/

#include "../../genteeapi/gentee.h"
#ifdef WINDOWS
 #include "windows.h"
#endif
#include "../../os/user/defines.h"
pubyte      profile = NULL;
pubyte      inifile = NULL;
ubyte       exepath[512];
ubyte       gpath[512];
pubyte      gname = NULL;
#ifdef LINUX
   pubyte*      __argv;
   int         __argc;
   #define getchar getchar
#else
   #define getchar _getch
#endif

void __cdecl printc( pubyte text )
{
#ifdef LINUX
   write( 1, text, strlen( text ));
#else
   uint  write;
   WriteFile( GetStdHandle( STD_OUTPUT_HANDLE ), text, lstrlen( text ),
                &write, 0 );
#endif
//   printf( "%s", text );
}

pubyte getpath( pubyte filename )
{
   uint i = 0, last = 0, dot = 0;

   while ( filename[i] )
   {
      if ( filename[i] == '\\' )
         last = i;
      if ( filename[i] == '.' )
         dot = i;
      i++;
   }
   if ( !last )
   {
      ubyte  temp[512];
      #ifdef LINUX
         os_filefullname( filename, temp );
      #else
         GetFullPathName( filename, 512, temp, NULL );
	   #endif 
      mem_copyuntilzero( filename, temp );
      return getpath( filename );
   }
   filename[dot] = 0;
   filename[last] = 0;

   return filename + last + 1;
}

pubyte copymacros( pubyte dest, pubyte src )
{
   while ( *src )
   {
      if ( !mem_cmpign( src, "%GNAME%", 7 ))
      {
         dest += mem_copyuntilzero( dest, gname ) - 1;
         src += 7;
      }
      else
         if ( !mem_cmpign( src, "%GPATH%", 7 ))
         {
            dest += mem_copyuntilzero( dest, gpath ) - 1;
            src += 7;
         }
         else
            if ( !mem_cmpign( src, "%EXEPATH%", 9 ))
            {
               dest += mem_copyuntilzero( dest, exepath ) - 1;
               src += 9;
            }
            else
               *dest++ = *src++;
   }
   *dest++ = 0;
   return dest;
}

pubyte getprofile( pubyte key, puint pflag, uint flagval )
{
   pubyte      ret = ( pubyte )pflag;
   ubyte       val[512];
   #ifdef LINUX
    struct      CfgStruct this_var;
   #endif

   if ( flagval < 0xFFF0 )
   {
      #ifdef LINUX
       this_var.Name   = key;
       this_var.DataPtr = val;
       this_var.VarType = Cfg_String;
       ReadCfg(inifile, profile, &this_var);
      #else
       GetPrivateProfileString( profile, key, *pflag & flagval ? "1" : "0",val, 512, inifile );
      #endif
      if ( val[0] == '1' )
         *pflag |= flagval;
      else
         *pflag &= ~flagval;
   }
   if ( flagval == 0xFFF0 )
   {
      #ifdef LINUX
       this_var.Name   = key;
       this_var.DataPtr = val;
       this_var.VarType = Cfg_String;
       ReadCfg(inifile, profile, &this_var);
      #else
       GetPrivateProfileString( profile, key, ( pubyte )pflag,val, 512, inifile );
       #endif
      copymacros( ( pubyte )pflag, val );
   }
   if ( flagval == 0xFFF1 )
   {
      ubyte keyi[64];
      uint  i = 0;

      mem_copyuntilzero( keyi, key );
      while ( 1 )
      {
          #ifdef LINUX
           this_var.Name   = keyi;
           this_var.DataPtr = val;
           this_var.VarType = Cfg_String;
           ReadCfg(inifile, profile, &this_var);
          #else
            GetPrivateProfileString( profile, keyi, "", val, 512, inifile );
          #endif
         if ( !val[0] )
            break;

         ( pubyte )pflag = copymacros( ( pubyte )pflag, val );
         sprintf( keyi, "%s%i", key, ++i );
      }
      ret = ( pubyte )pflag;
   }
   return ret;
}

/*
uint  _stdcall myexport( uint par1, uint par2 )
{
   return par1 * par2;
}

pvoid  __stdcall export( pubyte name )
{
   if ( mem_iseqzero( name, "myexport" ))
      return &myexport;
   return NULL;
}
*/

int __cdecl main( int argc, char *argv[] )
{
   pubyte    head = "\nGentee Programming Language Version 3.6.3\n\
Freeware open source compiler & the run-time engine\n\
Copyright (C) 2004-10 The Gentee Group. All rights reserved.\n\n\
Internet: http://www.gentee.com  Email: info@gentee.com\n\n";

   compileinfo cmplinfo;
   int         next = 1;
   uint        flag = G_CONSOLE;// | G_CHARPRN;
   pvoid       cargs;
   pubyte      curargs;
   pubyte      defargs = NULL;
   pubyte      libdirs = NULL;
   pubyte      include = NULL;
   pubyte      exename;
   ubyte       proname[ 512 ];
#ifdef LINUX
   ubyte       fdrive_[FILENAME_MAX+1];
   ubyte       fpath_[PATH_MAX+1];
   ubyte       fname_[FILENAME_MAX+1];
   ubyte       fext_[FILENAME_MAX+1];
#endif
   if ( argc < 2 )
   {
      printc( head );
      printc( "How to compile: \n\
gentee.exe [<switches>] <source .g or .ge file> [command line arguments]\n\n\
<switches>\n\
   -c - Compiling only. Do not run the program after compiling\n\
   -m <define macros>- Define macros for compiling\n\
       Example: -d \"MODE=1;NAME=\\\"My Company, Inc\\\"\"\n\
   -f - Create GE file.\n\
   -n - Ignore the command line #!...\n\
   -o <output file> - Output GE filename (not default) will be specified.\n\
   -p <profile name> - Use the profile from gentee.ini file.\n\
   -s - Do not display any messages during the compiling or the executing\n\
   -t - Convert print strings to OEM-defined character set\n\
   -d - Include debug information\n\
   Examples\n\
      gentee.exe -f myfile.g\n\n\
\nPress any key...\n\n");
      getchar();
      return 0;
   }
   #ifdef LINUX
      __argv = argv;
      __argc = argc;
      strcpy(exepath,argv[0]);
    //exepath = __argv[0];
      exename = getpath( exepath );
      os_splitpath(exepath, fdrive_, fpath_, fname_, fext_);
      strcpy(exename,fname_);
   #else
      GetModuleFileName( NULL, exepath, 512 );
      exename = getpath( exepath );   
   #endif

   gentee_init( flag );
   mem_zero( &cmplinfo, sizeof( compileinfo ));

   cmplinfo.defargs = mem_alloc( 8192 );
   defargs = cmplinfo.defargs;
   cmplinfo.output = cmplinfo.defargs + 2048;
   cmplinfo.output[0] = 0;
   cmplinfo.libdirs = cmplinfo.output + 512;
   libdirs = cmplinfo.libdirs;
   cmplinfo.include = cmplinfo.libdirs + 2048;
   include = cmplinfo.include;

   cmplinfo.flag |= CMPL_LINE;// | CMPL_THREAD;

   while ( next < argc && argv[ next ][0] == '-')
   {
      switch ( argv[ next ][ 1 ] ) {
         case 'c':
         case 'C':
            cmplinfo.flag |= CMPL_NORUN;
            break;
         case 'n':
         case 'N':
            cmplinfo.flag &= ~CMPL_LINE;
            break;
         case 'm':
         case 'M':
            if ( next + 1 == argc )
            {
               printc("Please specify macros after '-m' option.\n\n\
gentee.exe [<switches>] -m <macros> <source file>");
               getchar();
               return 0;
            }
            defargs += mem_copyuntilzero( defargs, argv[ ++next ] );
            break;
         case 'f':
         case 'F':
            cmplinfo.flag |= CMPL_GE;
            break;
         case 'o':
         case 'O':
            cmplinfo.flag |= CMPL_GE;
            if ( next + 1 == argc )
            {
               printc("Please specify an output filename after '-o' option.\n\n\
gentee.exe [<switches>] -o <output file> <source file>");
               getchar();
               return 0;
            }
            mem_copyuntilzero( cmplinfo.output, argv[ ++next ] );
            break;
         case 's':
         case 'S':
            flag |= G_SILENT;
            break;
         case 't':
         case 'T':
            flag |= G_CHARPRN;
            break;
         case 'd':
         case 'D':
            cmplinfo.flag |= CMPL_DEBUG;
            break;
         case 'p':
         case 'P':
            if ( next + 1 == argc )
            {
               printc("Please specify a profile name after '-p' option.\n\n\
gentee.exe -p <profile name> <source file>");
               getchar();
               return 0;
            }
            profile = argv[ ++next ];
            break;
      }
      next++;
   }
   if ( next == argc )
   {
      printc( head );
      printc("Please specify a source filename.\n\n\
gentee.exe [<switches>] <source file>");
      getchar();
      return 0;
   }
   cmplinfo.input = argv[ next++ ];
   mem_copyuntilzero( gpath, cmplinfo.input );
   gname = getpath( gpath );

   if ( profile )
   {
      sprintf( proname, "%s\\%s.ini", exepath, exename );
      inifile = proname;

      // Load options from profile
      getprofile( "silent", &flag, G_SILENT );
      getprofile( "charoem", &flag, G_CHARPRN );
      getprofile( "gefile", &cmplinfo.flag, CMPL_GE );
      getprofile( "norun", &cmplinfo.flag, CMPL_NORUN );
      getprofile( "debug", &cmplinfo.flag, CMPL_DEBUG );
      getprofile( "firstline", &cmplinfo.flag, CMPL_LINE );
      getprofile( "gename", ( puint )cmplinfo.output, 0xFFF0 );
      defargs = getprofile( "define", ( puint )defargs, 0xFFF1 );
      libdirs = getprofile( "libdir", ( puint )libdirs, 0xFFF1 );
      include = getprofile( "include", ( puint )include, 0xFFF1 );
   }
   gentee_set( GSET_FLAG, ( pvoid )flag );
//   gentee_set( GSET_MESSAGE, &message );
//   gentee_set( GSET_EXPORT, &export );

   *( pushort )defargs = 0;
   *( pushort )libdirs = 0;
   *( pushort )include = 0;

   // Getting command-line parameters
   cargs = mem_alloc( 1024 );
   curargs = cargs;
   while ( next < argc )
   {
      curargs += mem_copyuntilzero( curargs, argv[ next++ ] );
//      curargs += mem_len( curargs ) + 1;
   }
   *curargs = 0;
   if ( *( pubyte )cargs )
      gentee_set( GSET_ARGS, cargs );

   if ( !( flag & G_SILENT ) && !getenv("GNUMSIGN"))
      printc( head );

//   cmplinfo.libs = "k:\\gentee\\open source\\gentee\\lib\\stdlib\\stdlib.g\00";
   gentee_compile( &cmplinfo );
//   getch();
   mem_free( cargs );
//   mem_free( cmplinfo.defargs );
   gentee_deinit();
   return 0;
}