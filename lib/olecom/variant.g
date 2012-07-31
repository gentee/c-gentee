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

import "Oleaut32.dll"
{
   uint SysAllocString( uint )  
   uint SysFreeString( uint )
   uint SysAllocStringByteLen( uint, uint )
   uint SysStringByteLen( uint )
}

//Типы VARIANT VARIANT.vt
define <export> {	
   VT_EMPTY	= 0
	VT_NULL	= 1
	VT_I2	   = 2
	VT_I4	   = 3
	VT_R4	   = 4
	VT_R8	   = 5
	VT_CY	   = 6
	VT_DATE	= 7
	VT_BSTR	= 8
	VT_DISPATCH	= 9
	VT_ERROR	   = 10
	VT_BOOL	   = 11
	VT_VARIANT	= 12
	VT_UNKNOWN	= 13
	VT_DECIMAL	= 14
	VT_I1	   = 16
	VT_UI1	= 17
	VT_UI2	= 18
	VT_UI4	= 19
	VT_I8	   = 20
	VT_UI8	= 21
	VT_INT	= 22
	VT_UINT	= 23
	VT_VOID	= 24
	VT_HRESULT	   = 25
	VT_PTR	      = 26
	VT_SAFEARRAY	= 27
	VT_CARRAY	   = 28
	VT_USERDEFINED	= 29
	VT_LPSTR	   = 30
	VT_LPWSTR	= 31
	VT_RECORD	= 36
	VT_FILETIME	= 64
	VT_BLOB	   = 65
	VT_STREAM	= 66
	VT_STORAGE	= 67
	VT_STREAMED_OBJECT  = 68
	VT_STORED_OBJECT	  = 69
	VT_BLOB_OBJECT	     = 70
	VT_CF	        = 71
	VT_CLSID	     = 72
	VT_BSTR_BLOB  = 0xfff
	VT_VECTOR	  = 0x1000
	VT_ARRAY	     = 0x2000
	VT_BYREF	     = 0x4000
	VT_RESERVED	  = 0x8000
	VT_ILLEGAL	  = 0xffff
	VT_ILLEGALMASKED    = 0xfff
	VT_TYPEMASK	        = 0xfff
}

define {   
   FADF_AUTO	= 0x1 
   FADF_STATIC	= 0x2 
   FADF_EMBEDDED	= 0x4 
   FADF_FIXEDSIZE	= 0x10 
   FADF_RECORD	= 0x20 
   FADF_HAVEIID	= 0x40 
   FADF_HAVEVARTYPE	= 0x80 
   FADF_BSTR	= 0x100 
   FADF_UNKNOWN	= 0x200 
   FADF_DISPATCH	= 0x400 
   FADF_VARIANT	= 0x800 
   FADF_RESERVED	= 0xf008 
}

type VARIANT {
   ushort vt          
   ushort wReserved1     
   ushort wReserved2     
   ushort wReserved3 
   ulong  val
}



type DISPPARAMS {
   uint rgvarg       // Array of arguments.
   uint rgdispidNamedArgs    // Dispatch IDs of named arguments.
   uint cArgs        // Number of arguments.
   uint cNamedArgs   // Number of named arguments.
} 

type SAFEARRAYBOUND
{
   uint cElements
   int  lLbound
} 

type SAFEARRAY 
{
   ushort cDims
   ushort fFeatures
   ushort cbElements
   ushort cLocks
   ushort handle
   ushort empty
   uint   pvData
   SAFEARRAYBOUND rgsabound
}

/*-----------------------------------------------------------------------------
* Id: variant_clear F3
* 
* Summary: Clears the variable contents, the storage area is released if
           necessary. The VARIANT type is equal to VT_EMPTY. This method is
           automatically called before a new value has been set . 
*
-----------------------------------------------------------------------------*/

method VARIANT.clear()
{
   if this.vt && !(this.vt & $VT_BYREF)
   {
      if this.vt & $VT_ARRAY
      {
         uint i, j, off, nums
         uint sarr as uint(this.val)->SAFEARRAY
         if (this.vt & $VT_TYPEMASK) == $VT_VARIANT 
         {                 
            off = &sarr.rgsabound         
            nums = 1
            fornum i = 0, sarr.cDims
            {  
               nums = nums * off->SAFEARRAYBOUND.cElements
               off += sizeof(SAFEARRAYBOUND)
            }
            
            off = sarr.pvData
            fornum i = 0, nums 
            {
               off->VARIANT.clear()
               off += sizeof(VARIANT)
            }
         }
         SysFreeString( sarr.pvData )      
         //SysFreeString( uint( this.val ) )
         mfree( uint( this.val ) )      
      }
      elif (this.vt & $VT_TYPEMASK) == $VT_BSTR
      {
         SysFreeString( uint(this.val) )
      }
      elif (this.vt & $VT_TYPEMASK) == $VT_DISPATCH
      {           
      //print( "ddd \(this.val)\n" )   
         if this.val : ((uint(this.val)->uint+8)->uint)->stdcall(uint(this.val))         
      }  
   }
   mzero( &this, sizeof( VARIANT ))   
}

include {
   "varconv.g"
}

method VARIANT.delete()
{
   this.clear()    
}

/*method VARIANT.arrgetptr( collection*/
/*-----------------------------------------------------------------------------
* Id: variant_arrcreate F2
* 
* Summary: Creating the SafeArray array. This method creates the #b(SafeArray) 
           array in the variable of the VARIANT type. VARIANT is an 
           element of the array. Values can be assigned to the array 
           elements using the #a(variant_arrfromg) method. An element of 
           the array can be obtained with the help of the 
           #a(variant_arrgetptr) method. 
           
           #p[The example uses SafeArray] 
#srcg[
|VARIANT v
|//An array with 3 lines and 2 columns is being created 
|v.arrcreate( %{3,0,2,0} )
|    
|v.arrfromg( %{0,0, 0.1234f} )    
|v.arrfromg( %{0,1, int(100)} )   
|v.arrfromg( %{2,1, "Test" } )
|...
|//The array is being transmitted to the COM object   
|excapp~Range( excapp~Cells( 1, 1 ), excapp~Cells( 3, 2 ) ) = v]
#p[SafeArray allows you to group data, that makes data exchange with the COM object faster.] 
*
* Params: bounds - The collection that contains array parameters. Two /
          numbers are specified for each array dimension: the first /
          number - an element quantity, the second number - a sequence /
          number of the first element in the dimension. 
*
* Return: #lng/retf#
*
-----------------------------------------------------------------------------*/

method uint VARIANT.arrcreate( collection bounds )
{
   this.clear()
   if *bounds > 1 && !(*bounds & 0x01)
   {  
      uint sarr      
      uint els
      int i
      uint arrbound
      
      this.vt = $VT_ARRAY | $VT_VARIANT//eltype   
      els = sizeof(SAFEARRAY) + sizeof(SAFEARRAYBOUND) * ( (*bounds >> 1) - 1 ) 
      //sarr as SysAllocStringByteLen( 0, els - 1  )->SAFEARRAY
      sarr as malloc( els + sizeof(SAFEARRAYBOUND) + 100 )->SAFEARRAY
//print( "alloc \(sizeof(SAFEARRAY) + sizeof(SAFEARRAYBOUND) * 
//( (*bounds >> 1) -1 ))\n" )
      mzero( &sarr, els )
      this.val = ulong( &sarr )
      sarr.cDims = *bounds >> 1
      arrbound as sarr.rgsabound
      els = 1
      for i = *bounds-1, i>=0, i--
      {  
         arrbound.lLbound = bounds[i--]
         els *= bounds[i]
         arrbound.cElements = bounds[i]         
         arrbound as uint 
         arrbound += sizeof(SAFEARRAYBOUND) 
      }
      sarr.fFeatures = /*$FADF_HAVEVARTYPE*/ $FADF_VARIANT |$FADF_FIXEDSIZE
      sarr.cbElements = sizeof(VARIANT)
      els *= sarr.cbElements      
      sarr.pvData = SysAllocStringByteLen( 0,  els - 1 )
      mzero( sarr.pvData, els )
      return 1      
   }  
   return 0
}

/*-----------------------------------------------------------------------------
* Id: variant_arrgetptr F2
* 
* Summary: Obtaining a pointer to an element of the SafeArray array. 
*
* Params: item - The collection that contains "coordinates" of an element.   
*
* Return: The method returns address of an array element, if error occurs 
          it returns zero.
*
-----------------------------------------------------------------------------*/

method uint VARIANT.arrgetptr( collection item )
{
   uint off
   
   if this.vt & $VT_ARRAY &&
      uint(this.val)->SAFEARRAY.cDims == *item
   {      
      uint sa as uint(this.val)->SAFEARRAY
      uint sba = &sa.rgsabound + sizeof( SAFEARRAYBOUND ) * (*item-1)
      uint r
      int i      
      for i = *item-1, i >= 0, i--
      {     
         off = off + item[i] - sba->SAFEARRAYBOUND.lLbound 
         if i > 0
         {
            off *= sba->SAFEARRAYBOUND.cElements
         }
         sba -= sizeof( SAFEARRAYBOUND )
      }
      off = sa.pvData + off * sa.cbElements      
   }
   return off
}

/*-----------------------------------------------------------------------------
* Id: variant_arrfromg F2
* 
* Summary: Assigning a value to an element of the SafeArray array. Example 
#srcg[
|v.arrfromg( %{0,0, 0.1234f} )    
|v.arrfromg( %{0,1, int(100)} )   
|v.arrfromg( %{2,1, "Test" } )]
*
* Params: item - The collection that contains "coordinates" of an element; /
                 the last element of the collection - the assigned value.   
*
* Return: #lng/retf#
*
-----------------------------------------------------------------------------*/

method uint VARIANT.arrfromg( collection item ) 
{
   uint gtype = item.gettype(*item-1)
   uint val = ?( gtype <= double, item.ptr(*item-1), item.ptr(*item-1)->uint )
   item.count--
   uint off = this.arrgetptr( item )
   item.count++
   if off && ( this.vt & $VT_TYPEMASK ) == $VT_VARIANT 
   {            
      off->VARIANT.fromg( gtype, val )
      return 1
   }
   return 0
}

