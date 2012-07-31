/******************************************************************************
*
* Copyright (C) 2005, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: factorial 17.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

func uint factorial( uint n )
{
   if n < 3 : return n
   return n * factorial( n - 1 )
}
 
func main<main>
{
   uint    n
   
   print("This program calculates n! ( 1 * 2 *...* n ) for n from 1 to 12\n\n")

   fornum n = 1, 13
   {
      print("\(n)! = \( factorial( n ))\n")
   }
   getch()
}
