/******************************************************************************
*
* Copyright (C) 2005, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: runini 17.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

include : $"..\..\lib\ini\ini.g"

func uint  openini( ini retini )
{
   str   inifile = "runini.ini"

   if !fileexist( inifile )
   {
      congetch( "Cannot find file \(inifile).\nPress any key..." )
      exit( 0 )
   }
   retini.read( inifile )   
   return 1
}

func uint  idaction( ini retini, str section )
{
   str   src name outname 
   uint  run exe result nodll

   retini.getvalue( section, "Src", src, "" )
   if !*src 
   {
      congetch("ID '\(section)' is not valid. Press any key...\n")
      return 0 
   }
   run = retini.getnum( section, "Run", 1 )
   exe = retini.getnum( section, "Exe", 0 )
      
   retini.getvalue( section, "Output", outname, "" )
   
   if exe
   {
      process( "..\\..\\exe\\gentee.exe -p samples \(src)", ".", &result )
      src.fsetext( src, "ge" )
      process( "..\\..\\exe\\ge2exe.exe \(src)", ".", &result )
      deletefile( src )
      src.fsetext( src, "exe" )
      if run : process( src, ".", &result )
   }
   else : shell( src )
   
   return 1
}

func runini< main >
{
   ini      tini
   arrstr   sections
   str      name src section
   
   openini( tini )
   
   tini.sections( sections )
   while 1
   {
      print( "-----------\n" )
      foreach  cur, sections
      {
         tini.getvalue( cur, "Src", src, "" )
         if !*src : continue

         tini.getvalue( cur, "Name", name, src )
         print( "\(cur)".fillspacer( 20 ) + name + "\n" )
      }
      print( "-----------\n" )
      congetstr("Enter ID name (enter 0 to exit): ", section )
      if section[0] == '0' : break

      idaction( tini, section )
   }
}
