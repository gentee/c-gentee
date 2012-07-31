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
* Id: collections L "Collection"
* 
* Summary: Collection. You can use variables of the #b(collection)
   type for working with collections. Collection is an object which can 
   contains objects of different types. The #b(collection) type is
   inherited from the #b(buf) type. So, you can also use 
   #a(buffer, methods of the buf type).
*
* List: *#lng/opers#,collection_oplen,collection_opind,collection_opeq,
        collection_opadd,collection_opsum,collection_opfor,
        *#lng/methods#,collection_append,collection_clear,collection_gettype,
        collection_ptr,
        *#lng/types#,collection_colitem
* 
-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
* Id: collection_opeq F4
* 
* Summary: Collection copying.
*  
-----------------------------------------------------------------------------*/

operator collection =( collection left, collection right )
{
   left->buf = right->buf
   left.count = right.count
   return left
}

/*-----------------------------------------------------------------------------
* Id: collection_opadd F4
* 
* Summary: Appends elements of a collection to another collection.
*  
-----------------------------------------------------------------------------*/

operator collection +=( collection left, collection right )
{
   left->buf += right->buf
   left.count += right.count
   return left
}

/*-----------------------------------------------------------------------------
* Id: collection_opsum F4
* 
* Summary: Putting two collections together and creating a resulting 
           collection.
*
* Return: The new result collection.            
*  
-----------------------------------------------------------------------------*/

operator collection +<result> ( collection left, collection right )
{
   result = left
   result += right     
}

/*-----------------------------------------------------------------------------
* Id: collection_clear F3
* 
* Summary: Delete all items from the collection. 
*
* Return: #lng/retobj#
*
-----------------------------------------------------------------------------*/

method collection collection.clear()
{
   this->buf.clear()
   this.count = 0
   return this
}

/*-----------------------------------------------------------------------------
* Id: collection_append F2
* 
* Summary: Append an object or a numeric value to the collection.
*
* Params: value - The value of the 32-bit number or the pointer to 64-bit /
                  number or the ponter to any other object.
          itype - The type of the appending value.
*
* Return: An index of the appended item.
*
-----------------------------------------------------------------------------*/

method uint collection.append( uint value, uint itype )
{
   this.count++;
   this->buf += itype
   if ( itype >= double && itype <= ulong )
   {
      this.flag |= 0x01;
      this->buf += value->ulong
   }
   else : this->buf += value
   return this.count - 1
}

/*-----------------------------------------------------------------------------
* Id: collection_colitem T 
* 
* Summary: The structure is used in #a(collection_opfor, #b[foreach] ) 
           operator. The variable of the foreach operator has this type.
*
* Title: colitem
*
-----------------------------------------------------------------------------*/

type colitem {
   uint oftype     // The type of the item. 
   uint val        // The value of the item. 
   uint hival      // The hi-uint of the value. It is used if the value is  /
                   // 64-bit.
   uint ptr        // The pointer to the value.
}

/*-----------------------------------------------------------------------------
* Id: collection_opfor F5
*
* Summary: Foreach operator. You can use #b(foreach) operator to look over 
           items of the collection. The variable #b(var) has
           #a(collection_colitem, colitem) type.
*  
* Title: foreach var,collection
*
* Define: foreach variable,collection {...}
* 
-----------------------------------------------------------------------------*/

type colfordata <inherit=fordata>{
   uint pcur
   colitem item
}

method uint collection.eof( colfordata fd )
{
   return ?( fd.icur < *this, 0,  1 )
}

method colitem collection.next( colfordata fd )
{
   fd.icur++
   
   fd.item.oftype = fd.pcur->uint
   fd.pcur += 4
   fd.item.ptr = fd.pcur      
   if fd.item.oftype == double || fd.item.oftype == long || fd.item.oftype == ulong
   {
      (&fd.item.val)->ulong = fd.pcur->ulong 
      fd.pcur += 8
   } 
   else : fd.pcur +=4   
   
   fd.item.val = fd.item.ptr->uint 
   return fd.item
}

method colitem collection.first( colfordata fd )
{
   fd.icur = -1
   fd.pcur = .data
   return .next( fd )
}

/*Тип collection является встроенным
Cтруктура collection включена в компилятор
type collection <inherit=buf>
{       
   uint      count;   // The number of items
   uint      flag;
}
В компилятор включены следующее методы и операции:
uint collection.gettype( uint index )
uint collection.getptr( uint index )
*/
