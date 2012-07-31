#exe = 1
#output = k:\gentee\open source\gentee\exe\geddemo.exe
/******************************************************************************
*
* Copyright (C) 2009, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

include : "ged.g"

define
{
   PATH = $"c:\temp"
   DBNAME = "\$PATH\\demo.ged"
}

func uint ged_notify( ged pdb )
{
   str stemp
   
   if pdb.filename : stemp.copy( pdb.filename )
   print("Notify \( pdb.error )\n")
   switch pdb.error
   {
      case $GDE_GEDEXIST
      {
         return 0 // Overwrite existing database
//         return !conyesno("Database \( pdb.dbfile ) exists. Overwrite? (Y/N)" )
      }
      case $GDE_OPENFILE : print( "ERROR: Cannot open file \( stemp )\n")  
      case $GDE_WRITEFILE : print( "ERROR: Cannot write file \( stemp )\n")  
      case $GDE_FORMAT : print( "ERROR: Wrong GED format of \( stemp )\n")  
      case $GDE_READFILE : print( "ERROR: Cannot read file \( stemp )\n")  
   }
   return pdb.error
}

method ged.printrec()
{
   str out
   uint i
   out = "\( ?( this.isdel(), "*", " " ))\( this.reccur )"
   fornum i, this.fieldcount()
   {
      str stemp
      this.getstr( i, stemp )
      out += " >\(stemp)"
   }
   out += "\l"
   print( out )
}

method gedsel.printrec()
{
   str out
   uint i recno
   recno = ged_goto( this.pdb->ged, ges_recno( this ))
   out = "\( this.reccur ) N\( recno )"
   fornum i, this.pdb->ged.fieldcount()
   {
      str stemp
      this.pdb->ged.getstr( i, stemp )
      out += " >\(stemp)"
   }
   out += "\l"
   print( out )
}

func main<main>
{
   ged        pdb
   collection cfield
   uint       i
   arrstr     in
   str        path
   
   cfield = %{ $FT_INT | $FTF_AUTO, "id" ,
               $FT_SHORT, "short",
               $FT_BYTE, "char", 
               $FT_LONG, "long", 
               $FT_DOUBLE, "real",
               $FT_FLOAT, "float",
               $FT_STR | ( 16 << 16 ), "email",
               $FT_USTR | ( 16 << 16 ), "name" }
               
   pdb.create( $DBNAME, cfield, &ged_notify );
   pdb.open( $DBNAME, &ged_notify );
   print( "Field index: email = \( pdb.findfield( "email" 
                   )) qqq = \( pdb.findfield( "qqq" ))\n" )
   fornum i = 0, pdb.fieldcount()
   {
      uint fi
      
      fi as pdb.field( i )
      print( "\(i + 1): type=\( fi.ftype ) \("".copy( fi.name )) width = \(
               fi.width ) off = \( fi.offset )\n" )
   }
   pdb.append();
   pdb.append( %{ 0, 1, 2, 30123456789L, 2.123, 4.13F, "test@....com", "John Smith" });
   print( "Number of records = \( *pdb )\n" )
   
   foreach curdb, pdb : pdb.printrec()
   pdb.close()
   
   path.fgetdir( $_FILE )
   ffind fd
   
   fd.init( path.faddname("*.g"), $FIND_FILE )
   foreach cur,fd
   {
      str stemp
      
      stemp.read( cur.fullname )
      in.load( stemp, $ASTR_APPEND | $ASTR_TRIM )  
   }
   
   pdb.open( $DBNAME, &ged_notify );
   fornum i = 0, 100
   {
      pdb.append( %{ 0, i, i & 0xf, 0L, 0.0, 0F, in[i*2], in[i*2+1] });
   }     
   foreach curdb, pdb : pdb.printrec()
   print("=====================================\l")
   
   gedsel sel
       
/*   sel.open( pdb, %{ $SF_EQ | $SF_OR, "id", 56,
                     $SF_GREAT | $SF_OR, "id", 90,
                     $SF_EQ, "email", "{" }, %{10} )*/
   sel.open( pdb, %{ $SF_GREAT | $SF_NOT, "name", "fi" }, 
                  %{ "char", $IF_DESC, "email", 0 } )
   print( "Number of records = \( *sel )\n" )
   pdb.append( %{ 0, 1, 255, 301L, 0.123, 4.13F, "film@....com", "film" });
   sel.update()
//   sel.reverse()
   foreach cursel, sel : sel.printrec()
   print("======================================\l")
   sel.close()
   pdb.close()
   congetch( "Press any key..." )
}