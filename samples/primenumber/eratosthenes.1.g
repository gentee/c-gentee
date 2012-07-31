/******************************************************************************
*
* Copyright (C) 2005, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: eratosthenes 17.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

func main<main>
{
   str   input
   uint  high i j
   
   print("This program uses \"The Sieve of Eratosthenes\" for finding prime numbers.\n\n")
   high = uint( congetstr("Enter the high limit number ( < 100000 ): ", input ))
   if high > 100000 : high = 100000
	
   arr  sieve[ high + 1 ] of byte
   
   fornum i = 2, high/2 + 1
   {
      if !sieve[ i ]
      {
         j = i + i
         while j <= high
         {
            sieve[ j ] = 1
            j += i
         }
      }
   }
   j = 0
   input.setlen( 0 )

   fornum i = 2, high + 1
   {
      if !sieve[ i ]
      {
         input.out4( "%8u", i )
         if ++j == 10 
         {
            j = 0
            input += "\l"
         }
      }
   }

   input.write( "prime.txt" )
   shell( "prime.txt" )
}
