/******************************************************************************
*
* Copyright (C) 2005, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: samefiles 17.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

include : "samefiles.1.g"

func mainex <main>
{
   arrstr  drives
   
   @"This program looks for the same files on all fixed drives.\n"
   init()
   drives = getdrives()
               
   foreach cur, drives
   {
      if getdrivetype( cur ) == $DRIVE_FIXED && conyesno("Would you like to search on \(cur)? (Y/N) ")
      {
         scaninit( cur )
      }
   }               
   search()   
}