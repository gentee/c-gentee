/******************************************************************************
*
* Copyright (C) 2004-2008, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

/*-----------------------------------------------------------------------------
* Id: console L "Console"
* 
* Summary: Console library. Functions for working with the console.
*
* List: *,congetch,congetstr,conread,conrequest,conyesno
* 
-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
* Id: conread F
*
* Summary: Get a string entered by the user. 
*  
* Params: input - The variable of the str type for getting data. 
* 
* Return: #lng/retpar(input)
*
-----------------------------------------------------------------------------*/

func  str  conread( str input )
{
   uint len
   
   input.setlen( 0 )
   input.reserve( 512 )
   len = scan( input.ptr(), 512 )
   input.setlen( len - ?( len >= 2 && input[ len - 1 ] == 0xA, 2, 0 ))
   return input
}

/*-----------------------------------------------------------------------------
* Id: congetstr F
*
* Summary: Getting a string after text is displayed. Get the string entered by
           the user with some text displayed before that.  
*  
* Params: output - Text for displaying. 
          input - The variable of the str type for getting data. 
* 
* Return: #lng/retpar(input)
*
-----------------------------------------------------------------------------*/

func str  congetstr( str output, str input )
{
   print( output )
   return conread( input )
}

/*-----------------------------------------------------------------------------
* Id: conrequest F
*
* Summary: Displaying a multiple choice request on the console. 
*  
* Params: output - Request text. 
          answer - Enumerating possible answer letters. Answer variants are /
                   separated by '|'. For example, "Nn|Yy"  
* 
* Return: The function returns the number of the selected variant beginning 
          from 0. 
*
-----------------------------------------------------------------------------*/

func  uint conrequest( str output, str answer )
{
   int  ch
   uint i ret
   
label again   
   print( output )
   ch = getch()
   ret = 0
   fornum i = 0, *answer
   {
      if answer[i] == '|' 
      {
         ret++
         continue
      }
      if answer[i] == ch 
      {
         str   stemp

         print( stemp.appendch(ch) += "\n" )
         return ret 
      }
   }   
   print("\n")
   goto again

   return ret
}

/*-----------------------------------------------------------------------------
* Id: conyesno F
*
* Summary: Displaying a question on the console. 
*  
* Params: output - Question text. 
* 
* Return: The function returns 1 if the answer is 'yes' and 0 otherwise. 
*
-----------------------------------------------------------------------------*/

func uint conyesno( str output )
{
   return conrequest( output, "Nn|Yy" ) 
}

/*-----------------------------------------------------------------------------
* Id: congetch F
*
* Summary: Displaying text and waiting for a keystroke. 
*  
* Params: output - Message text. 
* 
* Return: The function returns the value of the pressed key. 
*
-----------------------------------------------------------------------------*/

func  uint  congetch( str output )
{
   print( output )
   return getch()
}
