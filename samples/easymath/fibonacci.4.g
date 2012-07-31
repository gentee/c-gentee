/******************************************************************************
*
* Copyright (C) 2005, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: fibonacci 17.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

func main<main>
{
   uint  prevprev sum, prev = 1
   
   print("This program displays 48 numbers of Fibonacci (Xn = Xn-1 + Xn-2)\n\n")

   print( "0\n1\n" )
   while sum < 2000000000
   {
      sum = prevprev + prev
      prevprev = prev
      prev = sum    
      print( "\(sum)\n" )
   }
   getch()
}
