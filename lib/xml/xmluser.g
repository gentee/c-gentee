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
* Id: xml_getroot F3
*
* Summary: Gets the root item of the XML document tree. Actually, a root item
           contains all items of an XML document tree only. 
*
* Return: Returns a root item.  
*
-----------------------------------------------------------------------------*/

method xmlitem xml.getroot()
{
   return this.tags[0]  
}

/*-----------------------------------------------------------------------------
* Id: xmlitem_getnext F3
*
* Summary: Gets the next item. However, the next item must be searched 
           through the items with the same parent item. 
*
* Return: Returns the next item or zero, if the item is the last item.  
*
-----------------------------------------------------------------------------*/

method xmlitem xmlitem.getnext()
{     
   return ?( this.nnext, this.xml->xml.tags[this.nnext], 0->xmlitem ) 
}

/*-----------------------------------------------------------------------------
* Id: xmlitem_getnexttext F3
*
* Summary: Gets the next text item. This method is similar to the
           #a(xmlitem_getnext) method, but if the next item is not a text item, 
           this operation repeats.
*
* Return: Returns the next text item or zero, if the item is the last item. 
*
-----------------------------------------------------------------------------*/

method xmlitem xmlitem.getnexttext()
{   
   uint cur = &this      
   while (cur = &cur->xmlitem.getnext()) && !(cur->xmlitem.tgtype & $TG_TEXT) :   
   return cur->xmlitem
}

/*-----------------------------------------------------------------------------
* Id: xmlitem_getnexttag F3
*
* Summary: Gets the next tag item. This method is similar to the
           #a(xmlitem_getnext) method, but if the next item is not a tag 
           item, this operation repeats.
*
* Return: Returns the next tag item or zero, if the item is the last item. 
*
-----------------------------------------------------------------------------*/

method xmlitem xmlitem.getnexttag
{
   uint cur = &this   
   while (cur = &cur->xmlitem.getnext()) && !(cur->xmlitem.tgtype & $TG_TAG) :   
   return cur->xmlitem
}

/*-----------------------------------------------------------------------------
* Id: xmlitem_getchild F3
*
* Summary: Gets the first child item of the current item.
*
* Return: Returns the child item or zero, if the item does not contain any 
          child items. 
*
-----------------------------------------------------------------------------*/

method xmlitem xmlitem.getchild()
{   
   return ?( this.nchild, this.xml->xml.tags[this.nchild], 0->xmlitem )   
}

/*-----------------------------------------------------------------------------
* Id: xmlitem_getchildtag F3
*
* Summary: Gets the first child tag item. This method is similar to the
           #a(xmlitem_getchild) method; however, if the child item is not a 
           tag item, in this case, the tag item that comes first is searched
           through the child items. 
*
* Return: Returns the child tag item or zero, if the item does not contain 
          any child tag items.   
*
-----------------------------------------------------------------------------*/

method xmlitem xmlitem.getchildtag()
{  
   uint cur = &this.getchild()   
   if cur && !(cur->xmlitem.tgtype & $TG_TAG) : cur = &cur->xmlitem.getnexttag()       
   return cur->xmlitem      
}

/*-----------------------------------------------------------------------------
* Id: xmlitem_getchildtext F3
*
* Summary: Gets the first child text item. This method is similar to the
           #a(xmlitem_getchild) method; however, if the child item is not a 
           text item, in this case, the text item that comes first is 
           searched through the child items. 
*
* Return: Returns the child text item or zero, if the item does not contain 
          any child text items. 
*
-----------------------------------------------------------------------------*/

method xmlitem xmlitem.getchildtext()
{
   uint cur = &this.getchild()         
   if cur && !(cur->xmlitem.tgtype & $TG_TEXT)
   { 
      cur = &cur->xmlitem.getnexttext()
   }
   return cur->xmlitem     
}

/*-----------------------------------------------------------------------------
* Id: xmlitem_getparent F3
*
* Summary: Gets the parent item of the current item.
*
* Return: Returns the parent item or zero, if the current item is the 
          root item.  
*
-----------------------------------------------------------------------------*/

method xmlitem xmlitem.getparent()
{
   if &this != &this.xml->xml.tags[0]
   {
      return this.xml->xml.tags[this.nparent]
   }
   return 0->xmlitem
}

method xml.gettext( str result, uint start, uint end )
{
   uint i
   uint tx
   fornum i = start, end 
   {      
      tx = &this.texts[i]
      tx as xtext      
      switch tx.txtype
      {
         case $TX_TEXT : result.append( tx.txaddr_code, tx.txlen )
         case $TX_SYMBOL : result.appendch( tx.txaddr_code )
         case $TX_ENTITY 
         {                        
            if tx.txaddr_code 
            {
               result += this.names[tx.txaddr_code->uint]
            } 
         }
      }  
   }  
   if .encoding == 1
   {
      ustr tmp
      tmp.fromutf8( result )
      result = tmp
   }
}

/*-----------------------------------------------------------------------------
* Id: xmlitem_gettext F2
*
* Summary: Gets a text of the current item in the XML tree. This method is
           applied either to a text item or a tag item, in the latter case, 
           the text is obtained from the child text item.
*
* Params: result - Result string. 
* 
* Return: Returns the string that contains the text of the item. If no text 
          has been found, it returns an empty string. 
*
-----------------------------------------------------------------------------*/

method str xmlitem.gettext( str result )
{
   uint cur = &this
   //result.clear()   
   if cur->xmlitem.tgtype & $TG_TAG 
   {      
      cur = &cur->xmlitem.getchildtext()      
   }   
   if cur && cur->xmlitem.tgtype & $TG_TEXT
   {
      cur->xmlitem.xml->xml.gettext( result, cur->xmlitem.tgstart, 
                                     cur->xmlitem.tgend )       
   }   
   return result
}

/*-----------------------------------------------------------------------------
* Id: xmlitem_chtag F2
*
* Summary: Gets a tag item with the help of a "path". Searches through the XML
           tree for a tag item with the help of the specified "path". 
           A "path" consists of tag names separated by the '/' character, 
           if the first character in a path is the '/' character, the item
           search begins from the tree root; otherwise - 
           from the current item. 
*
* Params: path - Path of the item.  
* 
* Return: Returns the item obtained or zero, if no item has been found.  
*
-----------------------------------------------------------------------------*/

method xmlitem xmlitem.chtag( str path )
{  
   arrstr apath 
   uint id   
   uint i, cur = &this
   path.split( apath, '/', $SPLIT_QUOTE )
   if *apath[i] : i=0
   else
   { 
      i=1
      cur = &cur->xmlitem.xml->xml.getroot()
   }
   fornum i, *apath
   {      
      id = cur->xmlitem.xml->xml.hnames[apath[i]]      
      cur = &cur->xmlitem.getchildtag()      
      while cur && cur->xmlitem.tgid != id 
      {           
         cur = &cur->xmlitem.getnexttag()         
      } 
      if !cur : break
   } 
   return cur->xmlitem
}

method xmlitem xmlitem.findid( uint id )
{
   uint cur = &this
   uint finded 
   
   cur = &cur->xmlitem.getchildtag()      
   while cur && cur->xmlitem.tgid != id 
   {           
      finded = &cur->xmlitem.findid( id )
      if finded
      {
         return finded->xmlitem 
      }
      cur = &cur->xmlitem.getnexttag()         
   }
   return cur->xmlitem
}
 
/*-----------------------------------------------------------------------------
* Id: xmlitem_findtag F2
*
* Summary: Search for a tag item by the name. Searches through the XML tree 
           for a tag item with the specified name. The item is searched
           recursively through all child items.
*
* Params: name - Name of the required tag.  
* 
* Return: Returns the item obtained or zero, if no item has been found.  
*
-----------------------------------------------------------------------------*/

method xmlitem xmlitem.findtag( str name )
{  
   return this.findid( this.xml->xml.hnames[name] )  
}

/*-----------------------------------------------------------------------------
* Id: xmlitem_getattrib F2
*
* Summary: Gets a tag item attribute value. 
*
* Params: name - Attribute name. 
          result - Result string. 
* 
* Return: Returns the string that contains the attribute value. If no 
          attribute has been found, it returns an empty string.   
*
-----------------------------------------------------------------------------*/

method str xmlitem.getattrib( str name, str result )
{
   uint i
   uint id    
   result.clear()
   if this.tgtype & $TG_TAG
   {
      id = this.xml->xml.hnames[ name ]
      fornum i = this.tgstart, this.tgend
      {
         if this.xml->xml.attribs[i].attid == id 
         {
            this.xml->xml.gettext( result, this.xml->xml.attribs[i].attstart, 
                  this.xml->xml.attribs[i].attend )
            break
         }
      }  
   }
   return result
}

/*-----------------------------------------------------------------------------
* Id: xmlitem_istext F3
*
* Summary: Determines if the current item is a text item.  
* 
* Return: Returns nonzero if the item is a text item; otherwise, it returns
          zero.  
*
-----------------------------------------------------------------------------*/

method uint xmlitem.istext()
{
   return this.tgtype & $TG_TEXT
}

/*-----------------------------------------------------------------------------
* Id: xmlitem_istag F3
*
* Summary: Determines if the current item is a tag item.
* 
* Return: Returns nonzero if the item is a tag item; otherwise, it returns 
          zero. 
*
-----------------------------------------------------------------------------*/

method uint xmlitem.istag()
{
   return this.tgtype & $TG_TAG
}

/*-----------------------------------------------------------------------------
* Id: xmlitem_isemptytag F3
*
* Summary: Determines if the item is an empty tag item. Determines if the
           current item is a tag item, that contains no child items 
           #b(#lgt[tag .../]);. 
* 
* Return: Returns nonzero if the item is a tag item, that contains no child
          items; otherwise, it returns zero.  
*
-----------------------------------------------------------------------------*/

method uint xmlitem.isemptytag()
{
   return this.tgtype == $TG_NOCHILD
}

/*-----------------------------------------------------------------------------
* Id: xmlitem_ispitag F3
*
* Summary: Checks if the item is a tag processing instruction. Determines if 
           the current item is a tag of processing instruction
           #b(#lgt[?tag ...?]).  
* 
* Return: Returns nonzero if the item is a tag of processing instruction,
          otherwise, it returns zero. 
*
-----------------------------------------------------------------------------*/

method uint xmlitem.ispitag()
{
   return this.tgtype == $TG_QUEST
}

/*-----------------------------------------------------------------------------
* Id: xml_addentity F2
*
* Summary: Adds an entity description. The entity must have been described
           before the gettext method is called. Below you can see the list 
           of entities described by default:#br#
&amp;amp; - #b(&);#br#
&amp;quot; - #b('"');#br#
&amp;apos; - #b("'");#br#
&amp;gt; - #b(&gt;);#br#
&amp;lt; - #b(&lt;);#br#
*
* Params: key - Key (an entity name - #b(&entity_name;) ).  
          value - Entity value is a string that will be pasted into the text. 
*
-----------------------------------------------------------------------------*/

method xml.addentity( str key, str value )
{   
   uint n = *this.names
   this.names.expand( 1 )
   this.names[n] = value
   this.hentities[key] = n   
}

/*-----------------------------------------------------------------------------
* Id: xmlitem_getname F2
*
* Summary: Gets the name of the XML item. 
*
* Params: res - Result string. 
* 
* Return: #lng/retpar( res )  
*
-----------------------------------------------------------------------------*/

method str xmlitem.getname( str res )
{
   res = this.xml->xml.names[this.tgid]
	return res
} 
//-----------------------------------------------------------------

method  xmltags  xmlitem.tags( xmltags tags )
{
   tags.parent = &this
//   tags.cur = 0
   return tags
}


/*-----------------------------------------------------------------------------
* Id: xml_opfor F5
*
* Summary: Foreach operator. Looking through all items with the help of the
           #b(foreach) operator. Defining an optional variable of the 
           #b(xmltags) type is required. The foreach statement is used for
           variables of the #b(xmlitem) type and goes through all child tag
           items of the current tag.#srcg[
|xmltags xtags
|xmlitem curtag
|...
|foreach xmlitem cur, curtag.tags( xtags )
|{
|   ...
|}]
*  
* Title: foreach var,xmlitem
*
* Define: foreach variable,xmlitem.tags( xmltags ) {...}
* 
-----------------------------------------------------------------------------*/

method uint xmltags.eof( fordata tfd )
{
   //return !this.cur
   return !tfd.icur
}

method uint xmltags.next( fordata tfd )
{
   /*if !this.cur : return 0
   this.cur = &this.cur->xmlitem.getnexttag()    
   return this.cur*/
   if !tfd.icur : return 0
   tfd.icur = &tfd.icur->xmlitem.getnexttag()    
   return tfd.icur
}

method uint xmltags.first( fordata tfd )
{
   /*this.cur = &this.parent->xmlitem.getchildtag()
   return this.cur*/
   tfd.icur = &this.parent->xmlitem.getchildtag()
   return tfd.icur
}


/*-----------------------------------------------------------------------------
* Id: xml_opfor F5
*
* Summary: Foreach operator. Looking through all items with the help of the
           #b(foreach) operator. Defining an optional variable of the 
           #b(xmltags) type is required. The foreach statement is used for
           variables of the #b(xmlitem) type and goes through all child tag
           items of the current tag.#srcg[
|xmltags xtags
|xmlitem curtag
|...
|foreach xmlitem cur, curtag.tags( xtags )
|{
|   ...
|}]
*  
* Title: foreach var,xmlitem
*
* Define: foreach variable,xmlitem.tags( xmltags ) {...}
* 
-----------------------------------------------------------------------------


type xmlattribs <index = str>
{        
   uint   item
}

method  xmlattribs  xmlitem.tags( xmlattribs attribs )
{
   tags.parent = &this
//   tags.cur = 0
   return attribs
}

method uint xmlattribs.eof( fordata tfd )
{
   return tfd.icur >= this.item.tgend
}

method uint xmlattribs.next( fordata tfd )
{
   if tfd.icur == this.item.tgend : return 0
   tfd.icur++    
   return tfd.icur
}
/*fornum i = this.tgstart, this.tgend
      {
         if this.xml->xml.attribs[i].attid == id 
         {
            this.xml->xml.gettext( result, this.xml->xml.attribs[i].attstart, 
                  this.xml->xml.attribs[i].attend )
            break
         }
      }
method uint xmlattribs.first( fordata tfd )
{
   tfd.icur = this.tgstart
   return tfd.icur
}*/