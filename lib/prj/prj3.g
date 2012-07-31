/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: prj 17.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

include
{
//   $"..\gt2\gt.g"
   "gtsave.g"
}

/*-----------------------------------------------------------------------------
*
* ID: prj 12.10.06 1.1.A. 
* 
* Summary: Project type
*  
-----------------------------------------------------------------------------*/

type prj <inherit = gt index = str>
{
   uint opened       // 1 if there is an open project
   uint changed      // 1 if the project was changed
   uint nfy          // id of the notify function
   str  filename     // The current file name or an empty string
   str  program      // The unique program name
   uint version      // The unique version
   str  update       // Update data for adding missing values
}

/*-----------------------------------------------------------------------------
*
* ID: prjnfy 12.10.06 1.1.A. 
* 
* Summary: Project notify codes
*  
-----------------------------------------------------------------------------*/

define <export>
{
   PRJNFY_OPEN = 0    // The project was opened
   PRJNFY_CLOSE       // The project was closed
   PRJNFY_CANCLOSE    // Send when the user tries to close the project
   PRJNFY_CHANGE      // The project was chaged. Send one time (after the 
                      // first changing )
   PRJNFY_NEW         // Request the new project pattern
   PRJNFY_NAME        // Change the file name    
}

global
{
   str  prjempty
}

method gt.clear()
{
   this.names.clear()
   this.items.clear()
   this.files.clear()
   this.procval.clear()
} 

/*-----------------------------------------------------------------------------
*
* ID: prj_setnotify 12.10.06 1.1.A. 
* 
* Summary: Specify notify function. func uint name( prj iprj, uint code )
  where code can be PRJNFY_*
*  
-----------------------------------------------------------------------------*/

method  prj.settings( uint nfyfunc, str program, uint version )
{
   this.nfy = nfyfunc
   this.program = program
   this.version = version         
}

/*-----------------------------------------------------------------------------
*
* ID: prj_notify 12.10.06 1.1.A. 
* 
* Summary: Send notify message PRJNFY_*
*  
-----------------------------------------------------------------------------*/

method uint prj.notify( uint nfy )
{
   if this.nfy : return this.nfy->func( this, nfy )
   return 0      
}

/*-----------------------------------------------------------------------------
*
* ID: prj_close 12.10.06 1.1.A. 
* 
* Summary: Close the project
*  
-----------------------------------------------------------------------------*/

method uint prj.close
{
   if !this.opened : return 1
   
   this.notify( $PRJNFY_CANCLOSE ) 
   
   this.clear()
   this.opened = 0
   this.changed = 0
//   this.filename.clear()   
   
   this.notify( $PRJNFY_CLOSE )
   return 1   
}

/*-----------------------------------------------------------------------------
*
* ID: prj_new 12.10.06 1.1.A. 
* 
* Summary: Specify notify function. func uint name( prj iprj, uint code )
  where code can be PRJNFY_*
*  
-----------------------------------------------------------------------------*/

method uint prj.new
{
   if this.opened : this.close()
   if *this.update : this += this.update
   this.notify( $PRJNFY_NEW )
   this.filename.clear()
   this.opened = 1
   this.changed = 1   
   this.notify( $PRJNFY_OPEN )
   return 1   
}

/*-----------------------------------------------------------------------------
*
* ID: prj_open 12.10.06 1.1.A. 
* 
* Summary: Load a project from the file
*  
-----------------------------------------------------------------------------*/

method uint prj.open( str filename )
{
   if this.opened : this.close()
   if *this.update : this += this.update
   this.read( filename )
   this.filename = filename
   this.opened = 1
   this.notify( $PRJNFY_OPEN )
   return 1   
}

/*-----------------------------------------------------------------------------
*
* ID: prj_save 12.10.06 1.1.A. 
* 
* Summary: Save a project
*  
-----------------------------------------------------------------------------*/


method uint prj.save()
{
   str data script
/*   subfunc str getedit( str name )
   {
      name = this[ name ]
      if name[0] == '<' || name[0] == '"' || name[0] == '''
      { 
         name.insert( 0, "*" )
      }
      return name
   }*/
   //   gt2save gt2s
   
   if !this.opened || !*this.filename : return 0
    
//   gt2s.offstep = 3
//   gt2s.inside = 0
//   gt2s.endname = 0
   
//   this.write( this.filename, gt2s )
/*
   data = "<project version = 1 program = Scriptius >
<name>\( getedit( "name" ))</>
<runshell>\( getedit( "runshell" ))</>
<recompile>\( getedit( "recompile" ))</>
<exe>\( getedit( "exe" ))</>
<icon>\( getedit( "icon" ))</>
<autoexe>\( getedit( "autoexe" ))</>
<savelog>\( getedit( "savelog" ))</>
<check1>\( getedit( "check1" ))</>
<check2>\( getedit( "check2" ))</>
<script>\( prjrw_getlist( script ))</>
</>"

   data.write( this.filename )
*/    
   if this.changed
   {
      this.changed = 0
      this.notify( $PRJNFY_CHANGE )
   }
   return 1   
}

/*-----------------------------------------------------------------------------
*
* ID: prj_save 12.10.06 1.1.A. 
* 
* Summary: Save a project to the filename
*  
-----------------------------------------------------------------------------*/

method uint prj.save( str filename )
{
   uint ret
   
   this.filename = filename
   ret = this.save()   
   this.notify( $PRJNFY_NAME )
   return ret
}

/*-----------------------------------------------------------------------------
*
* ID: prj_index 12.10.06 1.1.A. 
* 
* Summary: 
*  
-----------------------------------------------------------------------------*/

method uint prj.index( str name )
{
   uint gti
   
   gti as this.find( "project/\(name)" )
   if &gti : return  &gti.val[ 0 ].value
   prjempty.clear()
   return &prjempty
}

/*-----------------------------------------------------------------------------
*
* ID: prj_set 12.10.06 1.1.A. 
* 
* Summary: Set a project value
*  
-----------------------------------------------------------------------------*/

method prj.set( str name value )
{
   uint  sti
   
   sti as this[ name ]
   if &sti
   {
      sti = value
      if !this.changed
      {
         this.changed = 1
         this.notify( $PRJNFY_CHANGE )
      }
   }
}

/*-----------------------------------------------------------------------------
*
* ID: prj_set 12.10.06 1.1.A. 
* 
* Summary: Set a project value
*  
-----------------------------------------------------------------------------*/

method prj.set( gtitem gti, str value )
{
   gti.value() = value
   if !this.changed
   {
      this.changed = 1
      this.notify( $PRJNFY_CHANGE )
   }
}

/*-----------------------------------------------------------------------------
*
* ID: prj_insert 12.10.06 1.1.A. 
* 
* Summary: Insert project items
*  
-----------------------------------------------------------------------------*/

method gtitem prj.insert( str data, gtitem parent after )
{
   uint  ret
 
 //  ret as parent.load( data, after )
   if !this.changed
   {
      this.changed = 1
      this.notify( $PRJNFY_CHANGE )
   }
       
   return ret->gtitem
}

/*-----------------------------------------------------------------------------
*
* ID: prj_moveup 12.10.06 1.1.A. 
* 
* Summary: Move the project item up
*  
-----------------------------------------------------------------------------*/

method gtitem prj.moveup( gtitem cur )
{
/*   if cur.moveup() && !this.changed
   {
      this.changed = 1
      this.notify( $PRJNFY_CHANGE )
   }*/    
   return cur
}

/*-----------------------------------------------------------------------------
*
* ID: prj_movedown 12.10.06 1.1.A. 
* 
* Summary: Move the project item down
*  
-----------------------------------------------------------------------------*/

method gtitem prj.movedown( gtitem cur )
{
/*   if cur.movedown() && !this.changed
   {
      this.changed = 1
      this.notify( $PRJNFY_CHANGE )
   }*/    
   return cur
}

/*-----------------------------------------------------------------------------
*
* ID: prj_disable 12.10.06 1.1.A. 
* 
* Summary: Move the project item down
*  
-----------------------------------------------------------------------------*/

method uint prj.disable( gtitem gti, uint state )
{
//   if state : gti.setattrib( "disable" )
//   else : gti.delattrib( "disable" )
   
   if !this.changed
   {
      this.changed = 1
      this.notify( $PRJNFY_CHANGE )
   }    
   return 1
}

/*-----------------------------------------------------------------------------
*
* ID: prj_disable 12.10.06 1.1.A. 
* 
* Summary: Move the project item down
*  
-----------------------------------------------------------------------------*/

method uint prj.del( gtitem gti )
{
   gti.del()
      
   if !this.changed
   {
      this.changed = 1
      this.notify( $PRJNFY_CHANGE )
   }    
   return 1
}