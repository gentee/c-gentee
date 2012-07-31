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

define {
   CP_ACP = 0  
   MB_PRECOMPOSED = 1
}

global {
   VARIANT VNULL
   VARIANT VTRUE
   VARIANT VFALSE
   VARIANT VMISSING
}
method buf buf.unicode( str src )
{
   uint len = (MultiByteToWideChar( $CP_ACP, $MB_PRECOMPOSED, src.ptr(), *src, this.ptr(), 0 ) + 1)*2
   this.expand( len )   
   MultiByteToWideChar( $CP_ACP, $MB_PRECOMPOSED, src.ptr(), *src, this.ptr(), len  )
   this[len-2] = 0
   this[len-1] = 0
   this.use = len
   return this
}

method str str.fromunicode( uint src )
{ 
   uint len = WideCharToMultiByte( $CP_ACP, 0, src, -1, this.ptr(), 0, 0, 0 ) 
   this.reserve( len )
   WideCharToMultiByte( $CP_ACP, 0, src, -1, this.ptr(), len, 0, 0  )   
   this.setlen( len - 1 )
   return this
}

method VARIANT VARIANT.fromg( uint gtype, uint pval )
{
   uint vt
   long val   
   this.clear()   
   switch gtype 
   {
      case ulong
      {
         vt = $VT_UI8
         val = pval->ulong
      }
      case long
      {
         vt = $VT_I8 
         val = pval->long
      }
      case uint
      {            
         vt = $VT_UI4
         val = ulong( pval->uint )  
      }
      case int
      {  
         vt = $VT_I4
         val = ulong( pval->uint )  
      }
      case float
      {
         vt = $VT_R4         
         (&val)->float = pval->float
      }
      case double
      {
         vt = $VT_R8         
         val = pval->ulong
      }
      case str
      {
         vt = $VT_BSTR
         buf ul         
         ul.unicode( pval->str )         
         val = ulong( SysAllocString( ul.ptr() ))
      }
      case oleobj
      {
         /*vt = $VT_DISPATCH | $VT_BYREF
         val = ulong( &(pval->oleobj.ppv) )
         print( "aaaaaaaaaaa \(val)\n" )*/
         //последние исправления
         vt = $VT_DISPATCH 
         val = ulong( pval->oleobj.ppv )
         ((uint(val)->uint+4)->uint)->stdcall(uint(val))
      }
      case VARIANT
      {   
      
        if (pval->VARIANT.vt & $VT_TYPEMASK) == $VT_ERROR && pval->VARIANT.val == 0x80020004L
         {
            val=ulong(pval->VARIANT.val)
            vt =pval->VARIANT.vt 
         }
         else
         {
            vt = pval->VARIANT.vt | $VT_BYREF    
            if pval->VARIANT.vt & $VT_BYREF 
            {            
               val = ulong(pval->VARIANT.val)
            }
            else
            {  
               val = ulong(&pval->VARIANT.val)
            }            
         }
      }
   }
   this.vt = vt
   this.val = val
   return this
}

/*-----------------------------------------------------------------------------
* Id: variant_opeq F4
* 
* Summary: Assign operation. #b(VARIANT = uint).
*
* Title: VARIANT = type 
*  
* Return: VARIANT( VT_UI4 ).
*
-----------------------------------------------------------------------------*/

operator VARIANT = (VARIANT left, uint right )
{
   return left.fromg( uint, &right )
}

/*-----------------------------------------------------------------------------
* Id: variant_opeq_1 FC
* 
* Summary: Assign operation: #b(VARIANT = int). 
*
* Return: VARIANT( VT_I4 ).
*
-----------------------------------------------------------------------------*/

operator VARIANT = (VARIANT left, int right )
{
   return left.fromg( int, &right )
}

/*-----------------------------------------------------------------------------
* Id: variant_opeq_2 FC
* 
* Summary: Assign operation: #b(VARIANT = float). 
*
* Return: VARIANT( VT_R4 ).
*
-----------------------------------------------------------------------------*/

operator VARIANT = (VARIANT left, float right )
{
   return left.fromg( float, &right )
}

/*-----------------------------------------------------------------------------
* Id: variant_opeq_3 FC
* 
* Summary: Assign operation: #b(VARIANT = double). 
*
* Return: VARIANT( VT_R8 ).
*
-----------------------------------------------------------------------------*/

operator VARIANT = (VARIANT left, double right )
{
   return left.fromg( double, &right )
}

/*-----------------------------------------------------------------------------
* Id: variant_opeq_4 FC
* 
* Summary: Assign operation: #b(VARIANT = long). 
*
* Return: VARIANT( VT_I8 ).
*
-----------------------------------------------------------------------------*/

operator VARIANT = (VARIANT left, long right )
{
   return left.fromg( long, &right )
}

/*-----------------------------------------------------------------------------
* Id: variant_opeq_5 FC
* 
* Summary: Assign operation: #b(VARIANT = ulong). 
*
* Return: VARIANT( VT_UI8 ).
*
-----------------------------------------------------------------------------*/

operator VARIANT = (VARIANT left, ulong right )
{
   return left.fromg( ulong, &right )
}

/*-----------------------------------------------------------------------------
* Id: variant_opeq_6 FC
* 
* Summary: Assign operation: #b(VARIANT = str). 
*
* Return: VARIANT( VT_BSTR ).
*
-----------------------------------------------------------------------------*/

operator VARIANT = (VARIANT left, str right )
{
   return left.fromg( str, &right )
}

/*-----------------------------------------------------------------------------
* Id: variant_opeq_7 FC
* 
* Summary: Assign operation: #b(VARIANT = VARIANT). 
*
* Return: VARIANT.
*
-----------------------------------------------------------------------------*/

operator VARIANT = (VARIANT left, VARIANT right )
{
   left.clear()
   if !( right.vt & $VT_ARRAY )
   {
      left.vt = right.vt
      left.val = right.val
      if !(left.vt & $VT_BYREF) && ((left.vt & $VT_TYPEMASK) == $VT_DISPATCH)
      {   
         ((uint(left.val)->uint+4)->uint)->stdcall(uint(left.val))        
      }
   }
   return left
}

/*-----------------------------------------------------------------------------
* Id: type_opvar F4
* 
* Summary: Conversion. #b[str(VARIANT)]. 
*
* Title: type( VARIANT )
*
* Return: The result #b(str) value.
*
-----------------------------------------------------------------------------*/

method str VARIANT.str <result> 
{   
   uint  pstr
      
   if this.vt & $VT_BYREF : pstr = uint( this.val )->uint
   else : pstr = uint( this.val )
   
   switch this.vt & $VT_TYPEMASK 
   {
      case $VT_BSTR
      {                 
         result.fromunicode( pstr )
      }
   }   
}

/*-----------------------------------------------------------------------------
* Id: typevar_opeq F4
* 
* Summary: Assign operation. #b[str = VARIANT( VT_BSTR )].
*
* Title: type = VARIANT 
*  
* Return: The result string.
*
-----------------------------------------------------------------------------*/

operator str = ( str left, VARIANT right )
{
   return left = str( right )
}

/*-----------------------------------------------------------------------------
* Id: type_opvar_1 FC
* 
* Summary: Conversion: #b[ulong(VARIANT)]. 
*
* Return: The result #b(ulong) value.
*
-----------------------------------------------------------------------------*/

method ulong VARIANT.ulong
{
   ulong  res
   ulong  val 
   
   if this.vt & $VT_BYREF : val = uint( this.val )->ulong
   else : val = this.val
   
   switch this.vt & $VT_TYPEMASK 
   {
      case $VT_I8
      {                 
         res = val
      }      
      default : res = 0L
   }
   return res 
}

/*-----------------------------------------------------------------------------
* Id: type_opvar_2 FC
* 
* Summary: Conversion: #b[long(VARIANT)]. 
*
* Return: The result #b(long) value.
*
-----------------------------------------------------------------------------*/

method long VARIANT.long
{
   long  res
   ulong  val 
   
   if this.vt & $VT_BYREF : val = uint( this.val )->ulong
   else : val = this.val
   
   switch this.vt & $VT_TYPEMASK 
   {
      case $VT_I8
      {                 
         res = val
      }      
      default : res = 0L
   }
   return res 
}

/*-----------------------------------------------------------------------------
* Id: type_opvar_3 FC
* 
* Summary: Conversion: #b[uint(VARIANT)]. 
*
* Return: The result #b(uint) value.
*
-----------------------------------------------------------------------------*/

method uint VARIANT.uint
{
   uint res
   ulong val

   if this.vt & $VT_BYREF : val = uint( this.val )->ulong
   else : val = this.val
   
   switch this.vt & $VT_TYPEMASK
   {
      case $VT_UI4, $VT_UI2, $VT_UI1, $VT_I4, $VT_I2, $VT_I1, $VT_DECIMAL
      {
         res = uint( val )
      }
      case $VT_BOOL
      {
         if uint( val ) : res = 1
         else : res = 0
      }      
      default : res = 0
   }
   return res 
}

/*-----------------------------------------------------------------------------
* Id: type_opvar_4 FC
* 
* Summary: Conversion: #b[int(VARIANT)]. 
*
* Return: The result #b(int) value.
*
-----------------------------------------------------------------------------*/

method int VARIANT.int
{
   uint res
   ulong val 
   
   if this.vt & $VT_BYREF : val = uint( this.val )->ulong
   else : val = this.val
   
   switch this.vt & $VT_TYPEMASK 
   {
      case $VT_I4, $VT_UI4, $VT_UI2, $VT_UI1, $VT_DECIMAL
      {      
         res = int( val )
      }
      case $VT_I2
      {               
         if uint( val ) & 0x8000
         {
            res = 0x80000000 & uint( val ) & 0x7FFF
         }
         else 
         {
            res = int( val )
         }  
      }
      case $VT_I1
      {               
         if uint( val ) & 0x80
         {
            res = 0x80000000 & uint( val ) & 0x7F
         }
         else
         {
            res = int( val )
         }  
      }
      case $VT_BOOL
      {
         if uint( val ) : res = 1
         else : res = 0
      }            
      default : res = 0
   }
   return res 
}

/*-----------------------------------------------------------------------------
* Id: type_opvar_5 FC
* 
* Summary: Conversion: #b[float(VARIANT)]. 
*
* Return: The result #b(float) value.
*
-----------------------------------------------------------------------------*/

method float VARIANT.float
{
   float  res
   ulong  val 
   
   if this.vt & $VT_BYREF : val = uint( this.val )->ulong 
   else : val = this.val
   
   switch this.vt & $VT_TYPEMASK 
   {
      case $VT_R4
      {                 
         res = (&val)->float
      }      
      default : res = 0f
   }
   return res 
}

/*-----------------------------------------------------------------------------
* Id: type_opvar_6 FC
* 
* Summary: Conversion: #b[double(VARIANT)]. 
*
* Return: The result #b(double) value.
*
-----------------------------------------------------------------------------*/

method double VARIANT.double
{
   double  res
   ulong  val 
   
   if this.vt & $VT_BYREF : val = uint( this.val )->ulong
   else : val = this.val
   
   switch this.vt & $VT_TYPEMASK 
   {
      case $VT_R8
      {                 
         res = (&val)->double
      }      
      default : res = 0d
   }
   return res 
}

/*-----------------------------------------------------------------------------
* Id: variant_isnull F3
* 
* Summary: Enables to define whether or not a variable is NULL. This method
           enables you to define whether or not a variable is NULL - the
           VARIANT( VT_NULL ) type. 
*
* Return: The method returns 1, if the VARIANT variable is of the VT_NULL 
          type, otherwise, it returns zero.
*
-----------------------------------------------------------------------------*/

method uint VARIANT.isnull()
{
   if (this.vt & $VT_TYPEMASK) == $VT_NULL : return 1
   return 0 
}

/*-----------------------------------------------------------------------------
* Id: variant_ismissing F3
* 
* Summary: Checks if the variant is "missing" (optional) parameter of the
           method. 
*
* Return: The method returns 1, if the VARIANT variable is "missing".
*
-----------------------------------------------------------------------------*/

method uint VARIANT.ismissing()
{
   if (this.vt & $VT_TYPEMASK) == $VT_ERROR && this.val == 0x80020004L : return 1
   return 0 
}

/*-----------------------------------------------------------------------------
* Id: variant_setmissing F3
* 
* Summary: Sets the "missing" variant. The method sets the variant variable 
           as "missing" (optional) parameter.
*
-----------------------------------------------------------------------------*/

method VARIANT.setmissing()
{
   this.clear()
   this.vt = $VT_ERROR
   this.val = 0x80020004L
}


/*-----------------------------------------------------------------------------
* Id: variant_istrue F3
* 
* Summary: Checks if the variant is "true" parameter of the
           method. 
*
* Return: The method returns 1, if the VARIANT variable is "true".
*
-----------------------------------------------------------------------------*/
method uint VARIANT.istrue()
{
   if this.vt == $VT_BOOL && (&this.val)->uint == 0xffff
   {
      return 1
   }   
   return 0
}

func variantinit<entry>
{
   
   VMISSING.clear()
   VMISSING.vt = $VT_ERROR
   VMISSING.val = 0x80020004L
   VTRUE.clear()
   VTRUE.vt = $VT_BOOL
   (&VTRUE.val)->uint = 0xffff
   VFALSE.clear()   
   VFALSE.vt = $VT_BOOL   
   VNULL.clear()
   VNULL.vt = $VT_NULL
}