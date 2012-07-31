/******************************************************************************
*
* Copyright (C) 2004-2007, The Gentee Group. All rights reserved. 
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
* Id: array L "Array"
* 
* Summary: Array. You can use variables of the #b(arr) type for working with
           arrays. The #b(arr) type is inherited from the #b(buf) type. 
*
* List: *Operators,arr_oplen,arr_opfor,arr_opof,arr_opind,
         *Methods,arr_clear,arr_cut,arr_del,arr_expand,arr_insert,
         arr_move,arr_sort  
* 
-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
* Id: arr_clear F3
*
* Summary: Clear an array. The method removes all items from the array.
*  
* Return: #lng/retobj#
*
-----------------------------------------------------------------------------*/

method arr arr.clear()
{
   this.del( 0, *this )
   this.free()   
   return this
}

/*-----------------------------------------------------------------------------
* Id: arr_sort F2
*
* Summary: Sorting an array. Sort array items according to the sorting 
           function. The function must have two parameters containing pointers
           to two compared items. It must return #b(int) less than, equal to or
           greater than zero if the left value is less than, equal to or 
           greater than the first one respectively. 
*  
* Params: sortfunc - Sorting function. 
* 
* Return: #lng/retobj#
*
-----------------------------------------------------------------------------*/

method arr arr.sort( uint sortfunc )
{ 
   sort( this.ptr(), *this, this.isize, sortfunc )//&setidvm( iv, sortfunc ))
   return this
} 

/*-----------------------------------------------------------------------------
* Id: arr_opfor F5
*
* Summary: Foreach operator. You can use #b(foreach) operator to look over 
           items of the array. 
*  
* Title: foreach var,arr
*
* Define: foreach variable,array {...}
* 
-----------------------------------------------------------------------------*/

method uint arr.eof( fordata fd )
{
   return ?( fd.icur < *this, 0,  1 )   
}

method uint arr.first( fordata fd )
{  
   return this.index( fd.icur = 0 )
}

method uint arr.next( fordata fd )
{
   return this.index( ++fd.icur )
}

/*-----------------------------------------------------------------------------
* Id: arr_del F2
*
* Summary: Deleting item(s). The method removes an item with the specified
           number.
*  
* Params: num - The number of item starting from 0. 
* 
-----------------------------------------------------------------------------*/

method arr.del( uint num )
{
   this.del( num, 1 )
}

/*-----------------------------------------------------------------------------
* Id: arr_cut F2
*
* Summary: Reducing an array. All items exceeding the specified number will be
           deleted. 
*  
* Params: count - The number of items left in the array. 
* 
-----------------------------------------------------------------------------*/

method arr.cut( uint count )
{ 
   this.del( count, *this - count )
}

/*-----------------------------------------------------------------------------
* Id: arr_move F2
*
* Summary: Move an item. 
*  
* Params: from - The current index of the item starting from zero.  
          to - The new index of the item starting from zero. 
* 
-----------------------------------------------------------------------------*/

method arr.move( uint from, uint to )
{
   buf btemp
   
   if from == to || from >= *this : return   
   
   if to >= *this : to = *this - 1
   
   btemp.copy( this.index( from ), this.isize )
   
   if from > to
   {
      mmove( this.index( to + 1 ), this.index( to ), this.isize * ( from - to ))   }
   else
   {
      mmove( this.index( from ), this.index( from + 1), 
             this.isize * ( to - from ))   
   }
   mcopy( this.index( to ), btemp.ptr(), this.isize )
}

/*-----------------------------------------------------------------------------
* Id: arr_insert F2
*
* Summary: Insert elements. The method inserts an element into the array at 
           the specified index.
*  
* Params: id - The index of the element needs to be inserted.  
* 
-----------------------------------------------------------------------------*/

method arr.insert( uint id )
{
   this.insert( id, 1 )
}

operator arr of uint = ( arr left of uint, collection right )
{
   uint i  
 
   fornum i=0, *right
   {
      if right.gettype(i) == uint || right.gettype(i) == int
      {           
         left += right[i]
      }
   }
   return left->arr of uint
}

/*operator arr of uint= ( arr left of uint, arr right of uint)
{
   uint i  
   left.clear()
   left.expand(*right)
   fornum i=0, *right
   {
      left[i] = right[i]      
   }
   return left->arr of uint
}*/

/*Тип arr является встроенным, структура arr включена в компилятор
type <inherit = buf> {
   uint    itype // The type of items
   uint    isize // The size of the item
   uint    dim[ MAX_MSR ]  // Dimensions   
}
В компилятор включены следующее методы и операции:
arr.del( uint from, uint number )
uint arr.expand( uint count )
arr.insert( uint from, uint number )
*/
