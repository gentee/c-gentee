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

func output( uint param1 param2, str more )
{
   uint l
   print("\(param1) => \( l = param2) + \(more)\l")
   l = 61
}

func test<main>
{
   uint i

   print( "Привет, World!\l" )
   fornum i, 10 : print("\(i)*\(i) = \(i*i)\l")
   getch()
}
