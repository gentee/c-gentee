/******************************************************************************
*
* Copyright (C) 2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS  FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: gtpublisher 23.03.07 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
* Summary: Библиотека для вывода информации в различные форматы документов
*
******************************************************************************/

include
{ 
   $"..\stdlib\stdlib.g"
   $"..\gt\gt.g"
   $"..\thread\thread.g"
   "utils.g"
}

type gtpub< inherit = gt >
{
   gt   prj     // Настройки проекта
 //  gt   data    // Данные в виде gt дерева
//   hash alias   // hash of gtitem objects
   str  output
   str  root
   str  ext
   str  lang
}

global
{
   gtpub _gtp   
   str   style
}

/*
   Стили style
   С - Копирование файлов по списку
   T - Вывод текста как есть
   W - вывод для web-сайта
*/

method str gtpub.getfilename( gtitem gti, str ret )
{
   str stemp
   
   ret = .output

   gti.get( "path", stemp )
   ret.faddname( stemp )  
   gti.get( "filename", stemp )
   this.process( stemp )   
   ret.faddname( stemp )  
   if gti.find( "ext" ) : gti.get( "ext", stemp )
   else : stemp = .ext
   ret.fsetext( ret, stemp )
   
   return ret
}

method str gtpub.geturlname( str name ret )
{
   uint mgti
   
   ret.clear()
   mgti as _gtp.find( name )
   if !&mgti : return ret
      
   mgti.getsubitem( "urlname", ret )
   if !*ret : mgti.getsubitem( "title", ret )
   return ret
}


method str gtpub.geturl( gtitem gti, str ret )
{
   gti.getsubitem( "url", ret )   

   if !*ret
   {
      str stemp
      
      this.getfilename( gti, stemp )
      stemp.replace( 0, *.output + 1, .root )
      ret.replacech( stemp, '\', "/")
   }
      
   return ret
}

include
{ 
   $"styles\c-copy\default.g"
   $"styles\t-text\default.g"
   $"styles\w-website\default.g"
   $"styles\l-phtml\default.g"
   $"styles\s-sources\default.g"
   $"styles\r-lib\default.g"
   $"styles\h-chm\default.g"
}

method gtpub.load
{
   str     input
   arrstr  ain
   uint    last newlast
   str     dir filename
   
   .prj.get( "project/input", input )
   
   ain.loadtrim( input )
   foreach curin, ain
   {
      ffind fd
      fd.init( "\(curin)\\*.gt", $FIND_FILE | $FIND_RECURSE )
      foreach curfile, fd
      {
         print( "\(curfile.fullname)\n" )
         last as this.root().lastchild() 
         this.read( curfile.fullname )
         newlast as this.root().lastchild()
         curfile.fullname.fgetparts( dir, filename, 0->str )
         dir.del( 0, *curin + 1 )
          
         while &newlast != &last 
         {
            newlast.set( "fullpath", "\(curin)\\\(dir)" )
            if !newlast.find( "path" ) : newlast.set( "path", dir )
            if !newlast.find( "filename" ) : newlast.set( "filename", filename )
            if !newlast.find( "ext" )
            {
               str  ext = "ext_"
               str  stemp
               
               newlast.get("style", stemp )
               ( ext += stemp ).lower()
               _gtp.prj.get( "project/\(ext)", stemp )
               
               newlast.set( "ext", ?( *stemp, stemp, .ext ))
            }
            newlast as newlast.getprev()   
         } 
      }
   }
} 

method gtpub.output
{
   uint     outfunc

   .prj.get( "project/style", style )

   style.upper()
//   verifypath( folder, 0->arr )
   foreach curitem, this.root()
   {
      str  cstyle preout out filename
       
      curitem as gtitem
      
//      print("1 \(curitem.name)\n")    
      curitem.get( "style", cstyle )
      cstyle.upper()
      if cstyle.findch( style[0] ) >= *cstyle : continue
      if curitem.find("text")
      {
         outfunc = getid( "T_default", 0, %{ gtitem } )   
      }
      elif !( outfunc = getid( "\( style )_default", 0, %{ gtitem } )) : continue
      
      preout@outfunc->func( curitem )
     
      if preout %== "nofile" : continue               
      curitem.process( preout, out, 0->arrstr )
      this.getfilename( curitem, filename )

      if style[0] == 'H'
      {
         ustr ustemp
         
         ustemp.fromutf8( out )
         out = ustemp
      }
      if fileupdate( filename, out )
      {
         print("Processing \(curitem.name) => \(filename)\n")
      }
   }
}

func main<main>
{
   // Загружаем настройки проекта
   str prjdata
   
   prjdata.read( $"..\..\..\scriptius\web.gt")           
   _gtp.utf8 = 1
   _gtp.prj += prjdata
   _gtp.prj.get( "project/output", _gtp.output )
   _gtp.prj.get( "project/root", _gtp.root )
   _gtp.prj.get( "project/ext", _gtp.ext )
   _gtp.prj.get("project/lang", _gtp.lang )   
   // Читаем все входящие файлы
   _gtp.load()
   // Предварительная обработка
//   _gtp.prepare( gtp.data.root())    
   // Вывод данных
   _gtp.output()
 
   print("Press any key...")
   Sleep( 2000 )
//   getch()   
}