/******************************************************************************
*
* Copyright (C) 2004-2007, The Gentee Group. All rights reserved. 
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
* Id: csv L "CSV"
* 
* Summary: Working with CSV data. Variables of the #b(csv) type allow you to
           work with data in the csv format.#p[
#b('string1_1,"string1_2",string1_3#br#
string2_1,"string2_2",string2_3')]
           The #b(csv) type is inherited from #b(str) type. So, you can use
           #a(string, string methods and operators).
           For using this library, it is required to specify the file 
           csv.g (from lib\csv subfolder) with include command. #srcg[
|include : $"...\gentee\lib\csv\csv.g"]   
*
* List: *#lng/opers#,csv_opfor, 
        *#lng/methods#,csv_append,csv_clear,csv_read,csv_settings,csv_write
* 
-----------------------------------------------------------------------------*/

type csvfordata <inherit=fordata>
{
   arrstr lst
   uint   flgeof
}

type csv <inherit=str index=arrstr> //Основная структура csv
{ 
   byte csepar          //Символ разделитель, по умолчанию ;
   byte copen           //Символ начала элемента, по умолчанию " 
   byte cclose          //Символ конца элемента, по умолчанию "   
}

method csv csv.init()
{
   this.copen = this.cclose = '"'
   this.csepar = ','  
   return this
} 

/*-----------------------------------------------------------------------------
* Id: csv_settings F2
*
* Summary: Set separating and limiting characters for csv data.
*
* Params: separ - Separator. Comma by default. 
          open - The left limiting character. Double quotes by default. 
          close - The right limiting character. Double quotes by default. 
*
-----------------------------------------------------------------------------*/

method csv.settings( uint separ, uint open, uint close )
{
   this.csepar = separ
   this.copen  = open
   this.cclose = close      
}

define //Флаги текущего состояния
{
   CSVP_OPEN      = 0x01
   CSVP_READ      = 0x02
   CSVP_LASTCLOSE = 0x04
   CSVP_LASTR     = 0x08
   CSVP_ENDITEM   = 0x10
   CSVP_ENDLINE   = 0x20
   CSVP_NOADD     = 0x40
}

method uint csv.proc( csvfordata fd )
{
   byte c
   uint i
   uint flg
   i = 0 
    
   if fd.icur >= *this : return 1  
   while 1
   {
      if !flg
      {
         if i >= *fd.lst : fd.lst.expand( 5 )
         fd.lst[i].clear()           
      }
      if fd.icur < *this->str 
      {
         c = this->str[fd.icur++]
         if !flg && c == this.copen : flg = $CSVP_READ | $CSVP_OPEN | $CSVP_NOADD
         else
         {
            switch c
            {
               case this.cclose
               {
                  if flg & $CSVP_LASTCLOSE : flg &= ~$CSVP_LASTCLOSE
                  else : flg |= $CSVP_LASTCLOSE | $CSVP_NOADD
               }
               case this.csepar
               {
                  if !(flg & $CSVP_OPEN) || flg & $CSVP_LASTCLOSE 
                  { 
                     flg |= $CSVP_ENDITEM | $CSVP_NOADD
                  }
               }
               case 0x0A
               {
                  if !(flg & $CSVP_OPEN) || flg & $CSVP_LASTCLOSE
                  {
                     flg |= $CSVP_ENDITEM | $CSVP_NOADD | $CSVP_ENDLINE
                  }
               }
               case 0x0D
               {
                  if !(flg & $CSVP_OPEN) || flg & $CSVP_LASTCLOSE 
                  {
                     flg |= $CSVP_ENDITEM | $CSVP_NOADD | $CSVP_ENDLINE | $CSVP_LASTR
                  }         
               }
               default
               {
                  if flg & $CSVP_LASTCLOSE 
						{
							fd.lst[i].appendch( this.cclose )
							flg &= ~$CSVP_LASTCLOSE
						}
               }
            }
         }
      }
      else 
      {
         flg |= $CSVP_NOADD | $CSVP_ENDITEM | $CSVP_ENDLINE
      }
      if !flg: flg = $CSVP_READ

      if flg & $CSVP_NOADD : flg &= ~$CSVP_NOADD
      else : fd.lst[i].appendch( c ) 
      if flg & $CSVP_ENDITEM
      {
         i++
         if flg & $CSVP_ENDLINE 
         {
            if !(flg & $CSVP_OPEN) && flg & $CSVP_LASTCLOSE
            {
               fd.lst[i].appendch( this.cclose )
            }
            if flg & $CSVP_LASTR && 
               fd.icur < *this->str && 
               this->str[fd.icur] == 0x0A : fd.icur++
            break
         }
         flg = 0
      }

   }
   fd.lst.cut( i )
   return 0   
}

/*-----------------------------------------------------------------------------
* Id: csv_opfor F5
*
* Summary: Foreach operator. Looking through all items with the help of the
           #b(foreach) operator. An element in an object of the #b(csv) type 
           is an array of strings #b(arrstr). Each string is split into 
           separate elements by the separator and these elements are 
           written into the passed array.#srcg[
|csv mycsv 
|uint i k 
|... 
|foreach item, mycsv 
|{ 
|   print( "Item: \(++i)\n" ) 
|   fornum k = 0, *item 
|   { 
|      print( "\(item[k])\n") 
|   } 
|}]
*  
* Title: foreach var,csv
*
* Define: foreach variable,csv {...}
* 
-----------------------------------------------------------------------------*/

method uint csv.next( csvfordata fd )
{      
   fd.flgeof = this.proc( fd )
   return &fd.lst
}

method uint csv.first( csvfordata fd )
{   
   fd.icur = 0
   fd.flgeof = this.proc( fd )      
   return &fd.lst
}

method uint csv.eof( csvfordata fd )
{  
   return fd.flgeof    
}

/*-----------------------------------------------------------------------------
* Id: csv_append F2
*
* Summary: Adds a string to a csv object. 
*
* Params: arrs - The array of strings containing the elements of a string. /
                 All strings will be combined into one record and added to /
                 the #b(csv) object.     
*
-----------------------------------------------------------------------------*/

method csv.append( arrstr arrs )
{
   uint i, j
   
   fornum i=0, *arrs
   {
      if i : this->str.appendch( this.csepar )
      this->str.appendch( this.copen )
      fornum j=0, *arrs[i]
      {
         this->str.appendch( (arrs[i])[j] )
         if (arrs[i])[j] == this.cclose 
         {
            this->str.appendch( (arrs[i])[j] )            
         } 
      }
      this->str.appendch( this.cclose )
   }
   this->str += "\l"   
}

/*-----------------------------------------------------------------------------
* Id: csv_read F2
* 
* Summary: Read data from a csv file.
* 
* Params: filename - Filename.
*
* Return: The size of the read data. 
*
* Define: method uint csv.read( str filename ) 
*
-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
* Id: csv_write F2
* 
* Summary: Writing csv data to a file. 
*  
* Params: filename - The name of the file for writing. If the file already /
                     exists, it will be overwritten. 
* 
* Return: The size of the written data.
*
* Define: method uint csv.write( str filename ) 
*
-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
* Id: csv_clear F3
* 
* Summary: Clear the csv data object. 
*  
* Define: method uint csv.clear() 
*
-----------------------------------------------------------------------------*/

//-----------------------------------------------------------------------------
