//#!gentee.exe -p default "%1"
/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: lextbl 17.10.06 0.0.A.HJWUU
*
* Author: Alexey Krivonogov ( gentee )
*
* Summary: This program creates tables for lexical analizer. It gets a
  description in GT format and generate .g and *.c sourse files with the
  according lexical tables.
*
******************************************************************************/
include : $"..\..\lib\stdlib\stdlib.g"
include : "genlex.g"

/*-----------------------------------------------------------------------------
*
* ID: lextbl 12.10.06 1.1.A.ABKL 
* 
* Summary: This program loads all *.gt files with lexical tables from the
  current directory and generate *.g or *.c files for gentee lexical analizer.
*  
-----------------------------------------------------------------------------*/

func  lextbl<main>
{
   ffind fd
   // This is required only for gentee2.dll. Later it must be deleted
//   gentee_init( 0 )
   
//   fd.init("fgentee.gt", $FIND_FILE )
   fd.init("fc.gt", $FIND_FILE )
   foreach cur, fd
   {
      str  name
      
      cur.name.fgetparts( 0->str, name, 0->str )
      print("Generating \( name )...")
      generatelex( name )
      print("OK\n")
   }         
//   gentee_deinit()
   congetch("Press any key...")
}
