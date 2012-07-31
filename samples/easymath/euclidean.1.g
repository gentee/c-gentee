/******************************************************************************
*
* Copyright (C) 2005, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: euclidean 17.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

func uint gcd( uint first second )
{
   if !second : return first
   return gcd( second, first % second )
}

func main<main>
{
   str     input
   uint    first second
   
   print("This program finds the greatest common divisor 
by the Euclidean Algorithm.\n\n")

   while 1
   {
      first = uint( congetstr( "Enter the first number ( enter 0 to exit ): ", input ))
      if !first : break
      
      second = uint( congetstr( "Enter the second number: ", input ))
      print("GCD = \( gcd( first, second ))\n\n")
   }
}
