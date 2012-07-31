/******************************************************************************
*
* Copyright (C) 2008, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: test 17.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

include : "test.g"

global
{
   uint g0,g1 = 10
   str  gstr
}
 
func uint debug<main>
{
   uint i

   print( "Hello, World!\l" )
   g0 = 77;
   gstr = "This is a global varaiable";
   fornum i, 10
   {
      uint k 
      
      k = i*i 
      output( i, k, "debug mode" )
   }
//   getch()
   return 7;
}
