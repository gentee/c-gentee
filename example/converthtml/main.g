#!ge2exe.exe "%1" "gen2html.exe"
/******************************************************************************
*
* Copyright (C) 2004-2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project.
* http://www.gentee.com
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: main.g 12.10.06
*
* Author: Aleksandr Antypenko ( santy )
*
* Summary: Example of the using gentee analizer, convertor from gentee code file 
*	   to the html file
*
******************************************************************************/

include
{
   $"..\..\lib\lex\lex.g"
   "lexfgentee.g"
} 


include
{
   "htmlfromcode.g"
} 

func gen2html < main >( )
{
   str findDir
   if argc( ) < 1
   {
      print( "\n" )
      print( "Convert from Gentee file to html file \n" )
      print( "\t\nUsage : gen2html [File_name] \n" )
      //print("\t\n Options : -k - Create backup file\n")
      print( "\n" )
      print( "\n" )
      getch( )
      exit( 1 )
   } 
   print( "--------------------------\n\n" )
   if !( process_file( argv( findDir, 1 ) ) ) : print( "Error run function \n" )
   else : print( "File -- " + findDir + " -- html code created. \n" )
   print( "\n--------------------------\n" )
   getch( )
} 


