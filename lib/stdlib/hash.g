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
* Id: hash L "Hash"
* 
* Summary: Hash (Associative array). Variables of the hash type allow you to
           work with associative arrays or hash tables. Each item in such an
           array corresponds to a unique key string. Items are addresses by
           specifying the corresponding key strings.  
*
* List: *Operators,hash_opof,hash_oplen,hash_opind,hash_opfor,
        *Methods,hash_clear,hash_create,hash_del,hash_find,
         hash_ignorecase,hash_sethashsize, 
        *Type,thash 
* 
-----------------------------------------------------------------------------*/

type hashkey
{
   str   key   // ключ
   uint  next  // Указатель на следующий ключ
}
//После hashkey идут данные

type hkeys <index = str>
{
   uint  owner
}

type hashfordata <inherit=fordata>{   
   uint curind  // текущий индекс для foreach
   uint curitem // текущий элемент для foreach
   uint forkeys // 1 если foreach для ключей
}

/*-----------------------------------------------------------------------------
* Id: thash T hash
* 
* Summary: The main structure of the hash.
*
-----------------------------------------------------------------------------*/

type hash {
   arr   hashes   // Array of hash values. Pointers to hashkey.
   uint  itype    // The type of the items.
   uint  isize    // The type of the item.
   uint  count    // The count of items.
   uint  igncase  // Equals 1 if the hash ignores case sensetive.
   hkeys keys     // The structure for looking over keys
}

/*-----------------------------------------------------------------------------
* Id: hash_opof F4
* 
* Summary: Specifying the type of items. You can specify #b(of) type when you 
           describe #b(hash) variable. In default, the type of the items 
           is #b(uint).
*  
* Title: hash of type
*
-----------------------------------------------------------------------------*/

method hash.oftype( uint itype )
{
   this.itype = itype
   this.isize = sizeof( hashkey ) + sizeof( itype )
}

/*-----------------------------------------------------------------------------
* Id: hash_sethashsize F2
*
* Summary: Set the size of a value table. Set the size of the value table for
           searching for keys. The method must be called before any items are 
           added. The parameter contains the power of two for calculating the 
           size of the table since the number of items must be the power of 
           two. By default, the size of a table is 4096 items. 
*  
* Params: power - The power of two for calculating the size of the table. 
* 
* Return: #lng/retf#
*
-----------------------------------------------------------------------------*/

method uint hash.sethashsize( uint power )
{
   if this.count : return 0
   if power < 8 : power = 8
   if power > 20 : power = 20
   this.hashes.clear()
   this.hashes.expand( 1 << power )
   return 1
}

method hash hash.init()
{
   this.sethashsize( 12 )  // 4096
   this.oftype( uint )
   this.keys.owner = &this
   return this
} 

/*-----------------------------------------------------------------------------
* Id: hash_oplen F4
* 
* Summary: Get the count of items.
*  
* Return: Count of hash items.
*
-----------------------------------------------------------------------------*/

operator uint *( hash left )
{
   return left.count
}

/*-----------------------------------------------------------------------------
* Id: hash_ignorecase F3
*
* Summary: Ignoring the letter case of keys. Work with the keys of this hash
           table without taking into account the case of letters. The method 
           must be called before any items are added. 
*  
* Return: #lng/retf#
*
-----------------------------------------------------------------------------*/

method uint hash.ignorecase
{
   if this.count : return 0
   this.igncase = 1
   return 1
}

method hash.delete()
{
   uint i
   uint base
   
   fornum i, *this.hashes
   {
      while this.hashes[ i ]
      {
         base = this.hashes[ i ]
         this.hashes[ i ] = base->hashkey.next
         if type_hasdelete( this.itype )
         {
            type_delete( base + sizeof( hashkey ), this.itype )
         }      
         type_delete( base, hashkey )
         mfree( base )
      }
   }
} 

/*-----------------------------------------------------------------------------
* Id: hash_clear F3
*
* Summary: Clear a hash. The method removes all items from the hash.
*  
-----------------------------------------------------------------------------*/

method hash.clear()
{
   this.delete()
   this.count = 0
}

method uint hash.keyfind( str key, uint index )
{
   uint  i
   
   if this.igncase 
   {
      str lkey = key
      
      lkey.lower()
      i = lkey.crc() & ( *this.hashes - 1 )
   }
   else : i = key.crc() & ( *this.hashes - 1 )
   uint  ptr = this.hashes[ i ]
   
   if index : index->uint = i
   if !ptr : return 0
   while ptr
   {
      if this.igncase 
      {
         if ptr->hashkey.key %== key : break
      }
      elif ptr->hashkey.key == key : break
      ptr = ptr->hashkey.next
   }
   return ?( ptr, ptr + sizeof( hashkey ), 0 )
}

/*-----------------------------------------------------------------------------
* Id: hash_find F2
*
* Summary: Find an item with this key. 
*  
* Params: key - Key value. 
* 
* Return: Either the pointer to the found item is returned or 0 is returned 
          if there is no item with this key. 
*
-----------------------------------------------------------------------------*/

method uint hash.find( str key )
{
   return this.keyfind( key, 0 )
}

/*-----------------------------------------------------------------------------
* Id: hash_create F2
*
* Summary: Creating an item with this key. If an item with this key already
           exists, it will be initiated again. Items are created automatically 
           when they are addressed as array items for the first time - 
           hashname["key string"]. 
*  
* Params: key - Key value. 
* 
* Return: The pointer to the created item is returned. 
*
-----------------------------------------------------------------------------*/

method uint hash.create( str key )
{
   uint  index
   uint  item = this.keyfind( key, &index )
   uint  data
   if !item
   {
      data = malloc( this.isize )
      type_init( data, hashkey )
      item = data + sizeof( hashkey )
      // вставка элемента
      data->hashkey.key = key
      data->hashkey.next = this.hashes[ index ]
      this.hashes[ index ] = data
      this.count++
   }
   else
   {
      if type_hasdelete( this.itype ) : type_delete( item, this.itype )
   }
   type_init( item, this.itype )
   return item   
} 

/*-----------------------------------------------------------------------------
* Id: hash_opind F4
* 
* Summary: Getting an item by a key string. In case there is no item, 
           it will be created automatically.
*  
* Title: hash[ name ]
*
* Return: The #b('["key"]') item of the hash.
*
-----------------------------------------------------------------------------*/

method uint hash.index( str key )
{
   uint  item = this.find( key )
   
   if !item : return this.create( key )
   return item
}

/*-----------------------------------------------------------------------------
* Id: hash_del F2
*
* Summary: Delete an item with this key.
*  
* Params: key - Key value. 
* 
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

method uint hash.del( str key )
{
   uint index
   uint ptr
   uint item = this.keyfind( key, &index )
   uint base
   
   if !item : return 0
   // Удаляем из списка
   ptr = this.hashes[ index ]
   base = item - sizeof( hashkey )
   if ptr == base
   {
      this.hashes[ index ] = base->hashkey.next
   }
   else
   {
      while ptr->hashkey.next != base
      {
         ptr = ptr->hashkey.next
         if !ptr : return 0
      }
      ptr->hashkey.next = base->hashkey.next
   }
   // Удаляем объект   
   if type_hasdelete( this.itype )
   {
      type_delete( item, this.itype )
   }      
   type_delete( base, hashkey )
   mfree( base )
   this.count--
   return 1
}

/*-----------------------------------------------------------------------------
* Id: hash_opfor F5
*
* Summary: Foreach operator. You can use #b(foreach) operator to look over all 
           items of the hash. #b(Variable) is a pointer to the hash item.
*  
* Title: foreach var,hash
*
* Define: foreach variable,hash {...}
* 
-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
* Id: hash_opfor_1 FD
*
* Summary: You can use #b(foreach) operator to look over all 
           keys of the hash. 
*  
* Title: foreach var,hash.keys
*
* Define: foreach variable,hash.keys {...}
* 
-----------------------------------------------------------------------------*/

method uint hash.eof( hashfordata fd )
{
   return fd.curind >= *this.hashes 
}

method uint hash.next( hashfordata fd )
{
   if fd.curitem
   {
      if fd.curitem = fd.curitem->hashkey.next      {

         return ?( fd.forkeys, &fd.curitem->hashkey.key,
                   fd.curitem + sizeof( hashkey ))
      }
      fd.curind++
   }      
   while fd.curind < *this.hashes && !this.hashes[ fd.curind ]  
   {
      fd.curind++
   }
   if fd.curind < *this.hashes
   {
      fd.curitem = this.hashes[ fd.curind ]
      return ?( fd.forkeys, &fd.curitem->hashkey.key,
                fd.curitem + sizeof( hashkey ))
   }
   return 0
}

method uint hash.forfirst( hashfordata fd )
{
   fd.curind = 0
   fd.curitem = 0
   return this.next( fd )
}

method uint hash.first( hashfordata fd ) 
{
   fd.forkeys = 0
   return this.forfirst( fd )
}

method uint hkeys.eof( hashfordata fd )
{
   return this.owner->hash.eof( fd )
}

method uint hkeys.next( hashfordata fd )
{
   return this.owner->hash.next( fd )
}

method uint hkeys.first( hashfordata fd )
{
   fd.forkeys = 1
   return this.owner->hash.forfirst( fd )
}
