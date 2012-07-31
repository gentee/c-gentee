/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: gt2 17.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

define
{
   gt2_CHDIV = '/'   // Name divider
}

include
{
   $"..\lex\lex.g" 
   $"..\tree2\tree.g"
   "gtitem.g"
   "lexgt.g"
   "lexgtdo.g"
}

type gt2
{
   uint  lexgt2            // Lexical table for gt2item.load
   uint  lexdo             // Lexical table for gt2item.process
   hash  names             // хэш-таблица имен - значения указатели на tree2item
   tree2  items of gt2item   // the tree2 of items
   uint   id                 // The latest id 
}

extern
{
   method gt2item gt2item.inherit( gt2item src )
}

method gt2.clear
{
   this.names.clear()
   this.items.clear()
}

method gt2item gt2.find( str objname )
{
   uint result 
   
   result = this.names.find( objname )
   
   if !result : return 0->gt2item
   result = result->uint
   
   return result->tree2item.data()->gt2item
}

method uint gt2.find( str objname attr )
{
   uint gt2i

   gt2i as this.find( objname )
   if &gt2i : return gt2i.find( attr )
   return 0
}

method gt2item gt2item.findrel( str objname )
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
    
   return this.maingt2->gt2.find( newname )
}

func gt2item_del( tree2item ti )
{
   uint  gtg
   str   name
   
   gtg as ti.data()->gt2item
//   gtg.delitem = 1
   gtg.getfullname( name )   
   gtg.maingt2->gt2.names.del( name )
}

method gt2item.del
{
   uint  gtg

   // Удаляем дочерние элементы
   gtg as this.maingt2->gt2
//   gtg.delitem = 1
   gtg.items.del( this.gettree2item(), &gt2item_del )
//   gtg.delitem = 0   
}

method gt2item gt2.root
{
   return this.items.root().data()->gt2item
}

method gt2.init
{
   this.names.sethashsize( 15 ) // Размер хэш-таблицы 32000
   this.names.ignorecase()
   this.root().maingt2 = &this
   this.lexgt2 = lex_init( 0, lexgt2.ptr())
   this.lexdo = lex_init( 0, lexgtdo.ptr())
}

method gt2.delete
{
   lex_delete( this.lexgt2 )
   lex_delete( this.lexdo )
}

method  str gt2.get( str objname attrib ret )
{
   uint gt2i
   
   ret.clear()
   gt2i as this.find( objname )
   if &gt2i : gt2i.get( attrib, ret )
   return ret
}

method  str gt2.get( str objname ret )
{
   uint gt2i
   
   ret.clear()
   gt2i as this.find( objname )
   if &gt2i : ret = gt2i.value
   return ret
}

method  gt2item gt2item.insertchild( str name, gt2item after )
{
   uint  ret maingt2 item
   str   fullname idname
   
   if !*name : name = "_"
   
   maingt2 as this.maingt2->gt2 
   
   if name == "_" : idname = "_ \( ++maingt2.id )"
   else : idname = name
   // Check if gt2item has already had the child with this name
   if this.isroot() : fullname = idname
   else
   {
      this.getfullname( fullname )
      fullname.appendch( $gt2_CHDIV ) += idname
   }
   if ( ret as this.findrel( "/\(name )" )) && name != "_" : return ret

   item as maingt2.items.node( this.gettree2item(),
                               ?( &after, after.gettree2item(), 0->tree2item ))
   ret as item.data()->gt2item
   ret.maingt2 = this.maingt2  
   ret.name = idname
//   if name == "_" : ret.id = maingt2.id  
   maingt2.names[ fullname ] = &item
//   print("INsert full= \( fullname )\n")
//   print("\(idname) = \(fullname)\n") 
          
   return ret   
}

method  gt2item gt2item.insertchild( str name )
{
   return this.insertchild( name, 0->gt2item ) 
}

method  gt2 gt2item.getgt2
{
   return this.maingt2->gt2 
}

method uint gt2item.set( str attrib value )
{
   uint id
   
   if !*attrib : return 0

   if attrib %== "inherit"
   {
      this.inherit( this.getgt2().find( value ))
   }   
   if !( id = this.find( attrib )) 
   {
      id = this.attrib.expand( 1 )
      this.attrib[ id - 1 ].name = attrib
   }
   this.attrib[ id - 1 ].value = value
  
   return id       
}

method uint gt2item.setattrib( str attrib )
{
   return this.set( attrib, "" )
}


method gt2item.setuint( str attrib, uint val )
{
   this.set( attrib, str( val ))
}

/*
import $"..\..\projects\msvisual6.0\gentee2\release\gentee2.dll"
{
   uint  gentee_deinit()
   uint  gentee_init() 
//   uint  gentee_lex( buf, lex, arrout )
//   uint  lex_tbl( lex, uint )
}
*/
include
{ 
   "gtsave.g"
   "gtload.g"
   "gtprocess.g"
}

operator gt2 += ( gt2 dest, str in )
{
   dest.root().load( in )
   return dest
}

method gt2item gt2item.inherit( gt2item src )
{
   gt2items gt2is

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
   foreach child, src.items( gt2is )
   {
      uint new
      
      if !&this.findrel("/\( child.name )")
      {
         new as this.insertchild( child.name )
         new.inherit( child )
      }     
   } 
   return this
}

method str gt2item.getsubitem( str name value )
{
   uint  subitem
   
   subitem as this.findrel("/\(name)")
   if &subitem : value = subitem.value
   else : value.clear()
   
   return value       
}

/*
// Temporary test function
func gt2main<main>
{
   gt2     igt2
   gt2save gt2s
   str    stemp
   uint   ni
   arrout  out
//   lex  ilex
   str  in = "/******************* esesesese
   
   seseseseses************** /<- qwe-rty ->
   <my_gt2 /asd = \"qwerty sese'\" qq21 = 'dedxd' 'esese;' aqaq=325623/>
   <a asdff /a>
   <mygt2dd a = \"AAAparam=&#1; + &#2;\">
       <a = \"param=&#1; + &#2;\"/>
       <-ooops->
       <1 a2345=310> 223 mygt2t/1</1>
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
   </>"
//   str  data = "qwerty quote" 
     str  data = "qqq &\\
   #mygt2dd/a: 
     Ooops #my_gt2.asd#, ede,,&\\
 e3e3e3e3e
     :##zzz( #my_gt2.asd# ).attrib1#Simple## &#1; &#2;
#mygt2dd/1# #qwerty##a22222/aaa.attr#&\\


#a22222( 'qwerty quote  ' \"append\", \"double quote  \" ssxsxsx    )
#a22222( 23, 45 
#mygt2dd#aa wswsw \"my string\" )
text#/opsew#=>#//aaa.attr#&xd;&xa;"
   arr  par of str = %{"par1","par2"}      
      
//   gentee_init()
   out.isize = sizeof( lexitem );
   
//   lex_tbl( ilex, tblgt2.ptr())
//   gentee_lex( in->buf, ilex, out )
   print("OK 0\n")
   igt2.root().load( in )
   print("OK 1\n")
   gt2s.offstep = 3
   gt2s.inside = 10
   gt2s.endname = 1
   ni as igt2.root().insertchild("Ooops")
   ni.set("qqq","Value q\"qq")
   
   ni.insertchild("Subitem").value = "<Qw\"ert/y dxd</>xdx"
   
   print("OK 0 -------------------\n")
   print( igt2.find( "a22222/abc" ).process( data, "", par ))
   print( igt2.root().save( stemp, gt2s ))
//   lex_init( ilex, 0 )
 //  lex_delete( ilex )
//   gentee_deinit()
   congetch("Press any key...") 
}
*/
