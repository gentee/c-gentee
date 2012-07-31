/******************************************************************************
*
* Copyright (C) 2004-2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: vis.vis 17.07.07 0.0.A.
*
* Author: Alexander Krivonogov ( gentee )
*
******************************************************************************/

/*Основа для визуальных компонент

 */
 

//
type tTypeDef
{     
   str  TypeName   
   arr  VirtTbl of uint
   arr  ProcTbl[$WM_USER]  of uint 
   arr  ProcUserTbl[0] of uint  
   //arr  ProcTbl/*[200]*//*[129]*/  of uint
   uint InheritTypeId     
}

method uint tTypeDef.findprocuser( uint msg )
{
   uint i
   for i = 0, i < *.ProcUserTbl, i += 2
   {
      if .ProcUserTbl[i] == msg
      {  
         return i
      }  
   }
   return 0
}

method uint tTypeDef.setproc( uint msg newproc )
{   
   uint oldproc
   if msg < $WM_USER
   {
      oldproc = .ProcTbl[msg]
      .ProcTbl[msg] = newproc
   }
   else
   {
      uint i 
      if i = .findprocuser( msg )
      {
         oldproc = .ProcUserTbl[i]            
      }
      else
      {      
         i = .ProcUserTbl.expand( 2 )
         .ProcUserTbl[i++] = msg
      }
      .ProcUserTbl[i] = newproc   
   }
   return oldproc
}

method tTypeDef.delproc( uint msg oldproc )
{  
   if msg < $WM_USER
   {
      .ProcTbl[msg] = oldproc
   }
   else
   {      
      uint i 
      if i = .findprocuser( msg )
      {      
         if oldproc : .ProcUserTbl[i] = oldproc
         else {        
            .ProcUserTbl.del( i, 2 )          
         }
      }      
   }
}

method uint tTypeDef.getproc( uint msg )
{
   if msg < $WM_USER
   {
      .ProcTbl[msg]
   }
   else
   {
      uint i 
      if i = .findprocuser( msg )
      {
         return .ProcUserTbl[i]
      }
   }
   return 0
} 

method tTypeDef.delete()
{
   /*print( "tTypeDef.Delete\n" )
   getch()*/
}
/*method tTypeDef tTypeDef.init()
{
print( "reseeeeee\n" )
   if 0 :this.ProcTbl->buf.expand( 129*4 )
   //this.ProcTbl.data = buf_alloc( pb, size );
   //this.ProcTbl.use=129
   return this
}*/

global {
   arr tbltypedef[0,2] of uint   
}

func tTypeDef gettypedef( uint typeid )
{
   uint i   
   fornum i = 0, *tbltypedef
   {      
      if typeid == tbltypedef[i,0]
      {       
         return tbltypedef[i,1]->tTypeDef
      } 
   }
   return 0->tTypeDef
}

func uint gettypeid( str typename )
{
   uint i   
   fornum i = 0, *tbltypedef
   {      
      if tbltypedef[i,1]->tTypeDef.TypeName == typename
      {       
         return tbltypedef[i,0]
      } 
   }
   return 0
}

func uint regcomp( uint typeid, str typename, uint inherit, uint maxvirt, collection virt, collection proc)
{   

   uint td as new( tTypeDef )->tTypeDef 
   uint i   
   //td.typeid = typeid
   td.TypeName = typename 
   td.InheritTypeId = inherit
   uint ptd as gettypedef(inherit)
//td.ProcTbl->buf.expand( 129*4 )
   if &ptd 
   {
      td.VirtTbl = ptd.VirtTbl
      //print( "- \(td.VirtTbl.itype)  \(ptd.VirtTbl.itype)\n" ) 
      td.ProcTbl = ptd.ProcTbl
      td.ProcUserTbl = ptd.ProcUserTbl
      td.VirtTbl.expand( max( 0, int( maxvirt ) - *ptd.VirtTbl ) )
   }   
   else
   {
      td.VirtTbl.expand( maxvirt )
   }


   if &virt
   {   
     fornum i = 0, *virt
      {   
         uint fdef as virt[i]->collection
         td.VirtTbl[fdef[0]] = fdef[1]
      }
      
   }
      
   if &proc
   {                               
      fornum i = 0, *proc 
      {
         uint fdef as proc[i]->collection
         //print( "fdef \(fdef[0]) \(*td.ProcTbl)\n" )
         //td.ProcTbl[fdef[0]] = fdef[1]
         td.setproc(fdef[0],fdef[1])         
      } 
   }   
   //return &td
   uint cur = tbltypedef.expand( 2 ) / 2   
   tbltypedef[ cur, 0 ] = typeid
   tbltypedef[ cur, 1 ] = &td
   //print( "reg \(cur) \(typeid) \(tbltypedef[ cur, 1 ])\n" )
   /*print( "x5\n" )*/
   return &td
//%{ %{$id_insert, vComp_insert}, %{$id_predel, vComp_predel }, %{$id_remove, vComp_remove} }
} 