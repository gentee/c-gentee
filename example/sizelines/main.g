/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: main 18.10.06 0.0.A.
*
* Author: Aleksandr Antypenko ( santy )
*
******************************************************************************/

include
{
 "sizelines.g"
}

func findfiledir <main>()
{
   str findDir; //"C:\\gentee\\";
   flinfo infofile;
   if argc()<1 
   {
    print("\t\nUsage : findfiledir  [dir+pattern] \n")
    exit(1)
   }
   if !(sizelines(infofile,argv(findDir,1))) : print("Error run function \n")
   else : print("Size -> \(infofile.countsize) Lines -> \(infofile.countlines) \n") 
}
