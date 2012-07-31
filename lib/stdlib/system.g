/******************************************************************************
*
* Copyright (C) 2004-2008, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* Author: Alexander Krivonogov ( algen )
*
******************************************************************************/

/*-----------------------------------------------------------------------------
* Id: system L "System"
* 
* Summary: System functions.
*
* List: *,max,min,
        *Callback and search features,callback,freecallback,getid,
        *Type functions,destroy,new,sizeof,type_delete,type_hasdelete,
        type_hasinit,type_init  
* 
-----------------------------------------------------------------------------*/

define <export>
{
/*-----------------------------------------------------------------------------
* Id: getidflags D
* 
* Summary: Flags for getid function.
*
-----------------------------------------------------------------------------*/
    GETID_METHOD   = 0x01 // Search method. Specify the main type of the /
                          // method as the first parameter in the collection.  
    GETID_OPERATOR = 0x02 // Search operator. You can specify the operator in /
                          // name as is. For example, #b(+=).
    GETID_OFTYPE   = 0x04 // Specify this flag if you want to describe /
                  // parameters with types of items (of type). In this case, /
                  // collection must contains pairs - idtype and idoftype.
//-----------------------------------------------------------------------------
}

/*-----------------------------------------------------------------------------
* Id: max F
*
* Summary: Determining the largest of two numbers. 
*  
* Params: left - The first compared number of the uint type. 
          right - The second compared number of the uint type. 
* 
* Return: The largest of two numbers.
*
-----------------------------------------------------------------------------*/

func  uint  max( uint left, uint right )
{
   return ?( left > right, left, right )
}

/*-----------------------------------------------------------------------------
* Id: min F
*
* Summary: Determining the smallest of two numbers. 
*  
* Params: left - The first compared number of the uint type. 
          right - The second compared number of the uint type. 
* 
* Return: The smallest of two numbers.
*
-----------------------------------------------------------------------------*/

func  uint  min( uint left, uint right )
{
   return ?( left < right, left, right )
}

/*-----------------------------------------------------------------------------
* Id: max_1 F8
*
* Summary: Determining the largest of two int numbers. 
*  
* Params: left - The first compared number of the int type. 
          right - The second compared number of the int type. 
* 
* Return: The largest of two int numbers.
*
-----------------------------------------------------------------------------*/

func  uint  max( int left, int right )
{
   return ?( left > right, left, right )
}

/*-----------------------------------------------------------------------------
* Id: min_1 F8
*
* Summary: Determining the smallest of two int numbers. 
*  
* Params: left - The first compared number of the int type. 
          right - The second compared number of the int type. 
* 
* Return: The smallest of two int numbers.
*
-----------------------------------------------------------------------------*/

func  uint  min( int left, int right )
{
   return ?( left < right, left, right )
}

/*-----------------------------------------------------------------------------
* Id: new F
*
* Summary: Creating an object. The function creates an object of the specified
           type.   
*  
* Params: objtype - The identifier or the name of a type. 
* 
* Return: The pointer to the created object.
*
-----------------------------------------------------------------------------*/

func uint new( uint objtype )
{
   return new( objtype, 0 )
}

/*-----------------------------------------------------------------------------
* Id: new_1 F8
*
* Summary: The function creates an object with specifing the count and the 
           type of its items.   
*  
* Params: objtype - The identifier or the name of a type.
          oftype - The type of object's items. 
          count - The initial count of object's items. 
* 
* Return: The pointer to the created object.
*
-----------------------------------------------------------------------------*/

func uint new( uint objtype, uint oftype, uint count )
{
   uint ret funcof
   
   ret = new( objtype, 0 )
   if oftype && funcof = getid("oftype", 1 /*GETID_METHOD*/, 
                                 %{ objtype, uint } )  
   {
      funcof->func( ret, oftype )
   }
   if count && funcof = getid("array", 1 /*GETID_METHOD*/, %{ objtype, uint } )  
   {
      funcof->func( ret, count )
   }
   return ret
}

/*
50             push eax
55             push ebp
53             push ebx
8B DC          mov  ebx, esp
83 C3 XX       add  ebx, ( parsize * 4 + 0Ch )
8B EB          mov  ebp, ebx 
83 ED XX       sub  ebp, ( parsize * 4 )
3B EB          cmp  ebp, ebx
74 08          je   endcopy 
8B 03          mov  eax, [ebx] 
50             push eax
83 EB 04       sub  ebx, 4 
EB F4          jmp  copy 
83 ED 04       sub  ebp, 4
55             push ebp 
68 01 01 00 00 push id
ba XX XX XX XX mov  edx,  &ge_call
ff d2          call edx
83 C4 XX       add  esp, ( parsize + 2 )* 4 
5B             pop ebx
5D             pop ebp
58             pop eax 
C2 XX          ret ( parsize * 4 )/C3 ret cdecl
00
*/

import "kernel32.dll"
{
uint VirtualAlloc( uint, uint, uint, uint )
uint VirtualFree( uint, uint, uint )
}

/*-----------------------------------------------------------------------------
* Id: callback F
*
* Summary: Create a callback function. This function allows you to use gentee
           functions as callback functions. For example, gentee function 
           can be specified as a message handler for windows. 
*  
* Params: idfunc - Identifier ( address ) of gentee function that will be /
                   callback function.
          parsize - The summary size of parameters (number of uint values). /
          One parameter uint = 1 (uint = 1). uint + uint = 2, uint + long = 3. 
* 
* Return: You can use the return value as the callback address. You have to 
          free it with #a(freecallback) function when you don't need this
          callback function. 
*
-----------------------------------------------------------------------------*/
define <export>
{
   CB_STDCALL = 0
   CB_CDECL   = 1
   
}
func uint callback( uint idfunc, uint parsize, uint ftype )
{     
   buf  bc = '\h
50            
55            
53            
8B DC         
83 C3 \(byte( parsize * 4 + 0x0C ))      
8B EB         
83 ED \(byte( parsize * 4 ))      
3B EB         
74 08         
8B 03         
50             
83 EB 04      
EB F4         
83 ED 04      
55            
68 \( idfunc )
b8 \( calladdr() )
ff d0
83 C4 \(byte( ( parsize + 2 )* 4 ))      
5B            
5D            
58            
\( ?( ftype == $CB_CDECL, byte( 0xC3 ), byte( 0xC2) ))
\( parsize * 4 )         
00
'
// ba \( calladdr() ) till 12.01.09
// ff d2         
   uint pmem
   pmem = VirtualAlloc( 0, *bc, 0x3000,  0x40 )  
   mcopy( pmem, bc.ptr(), *bc )      
   return pmem
   
}

func uint callback( uint idfunc, uint parsize )
{     
   return callback( idfunc, parsize, 0 )   
}


/*-----------------------------------------------------------------------------
* Id: freecallback F
*
* Summary: Free a created callback function.  
*  
* Params: pmem - The pointer that was returned by #a(callback) function.
* 
-----------------------------------------------------------------------------*/

func freecallback( uint pmem )
{
   VirtualFree( pmem, 0, 0x8000 )   
}


