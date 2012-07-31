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
* Id: stack L "Stack"
* 
* Summary: Stack. You can use variables of the #b(stack) type for working with
           stacks. The #b(stack) type is inherited from the #b(arr) type. So,
           you can also use #a(array, methods of the arr type). 
*
* List: *Methods,stack_pop,stack_popval,stack_push,stack_top, 
        *Type,tstack 
* 
-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
* Id: tstack T stack
* 
* Summary: The main structure of the stack.
*
-----------------------------------------------------------------------------*/

type stack <inherit = arr> {
}

/*-----------------------------------------------------------------------------
* Id: stack_push F3
* 
* Summary: Add an item to a stack.
*
* Return: The pointer to the added item. 
*
-----------------------------------------------------------------------------*/

method uint stack.push
{
   this.expand( 1 )
   return this.index( *this - 1 )
}

/*-----------------------------------------------------------------------------
* Id: stack_push_1 FA
* 
* Summary: The method adds a number to a stack. 
*
* Params: val - Pushing uint or int number.    
*
* Return: The added value is returned. 
*
-----------------------------------------------------------------------------*/

method uint stack.push( uint val )
{
   uint ind
   
   ind = this.expand( 1 )
   this.index( ind )->uint = val 
   
   return val
}

/*-----------------------------------------------------------------------------
* Id: stack_push_2 FA
* 
* Summary: The method adds a string to a stack. The stack must be described as 
           #b( stack of str ).
*
* Params: val - Pushing string.    
*
* Return: The added string is returned. 
*
-----------------------------------------------------------------------------*/

method str stack.push( str val )
{
   uint ptr = this.push()
   
   ptr->str = val
   
   return ptr->str
}

/*-----------------------------------------------------------------------------
* Id: stack_pop F3
* 
* Summary: Extracting an item. The method deletes the top item from a stack. 
*
* Return: The pointer to the next new top item.  
*
-----------------------------------------------------------------------------*/

method uint stack.pop
{
   uint count = *this
   
   if count
   {
      this.del( --count )
   }
   return ?( count, this.index( count - 1 ), 0 )
}

/*-----------------------------------------------------------------------------
* Id: stack_top F3
* 
* Summary: Get the top item in a stack.
*
* Return: The pointer to the top item.
*
-----------------------------------------------------------------------------*/

method uint stack.top
{
   return ?( *this, this.index( *this - 1 ), 0 )
}

/*-----------------------------------------------------------------------------
* Id: stack_popval F3
* 
* Summary: Extracting an number. The method extracts a number from a stack. 
*
* Return: The number extracted from the stack is returned.
*
-----------------------------------------------------------------------------*/

method uint stack.popval
{
   uint count = *this
 
   if !count : return 0
   
   uint ret = this.index( count - 1 )->uint
   this.pop()
   
   return ret
}

/*-----------------------------------------------------------------------------
* Id: stack_pop_1 FA
* 
* Summary: The method extracts a string from a stack. The stack must be
           described as #b( stack of str ).
*
* Params: val - Result string.    
*
* Return: #lng/retpar( val ) 
*
-----------------------------------------------------------------------------*/

method str stack.pop( str val )
{
   uint count = *this
 
   if !count : return val

   val = this.index( count - 1 )->str
   this.pop()
   
   return val
}

/*
type stack <> {
   arr   sarr  
}

operator uint *( stack left )
{
   return *left.sarr
}

method uint stack.index( uint i )
{
   return this.sarr.index( i )
}

method uint stack.push
{
   this.sarr.expand( 1 )
   return this.index( *this - 1 )
}

method uint stack.push( uint val )
{
   uint ind
   
   ind = this.sarr.expand( 1 )
   this.index( ind )->uint = val 
   
   return val
}

method str stack.push( str val )
{
   uint ptr = this.push()
   
   ptr->str = val
   
   return ptr->str
}

method uint stack.pop
{
   uint count = *this
   
   if count
   {
      count--
      if type_hasdelete( this.sarr.itype )
      {
         type_delete( this.index( count ), this.sarr.itype )
      }       
      this.sarr->buf.use -= this.sarr.isize         
   }
   return ?( count, this.index( count - 1 ), 0 )
}

method uint stack.top
{
   return ?( *this, this.index( *this - 1 ), 0 )
}

method uint stack.popval
{
   uint count = *this
 
   if !count : return 0
   
   uint ret = this.index( count - 1 )->uint
   this.pop()
   
   return ret
}

method str stack.pop( str val )
{
   uint count = *this
 
   if !count : return val

   val = this.index( count - 1 )->str
   this.pop()
   
   return val
}

// Метод для разрешения указания подтипа при описании переменной
method stack.oftype( uint itype )
{
   this.sarr.oftype( itype )
}

method stack.clear
{
   this.sarr.delete()
   this.sarr->buf.use = 0
}
method stack.oftype( uint itype )
{
   this->arr.oftype( itype )
}
*/