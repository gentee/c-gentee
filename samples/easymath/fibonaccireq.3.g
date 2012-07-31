/******************************************************************************
*
* Copyright (C) 2005, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: fibonaccireq 17.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

func uint fibonacci( uint prevprev prev )
{
   if prev > 2000000000 : return prev
   print( "\( prev + prevprev )\n" )
   return fibonacci( prev,  prev + prevprev )
}

func main<main>
{
   print("This program displays 47 numbers of Fibonacci (Xn = Xn-1 + Xn-2)\n\n")

   print( "1\n1\n" )
   fibonacci( 1, 1 )
   getch()
}
