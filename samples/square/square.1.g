/******************************************************************************
*
* Copyright (C) 2005, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: square 17.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

func main<main>
{
   str     input
   double  width height
   
   while 1
   {
      print("Enter the number of the action:
1. Calculate the area of a rectangle
2. Calculate the area of a circle
3. Exit\n")
      switch getch()
      {
         case '1' 
         {
            print("Specify the width of the rectangle: ")
            width = double( conread( input ))
            print("Specify the height of the rectangle: ")
            height = double( conread( input ))
            print("The area of the rectangle: \( width * height )\n\n")
         }
         case '2' 
         {
            print("Specify the radius of the circle: ")
            width = double( conread( input ))
            print("The area of the circle: \( 3.1415 * width * width )\n\n")
         }
         case '3', 27 : break
         default : print("You have entered a wrong value!\n\n")
      }
   }
}
