/******************************************************************************
*
* Copyright (C) 2004-2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: visedit.manrpops 09.08.07 0.0.A.
*
* Author: Alexander Krivonogov ( gentee )
*
******************************************************************************/
define {
   PROP_LOADAFTERCHILD = 0x1 //PropFlags - загрузить данной свойство после создания дочерних элементов
   PROP_LOADAFTERCREATE = 0x2 //PropFlags - загрузить данное свойство после создания всего дерева объектов

   PI_SIMPLE = 0x000
   PI_UPDOWN = 0x001
   PI_DLG    = 0x002
   PI_SEL    = 0x100
   
   PI_DEFVAL = 0x1000000
   PI_LIST   = 0x1000
}
//Описание возможного числового значения
type CompEnumVal {
   str  Name //Имя значения
   uint Val  //Непосредственное значение
}

//Описание свойства
type CompProp {
   str  PropName //Имя свойства
   uint PropType //Тип свойства
   uint PropFlags //Флаги свойства
   uint AddrGet //Адрес get метода
   uint AddrSet //Адрес set метода
   uint Vals    //Список возможных значений если нужен - arr of CompEnumVal
   ustr DefVal  //Значение по умолчанию     
}

//Описание события
type CompEvent {
   str  EventName  //Имя события
   str  EventType  //Тип события
   uint EventId     
}

//Описание компонента
type CompDescr{
   uint TypeId    //Тип компонента
   str  TypeName  //Имя типа
   str  File     //Имя модуля содержащее данный компонент
   uint VisComp   //Данный компонент будет отображаться в списке добавляемых компонентов
   arr  Props  of CompProp    //Список свойств
   arr  Events of CompEvent  //Список событий   
}

//Менеджер свойств
type VEManProps{
   arr Descrs of CompDescr //Список компонентов 
}

type EventDescr{
//uint idmethod //Идентификатор метода
str  MethodName  //Имя метода 
str  EventType   //Тип параметра сообщения
uint CompCount   //Количество подключенных компонентов
}
//Менеджер событий
type VEManEvents{
   arr Descrs of EventDescr 
}

//Элемент списка свойств/событий
type PropItem
{
   ustr Name   //Имя свойства/события
   ustr Value  //Значение свойства/события
   uint Flags  //Флаги PI_*
}


global {
VEManProps cm
VEManEvents ManEvents
}


extern {
   method str CompProp.GetVal <result> ( vComp comp )
}

//Найти описание компонента по идентификатору типу
method CompDescr VEManProps.GetCompDescr( uint typeid )
{
   uint descr
   uint i
   
   fornum i = 0, *this.Descrs
   {
      descr as this.Descrs[i]
      if descr.TypeId == typeid 
      {
         return descr
      } 
   }
   return 0->CompDescr
}

func int sortstr( CompProp left right )
{
   
   //return scmpignore( left.Name.ptr(), right.Name.ptr())      
   return strcmpign( left.PropName.ptr(), right.PropName.ptr() )  
}

//Найти событие в данном описании
method  CompEvent CompDescr.FindEvent( str Name )
{
   uint i
   fornum i=0, *this.Events
   {   
      if this.Events[i].EventName == Name 
      {    
         return this.Events[i]
      }
   }   
   return 0->CompEvent
}

//Найти свойство в данном описании
method CompProp CompDescr.FindProp( str Name )
{
   //int i
   //for i= *this.Props - 1, i >=0, i-- 
   uint i
   fornum i=0, *this.Props
   {
      if this.Props[i].PropName == Name 
      {
         return this.Props[i]
      }
   }
   return 0->CompProp
}



//Добавить новый тип компонента
method VEManProps.AddComp( uint typeid, uint viscomp, str group, str file )
{
   uint i
   uint fnc   
   uint descr as this.Descrs[this.Descrs.expand(1)]
   uint typedef as gettypedef( typeid )
   descr.TypeName = typedef.TypeName
   descr.TypeId = typeid
   descr.VisComp = viscomp   
   descr.File = file  
   
   //Получение свойств наследуемых свойств объекта
   while typedef
   {      
      uint inhtypeid, inh      
      if inhtypeid = typedef.InheritTypeId
      {    
         uint inh as this.GetCompDescr( inhtypeid  )
         if inh 
         {    
            descr.Props.expand( *inh.Props )
            fornum i=0, *inh.Props
            {
               uint left as descr.Props[i] 
               uint right as inh.Props[i]
               left.PropName = right.PropName
               left.PropType = right.PropType
               left.PropFlags = right.PropFlags
               left.AddrGet = right.AddrGet
               left.AddrSet = right.AddrSet
               //left.Vals    = right.Vals
               if right.Vals
               {
                  left.Vals = new( arr, CompEnumVal, 0  )
                  uint lar as left.Vals->arr of CompEnumVal
                  uint rar as right.Vals->arr of CompEnumVal            
                  lar.expand( *rar )                  
                  uint j           
                  fornum j = 0, *lar
                  {
                     lar[j].Name = rar[j].Name
                     lar[j].Val = rar[j].Val
                  }
               }
               left.DefVal  = right.DefVal
            }
            descr.Events.expand( *inh.Events )
            fornum i=0, *inh.Events
            {
               uint left as descr.Events[i] 
               uint right as inh.Events[i]
               left.EventName = right.EventName
               left.EventType = right.EventType
               left.EventId = right.EventId
            }
            break
         }       
         typedef as gettypedef( inhtypeid )
      }
      else 
      {
         break
      }    
   }   
   /*
   if typedef.InheritTypeId 
   {  
      uint inh as this.GetCompDescr( typedef.InheritTypeId )
      if inh 
      {         
         descr.Props.expand( *inh.Props )
         fornum i=0, *inh.Props
         {
            uint left as descr.Props[i] 
            uint right as inh.Props[i]
            left.PropName = right.PropName
            left.PropType = right.PropType
            left.AddrGet = right.AddrGet
            left.AddrSet = right.AddrSet
            left.Vals    = right.Vals
            left.DefVal  = right.DefVal
         }
         descr.Events.expand( *inh.Events )
         fornum i=0, *inh.Events
         {
            uint left as descr.Events[i] 
            uint right as inh.Events[i]
            left.EventName = right.EventName
            left.EventType = right.EventType
            left.EventId = right.EventId
         }
      }
      
   }*/
         
   /*fnc = getid( "mRegProps", 1, %{TypeId, uint, VEManProps} )   
   if fnc : fnc->func( 0, TypeId, this )
   */
   //Сортировка
   
//   fnc = getid( "getevents", 1, %{TypeId, uint, VEManProps} )   
//   if fnc : fnc->func( 0, TypeId, this )
//   descr.Events.sort(&sortstr)
   
   //Получение значений свойств по умолчанию
   uint excomp = new( typeid )//&newcomp( TypeId, 0->vComp )  //создание временного объекта   
   //print( "descr \(typeid) \(*descr.Props )\n" ) 
   fornum i = 0, *descr.Props
   {
      //print( "add3 \(i) \(*descr.Props) \(excomp) \( descr.Props[i].GetVal( excomp->vComp ))\n" )      
      descr.Props[i].DefVal = descr.Props[i].GetVal( excomp->vComp )        
   }   
   destroy( excomp ) //удаление временного объекта
      
} 


method VEManProps.AddComp( uint typeid )
{
   this.AddComp( typeid, 0, "", "" )
}

//Добавить свойства
method VEManProps.AddProps( uint TypeId, collection col )
{
   uint comp as this.GetCompDescr( TypeId )
   uint prop
   uint i
   if &comp 
   {
      i = 0
      while i < *col
      {         
         prop as cm.GetCompDescr( TypeId ).FindProp( col[i]->str )
         if !&prop : prop as comp.Props[comp.Props.expand(1)]         
         prop.PropName = col[i++]->str
         prop.PropType = col[i++]
         prop.PropFlags = col[i++]                  
         prop.AddrGet = getid( prop.PropName, 1, %{TypeId} )         
         prop.AddrSet = getid( prop.PropName, 1, %{TypeId, prop.PropType} )
         //print( p.Name + " \(p.TypeId)\n" )
      }   
      //print( "START SORT \(*descr.Props)\n" )
      comp.Props.sort(&sortstr)
   }
}

//Добавить перечисление возможных значений
method VEManProps.AddPropVals( uint TypeId, str propName, collection col )
{
   
   uint comp as this.GetCompDescr( TypeId )
   if &comp
   {
      uint prop as comp.FindProp( propName )
      if &prop
      {
         if !prop.Vals
         {
            prop.Vals = new( arr, CompEnumVal, 0  )
            //prop.Vals->arr.oftype( CompEnumVal )
            uint ar = prop.Vals            
            ar as (arr[] of CompEnumVal)            
            ar.expand( *col>>1 )            
            uint i, j            
            while i < *col
            {            
               //print( "col=\(col.Val(i)->str)\n" )               
               ar[j].Name = col[i++]->str               
               ar[j++].Val = col[i++]
            }
         }         
      }      
   }
}


//Добавить события
method VEManProps.AddEvents( uint TypeId, collection col )
{
   uint comp as this.GetCompDescr( TypeId )
   uint event
   uint i
   if &comp 
   {
      i = 0
      uint id = *comp.Events
      while i < *col
      {         
         event as comp.Events[comp.Events.expand(1)]         
         event.EventName = col[i++]->str
         event.EventType = col[i++]->str 
         event.EventId = id++       
         //print( "addevents " + event.Name + " \(event.evtype)\n" )
      }   
   }
}


method CompProp.delete
{
   if this.Vals
   {
      destroy( &(this.Vals->arr[] of CompEnumVal) )
   }
}

//Получить имя значения перечисления
method str CompProp.GetEnumName <result>( uint Val )
{
   if this.Vals
   {
      uint ar = this.Vals          
      uint i  
      ar as (arr[] of CompEnumVal)
      fornum i=0, *ar
      {
         if ar[i].Val == Val 
         {
            result = ar[i].Name
            return
         }
      } 
   }   
} 

//Получить значение перечисления по имени
method uint CompProp.GetEnumVal ( str Name, uint res )
{
   if this.Vals
   {
      uint ar = this.Vals          
      uint i  
      ar as (arr[] of CompEnumVal)
      fornum i=0, *ar
      {
         if ar[i].Name == Name 
         {
            res->uint = ar[i].Val
            return 1
         }
      } 
   }
   return 0
}

//Установить значение свойства
method CompProp.SetVal ( vComp comp, ustr val )
{    
   if .AddrSet 
   {
      switch .PropType
      {
         case uint, int
         {
            uint z = val.str().uint()   
            if .Vals
            {  
               if .GetEnumVal( val.str(), &z ) : .AddrSet->func( comp, z )               
            }  
            else : .AddrSet->func( comp, z)         
         }
         case ustr
         {
            .AddrSet->func( comp, val )
         }
         case str
         {
            .AddrSet->func( comp, val.str() )
         }
         default
         {
            if *val
            {
               uint link as comp.GetForm()->vComp.FindComp( val.str() )
               if &link && link.TypeIs( .PropType )
               {
                  .AddrSet->func( comp, link )
               }
            }
            else
            {
               .AddrSet->func( comp, 0 )
            }
         }
      }
   }   
}

//Получить значение свойства
method ustr CompProp.GetVal <result> ( vComp comp )
{
 //  print( "GetVal \(.PropName ) \(.PropType)\n" )
   if this.AddrGet
   {            
      switch this.PropType
      {                
         case ustr 
         {
            result = (this.AddrGet->func( comp, "" ))->ustr         
         }
         case uint, int
         {           
            int z = (this.AddrGet->func( comp ))            
            if this.Vals
            {
               result = this.GetEnumName(z)
            }               
            else
            {                  
               result = "\(z)"
            }
            
         }
         case str
         {
            result = (this.AddrGet->func( comp, "" ))->str 
         }
         default
         {                  
            if this.PropType == vComp || type_isinherit( this.PropType, vComp )
            {
               uint link as this.AddrGet->func( comp )->vComp
               if &link
               {
                  uint checklink as App.FindComp( link )                  
                  if &checklink && checklink.TypeIs( .PropType )
                  {
                     result = link.Name
                  }
                  else 
                  {
                     result = "".ustr()   
                     .SetVal( comp, result ) 
                     
                  }
               }  
            } 
         }
      }
   }   
}


method ustr CompEvent.GetVal <result> ( vComp comp )
{  
//print( "event.GetVal 1 \(this.EventId)\n" )
   uint index = comp.des1->arr of uint[this.EventId] 
//print( "event.GetVal 2 \(index)\n" )   
   if index
   {
      result = ManEvents.Descrs[index].MethodName
   }
//print( "event.GetVal 10\n" )      
} 

define
{
   EVENT_DEL    = 1
   EVENT_NEW    = 2
   EVENT_RENAME = 4
}
method uint CompEvent.SetVal( vComp comp, ustr val )
{  
   uint setres
//print( "event.SetVal 1\n" )
   if val != .GetVal( comp )
   {
      uint newindex = 0
      uint oldindex
      uint i
      fornum i = 1, *ManEvents.Descrs
      {
         uint descr as ManEvents.Descrs[i]          
         if descr.MethodName == val.str()
         {
            if descr.EventType == .EventType 
            {
               newindex = i               
               break
            }
            return 0
         }  
      }
      
      oldindex = comp.des1->arr of uint[this.EventId] 
       
      //index = findevent( val, .EventType )
      if *val
      {
         if !newindex 
         {
            if oldindex
            {
               newindex = oldindex
               oldindex = 0
               setres |= $EVENT_RENAME
            }
            else
            {
               newindex = ManEvents.Descrs.expand( 1 )
               setres |= $EVENT_NEW
               //comp.des1->arr of uint[this.EventId] = newindex            
               //ManEvents.Descrs[newindex].CompCount++
            }                     
            ManEvents.Descrs[newindex].MethodName = val
            ManEvents.Descrs[newindex].EventType = .EventType                   
         }      
         //else
         if !( setres & $EVENT_RENAME )
         {
            comp.des1->arr of uint[this.EventId] = newindex            
            ManEvents.Descrs[newindex].CompCount++
         }
      }
      else
      {
         comp.des1->arr of uint[this.EventId] = 0
      }
      if oldindex
      {
         ManEvents.Descrs[oldindex].CompCount--
         if !ManEvents.Descrs[oldindex].CompCount
         {  
            setres |= $EVENT_DEL
         }
      }        
   }   
   return setres
//print( "event.SetVal 10\n" )   
} 


//Получить список свойств для данной компоненты
method VEManProps.GetPropList( vComp comp, arr arp of PropItem, arr are of PropItem )
{     
   arp.clear()
   are.clear()   
   uint descr as this.GetCompDescr( comp.TypeId )
   if &descr 
   {      
      arp.expand( *descr.Props )
      uint i
      foreach item, arp
      {         
         uint prop as descr.Props[i++]
         item.Name = prop.PropName
         item.Value = prop.GetVal( comp )
         if item.Value == prop.DefVal
         {
            item.Flags |= $PI_DEFVAL
         }      
         if prop.Vals ||
            ( prop.PropType == vComp || type_isinherit( prop.PropType, vComp ))
         {
            item.Flags |= $PI_LIST
         }   
                           
      }
      are.expand( *descr.Events )     
      //print( "            GETEVENT\n" ) 
      i = 0
      foreach item, are
      {         
         
         uint event as descr.Events[i]
         item.Name = event.EventName
         //print( "eventname = \(event.EventName)\n" )
         
         item.Value = event.GetVal( comp )
         /*if item.Value == prop.DefVal
         {
            item.Flags |= $PI_DEFVAL
         }*/      
         item.Flags |= $PI_LIST   
         
         i++                  
      }      
   }
}   


