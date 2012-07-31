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
* Id: registry L "Registry"
* 
* Summary: Working with the Registry. This library allows you to work with 
           the Windows Registry. For using this library, it is required to
           specify the file registry.g (from
            lib\registry subfolder) with include command. #srcg[
|include : $"...\gentee\lib\registry\registry.g"]    
*
* List: *#lng/funcs#,regdelkey,regdelvalue,reggetmultistr,reggetnum,
         regkeys,regsetmultistr,regsetnum,regvaltype,regvalues,regverify, 
        *#lng/methods#,buf_regget,buf_regset,str_regget,str_regset
* 
-----------------------------------------------------------------------------*/

define <export>
{
/*-----------------------------------------------------------------------------
* Id: regroot D
* 
* Summary: Registry roots
*
-----------------------------------------------------------------------------*/
   HKEY_CLASSES_ROOT   = 0x80000000   // Classes Root.
   HKEY_CURRENT_USER   = 0x80000001   // Current user's settings.
   HKEY_LOCAL_MACHINE  = 0x80000002   // Local machine settings.
   HKEY_USERS          = 0x80000003   // All users' settings

//-----------------------------------------------------------------------------
   REG_OPTION_NON_VOLATILE  = 0x00000000

   REG_CREATED_NEW_KEY      = 0x00000001
   REG_OPENED_EXISTING_KEY  = 0x00000002
/*-----------------------------------------------------------------------------
* Id: regtype D
* 
* Summary: Registry types
*
-----------------------------------------------------------------------------*/
   REG_NONE       = 0   // Unknown. 
   REG_SZ         = 1   // String.
   REG_EXPAND_SZ  = 2   // Expanded string. String with environment variables.
   REG_BINARY     = 3   // Binary data.
   REG_DWORD      = 4   // Number.
   REG_MULTI_SZ   = 7   // String sequence.

//-----------------------------------------------------------------------------
   KEY_READ       = 0x20019
   KEY_WRITE      = 0x20006
   KEY_WOW64_64KEY = 0x0100
   
/*-----------------------------------------------------------------------------
* Id: regsetret D
* 
* Summary: Result of buf.regset
*
-----------------------------------------------------------------------------
#define   0    // No data has been written.
#define   1    // The value of the key was created during the writing process.
#define   2    // Data is written into the existing value.

//-----------------------------------------------------------------------------
-----------------------------------------------------------------------------*/
   REGSET_FALSE   = 0
   REGSET_CREATED = 1
   REGSET_OPENED  = 2

   ERROR_NO_MORE_ITEMS = 259
}

global {
   uint g_regflag = 0
}

import "advapi32.dll"
{
   int RegCloseKey( uint )
   int RegCreateKeyExA( uint, uint, uint, uint, uint, uint, uint, uint,
                        uint ) -> RegCreateKeyEx
   int RegDeleteKeyA( uint, uint ) -> RegDeleteKey
   int RegDeleteKeyExA( uint, uint, uint, uint ) -> RegDeleteKeyEx
   int RegDeleteValueA( uint, uint ) -> RegDeleteValue
   int RegEnumKeyExA( uint, uint, uint, uint, uint, uint, uint, 
                      filetime ) -> RegEnumKeyEx   
   int RegEnumValueA( uint, uint, uint, uint, uint, uint, uint, 
                        uint ) -> RegEnumValue
   int RegOpenKeyExA( uint, uint, uint, uint, uint ) -> RegOpenKeyEx
   int RegQueryValueExA( uint, uint, uint, uint, 
                         uint, uint ) -> RegQueryValueEx
   int RegSetValueExA( uint, uint, uint, uint, uint, uint ) -> RegSetValueEx
}

/*-----------------------------------------------------------------------------
* Id: regvaltype F
* 
* Summary: Get the type of a registry key value.
*  
* Params: root - A root key. $$[regroot] 
          subkey - A name of the registry key. 
          valname - The name of the key value the type of which is being /
                    determined. 
*
* Return: 0 is returned if the type is not determined or there is no such 
          value. Besides, the following values are possible: $$[regtype]   
*
-----------------------------------------------------------------------------*/

func uint regvaltype( uint root, str subkey, str valname )
{
   uint hkey
   uint result
   
   if !RegOpenKeyEx( root, subkey.ptr(), 0, $KEY_READ | g_regflag, &hkey )
   {
      if RegQueryValueEx( hkey, valname.ptr(), 0, &result, 0, 0 ) : result = 0
      RegCloseKey( hkey )
   }
   return result
}

/*-----------------------------------------------------------------------------
* Id: buf_regget F2
* 
* Summary: Getting a value. This method writes the value of a registry key 
           into a #a(buffer) object.
*  
* Params: root - A root key. $$[regroot] 
          subkey - A name of the registry key. 
          valname - A name of the specified key value.
          regtype - The pointer to uint the type of this value will be /
                    written to. It can be 0. 
*
* Return: #lng/retobj#
*
-----------------------------------------------------------------------------*/

method buf buf.regget( uint root, str subkey, str valname, uint regtype )
{
   uint  size
   uint  hkey
   
   this.clear()
   if !RegOpenKeyEx( root, subkey.ptr(), 0, $KEY_READ | g_regflag, &hkey )
   {
      if !RegQueryValueEx( hkey, valname.ptr(), 0, regtype, 0, &size )
      {
         this.expand( size )
         if !RegQueryValueEx( hkey, valname.ptr(), 0, 0, this.ptr(), &size )
         {
            this.use = size
         }
      }
      elif regtype : regtype->uint = 0
      RegCloseKey( hkey )
   }
   return this
}

/*-----------------------------------------------------------------------------
* Id: str_regget F2
* 
* Summary: Getting a value. This method writes the value of a registry key 
           into a #a(string) object.
*  
* Params: root - A root key. $$[regroot] 
          subkey - A name of the registry key. 
          valname - A name of the specified key value.
*
* Return: #lng/retobj#
*
-----------------------------------------------------------------------------*/

method str str.regget( uint root, str subkey, str valname )
{
   uint  size itype

   this->buf.regget( root, subkey, valname, &itype )

   if itype == $REG_SZ || itype == $REG_EXPAND_SZ || itype == $REG_MULTI_SZ
   {
      this.setlenptr()
   } 
   elif itype == $REG_DWORD
   {
      size = this.ptr()->uint
      this = str( size )
   }
   else : this->buf += byte( 0 )

   return this
}

/*-----------------------------------------------------------------------------
* Id: str_regget_1 FA
* 
* Summary: This method writes the value of a registry key 
           into a #a(string) object.
*  
* Params: root - A root key. $$[regroot] 
          subkey - A name of the registry key. 
          valname - A name of the specified key value.
          defval - The default string in case there is no value.
*
* Return: #lng/retobj#
*
-----------------------------------------------------------------------------*/

method str str.regget( uint root, str subkey, str valname, str defval )
{
   uint  size itype

   if !regvaltype( root, subkey, valname )
   {
      this = defval
   }
   else : this.regget( root, subkey, valname )
   
   return this
}

/*-----------------------------------------------------------------------------
* Id: reggetnum F
* 
* Summary: Get the numerical value of a registry key.
*  
* Params: root - A root key. $$[regroot] 
          subkey - A name of the registry key. 
          valname - A name of the specified key value.
*
* Return: A numerical value is returned.
*
-----------------------------------------------------------------------------*/

func uint reggetnum( uint root, str subkey, str valname )
{
   uint  size itype
   buf   data
   
   data.regget( root, subkey, valname, &itype )

   if itype == $REG_SZ || itype == $REG_EXPAND_SZ || itype == $REG_MULTI_SZ
   {
      return data->str.uint()
   } 
   elif itype == $REG_DWORD
   {
      return data.ptr()->uint
   }

   return 0
}

/*-----------------------------------------------------------------------------
* Id: reggetnum_1 F8
* 
* Summary: Get the numerical value of a registry key.
*  
* Params: root - A root key. $$[regroot] 
          subkey - A name of the registry key. 
          valname - A name of the specified key value.
          defval - The default number in case there is no value.
*
* Return: A numerical value is returned.
*
-----------------------------------------------------------------------------*/

func uint reggetnum( uint root, str subkey, str valname, uint defval  )
{
   if !regvaltype( root, subkey, valname ) : return defval
   return reggetnum( root, subkey, valname )
}

/*-----------------------------------------------------------------------------
* Id: regverify F
* 
* Summary: Creating missing keys. Check if there is a certain key in the
           registry and create it if it is not there.
*  
* Params: root - A root key. $$[regroot] 
          subkey - The name of the registry key being checked. 
          ret - The array of strings all the created keys will be written to./
                It can be 0.
*
* Return: #lng/retf#
*
-----------------------------------------------------------------------------*/

func uint regverify( uint root, str subkey, arrstr ret )
{
   arrstr   keys 
   str   key
   uint  i hkey dwi
   
   subkey.fdelslash()
   subkey.split( keys, '\', 0 )
   if ret : ret.clear()
   
   fornum i, *keys 
   {
      key.faddname( keys[ i ] )
      
      if !RegCreateKeyEx( root, key.ptr(), 0, 0,
              $REG_OPTION_NON_VOLATILE, $KEY_WRITE | g_regflag, 0, &hkey, &dwi )
      {
         if dwi == $REG_CREATED_NEW_KEY && ret
         {
            ret += key
         }
         RegCloseKey( hkey )
      }
      else : return 0
   }
   return 1
}

/*-----------------------------------------------------------------------------
* Id: buf_regset F2
* 
* Summary: Writing a value. Write the data of an buf object as registry 
           key value. If there is no key, it will be created.
*  
* Params: root - A root key. $$[regroot] 
          subkey - A name of the registry key. 
          valname - The name of the value being written.
          regtype - Value type. $$[regtype]
          ret - The array of strings all the created keys will be written to. /
                It can be 0.
*
* Return: $$[regsetret]
*
-----------------------------------------------------------------------------*/

method uint buf.regset( uint root, str subkey, str valname, uint regtype, 
                        arrstr ret )
{
   uint  result size exist
   uint  hkey dwi
   
   subkey.fdelslash()
   if regvaltype( root, subkey, valname ) : exist = 1
   else : regverify( root, subkey, ret )
   
   if !RegCreateKeyEx( root, subkey.ptr(), 0, 0, $REG_OPTION_NON_VOLATILE, 
                       $KEY_WRITE | $KEY_READ | g_regflag, 0, &hkey, &dwi )
   {
      size = ?( regtype == $REG_DWORD, 4, *this )
      
      if !RegSetValueEx( hkey, valname.ptr(), 0, regtype, this.ptr(),
                         size ) : result = 1 + exist
      RegCloseKey( hkey )
   } 
   
   return result
}

/*-----------------------------------------------------------------------------
* Id: str_regset F2
* 
* Summary: Write a string as a registry key value. If there is no key, 
           it will be created.
*  
* Params: root - A root key. $$[regroot] 
          subkey - A name of the registry key. 
          valname - The name of the value being written.
          ret - The array of strings all the created keys will be written to. /
                It can be 0.
*
* Return: $$[regsetret]
*
-----------------------------------------------------------------------------*/

method uint str.regset( uint root, str subkey, str valname, arrstr ret )
{
   return this->buf.regset( root, subkey, valname, $REG_SZ, ret )
}

/*-----------------------------------------------------------------------------
* Id: str_regset_1 FA
* 
* Summary: Write a string as a registry key value. If there is no key, 
           it will be created.
*  
* Params: root - A root key. $$[regroot] 
          subkey - A name of the registry key. 
          valname - The name of the value being written.
*
* Return: $$[regsetret].
*
-----------------------------------------------------------------------------*/

method uint str.regset( uint root, str subkey, str valname )
{
   return this->buf.regset( root, subkey, valname, $REG_SZ, 0->arrstr )
}

/*-----------------------------------------------------------------------------
* Id: regsetnum F
* 
* Summary: Write a number as a registry key value. If there is no key, it 
           will be created.
*  
* Params: root - A root key. $$[regroot] 
          subkey - A name of the registry key. 
          valname - The name of the value being written.
          value - The number being written.
          ret - The array of strings all the created keys will be written to. /
                It can be 0.
*
* Return: $$[regsetret]
*
-----------------------------------------------------------------------------*/

func uint regsetnum( uint root, str subkey, str valname, uint value, 
                     arrstr ret  )
{
   buf bnum
   
   bnum += value
   return bnum.regset( root, subkey, valname, $REG_DWORD, ret )
}

/*-----------------------------------------------------------------------------
* Id: regsetmultistr F
* 
* Summary: Writing a string sequence. Write an array of strings as a value of 
           a registry key of the $REG_MULTISZ type. If there is no key, 
           it will be created. 
*  
* Params: root - A root key. $$[regroot] 
          subkey - A name of the registry key. 
          valname - The name of the value being written.
          val - The arrays of strings being written.
          ret - The array of strings all the created keys will be written to. /
                It can be 0.
*
* Return: $$[regsetret]
*
-----------------------------------------------------------------------------*/

func uint regsetmultistr( uint root, str subkey, str valname, arrstr val, 
                         arrstr ret  )
{
   buf bmulti
   
   //bmulti.setmultistr( val )
   val.setmultistr( bmulti )
   return bmulti.regset( root, subkey, valname, $REG_MULTI_SZ, ret )
}

/*-----------------------------------------------------------------------------
* Id: reggetmultistr F
* 
* Summary: Getting a string sequence. Get the value of a registry key of 
           the $REG_MULTISZ type into a string array.
*  
* Params: root - A root key. $$[regroot] 
          subkey - A name of the registry key. 
          valname - A name of the specified key value.
          val - The array strings are written to.
*
* Return: #lng/retpar( val )
*
-----------------------------------------------------------------------------*/

func arrstr reggetmultistr( uint root, str subkey, str valname, arrstr val )
{
   buf   bmulti
   uint  regtype

   val.clear()
   bmulti.regget( root, subkey, valname, &regtype )
      
   if regtype == $REG_MULTI_SZ || regtype == $REG_SZ || 
      regtype == $REG_EXPAND_SZ
   {
      bmulti.getmultistr( val )
   }
   
   return val
}

func uint regenum( uint root, str subkey, arrstr ret, uint enumtype )
{
   uint hkey index size
   filetime ft
   str      stemp
   
   subfunc int enum
   {
      if enumtype
      {
         return RegEnumValue( hkey, index++, stemp.ptr(), &size, 0, 0, 
                            0, 0 )      
      }
      return RegEnumKeyEx( hkey, index++, stemp.ptr(), &size, 0, 0, 
                              0, ft )      
   }
   
   ret.clear()
   if RegOpenKeyEx( root, subkey.ptr(), 0, $KEY_READ | g_regflag, &hkey )
   {
      return 0
   }
   size = 512
   stemp.reserve( size )
   
   while enum() != $ERROR_NO_MORE_ITEMS 
   {
      stemp.setlenptr()
      ret += stemp
      size = 512
   }
   RegCloseKey( hkey )
   return 1
}

/*-----------------------------------------------------------------------------
* Id: regkeys F
* 
* Summary: Getting the list of keys.
*  
* Params: root - A root key. $$[regroot] 
          subkey - A name of the registry key. 
          ret - The array the names of the keys will be written to. 
*
* Return: #lng/retf#
*
-----------------------------------------------------------------------------*/

func uint regkeys( uint root, str subkey, arrstr ret )
{
   return regenum( root, subkey, ret, 0 )
}

/*-----------------------------------------------------------------------------
* Id: regvalues F
* 
* Summary: Getting the list of values in a key.
*  
* Params: root - A root key. $$[regroot] 
          subkey - A name of the registry key. 
          ret - The array the names of values in the keys will be written to. 
*
* Return: #lng/retf#
*
-----------------------------------------------------------------------------*/

func uint regvalues( uint root, str subkey, arrstr ret )
{
   return regenum( root, subkey, ret, 1 )
}

/*-----------------------------------------------------------------------------
* Id: regdelkey F
* 
* Summary: Deleting a registry key.
*  
* Params: root - A root key. $$[regroot] 
          subkey - The name of the registry key being deleted. 
*
* Return: #lng/retf#
*
-----------------------------------------------------------------------------*/

func uint regdelkey( uint root, str subkey )
{
   arrstr keys
   uint  i
   str   stemp
   
   if !regkeys( root, subkey, keys )
   {
      return 0
   }
   fornum i, *keys
   {
      stemp = subkey
      if !regdelkey( root, stemp.faddname( keys[ i ] )) : return 0
   }
   if g_regflag & $KEY_WOW64_64KEY
   {
      return !RegDeleteKeyEx( root, subkey.ptr(), g_regflag, 0 )
   } 
   return !RegDeleteKey( root, subkey.ptr())
}

/*-----------------------------------------------------------------------------
* Id: regdelvalue F
* 
* Summary: Deleting the value of a key.
*  
* Params: root - A root key. $$[regroot] 
          subkey - A name of the registry key.
          value - The name of the value being deleted. 
*
* Return: #lng/retf#
*
-----------------------------------------------------------------------------*/

func uint regdelvalue( uint root, str subkey, str value )
{
   uint hkey
   uint result
   
   if !RegOpenKeyEx( root, subkey.ptr(), 0, $KEY_WRITE | g_regflag, &hkey )
   {
      result = !RegDeleteValue( hkey, value.ptr())
      RegCloseKey( hkey )
   }
   return result
}
