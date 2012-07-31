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
* Id: ini L "INI File"
* 
* Summary: INI files. This library allows you to work with ini files. 
           Variables of the ini type allow you to work with them. For using 
           this library, it is required to specify the file ini.g (from
            lib\ini subfolder) with include command. #srcg[
|include : $"...\gentee\lib\ini\ini.g"]    
*
* List: *#lng/methods#,ini_delkey,ini_delsection,ini_getnum,ini_getvalue,
        ini_keys,ini_read,ini_sections,ini_setnum,ini_setvalue,ini_write,
        *#lng/funcs#,inigetval,inisetval
* 
-----------------------------------------------------------------------------*/

type ini {
   str   data
   arrstr lines
   arr    offset of uint
}

/*-----------------------------------------------------------------------------
* Id: ini_read F2
* 
* Summary: Read data from a file.
*  
* Params: filename - The name of the ini file.
*
-----------------------------------------------------------------------------*/

method  ini.read( str filename )
{
   this.data.read( filename )
   this.data.lines( this.lines, 1, this.offset )
}

/*-----------------------------------------------------------------------------
* Id: ini_write F2
* 
* Summary: Save data into an ini file.
*  
* Params: filename - The name of the ini file.
*
* Return: Returns the size of the written data. 
*
-----------------------------------------------------------------------------*/

method uint ini.write( str filename )
{
   return this.data.write( filename )
}

/*-----------------------------------------------------------------------------
* Id: ini_sections F2
* 
* Summary: Getting the list of sections. All sections will be written into 
           an array of strings. 
*  
* Params: ret - The array of strings the names of sections will be written to.
*
* Return: #lng/retpar(ret) 
*
-----------------------------------------------------------------------------*/

method arrstr ini.sections( arrstr ret )
{
   uint end
   
   ret.clear()
   foreach cur, this.lines
   {
      if cur[ 0 ] == '['
      {
         end = 1
         while cur[ end ] && cur[ end ] != ']' : end++
         if cur[ end ] == ']'
         {
            uint ptr = cur.ptr() + 1
            uint len = end - 1
            ptr = trimsys( ptr, &len )
            ret[ ret.expand( 1 ) ].substr( cur, ptr - cur.ptr(), len )
         }
      }
   }            
   return ret
}

method uint ini.range( str section, uint last )
{
   uint from to i
   
   fornum i, *this.lines
   {
      if (this.lines[ i ])[0] == '['
      {
         if from : break

         str name = this.lines[ i ]
         uint right = name.findch( ']' )
         if right < *name : name.setlen( right + 1 )
         name.trim( '[', $TRIM_LEFT | $TRIM_RIGHT | $TRIM_PAIR )
         name.trimsys()
         if name %== section : from = i + 1
      }
   }            
   last->uint = i - 1
   return from
}


/*-----------------------------------------------------------------------------
* Id: ini_getvalue F2
* 
* Summary: Get the value of an entry. 
*  
* Params: section - Section name. 
          key - Key name. 
          value - The string for getting the value. 
          defval - The value to be assigned if the entry is not found. 
*
* Return: Returns 1 if the entry is found and 0 otherwise. 
*
-----------------------------------------------------------------------------*/

method uint ini.getvalue( str section, str key, str value, str defvalue )
{
   uint from to ret i
   arrstr  temp
   
   from = this.range( section, &to )
   if from
   {
      for i = from, i <= to, i++
      {
         this.lines[i].split( temp, '=', $SPLIT_NOSYS | $SPLIT_FIRST | 
                              $SPLIT_EMPTY )
         if *temp == 2 && key %== temp[0]
         {
            value = temp[1]
            ret = i
            break
         }
      }           
   }
   if !from || i > to : value = defvalue

   return ret
}

/*-----------------------------------------------------------------------------
* Id: ini_getnum F2
* 
* Summary: Get the numerical value of an entry.
*  
* Params: section - Section name. 
          key - Key name. 
          defval - The value to be assigned if the entry is not found. 
*
* Return: The numerical value of the key.  
*
-----------------------------------------------------------------------------*/

method uint ini.getnum( str section, str key, uint defvalue )
{
   str  value
   
   if !this.getvalue( section, key, value, "" ) : return defvalue
   
   return uint( value )
}

/*-----------------------------------------------------------------------------
* Id: ini_keys F2
* 
* Summary: Get the list of entries in this section. All entries will be 
           written into an array of strings.  
*  
* Params: section - Section name.
          ret - The array of strings the names of entries will be written to.  
*
* Return: #lng/retpar( ret ) 
*
-----------------------------------------------------------------------------*/

method arrstr ini.keys( str section, arrstr ret )
{
   uint from to i
   arrstr  temp 
 
   ret.clear()
   from = this.range( section, &to )
   
   if from
   {
      for i = from, i <= to, i++
      {
         this.lines[i].split( temp, '=', $SPLIT_NOSYS | $SPLIT_FIRST | 
                              $SPLIT_EMPTY )
         if *temp == 2 && (temp[0])[0] != ';' 
         {
            ret[ ret.expand( 1 )] = temp[0]
         }
      }           
   }   
   return ret
}

/*-----------------------------------------------------------------------------
* Id: ini_setvalue F2
* 
* Summary: Write the value of an entry. 
*  
* Params: section - Section name. 
          key - Key name. 
          value - The value of the entry being written.
*
-----------------------------------------------------------------------------*/

method ini.setvalue( str section, str key, str value )
{
   uint line from to i
   str  stemp
   str  result = "\(key)=\(value)\l"
   
   line = this.getvalue( section, key, stemp, "" )
   if line
   {
      this.data.replace( this.offset[ line ], ?( line == *this.lines - 1, 
                     *this.lines[ line ], 
                     this.offset[ line + 1 ] - this.offset[ line ] ), result )
   }
   else
   {
      from = this.range( section, &to )
      if !from
      {
         this.data += "\l[\(section)]\l\(result)"
      }
      else
      {  // »щем последнюю непустую после которой надо вставл€ть
         while to > from && !*this.lines[ to ] : to--
         if to == *this.lines - 1  // последн€€ строка
         {
            this.data += "\l\(result)"
         }
         else
         {
            this.data.insert( this.offset[ to + 1 ], result )
         }
      }
   }
   this.data.lines( this.lines, 1, this.offset )
}

/*-----------------------------------------------------------------------------
* Id: ini_setnum F2
* 
* Summary: Write the numerical value of an entry. 
*  
* Params: section - Section name. 
          key - Key name. 
          value - The value of the entry being written. 
*
-----------------------------------------------------------------------------*/

method ini.setnum( str section, str key, uint value )
{
   this.setvalue( section, key, str( value ))
}

/*-----------------------------------------------------------------------------
* Id: ini_delsection F2
* 
* Summary: Deleting a section. 
*  
* Params: section - The name of the section being deleted.
*
-----------------------------------------------------------------------------*/

method ini.delsection( str section )
{
   uint from to start
   from = this.range( section, &to )
   if from
   {
      start = this.offset[ from - 1 ]
      this.data.del( start, ?( to == *this.lines - 1, 
                     *this.data - start, this.offset[ to + 1 ] - start ))
      this.data.lines( this.lines, 1, this.offset )
   }  
}

/*-----------------------------------------------------------------------------
* Id: ini_delkey F2
* 
* Summary: Deleting a key. 
*  
* Params: section - Section name. 
          key - The name of the entry being deleted. 
*
-----------------------------------------------------------------------------*/

method ini.delkey( str section, str key )
{
   uint line start
   
   line = this.getvalue( section, key, "", "" )
   if line 
   {
      start = this.offset[ line ]
      this.data.del( start, ?( line == *this.lines - 1, 
                     *this.data - start, this.offset[ line + 1 ] - start ))
      this.data.lines( this.lines, 1, this.offset )
   }
}

/*-----------------------------------------------------------------------------
* Id: inigetval F
* 
* Summary: Get the value of an entry from an ini file.
*  
* Params: ininame - The name of the ini file. 
          section - Section name. 
          key - Key name. 
          value - The string for writing the value. 
          defval - The value that will be inserted in case of an error or /
                   if there is not such an entry. 
*
* Return: #lng/retpar( value )   
*
-----------------------------------------------------------------------------*/

func str inigetval( str ininame, str section, str key, str value, str defval )
{
   ini tini 
   
   tini.read( ininame )
   tini.getvalue( section, key, value, defval )
   return value
}

/*-----------------------------------------------------------------------------
* Id: inisetval F
* 
* Summary: Write the value of an entry into an ini file.
*  
* Params: ininame - The name of the ini file. 
          section - Section name. 
          key - Key name. 
          value - The value of the entry being written. 
*
* Return: #lng\retf#  
*
-----------------------------------------------------------------------------*/
   
func uint inisetval( str ininame, str section, str key, str value )
{
   ini tini 
   
   tini.read( ininame )
   tini.setvalue( section, key, value )
   return tini.write( ininame )
}

