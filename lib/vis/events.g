

type vloc
{
   int  left   
   int  top
   uint width
   uint height
}

define <export>{
   e_winmsg       = 1
   e_winntf       = 2
   e_poschanging  = 3
   e_mouse        = 4
   e_key          = 5
   e_paint        = 6
//   e_ownersize    = 7
   e_poschanged   = 8
   
   e_create = 10
   e_insert = 11
   e_remove = 12
   e_focus  = 13
   e_update = 14
} 



type evparEvent
{
   uint sender
   uint eventtypeid
   uint code   
}

type evEvent
{
   uint obj
   uint id
   uint eventtypeid   
}

/*type descrevent {
   str nameevent
   str namemethod
}*/

method evEvent evEvent.init
{
   this.eventtypeid = evparEvent
   return this
}


define <export>{
   evmMove  = 1  
   evmLDown = 2
   evmLDbl  = 3
   evmLUp   = 4
   evmRDown = 5
   evmRDbl  = 6
   evmRUp   = 7
   evmMDown = 8
   evmMDbl  = 9
   evmMUp   = 10    
   evmWhellUp   = 11 
   evmWhellDown = 12
   evmLeave   = 13
   evmActivate = 14
   
   evkDown  = 1
   evkPress = 2
   evkUp    = 3
   //evmOn  = 13
   //evmOut = 14
   
   mstAlt   = 0x001
   mstCtrl  = 0x002
   mstShift = 0x004
   mstWin   = 0x010
   mstLBtn  = 0x100
   mstRBtn  = 0x200
   mstMBtn  = 0x400
}

type eventwnd <inherit = evparEvent>
{
   uint wnd 
   uint message 
   uint wpar 
   uint lpar
}

type oneventwnd <inherit=evEvent> :

method oneventwnd oneventwnd.init
{
   this.eventtypeid = eventwnd
   return this
}


type evparMouse <inherit = evparEvent>
{
   uint evmtype
   uint mstate
   int x
   int y
   uint ret   
}

type evMouse <inherit=evEvent> :

method evMouse evMouse.init
{
   this.eventtypeid = evparMouse
   return this
}


type evparKey <inherit = evparEvent>
{
   uint evktype
   uint key
   uint mstate
   
}

type evKey <inherit=evEvent> :

method evKey evKey.init
{
   this.eventtypeid = evparKey
   return this
}


type eventpos <inherit = evparEvent>
{
   vloc loc
   uint move
   uint par
}

type oneventpos <inherit=evEvent> :

method oneventpos oneventpos.init
{
   this.eventtypeid = eventpos
   return this
}

type evparValUstr <inherit=evparEvent>
{
   ustr val
}

type evValUstr <inherit=evEvent> :

method evValUstr evValUstr.init
{
   this.eventtypeid = evValUstr 
   return this
}

type evparValUint <inherit=evparEvent> 
{
   uint val
}

type evValUint <inherit=evEvent> :

method evValUint evValUint.init
{
   this.eventtypeid = evparValUint
   return this
}

type evparValColl <inherit=evparEvent> 
{
   collection val
}

type evValColl <inherit=evEvent> :

method evValColl evValColl.init
{
   this.eventtypeid = evparValColl
   return this
}

type evparQuery <inherit=evparValUint>
{
   uint flgCancel
}

type evQuery <inherit=evValUint>
{  
}   

method evQuery evQuery.init
{
   this.eventtypeid = evparQuery
   return this   
}


method uint evEvent.run( evparEvent ev )
{
   if this.id 
   {        
      ev.eventtypeid = this.eventtypeid
      
      return this.id->func( this.obj, ev ) 
   }
   return 0
}


method uint evEvent.run()
{ 
   if this.id 
   {   
      evparEvent ev
      
      ev.eventtypeid = this.eventtypeid
      //print( "run=\(this.obj) \n" )
      return this.id->func( this.obj, ev ) 
   }
   return 0
}




method uint evEvent.is()
{
   return this.id
}
/*
method evEvent.set( any obj, uint funcid )
{
   this.id = funcid
   this.obj = obj   
}*/

method uint evEvent.Run( /*any Sender,*/ evparEvent ev )
{
   if this.id 
   {         
      ev->evparEvent.eventtypeid = this.eventtypeid
      return this.id->func( this.obj, /*Sender,*/ ev ) 
   }
   return 0
}

method uint evEvent.Run( /*any Sender,*/ evparEvent ev, vComp sender )
{
   if this.id 
   {         
      ev.eventtypeid = this.eventtypeid
      ev.sender = &sender
      return this.id->func( this.obj, /*Sender,*/ ev ) 
   }
   return 0
}

method uint evEvent.Run( vComp sender )
{
   if this.id 
   {  
      evparEvent ev
      ev.sender = &sender  
      ev.eventtypeid = this.eventtypeid
      //print( "run=\(this.obj) \(&sender)\n" )
      return this.id->func( this.obj, ev ) 
   }
   return 0
}

method evEvent.Set( any obj, uint funcid )
{
   this.id = funcid
   this.obj = obj   
}

operator evEvent = ( evEvent dest, evEvent src )
{
   dest.obj         = src.obj
   dest.id          = src.id
   return dest
}


type evparBeforeMove <inherit=evparEvent> 
{   
   uint CurItem    
   uint DestItem 
   uint Flag 
   uint flgCancel
}
type evBeforeMove <inherit=evEvent> :

method evBeforeMove evBeforeMove.init
{
   this.eventtypeid = evparBeforeMove
   return this
}

type evparAfterMove <inherit=evparEvent> 
{   
   uint CurItem
   uint DestItem
   uint Flag
}

type evAfterMove <inherit=evEvent> :

method evAfterMove evAfterMove.init
{
   this.eventtypeid = evparAfterMove
   return this
}