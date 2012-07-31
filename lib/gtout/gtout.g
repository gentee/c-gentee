#!k:\gentee\releases\gentee\ge2exe.exe -e "%1" 
//#!k:\gentee\releases\gentee\gentee.exe "%1" 
/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: gtout 17.11.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

define
{
   DEBUG = 0
}

global
{
   str  _rp     // rootpath
   str  _prefix // language prefix
   str  _flag
   hash _gtalias  // hash of gt2item objects
   uint _gt
}

include
{
   $"..\gt2\gt.g"
   $"..\number\str32x.g"
}

method str str.getfilename( gt2item gti )
{
   this.clear()
   
   if gti.find( "filename" )
   {
      gti.get( "filename", this )
      if !*this
      {
         uint ch = *gti.name - gti.name.findch( '_', 1 )
         
         if ch && ch < 4
         {
            ( this = gti.name ).setlen( *gti.name - ch )
         }
      } 
   }
   if !*this : this = gti.name
      
   this.fsetext( this, gti.get( "ext" ))

   return this
}

method str str.getlink( gt2item gti )
{
   this.clear()
   
   if gti.find( "link" )
   {
      gti.get( "link", this ) 
   }
   else
   {
      str  prev fname

      if ( gti.parent().name %!= "root" )
      {
         prev.getlink( gti.parent())   
      }
      else : prev = _rp

      if gti.find( "folder" ) : gti.get("folder", fname )
      else : fname.getfilename( gti )
      this = "\(prev)\(?( prev[ *prev - 1 ] != '/', "/", "" ))\(fname)"

      gti.set( "link", this ) 
   }
      
   return this
}


include
{
   "prepare.g"
   "processing.g"
   $"patterns\default.g"
   $"patterns\asis.g"
}

func scanfiles( str path, gt2item root )
{
   ffind fd
   
   fd.init( "\(path)\\*.*", $FIND_FILE )
   foreach curfile, fd
   {
      str  in
      
      print( "Loading \( curfile.fullname )\n" )
      in.read( curfile.fullname )
      root.load( in )
   }
   fd.init( "\(path)\\*.*", $FIND_DIR )
   foreach curdir, fd
   {
      uint dir
      
      dir as root.insertchild( "_" )
      dir.set( "folder", curdir.name )
      scanfiles( curdir.fullname, dir )
   }
}         

func err( str errtext )
{
   print( errtext )
   congetch("\nPress any key...")
   exit(0)
}

func gtout<main>
{
   gt2    igt
   uint   root
   str    prjname  common stemp out curdir
   ffind  fd
   gt2save gt2s
   
/*   if !argc()
   {
      congetch("Specify the project .gt file\nPress any key...")
      return 
   }
   argv( prjname, 1 )*/
   prjname = $"k:\gentee\open source\gentee\doc\en\site.gt"
//   prjname = $"k:\gentee\open source\gentee\doc\ru\site.gt"
//   prjname = $"k:\gentee\doc\scriptius\ru-www.gt"
//   prjname = $"k:\gentee\doc\scriptius\en-www.gt"
//   prjname = $"k:\gentee\doc\createinstall\en-www.gt"
//   prjname = $"k:\gentee\doc\createinstall\ru-www.gt"
   if argc()
   {
      str par 
      argv( par, 1 )
      switch par
      {
         case "sc-en" : prjname = $"k:\gentee\doc\scriptius\en-www.gt"
         case "sc-ru" : prjname = $"k:\gentee\doc\scriptius\ru-www.gt"
         case "ci-en" : prjname = $"k:\gentee\doc\CreateInstall\en-www.gt"
         case "ci-ru" : prjname = $"k:\gentee\doc\CreateInstall\ru-www.gt"
      } 
   }

   getmodulepath( common, "common.gt" )
   igt.read( common )
   getmodulepath( common, "html.gt" )
   _gt = &igt
   igt.read( common )
   
   igt.read( prjname )
   igt.get( "input", stemp )
   igt.get( "output", curdir )
   if !*stemp : err( "Input path has not been defined!")
   
   root as igt.root().insertchild( "root" )
   root.set( "folder", curdir )
   
   scanfiles( stemp, root )
   igt.get("rootpath", _rp )
   igt.get("language", _prefix )
   igt.get( "flag", _flag )

   prepare( igt.find("root"))
   processing( igt )         

   igt.root().save( stemp, gt2s )  
   congetch("( stemp ) Press any key...") 
}
