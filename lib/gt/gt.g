/******************************************************************************
*
* Copyright (C) 2006-08, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

define
{
   gt_CHDIV = '/'   // Name divider
}

include
{
//   $"..\stdlib\stdlib.g"
   $"..\lex\lexnew.g" 
   $"..\tree\tree.g"
   "lexgt.g"
   "lexgtdo.g"
}

type gtattrib    
{
   str   name
   str   value
}

type gtitem< index = this >   
{
   str   name
   str   value
   arr   attrib of gtattrib  // Массив данных у объекта
                          // 0 - main object data
   byte  comment          // 1 if the object is comment
   uint  maingt           // owner
   uint  param            // custom parameter
}

type gt<index = gtitem>
{
   uint  lexgt            // Lexical table for gtitem.load
   uint  lexdo             // Lexical table for gtitem.process
   hash  names             // хэш-таблица имен - значения указатели на treeitem
   tree  items of gtitem   // the tree of items
   uint  id                // The latest id
   uint  utf8              // 1 if values are in utf8
}

include : "gtitem.g"

method uint str.isprefutf8
{
   return "п»ї".eqlen( this ) 
}

extern
{
   method gtitem gtitem.inherit( gtitem src )
}

method  gt gtitem.getgt
{
   return this.maingt->gt 
}
/*
property uint gt.utf8
{
   return this.utf8
}

property gt.utf8( uint isutf8 )
{
   this.utf8 = isutf8
}
*/

method gt.clear
{
   this.names.clear()
   this.items.clear()
}

method gtitem gt.find( str objname )
{
   uint result 
   
   result = this.names.find( objname )
   
   if !result : return 0->gtitem
   result = result->uint
   
   return result->treeitem.data()->gtitem
}

method uint gt.find( str objname attr )
{
   uint gti

   gti as this.find( objname )
   if &gti : return gti.find( attr )
   return 0
}

method gtitem gtitem.findrel( str objname )
{
   str  newname
   
   if objname[0] == '/'
   {
      uint i = 1

      if !this.isroot()
      { 
         this.getfullname( newname )
         while objname[i] == '/'
         { 
            newname.setlen( newname.findch( '/', 1 ))
            i++
         }
         newname.appendch( '/' ).append( objname.ptr() + i, *objname - i )
      }
      else : newname.append( objname.ptr() + 1, *objname - 1 )
      
//      print( "NewName = \( newname )\n")
   }
   else : newname = objname
    
   return this.maingt->gt.find( newname )
}

func gtitem_del( treeitem ti )
{
   uint  gtg
   str   name
   
   gtg as ti.data()->gtitem
   gtg.getfullname( name )   
   gtg.maingt->gt.names.del( name )
}

method gtitem.del
{
   uint  gtg
   
   gtg as this.maingt->gt
//   gtg.delitem = 1
   gtg.items.del( this.gettreeitem(), &gtitem_del )
//   gtg.delitem = 0   
}

method gtitem.clear()
{
   while this.gettreeitem().child : this.child().del()  
}


method gtitem gt.root
{
   return this.items.root().data()->gtitem
}

method gt.init
{
   this.names.sethashsize( 15 ) // Размер хэш-таблицы 32000
   this.names.ignorecase()
   this.root().maingt = &this
   this.lexgt = lex_init( 0, lexgt.ptr())
   this.lexdo = lex_init( 0, lexgtdo.ptr())
}

method gt.delete
{
   lex_delete( this.lexgt )
   lex_delete( this.lexdo )
}

method  ustr gt.uval( str value, ustr ret )
{
   return ?( this.utf8, ret.fromutf8( value ), ret = value )
}


method  str gt.get( str objname attrib ret )
{
   uint gti
   
   ret.clear()
   gti as this.find( objname )
   if &gti : gti.get( attrib, ret )
   return ret
}

method  ustr gt.get( str objname attrib, ustr ret )
{
   str  stemp
   
   return this.uval( this.get( objname, attrib, stemp ), ret )
}


method  str gt.get( str objname ret )
{
   uint gti
   
   ret.clear()
   gti as this.find( objname )
   if &gti : ret = gti.value
   return ret
}

method  str gtitem.getobj( str objname, str ret )
{
   uint gti
   
   ret.clear()
   gti as this.findrel( "/\(objname)" )
   if &gti : ret = gti.value
   return ret
}

method  ustr gtitem.getobj( str objname, ustr ret )
{
   str  utf
   
   this.getobj( objname, utf )
   if .maingt->gt.utf8 : ret.fromutf8( utf )
   else : ret = ustr( utf )
   return ret
}

method  str gtitem.getobjutf8( str objname, str ret )
{
   str  utf
   ustr utemp
   
   if .maingt->gt.utf8
   { 
      this.getobj( objname, utf )
      ret = str( utemp.fromutf8( utf ))
   }
   else : this.getobj( objname, ret )
   return ret
}

method  int gtitem.getobjint( str objname )
{
   str stemp
   return int( this.getobj( objname, stemp ))
}

method  ustr gt.get( str objname, ustr ret )
{
   str stemp
   
   return this.uval( this.get( objname, stemp ), ret )
}

method  gtitem gtitem.insertchild( str name, gtitem after )
{
   uint  ret maingt item
   str   fullname idname
   
   if !*name : name = "_"

   maingt as this.maingt->gt 
   
   if name == "_" : idname = "_ \( ++maingt.id )"
   else : idname = name
   
   // Check if gtitem has already had the child with this name
   if this.isroot() : fullname = idname
   else
   {
      this.getfullname( fullname ).appendch( $gt_CHDIV ) += idname
   }
//   print("Findrel = \(name)\n")
   if ( ret as this.findrel( "/\(name )" )) && name != "_" : return ret

//   print("INsert full= \( fullname )\n")
   item as maingt.items.node( this.gettreeitem(), ?( &after  && 
          &after < 0xFFFFFFFF, after.gettreeitem(), after->treeitem ))
   ret as item.data()->gtitem
   ret.maingt = this.maingt  
   ret.name = idname
//   if name == "_" : ret.id = maingt.id  
   maingt.names[ fullname ] = &item
//   print("\(idname) = \(fullname)\n") 
          
   return ret   
}

method  gtitem gtitem.appendchild( str name )
{
   return this.insertchild( name, 0xFFFFFFFF->gtitem )
//   return this.insertchild( name, 0->gtitem ) 
}

method  gtitem gtitem.insertfirstchild( str name )
{
   return this.insertchild( name, 0->gtitem ) 
}

method gtitem gtitem.copy( gtitem src, gtitem after )
{
   uint gti i
   
   gti as this.insertchild( ?( "_ ".eqlen( src.name ), "_" , src.name ), after )
   
   if &gti == &src : return src
   
   gti.value = src.value
   gti.comment = src.comment
//   gti.param = src.param
   gti.attrib.clear()
   
   fornum i, *src.attrib
   {
      uint attr
      
      attr as gti.attrib[ gti.attrib.expand(1) ]
      attr.name = src.attrib[i].name
      attr.value = src.attrib[i].value
   } 
   foreach curg, src
   {
      gti.copy( curg, (-1)->gtitem )
   }   
   return gti->gtitem
} 

method uint gtitem.set( str attrib value )
{
   uint id
   
   if !*attrib : return 0

   if attrib %== "inherit"
   {
      this.inherit( this.getgt().find( value ))
   }   
   if !( id = this.find( attrib )) 
   {
      id = this.attrib.expand( 1 ) + 1  // ??? expand по новому
      this.attrib[ id - 1 ].name = attrib
   }
   if this.getgt().utf8 //&& !value.isutf8()
   {
      ustr  utemp
      utemp = value
//      utemp.toutf8( this.attrib[ id - 1 ].value ) ???
      this.attrib[ id - 1 ].value = value
   }
   else : this.attrib[ id - 1 ].value = value
  
   return id       
}

method uint gtitem.set( str attrib, ustr value )
{
   str  utfval
   
//   if this.getgt().utf8 : value.toutf8( utfval )  ???
//   else : utfval = value
   utfval = value
   return this.set( attrib, utfval )       
}

method uint gtitem.setattrib( str attrib )
{
   return this.set( attrib, "" )
}


method gtitem.setuint( str attrib, uint val )
{
   this.set( attrib, str( val ))
}

include
{ 
   "gtsave.g"
   "gtload.g"
   "gtprocess.g"
}

operator gt += ( gt dest, str in )
{
   dest.root().load( in )
   return dest
}

method gtitem gtitem.inherit( gtitem src )
{
   if !&src : return this
      
   if !*this.value
   {
      this.value = src.value
   }
   foreach attr, src.attrib
   {
      if !this.find( attr.name )
      {
         this.set( attr.name, attr.value )
      }      
   }
   foreach child, src
   {
      uint new
      
      if !&this.findrel("/\( child->gtitem.name )")
      {
         new as this.appendchild( child->gtitem.name )
         new.inherit( child->gtitem )
      }     
   } 
   return this
}

method str gtitem.getsubitem( str name value )
{
   uint  subitem
   
   subitem as this.findrel("/\(name)")
   if &subitem : value = subitem.value
   else : value.clear()
   
   return value       
}

method ustr gtitem.getsubitem( str name, ustr value )
{
   str  stemp   
   return this.getgt().uval( this.getsubitem( name, stemp ), value )  
}

method ustr gtitem.get( str attrib, ustr value )
{
   str    stemp
   return this.getgt().uval( this.get( attrib, stemp ), value )       
}

operator gtitem =( gtitem gti, str val )
{
   if gti.getgt().utf8 //&& !val.isutf8()
   {
      ustr  utemp
      utemp = val
      utemp.toutf8( gti.value )  
   }
   else : gti.value = val   
   return gti
}

operator gtitem =( gtitem gti, ustr val )
{
   if gti.getgt().utf8 : val.toutf8( gti.value )
   else : gti.value = val
     
   return gti
}

operator gt =( gt left, gt right )
{   
   str stemp 
   gtsave gts
   gts.offstep = 3
   right.root().save( stemp, gts )
   left.clear()
   left.root().load( stemp )
   return left
}

method uint gt.eof( fordata tfd )
{
   return !tfd.icur
}

method uint gt.next( fordata tfd )
{
   if !tfd.icur : return 0

   uint icur = tfd.icur 
   
   if tfd.icur = icur->treeitem.child : return tfd.icur->treeitem.data() 
   
   tfd.icur = icur->treeitem.next
   
   if !tfd.icur 
   {
      uint parent
      while 1  
      {
         if !icur->treeitem.parent : return tfd.icur = 0
         parent = icur->treeitem.parent->treeitem.next
         if parent
         {
            tfd.icur = parent
            break
         }
         else
         { 
            icur = icur->treeitem.parent//->treeitem.parent
         }
      }
   } 
   return tfd.icur->treeitem.data()
}

method uint gt.first( fordata tfd )
{
   tfd.icur = this.root().gettreeitem().child
   return tfd.icur->treeitem.data()
}


/*
// Temporary test function
func gtmain<main>
{
   gt     igt
   gtsave gts
   str    stemp
   uint   ni
   arrout  out
//   lex  ilex
   print("Start\n")
   str  in = "/******************* esesesese
   
   seseseseses************** /<- qwe-rty ->
   п»ї<my_gt /asd = \"qwerty sese'\" qq21 = 'dedxd' 'esese;' aqaq=325623/>
   <a asdff /a>
   <mygtdd a = \"AAAparam=&#1; + &#2;\">
       <a = \"param=&#1; + &#2;\"/>
       <-ooops Русский текст->
       <1 a2345=310> 223 mygtt/1</1>
       <ad />< qq &#1;
   </>
    xxx  </r/nm 
   <_aa = \"Oooops data _aa\" aqaqa /_aaaa /_aa>
   <a22222/ >
     <|abc attrib1 = Qqqq>
        <opsew =\"qwer\"/>
     </abc>
     <*aaa = qqqq attr = \"AAA attribute\"></aaa>
      ooops &#1;+&#2;aaa</eee>\"\r\n
   </>
   <11>
      <22>
         <33>
         </>
      </>
      &x3c;edede&x3c;edededeв deв 
   </>"
//   str  data = "qwerty quote" 
     str  data = "qqq &\\
   #mygtdd/a: 
     Ooops #my_gt.asd#, ede,,&\\
 e3e3e3e3e
     :##zzz( #my_gt.asd# ).attrib1#Simple## &#1; &#2;
#mygtdd/1# #qwerty##a22222/aaa.attr#&\\


#a22222( 'qwerty quote  ' \"append\", \"double quote  \" ssxsxsx    )
#a22222( 23, 45 
#mygtdd#aa wswsw \"my string\" )
text#/opsew#=>#//aaa.attr#&xd;&xa;"
   arrstr  par = %{"par1","par2"}
//   arr par of str      
//   par += "par1"
//   par += "par2"      
//   gentee_init()
   out.isize = sizeof( lexitem );

   igt.utf8 = 1   
//   lex_tbl( ilex, tblgt.ptr())
//   gentee_lex( in->buf, ilex, out )
   print("OK 0\n")
   igt.root().load( in )
   print("OK 1\n")
   gts.offstep = 3
   gts.inside = 10
   gts.endname = 1
   ni as igt.root().appendchild("Ooops")
   ni.set("qqq","Value q\"qq")
   
   ni.appendchild("Subitem").value = "<Qw\"ert/y dxd</>xdx"
   igt.root().load( "<1></><2><21></><22></><--2232323 --></><3></>", ni )
   
   igt.root().load( "<_ >
<key label = InstPath1 >InstPath1</>
<varname label = path >path</>
<defval label ></>
</>
<_ >
<key label = InstPath2 >InstPath2</>
<varname label = path >path</>
<defval label ></></>", ni )


//   ni.clear()
   print("OK 0 -------------------\n")
   foreach curg, igt
   {
      print("CUR=\(curg->gtitem.name) \(curg->gtitem.value)\n")  
   }
   print("OK 1 -------------------\n")
   ni as igt.find( "a22222/abc" )
   print( "Find=\(&ni)\n")
   ni.process( data, "", par )
   print( igt.find( "a22222/abc" ).process( data, "", par ))
   print( data )
   print( igt.root().save( stemp, gts ))
   stemp.write("c:\\temp\\gt.txt")
   print( "========\n" + igt.find("a22222").savechildren( "", gts ))
//   lex_init( ilex, 0 )
 //  lex_delete( ilex )
//   gentee_deinit()
   print("Press any key...")
   getch() 
}
*/
