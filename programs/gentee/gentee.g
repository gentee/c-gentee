#output = %EXEPATH%\gentee-x.exe
#norun = 1
#exe = 1 d g
#optimizer = 1
#include = clear
#wait = 3
#res = ..\..\res\exe\version.res
/******************************************************************************
*
* Copyright (C) 2008, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

// ѕри смене команд надо делать exe.exe -> gentee.exe и запускать так
//..\..\exe\gentee.exe gentee.g -xd gentee.g

include
{
   $"..\..\lib\stdlib\stdlib.g" 
   $"..\..\lib\compiler\compiler.g" 
   $"..\..\lib\linker\linker.g" 
   $"..\..\lib\ini\ini.g" 
}

global
{
   str  head = "Gentee Programming Language v3.6.3
Freeware open source compiler & the run-time engine
Copyright (C) 2004-10 The Gentee Group. All rights reserved.
Internet: http://www.gentee.com  Email: info@gentee.com\l\l"

}

global
{
   arrstr errtext = %{
      "Cannot create/open file %s.",
      "%s is not a launcher.",
      "Cannot write %s file.",
      "Cannot write the temporary resource file %s.",
      "Cannot add the resource file %s.",
      "Cannot copy %s",
      "Cannot read %s",
      "Cannot create the .gentee section.",
      "Cannot add the XP manifest."
   }
}

func linkerror( uint code, str param )
{
   str out

   if &param : out.printf( errtext[ code ], %{ param } )
   else : out = errtext[ code ]
   print( "Linker error: \(out)\nPress any key..." )
   getch()
   exit( 0 )
}

func  macroreplace( gcompileinfo gcinfo )
{
   arrstr  amacro = %{ "%GNAME%", "%GPATH%", "%EXEPATH%" }
   arrstr  mpath[3]
   str     stemp

   getmodulepath( mpath[2], "" )
   gcinfo.input.fgetparts( mpath[1], mpath[0], 0->str )
   
   gcinfo.includes.replace( amacro, mpath, $QS_IGNCASE )
   gcinfo.libs.replace( amacro, mpath, $QS_IGNCASE )
   gcinfo.defargs.replace( amacro, mpath, $QS_IGNCASE )
   gcinfo.args.replace( amacro, mpath, $QS_IGNCASE )
   gcinfo.output.replace( amacro, mpath, $QS_IGNCASE )
}

func uint wrongpar( str filename option )
{
   print( head )
   print( "Please specify \(filename) after '\(option)' option.\l
gentee.exe [<switches>] \(option) <\(filename)> <source file>\n" )
   getch()
   return 0
}

func uint main<main>
{
   gcompileinfo gcinfo
   uint next flag wait exe run i 
   ini  pini
   linker plinker 
   str  profile stemp ininame tempdir

   subfunc uint getprofile( str name, uint ptrval, uint flag )
   {
      str  val
      
      if flag < 0xFFF0
      {
         pini.getvalue( profile, name, val, ?( ptrval->uint & flag, "1", "0" )) 
         if  val[0] == '1' : ptrval->uint |= flag
         else : ptrval->uint &= ~flag
      }
      elif flag == 0xFFF0  // string value
      {
         pini.getvalue( profile, name, val, ptrval->str )
         ptrval->str = val
      }
      elif flag == 0xFFF1 
      {
         uint i
         str  skey = name
         
         while 1 
         {
            pini.getvalue( profile, skey, val, "" )
            if !*val : break
            ptrval->arrstr += val
            skey = "\(name)\(++i)"
         } 
      }
      elif flag == 0xFFF2 
      {
         arrstr apar 
         uint i clt k
         
         pini.getvalue( profile, name, val, "" )
         if !uint( val ) : return 0
         val.split( apar, ' ', $SPLIT_NOSYS )
         clt as ptrval->collection
          
         fornum i = 1, *apar
         {  
            fornum k = 0, *clt / 3
            {
               if clt[k*3]->str %== apar[i]
               {
                  clt[ k*3 + 1 ]->uint |= clt[ k*3 + 2 ]
                  break 
               }
            }          
         } 
         if *apar == 1 && !*( clt[*clt - 3]->str )
         {
            clt[ *clt - 2 ]->uint |= clt[ *clt - 1 ]
         }  
         return 1
      }
      elif flag == 0xFFF3 
      {
         pini.getvalue( profile, name, val, "0" ) 
         ptrval->uint = uint( val ) 
      }
      return 0
   }
    
   subfunc loadprofile( str data )
   {
      if *data
      {
         pini.data = data
         pini.data.lines( pini.lines, 1, pini.offset )
      }
      else
      {  
         getmodulename( ininame ).fsetext("ini")
         pini.read( ininame )
      }
      
      // Load options from profile
      getprofile( "silent", &flag, $G_SILENT )
      getprofile( "charoem", &flag, $G_CHARPRN )
      getprofile( "gefile", &gcinfo.flag, $CMPL_GE )
      getprofile( "norun", &gcinfo.flag, $CMPL_NORUN )
      getprofile( "debug", &gcinfo.flag, $CMPL_DEBUG )
      getprofile( "asm", &gcinfo.flag, $CMPL_ASM )
      getprofile( "numsign", &gcinfo.flag, $CMPL_LINE )
      getprofile( "output", &gcinfo.output, 0xFFF0 )
      getprofile( "wait", &wait, 0xFFF3 );
      exe = getprofile( "exe", &%{ "g", &plinker.flag, $LINK_GUI,
                        "d", &plinker.flag, $LINK_DLL,
                        "a", &plinker.flag, $LINK_ASM,
                        "p", &plinker.flag, $LINK_PACK,
                        "r", &plinker.flag, $LINK_ASMRT,
                        "t", &plinker.flag, $RES_ACCESS,
                        "n", &plinker.flag, $RES_ADMIN }, 0xFFF2 );
      if getprofile( "optimizer", &%{ "d", &gcinfo.optiflag, $OPTI_DEFINE,
                              "n", &gcinfo.optiflag, $OPTI_NAME,
                              "u", &gcinfo.optiflag, $OPTI_AVOID,
               "", &gcinfo.optiflag, $OPTI_DEFINE | $OPTI_NAME | $OPTI_AVOID 
                               }, 0xFFF2 )
      {                        
         gcinfo.flag |= $CMPL_OPTIMIZE   
      }                  
      getprofile( "icon", &plinker.icons, 0xFFF1 );
      getprofile( "res", &plinker.res, 0xFFF1 );
      getprofile( "define", &gcinfo.defargs, 0xFFF1 );
      getprofile( "libdir", &gcinfo.includes, 0xFFF1 );
      getprofile( "include", &gcinfo.libs, 0xFFF1 );
      getprofile( "args", &gcinfo.args, 0xFFF1 );      
   }
   subfunc addargs( str out )
   {
      foreach cura, gcinfo.args
      {
         if cura.findch(' ') < *cura : out += " \"\(cura)\""
         else : out += " \(cura)"
      }   
   }   
   if !argc()
   {
      print( head )
      print( "How to compile:
gentee.exe [<switches>] <source .g or .ge file> [command line arguments]

<switches>
   -a - Convert bytecode to assembler
   -c - Compiling only. Do not run the program after compiling
   -m <define macros>- Define macros for compiling
       Example: -m \"MODE=1;NAME=\\\"My Company, Inc\\\"\"
   -f - Create GE file.
   -n - Ignore the command line #!...
   -o <output file> - Output GE or EXE filename (not default) will be specified.
   -p <profile name> - Use the profile from gentee.ini file.
   -s - Do not display any messages during the compiling or the executing
   -t - Convert print strings to OEM-defined character set
   -d - Include debug information
   -w - Wait for pressing key at the end.
   -z[d][n][u] - Optimize a byte-code ( -f or -x compatible )
      -zd - Delete defines.
      -zn - Delete names.
      -zu - Delete no used objects.
      -z equals -zdnu. Combine -zd, -zn and -zu  
   -x[d][g][a][r][p] - Create executable EXE file.
      -xd - Dynamic usage of gentee.dll.
      -xg - Make a gui application. 
            In default a console application is created.
      -xa - Compile a bytecode to assembler.
      -xr - Run-time converting a bytecode to assembler.
      -xp - Compress a byte-code & dll.
      Example: -xdg - Combine -xd and -xg
   -i <icon file> - Link .ico file ( -x compatible ).
                    -i \"c:\\data\\myicon.ico\"
   -r <res file> - Link .res file ( -x compatible ). 
                    -r \"c:\\data\\myres.res\"  
   Examples
      gentee.exe -x -i \"c:\\myfile.ico\" -w myfile.g
      
Press any key...")
      getch()
      return 0
   }   
   gcinfo.flag |= $CMPL_LINE | $CMPL_THREAD
   
   fornum next, argc()
   {
      str sarg
      
      argv( stemp, next + 1 )
      if stemp[0] != '-' : break;
      
      switch stemp[ 1 ] 
      {
         case 'a','A' : gcinfo.flag |= $CMPL_ASM
         case 'c','C' : gcinfo.flag |= $CMPL_NORUN
         case 'n','N' : gcinfo.flag &= ~$CMPL_LINE
         case 'm','M' 
         {
            argv( sarg, ++next + 1 )
            if !*sarg || sarg[0] == '-' : return wrongpar( "macros", "-m" )
            gcinfo.defargs += sarg;
         }
         case 'f','F': gcinfo.flag |= $CMPL_GE
         case 'o','O'
         {
            argv( sarg, ++next + 1 )
            if !*sarg || sarg[0] == '-' : return wrongpar( "output file", "-o" )
            gcinfo.output = sarg
            gcinfo.flag |= $CMPL_GE
         }
         case 's','S': flag |= $G_SILENT
         case 't','T': flag |= $G_CHARPRN
         case 'd','D': gcinfo.flag |= $CMPL_DEBUG
         case 'p','P'
         {
            argv( sarg, ++next + 1 )
            if !*sarg || sarg[0] == '-'
            { 
               return wrongpar( "profile name", "-p" )
            }
            profile = sarg
            loadprofile( "" )
         }
         case 'w','W': wait = 1
         case 'x','X'
         {
            exe = 1
            i = 2
            stemp.lower()
            while stemp[ i ]
            {
               switch stemp[i]
               {
                  case 'g' : plinker.flag |= $LINK_GUI 
                  case 'd' : plinker.flag |= $LINK_DLL
                  case 'a' : plinker.flag |= $LINK_ASM 
                  case 'r' : plinker.flag |= $LINK_ASMRT
                  case 'p' : plinker.flag |= $LINK_PACK 
               }   
               i++
            } 
         }
         case 'i','I'
         {
            argv( sarg, ++next + 1 )
            if !*sarg || sarg[0] == '-' : return wrongpar( "icon file", "-i" )
            plinker.icons += "ICON_APP, \(sarg)"
         }
         case 'r','R'
         {
            argv( sarg, ++next + 1 )
            if !*sarg || sarg[0] == '-'
            { 
               return wrongpar( "resource file", "-r" )
            }
            plinker.res += sarg
         }
         case 'z','Z'
         {
            i = 2
            stemp.lower()
            if !stemp[2]
            { 
               gcinfo.optiflag = $OPTI_DEFINE | $OPTI_NAME | $OPTI_AVOID
            } 
            else
            {
               while stemp[ i ]
               {  
                  if stemp[i] == 'd' : gcinfo.optiflag |= $OPTI_DEFINE
                  elif stemp[i] == 'n' : gcinfo.optiflag |= $OPTI_NAME 
                  elif stemp[i] == 'u' : gcinfo.optiflag |= $OPTI_AVOID 
                  i++
               }
            }
            gcinfo.flag |= $CMPL_OPTIMIZE   
         }
      }
   }
   gentee_set( $GSET_FLAG, flag )
   if next == argc()
   {
      print( head )
      print( "Please specify a source filename.\l
gentee.exe [<switches>] <source file>")
      getch()
      return 0
   }
   argv( gcinfo.input, ++next )
   while next++ < argc()
   {
      argv( stemp, next )
      gcinfo.args += stemp
   }
   addargs( stemp.clear() )
   if gcinfo.flag & $CMPL_LINE && gcinfo.input.fgetext() %!= "ge" 
   {
      arrstr  alines
      alines.read( gcinfo.input )

      if *alines
      {
         if "#!".eqlen( alines[0] ) && !uint( getenv( "GNUMSIGN", "" )) 
         {
            getmodulepath( tempdir, 0->str )
            stemp.copy( alines[0].ptr() + 2 )
            stemp.replace( "%1", gcinfo.input, 0 )
            addargs( stemp ) 
            setenv( "GNUMSIGN", "1" )
//            tempdir.fgetdir( gcinfo.input )
            process( stemp, 0->str, 0 ) // tempdir
            return 0
         }
         // Read file for getting # options
         if alines[0][0] == '#' && alines[0][1] != '!'
         {
            profile = "gentee"
            stemp = "[gentee]\l"
            i = 0
            while alines[i][0] == '#'
            {
               stemp.append( alines[i].ptr() + 1, *alines[i] - 1 )
               stemp += "\l"
               i++
            } 
            loadprofile( stemp )
         } 
      }
   }
   // Replace macro values
    
   macroreplace( gcinfo )
   if !( flag & $G_SILENT ) : print( head )
   if exe
   {
      if !( gcinfo.flag & $CMPL_NORUN )
      {
         run = 1
         gcinfo.flag |= $CMPL_NORUN
      }
      gcinfo.flag |= $CMPL_GE
      if !*gcinfo.output :  gcinfo.output = gcinfo.input
         
      gcinfo.output.fsetext( "ge" )
   }
   if *gcinfo.libs && gcinfo.libs[ *gcinfo.libs - 1 ] %== "clear"
   {
      gcinfo.libs.clear()
   }      
   compile_file( gcinfo )
   if exe
   {
      with plinker
      {
         .errfunc = &linkerror
         .input = gcinfo.output
         (.output = .input ).fsetext("exe")
         if flag & $G_CHARPRN : .flag |= $LINK_CHAR
         if gcinfo.flag & $CMPL_ASM : .flag |= $LINK_ASM 
      }  
      if plinker.create() && !( flag & $G_SILENT )
      {
         print( "Executable file \( plinker.output ) - created...\n" )
      }
      deletefile( gcinfo.output )
   }
   
   if wait == 1 : congetch("\nPress any key...\n")
   elif wait > 1 : Sleep( wait * 1000 )
   if run
   { 
      stemp = "\"\(plinker.output)\""
      addargs( stemp )   
      tempdir.fgetdir( plinker.output )
      process( stemp, tempdir, 0 )
   }
   
   return 0
}