/******************************************************************************
*
* Copyright (C) 2004-2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: vis.comp 17.07.07 0.0.A.
*
* Author: Alexander Krivonogov ( gentee )
*
******************************************************************************/
/* Компонента vComp, корневая
События
Необходимо определять режим работы компоненты p_designing
Доработать присваивание хозяина mSetOwner mInsert
   
*/
include {
   "vis.g"   
 //  "events.g" 
   "..\\language\\language.g"
}
type vComp <index = this>
{   
//Hidden Fields
   uint pTypeDef //Указатель на tTypeDef с описанием типа компоненты
   uint pTypeId  //Тип компонента     
   str  pName    //Имя компонента
   uint pOwner   //Указатель на компонент владельца
   uint pIndex   //Номер компонента в списке владельца
   uint fDynamic //Компонент создан динамически, через функцию newcomp
   uint pTag     //Пользовательские данные
   uint pAutoLang //Автоматически подставлять языковой ресурс
            
   uint form
   uint p_designing
   uint p_loading
   uint des1// Используется дизайнером
   
//Public Fields
   arr  Comps of uint //Список дочерних компонентов  
   
}
include {
   "events.g"
}


//Virtual Method Identifiers
define <export>{
   mNull      = 0
   mInsert       //method vComp.mInsert( vComp newcomp )
   mRemove       //method vComp.mRemove( vComp remcomp )
   mPreDel       
   mSetOwner     //method vComp.mSetOwner( vComp newowner )
   mLangChanged  //method vComp.mLangChanged()
   mRegProps     //method vComp.mRegProps( uint typeid, compMan cm )
   mSetName
   mMenuClick 
   mLoad     
   mSetIndex  
   mOwnerCreateWin 
       
   vComp_last    
}


extern {
method uint vComp.GetForm()
method vComp vComp.FindComp( str name )
property vComp.Name( str val )
property str vComp.Name<result>( )
property vComp.Owner( vComp comp )
property vComp vComp.Owner
property str vComp.TypeName<result>
}


/*------------------------------------------------------------------------------
   Internal Methods
*/
/*Метод uint vComp.iSetName( str name )
Установить новое имя компоненты
name - новое имя
Возвращает 1 - если имя успешно установлено, 0 - в случае ошибки 
*/
func uint checkname( str s )
{
   uint i
   uint ch
   if !*s : return 0
   ch = s[i++]
   if ( ch >= 'a' && ch <= 'z' ) ||
      ( ch >= 'A' && ch <= 'Z' ) ||      
      ch == '_' || 
      ch >= 0x80 
   {    
      fornum i, *s
      {
         ch = s[i]
         if ( ch >= 'a' && ch <= 'z' ) ||
            ( ch >= 'A' && ch <= 'Z' ) ||            
            ( ch >= '0' && ch <= '9' ) ||
            ch == '_' ||
            ch >= 0x80 : continue
         return 0            
      }
      return 1
   }
   return 0
}


/*Метод uint vComp.Virtual( uint id )
Предназначен для получения адреса виртуального метода по его идентификатору
id - идентификатор метода 
*/
method uint vComp.mNull <alias=vComp_mNull>
{
   return 0
}

method uint vComp.GetVirtual( uint id )
{
   //print( "Virtual \(this.p_typename) \(id) \((this.VirtTbl + (id<<2))->uint)\n" )
   //return (this.VirtTbl + (id<<2))->uint
   if this.pTypeDef
   {         
      with this.pTypeDef->tTypeDef
      {          
         if *(.VirtTbl ) > id
         {
         //print( "Virtual \(.TypeName) \(id) \((.VirtTbl.data + (id<<2))->uint)\n" )
         uint addr = (.VirtTbl.data + (id<<2))->uint
         if addr
         { 
            return addr 
         }
         }
         return  (.VirtTbl.data)->uint
      }
   }
   return vComp_mNull
}

method uint vComp.GetInherited( uint id )
{  
   uint inherittypeid   
   if this.pTypeDef && ( inherittypeid = this.pTypeDef->tTypeDef.InheritTypeId )  
   {         
      uint ptypedef as gettypedef( inherittypeid )      
      if &ptypedef      
      {
         if *(ptypedef.VirtTbl ) > id
         {         
            uint addr = (ptypedef.VirtTbl.data + (id<<2))->uint
            if addr
            { 
               return addr 
            }
         }
         return  (ptypedef.VirtTbl.data)->uint
      }
   }
   return vComp_mNull
}

method uint vComp.Virtual( uint idfunc )
{     
   return this.GetVirtual( idfunc )->func( &this )
}

method uint vComp.Virtual( uint idfunc, any par1 )
{   
   return this.GetVirtual( idfunc )->func( &this, par1 )
}

method uint vComp.Virtual( uint idfunc, any par1 par2 )
{   
   return this.GetVirtual( idfunc )->func( &this, par1, par2 )
}

method uint vComp.Virtual( uint idfunc, any par1 par2 par3 )
{   
   return this.GetVirtual( idfunc )->func( &this, par1, par2, par3 )
}

method uint vComp.Virtual( uint idfunc, any par1 par2 par3 par4 )
{   
   return this.GetVirtual( idfunc )->func( &this, par1, par2, par3, par4 )
}

method uint vComp.Inherited( uint idfunc )
{     
   return this.GetInherited( idfunc )->func( &this )
}

method uint vComp.Inherited( uint idfunc, any par1 )
{   
   return this.GetInherited( idfunc )->func( &this, par1 )
}

method uint vComp.Inherited( uint idfunc, any par1 par2 )
{   
   return this.GetInherited( idfunc )->func( &this, par1, par2 )
}

method uint vComp.Inherited( uint idfunc, any par1 par2 par3 )
{   
   return this.GetInherited( idfunc )->func( &this, par1, par2, par3 )
}

method uint vComp.Inherited( uint idfunc, any par1 par2 par3 par4 )
{   
   return this.GetInherited( idfunc )->func( &this, par1, par2, par3, par4 )
}

method uint vComp.iSetName( str name )
{
   if this.pName != name
   {
      if this.p_designing 
      {
         if !checkname( name ) : return 0
         uint comp as this     
         while comp.pOwner && comp.pOwner->vComp.p_designing
         {
            comp as comp.pOwner->vComp
         }
         if &comp.FindComp( name ) : return 0
      }
      .Virtual( $mSetName, name )
      this.pName = name
      /*if .Virtual( $mSetName, name )
      {
         this.pName = name
      }*/
   }
   return 1
}
/*------------------------------------------------------------------------------
   Public Methods
*/
/*Метод vComp vComp.CreateComp( uint typeid )
Создать новый дочерний компонент
typeid - тип нового компонента
Возращает созданный компонент или 0 - в случае ошибки
*/
method vComp vComp.CreateComp( uint typeid, uint pDesigning )
{   
   uint comp as new( typeid )->vComp
   comp.p_designing = pDesigning  
   comp.fDynamic = 1
   
   comp.Owner = this
   
   /*if &this && comp.pOwner != &this  
   {      
      destroy( &comp )
      comp as 0
   } */ 
   return comp
}

method vComp vComp.CreateComp( uint typeid )
{   
   uint comp as new( typeid )->vComp   
   comp.fDynamic = 1
   
   comp.Owner = this
   
   /*if &this && comp.pOwner != &this  
   {      
      destroy( &comp )
      comp as 0
   } */ 
   return comp
}

/*Метод vComp.DestroyComp()
Уничтожить данную компоненту
*/
method vComp.DestroyComp()
{
   .Virtual( $mPreDel )
   .pTypeDef = 0    
   if this.fDynamic : destroy( &this )
}


/*Метод TypeIs( uint inhtypeid )
Определяет имеет ли компонент указанный тип или порожден от него
inhtypeid - тип 
Возращает:
   1 - компонент имеет указанный тип или порожден от него
   0 - компонент не совместим с указанным типом
*/    
method uint vComp.TypeIs( uint inhtypeid )
{
   if this.pTypeId == inhtypeid : return 1
   return type_isinherit( this.pTypeId, inhtypeid )
}

/*Метод vComp vComp.FindComp( str name )
Найти дочерний компонент с указанным именем
name - имя компонента
Возвращает 1 если компонент найден, иначе 0
*/
method vComp vComp.FindComp( str name )
{
   uint i
   uint comp   
   fornum i = 0, *this.Comps
   {
      comp as this.Comps[i]->vComp
      if comp.Name == name : return comp 
      if comp as comp.FindComp( name ) : return comp  
   }   
   return 0->vComp
}

method vComp vComp.FindComp( vComp srccomp )
{
   uint i
   uint comp   
   fornum i = 0, *this.Comps
   {
      comp as this.Comps[i]->vComp
      if &comp == &srccomp : return comp 
      if comp as comp.FindComp( srccomp ) : return comp  
   }   
   return 0->vComp
}

/*------------------------------------------------------------------------------
   Properties
*/
/* Свойство uint Tag - Get Set
Можно указывать любые пользовательские данные  
*/
property uint vComp.Tag
{   
   return this.pTag 
}

property vComp.Tag( uint val )
{
   this.pTag = val   
}

/* Свойство uint AutoLang - Get Set
Автоматически подставлять языковой ресурс  
*/
property uint vComp.AutoLang
{   
   return this.pAutoLang
}

property vComp.AutoLang( uint val )
{
   this.pAutoLang = val   
}
/* Свойство vComp Owner - Get Set
Получить, изменить владельца компонента
*/


property vComp.Owner( vComp newowner )
{
   if this.pOwner != &newowner
   {
      if &newowner 
      {   
         if !this.pTypeDef
         {                
            this.pTypeDef = &gettypedef( this.pTypeId )
         }  
         newowner.Virtual( $mInsert, &this )
      }     
      else
      {
         .pOwner->vComp.Virtual( $mRemove, &this )         
      }       
   }   
}

property vComp vComp.Owner
{
   return this.pOwner->vComp
}

/* Свойство uint TypeId - Get
Получить тип компонента
*/
property uint vComp.TypeId
{
   //return this.p_typeid
   return this.pTypeId//pTypeDef->tTypeDef.typeid
}

/* Свойство str TypeName - Get
Получить имя типа компонента
*/
property str vComp.TypeName<result>
{
   result = this.pTypeDef->tTypeDef.TypeName
}

/* Свойство str Name - Get Set
Получить, изменить имя компонента
*/
property str vComp.Name<result>
{   
   result = this.pName 
}

property vComp.Name( str val )
{
   .iSetName( val )   
}

/* Свойство uint CompIndex - Get Set
Получить, изменить позицию компонента в списке владельца
*/
property uint vComp.CompIndex
{
   return .pIndex  
}

property vComp.CompIndex( uint newidx )
{  
   .Virtual( $mSetIndex, newidx )
 /*  if this.pOwner && .pIndex != newidx
   {  
      uint Comps as this.pOwner->vComp.Comps
      uint oldidx, i
      newidx = min( max( -0, int( newidx )), *Comps - 1 )          
      if newidx != this.pIndex
      {           
         oldidx = this.pIndex
         if newidx > oldidx
         {            
            fornum i = oldidx + 1, newidx + 1 
            {
               Comps[i]->vComp.pIndex--
               Comps[i-1] = Comps[i]
            }            
         }
         else
         {            
            for i = oldidx - 1, int(i) >= newidx, i--
            {
               Comps[i]->vComp.pIndex++
               Comps[i+1] = Comps[i]
            }
         }       
         Comps[newidx] = &this
         this.pIndex = newidx          
      }
   }*/
}
property uint vComp.Index
{
   return .pIndex  
}

property vComp.Index( uint newidx )
{  
   .Virtual( $mSetIndex, newidx ) 
}


/*------------------------------------------------------------------------------
   Virtual Methods
*/


method vComp.mInsert <alias=vComp_mInsert> ( vComp newcomp )
{
   if newcomp.pOwner 
   {
      newcomp.pOwner->vComp.Virtual( $mRemove, &newcomp )
   }
   newcomp.pIndex = *this.Comps
   .Comps += &newcomp
   newcomp.Virtual( $mSetOwner, &this )      
}

method vComp.mRemove <alias=vComp_mRemove>( vComp remcomp )
{  
   uint ar as this.Comps
   uint i   
   if ar[remcomp.pIndex] == &remcomp
   {
      ar.del(remcomp.pIndex,1)
      fornum i = remcomp.pIndex, *ar 
      {
         ar[i]->vComp.pIndex--
      }
   }   
   remcomp.Virtual( $mSetOwner, 0 )   
}

method vComp.mSetOwner <alias=vComp_mSetOwner>( vComp newowner )
{   
   this.pOwner = &newowner 
}
/*global{
uint level}*/

method vComp.DelChildren()
{
   uint i
   for i=*this.Comps - 1, i != -1, i--
   {  
      this.Comps[i]->vComp.DestroyComp()
   }
   this.Comps.clear()
}

method vComp.mPreDel <alias=vComp_mPreDel>
{
   //if this.TypeName == "vForm" 
   /*{
   if level < 4
   {
      print( "PreDel \(level) \( this.Name ) \(this.TypeName )\n" )
   }
   level++
   }*/
   
   if this.p_designing && this.des1
   {     
      
      destroy( this.des1 )
      this.des1 = 0
      
   }   
   .DelChildren()
   if &this.Owner
   {
      this.Owner = 0->vComp
   }
   //level--
}

method vComp.mLangChanged <alias=vComp_mLangChanged> ( )
{
   uint i
   fornum i, *this.Comps
   {    
      this.Comps[i]->vComp.Virtual( $mLangChanged )
   }
} 


method vComp.mSetIndex <alias=vComp_mSetIndex>( uint newidx )
{   
   if this.pOwner //&& .pIndex != newidx
   {  
      uint Comps as this.pOwner->vComp.Comps
      uint oldidx, i
      newidx = min( max( -0, int( newidx )), *Comps - 1 )          
      if newidx != this.pIndex
      {           
         oldidx = this.pIndex
         if newidx > oldidx
         {            
            fornum i = oldidx + 1, newidx + 1 
            {
               Comps[i]->vComp.pIndex--
               Comps[i-1] = Comps[i]
            }            
         }
         else
         {            
            for i = oldidx - 1, int(i) >= newidx, i--
            {
               Comps[i]->vComp.pIndex++
               Comps[i+1] = Comps[i]
            }
         }
         Comps[newidx] = &this
         this.pIndex = newidx          
      }
   }    
}


method uint vComp.eof( fordata tfd )
{
   return ?( tfd.icur < *this.Comps, 0,  1 )
}

method uint vComp.next( fordata tfd )
{
   tfd.icur++
   if tfd.icur < *this.Comps
   { 
      return this.Comps[tfd.icur]
   }
   return 0
}

method uint vComp.first( fordata tfd )
{   
   tfd.icur = 0
   if tfd.icur < *this.Comps
   { 
      return this.Comps[tfd.icur]
   }
   return 0
}


/*------------------------------------------------------------------------------
   Registration
*/
method vComp vComp.init()
{
   this.pTypeId = vComp
   this.pAutoLang = 1
   return this
}

method vComp.delete()
{
   if .pTypeDef
   {
      .Virtual( $mPreDel )
   }
}

/*ifdef $DESIGNING
{
include{
$"../visedit/manprops.g"
}
}*/
/*
func init_vComp <entry>
{  
   regcomp( vComp, "vComp", 0, $vComp_last,
      %{ %{$mNull,   vComp_mNull},
         %{$mInsert, vComp_mInsert },
         %{$mRemove, vComp_mRemove },
         %{$mPreDel, vComp_mPreDel },
         %{$mSetOwner, vComp_mSetOwner },
         %{$mLangChanged, vComp_mLangChanged }
         
      },        
      0->collection )
      
ifdef $DESIGNING {
   cm.AddComp( vComp )
         
   cm.AddProps( vComp, %{ 
"Name"     , str,  0,
"Tag"      , uint, 0      
   })
}      
}
*/
/*
method uint onevent.set( vComp obj, str methodname )
{
   str m = methodname
   this.id = 0
   this.obj = &obj
   if this.eventtypeid
   {      
      //collection xx 
      //xx = xx+%{obj.typeid, this.eventtypeid}      
      this.id = getid( m, 1, %{obj.TypeId, this.eventtypeid})
      
   }
   if !this.id 
   {
      if !( this.id = getid( m, 1, %{obj.TypeId, eventn } ) )
      {
         this.id = getid( m, 1, %{obj.TypeId, uint } )
      }
   }  
   return 1
}
*/
/*
method uint vComp.event( eventn ev )
{
   if &ev 
   {      
      if this.f_defproc
      {         
         return this.f_defproc->func( this, ev )
          
      }
   }
   return 1
}

method uint vComp.event( uint code )
{
   eventn ev
   ev.code = code 
   if this.f_defproc
   {      
      return this.f_defproc->func( this, ev )
   }
   return 1
}*/