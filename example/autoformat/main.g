#!gentee.exe -p default "%1" -k test.g
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
* Summary: Example of the using gentee analizer, utility autoformatting Gentee sources
*
******************************************************************************/


include
{
   $"..\..\lib\lex\lex.g"
   "lexfgentee.g"
}


include
{
   "autoformat.g"
}

func formatfile <main>()
{
   str findDir,sBak //"C:\\gentee\\";
   byte bCreateBak = 0
   if argc()<1 || argc()>2 || (argc() == 2 && argv(sBak,1) != "-k")  
   {
    print("\t\nUsage : formatfile [Options] [File_name] \n")
    print("\t\n Options : -k - Create backup file\n")
    print("\n")
    print("\n")
    getch()
    exit(1)
   }
   congetch("Oooops\n")
   if (argc() == 1):  argv(findDir,1)
   else : bCreateBak = 1; argv(findDir,2)
   print("--------------------------\n\n")
   if !( formatfile(findDir,3,80,bCreateBak)) : print("Error run function \n")
   else : print("File -- "+findDir+" -- was formatted. \n") 
	print("\n--------------------------\n")
   //else : print("Ok. Formated file -> \(argv(findDir,1)) \n")
   getch() 
}


