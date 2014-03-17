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
* Id: xml L "XML"
* 
* Summary: XML file processing. This library is used for XML file processing 
           and XML tree building. Neither a multibyte-character set nor a
           document type description #b(#lgt[!DOCTYPE .....]) are handled in 
           the current version. For using this library, it is required to
           specify the file xml.g (from lib\xml subfolder) with include 
           command. #srcg[
|include : $"...\gentee\lib\xml\xml.g"]   
*
* List: *,xml_desc,
        *#lng/opers#,xml_opfor, 
        *#lng/methods#,xml_addentity,xml_getroot,xml_procfile,xml_procstr,
        *Methods of XML tree items,xmlitem_chtag,xmlitem_findtag,
        xmlitem_getattrib,xmlitem_getchild,xmlitem_getchildtag,
        xmlitem_getchildtext,xmlitem_getname,xmlitem_getnext,
        xmlitem_getnexttag,xmlitem_getnexttext,xmlitem_getparent,
        xmlitem_gettext,xmlitem_isemptytag,
        xmlitem_ispitag,xmlitem_istag,xmlitem_istext
* 
-----------------------------------------------------------------------------*/

define
{
   NUMSYM = 256
}

type posb
{
   byte state
   byte afunc
   byte retstate
}

type pos
{
   int   state
   uint  afunc
   int   retstate
   uint  r
}

operator pos = ( pos l, posb r)
{
   l.state = r.state
   l.afunc = r.afunc   
   l.retstate = r.retstate
   return l
}

define {
   TG_TEXT   = 0x01  //Текст (в tgstart номер начального текста, в tgend номер конечного текста)
   TG_TAG    = 0x10  //Тэг (в tgid идентификатор имени, в tgstart номер начального атрибута, в tgend номер конечного атрибута)
   TG_QUEST  = 0x12  //<? ?>
   TG_NOCHILD = 0x14   //< />
   
   TX_TEXT   = 0x01   //Просто текст    
   TX_SYMBOL = 0x02   //Символ, в txaddr_code код вставляемого символа 
   TX_ENTITY = 0x03   //Сущность, в txaddr_code код имени сущности в хэш таблице сущностей 
}
//Элемент дерева разбора текст или тэг
type xmlitem {
   byte tgtype  //Тип элемента TG_*
   uint tgid    //Идентфикатор имени тэга в хэш таблице тэгов   
   uint tgstart //Номер начального атрибута/текста в таблице атрибутов/текстов 
   uint tgend   //Номер конечного+1 атрибута/текста в таблице атрибутов/текстов   
   uint nparent //Номер тэга владельца 
   uint nnext   //Номер следующего тэга  
   uint nchild  //Номер первого потомка  
   uint xml      
}

type xmltags <index = xmlitem>
{        
   uint   parent
   //uint   cur
}


//Элемент массива атрибутов
type xattrib {
   uint attid     //Идентификатор имени атрибута
   uint attstart  //Номер начального текста(значение атрибута) в таблице текстов
   uint attend    //Номер конечного текста(значение атрибута) в таблице текстов
}

//Элемент массива текстов
type xtext {
   uint txtype       //Тип текста TX_*
   uint txaddr_code  //Адрес начала исходного текста/код символа/код имени сущности
   uint txlen        //Длина исходного теста
}

//Объект разбора xml текста
type xml
{
   buf  src                //Исходный текст
   arr  tags of xmlitem      //Массив/дерево тэгов
   arr  attribs of xattrib //Массив сущностей
   arr  texts of xtext     //Массив текстов      
   hash hnames             //Хэш таблица имён тэгов   
   arr  names of str       //Таблица строк для хэш таблицы hnames   
   hash hentities          //Хэш таблица имён сущностей
   uint err
   uint encoding           //1 - utf8
   
   hash hrealtime
}

global 
{
   arr  tp[1,256] of pos
         
   uint X_ia
   uint X_curtag, X_curtext, X_curattrib 
   uint X_ncurtag, X_nparenttag, X_ncurtext, X_ncurattrib
   uint X_maxtag, X_maxattrib, X_maxtext, X_maxstack   
   arr  X_stacktags of uint
   uint X_nstack
   uint X_curnameoff
   uint X_x   
   buf  X_tblsrc = '\<sp.tbl>'   
   str  X_sname
   uint X_n, X_tparenttag  
   
   uint hrealtime 
}

include {
   "xmlfuncs.g"
   "xmluser.g"
}

func xmlinit<entry>()
{
   uint i,j
   arr ar[0,$NUMSYM] of posb   
   ar->buf = X_tblsrc//.read( "sp.X_tblsrc" )
   tp.expand( (*ar/$NUMSYM)*256 )
   fornum i=0, *ar/$NUMSYM
   {
      fornum j=0, $NUMSYM
      {
         tp[i+1,j] = ar[i,j]
         if ar[i,j].state && ar[i,j].state !=-1
         {
            tp[i+1,j].state <<= 12
            tp[i+1,j].state += tp.ptr()
         }         
         if ar[i,j].retstate && ar[i,j].retstate !=-1
         {
            tp[i+1,j].retstate <<= 12
            tp[i+1,j].retstate += tp.ptr()
         }
         switch ar[i,j].afunc 
         {
            case 1   : tp[i+1,j].afunc = &f_begent
            case 2   : tp[i+1,j].afunc = &f_endent  
            case 3   : tp[i+1,j].afunc = &f_endentnum
            case 4   : tp[i+1,j].afunc = &f_endenthex
            case 5   : tp[i+1,j].afunc = &f_begatrval
            case 6   : tp[i+1,j].afunc = &f_endatrval
            case 7   : tp[i+1,j].afunc = &f_begquest
            case 8   : tp[i+1,j].afunc = &f_endquest
            case 9   : tp[i+1,j].afunc = &f_endtagname
            case 10  : tp[i+1,j].afunc = &f_begatr
            case 11  : tp[i+1,j].afunc = &f_endatr
            case 12  : tp[i+1,j].afunc = &f_begtag
            case 13  : tp[i+1,j].afunc = &f_endtag
            case 14  : tp[i+1,j].afunc = &f_endtagend  
            case 15  : tp[i+1,j].afunc = &f_begendtag  
            case 16  : tp[i+1,j].afunc = &f_begendtagend
            case 17  : tp[i+1,j].afunc = &f_begcdata  
            case 18  : tp[i+1,j].afunc = &f_endcdata            
            case 255 : tp[i+1,j].afunc = &f_error                     
         }  
      }
   }   
}

method xml.init()
{
/*   uint i,j
   arr ar[0,$NUMSYM] of posb   
   ar->buf = X_tblsrc//.read( "sp.X_tblsrc" )
   tp.expand( (*ar/$NUMSYM)*256 )
   fornum i=0, *ar/$NUMSYM
   {
      fornum j=0, $NUMSYM
      {
         tp[i+1,j] = ar[i,j]
         if ar[i,j].state && ar[i,j].state !=-1
         {
            tp[i+1,j].state <<= 12
            tp[i+1,j].state += tp.ptr()
         }         
         if ar[i,j].retstate && ar[i,j].retstate !=-1
         {
            tp[i+1,j].retstate <<= 12
            tp[i+1,j].retstate += tp.ptr()
         }
         switch ar[i,j].afunc 
         {
            case 1   : tp[i+1,j].afunc = &f_begent
            case 2   : tp[i+1,j].afunc = &f_endent  
            case 3   : tp[i+1,j].afunc = &f_endentnum
            case 4   : tp[i+1,j].afunc = &f_endenthex
            case 5   : tp[i+1,j].afunc = &f_begatrval
            case 6   : tp[i+1,j].afunc = &f_endatrval
            case 7   : tp[i+1,j].afunc = &f_begquest
            case 8   : tp[i+1,j].afunc = &f_endquest
            case 9   : tp[i+1,j].afunc = &f_endtagname
            case 10  : tp[i+1,j].afunc = &f_begatr
            case 11  : tp[i+1,j].afunc = &f_endatr
            case 12  : tp[i+1,j].afunc = &f_begtag
            case 13  : tp[i+1,j].afunc = &f_endtag
            case 14  : tp[i+1,j].afunc = &f_endtagend  
            case 15  : tp[i+1,j].afunc = &f_begendtag  
            case 16  : tp[i+1,j].afunc = &f_begendtagend
            case 17  : tp[i+1,j].afunc = &f_begcdata  
            case 18  : tp[i+1,j].afunc = &f_endcdata            
            case 255 : tp[i+1,j].afunc = &f_error                     
         }  
      }
   }*/    
}

method uint xml.process( )
{   
   //print( "process\n" )
   uint off
   arr  ars[512] of uint
   uint state, retstate
   uint afunc
   
   state = tp.ptr() + (1 << 12)   
   //Инициализация
   if X_x: return 0
   X_x = &this   
   this.err = 0
   this.encoding = 0
   this.hnames.clear()
   this.hentities.clear()
   this.tags.clear()
   this.texts.clear()      
   this.names.clear()   
   this.attribs.clear()
   
   this.hnames.ignorecase()
   this.hentities.ignorecase()
   //this.names.reserve(100)
   uint lim 
   if *this.hrealtime : lim = 100
   else : lim = 1
   this.names.expand(1)   
   X_maxtag = max( *this.src/(10*lim), 100 )
   this.tags.expand( X_maxtag )
   X_maxtext = max( *this.src/(20*lim), 100 )
   this.texts.expand(X_maxtext)
   X_maxattrib = max( *this.src/(40*lim), 100 )
   this.attribs.expand(X_maxattrib)
     
   X_ncurattrib = 0
   X_curattrib = &this.attribs[X_ncurattrib]
   
   X_ncurtext = 0
   X_curtext = &this.texts[X_ncurtext]   
     
   X_ncurtag = 0
   //Корневой элемент
   X_curtag = &this.tags[X_ncurtag]
   X_curtag->xmlitem.tgtype = 0//$TG_TEXT
   X_curtag->xmlitem.nchild = ++X_ncurtag      
   
   //Добавляем тэг заготовку      
   X_curtag = &this.tags[X_ncurtag]
   X_curtag->xmlitem.nchild = 1    
   X_curtag->xmlitem.tgstart = X_ncurtext  
   X_nparenttag = 0
   
   X_ia=this.src.ptr()  
   X_stacktags.clear()
   X_maxstack = 100
   X_stacktags.expand(X_maxstack)
   X_nstack = 0   
   
   //Начать пустой текст
   X_curtext->xtext.txaddr_code = X_ia 
   X_curtext->xtext.txtype = 0  
   
   hrealtime = &(this.hrealtime)    
   uint arrs = ars.ptr()
   
      if !this.err 
      {
         this.addentity("amp","&")
         this.addentity("quot","\"")
         this.addentity("apos","'")
         this.addentity("gt",">")
         this.addentity("lt","<")
      }
   fornum X_ia, this.src.ptr() + *this.src
   {
      //print( "".appendch(X_ia->ubyte) )          
      if afunc = ((off = state + (X_ia->ubyte << 4)) + 4)->uint {
        afunc->func()
      }
      if state = off->uint 
      {               
         if retstate = (off + 8)->uint 
         {
            arrs->uint = retstate
            arrs += 4
         }
         continue     
      }      
      state = (arrs -= 4)->uint      
   }
   if !X_curtext->xtext.txtype && 
      X_curtext->xtext.txaddr_code != X_ia 
   {  //Заканчиваем текст-текст     
      X_curtext->xtext.txlen = X_ia - X_curtext->xtext.txaddr_code 
      X_curtext->xtext.txtype = $TX_TEXT     
      X_curtag->xmlitem.tgtype = $TG_TEXT
      X_curtag->xmlitem.tgend = X_ncurtext + 1             
   }
   this.tags.del(X_ncurtag + 1)
   this.texts.del(X_ncurtext + 1)
   this.attribs.del(X_ncurattrib + 1)
   uint i
   fornum i = 0, *this.tags
   {
      this.tags[i].xml = &this
   }
   X_x = 0
/*   if !this.err 
   {
      this.addentity("amp","&")
      this.addentity("quot","\"")
      this.addentity("apos","'")
      this.addentity("gt",">")
      this.addentity("lt","<")
   }*/
/*   uint qxml as .getroot()->xmlitem.chtag( "/xml" )
   if &qxml
   {      
      str res
      qxml.getattrib( "encoding", res )
      if res %== "utf-8"
      {
         .encoding = 1
      } 
   }*/
   return !this.err
}

method xml.setrealtime( str tagname, uint addrfunc )
{
   .hrealtime[tagname] = addrfunc
}

/*-----------------------------------------------------------------------------
* Id: xml_procfile F2
*
* Summary: Process an XML file. Reads the XML file, the name of which is
           specified as a parameter, and process it.
*
* Params: filename - Name of the file processed.    
*  
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

method uint xml.procfile( str filename )
{
/*arr x of uint
print( "z1\n" )
   //this.tags.expand( 22000000 )
   x.expand( 183943500 )
print( "z2\n" )   
return 0   */
   if this.src.read( filename )
   { 
      return this.process()
   }
   return 0  
}

/*-----------------------------------------------------------------------------
* Id: xml_procstr F2
*
* Summary: Processes a string contained the XML document.
*
* Params: src - XML data string.   
*  
* Return: #lng/retf#  
*
-----------------------------------------------------------------------------*/

method uint xml.procstr( str src )
{
   this.src = src->buf
   return this.process()   
}

/*-----------------------------------------------------------------------------
* Id: xml_desc F1
*
* Summary: A brief description of XML library. Variables of either the #b(xml) 
           and the #b(xmlitem) type (an XML tree item) are used for processing 
           XML documents. An XML tree item can be of two types: a #b(text item) 
           and a #b(tag item). There are several types of tag items: 
#ul[
|tag item that contains other items #b(#lgt[tag ...].....#lgt[/tag]);
|tag item that contains no other items #b(#lgt[tag .../]);
|tag item of processing instruction #b(#lgt[?tag ...?]).
]
#p[A tag item may contain attributes.]

#p[The sequence of operations for processing an XML document:] 
#ul[
process a document (build an XML tree) with the help of the #a(xml_procfile) 
| method or the #a(xml_procstr) method;
|add entity definitions, using the #a(xml_addentity) method if necessary;
search for the required items in the XML tree using the following methods:
 #a(xml_getroot), #a(xmlitem_chtag), #a(xmlitem_findtag), 
| #a(xmlitem_getnext), etc.;
use the #b(foreach) statement in order to process similar elements if
| necessary;
gain access to tag attributes with the help of the #a(xmlitem_getattrib)
| method and get a text using the #a(xmlitem_gettext) method. 
]  
*
* Title: XML description
*
* Define:    
*
-----------------------------------------------------------------------------*/

//----------------------------------------------------------------------------
