define
{
   NUMSYM = 256
}
type pos
{
   byte state
   byte afunc
   byte retstate
}
/*type r
{
   arr of str
}*/
global 
{
  arr res[0,$NUMSYM] of pos
  uint cres = 0
  uint pres = 0
  uint mres = 0
  arr arbeg of str 
  hash names
  uint main
 //  arr ar of arr of str   
} 

operator pos = ( pos l r )
{
   l.state = r.state
   l.afunc = r.afunc
   l.retstate = r.retstate
   return l
}

method pos.getpos( str s )
{
   uint i
   arrstr ar 
   s.split( ar, '/',  /*$SPLIT_EMPTY |*/ $SPLIT_NOSYS )
   if *ar 
   {
      if (ar[0])[0] =='_'
      {
         this.state = names[ar[0]]
      }
      else
      {        
         this.state = ar[0].int()         
         if this.state != 255 && this.state
         { 
            this.state += pres 
         }          
      }
      this.afunc = 0
      this.retstate = 0 
      if *ar > 1
      {         
         this.afunc = ar[1].int()         
         if *ar > 2
         {
            this.retstate = ar[2].int()            
            if this.retstate != 255 && this.retstate
            { 
               this.retstate += pres               
            }
         }
      }
   }   
} 

func proc( str s, uint beg )
{   
   uint i, j
   arrstr ar
   pos  p,pd

   s.split( ar, ',', $SPLIT_EMPTY | $SPLIT_NOSYS /*| $SPLIT_QUOTE*/ )   
   if beg 
   {
      i=0
      res.expand( $NUMSYM )
      pd.getpos( ar[1] )
      /*i=0
      print( ?(i,",","") + ar[i] )
      i=1
      print( ?(i,",","") + ar[i] )*/
      fornum j=0, $NUMSYM
      {
         res[cres,j] = pd
      } 
      p.state = cres+1
      //res[cres,0] = p
      fornum i=2, *ar
      {
         p = pd         
         p.getpos(ar[i])
         //print( ?(i,",","") + ar[i] )                  
         fornum j=0, *arbeg[i]
         {
            res[cres, uint((arbeg[i])[j])] = p
         }
      }     
      cres++
      
   }
   else
   {    
      arbeg.cut( 0 )
      arbeg.expand( *ar )
      if ar[0] == "_main" {
         main = 1
         mres = cres
         //cres = 0         
      }
       
      names[ar[0]] = cres+1
      
      i=0
      print( ?(i,",","") + ar[i] )
      i=1
      print( ?(i,",","") + ar[i] )
      fornum i=2, *ar
      {
         print( ?(i,",","") + ar[i] )
         arbeg[i].setlen(0)
         if (ar[i])[0] == 0x27
         {            
            arbeg[i].appendch((ar[i])[1])
         }
         elif (ar[i])[0] == 'q'
         {          
            arbeg[i].appendch( 0x27 )  
         }
         elif (ar[i])[0] == 's'
         {  
            arbeg[i].appendch(0x20)          
            arbeg[i].appendch(0x09)            
            arbeg[i].appendch(0x0D)
            arbeg[i].appendch(0x0A)
         }         
      }
      print( "\n" )
   }   
}


func tblget<main>
{
   str s, curs
   uint i, j, beg = 0
   uint state = 0
   
   s.read( "sp.txt" )
   while i < *s
   {
      switch state
      {
         case 0
         {
            if s[i]=='(': state = 1
            elif s[i]=='-': state = 2
            else
            {    
               i--           
               state = 3               
            }
         }
         case 1
         {
            if s[i]==')': state = 2
         }
         case 2
         {
            if s[i]==0x0A
            {
               state = 0
               beg = 0
               pres = cres
            }
         }
         case 3
         {          
            if s[i] == 0x0A 
            {
               state = 0
               proc( curs, beg )
               beg = 1                         
               curs.clear()               
            }
            else
            {
               curs.appendch( s[i])
            }
         }
      } 
      i++         
   }
   
   str a
   print( "\( cres ) \( mres )\n" )
   fornum i=0, cres
   {
      fornum j=0, $NUMSYM
      { 
         if res[i,j].state && res[i,j].state !=255
         {
            if res[i,j].state > mres
            {
               res[i,j].state -= mres
            }
            else
            {
               res[i,j].state += cres-mres 
            }            
         }
         if res[i,j].retstate && res[i,j].retstate !=255
         {
            if res[i,j].retstate > mres
            {
               res[i,j].retstate -= mres
            }
            else
            {
               res[i,j].retstate += cres-mres
            }            
         }         
      }
   }
   res.insert( 0, (cres-mres)*$NUMSYM )
   //mres+1
   fornum i = 0, cres-mres
   {
      fornum j= 0, $NUMSYM
      {
         res[i,j]=res[i + cres,j]  
      }
   }
   res.del( cres*$NUMSYM, (2*cres-mres)*$NUMSYM )
/* 
   fornum i=0, *res/$NUMSYM
   {
      fornum j=0, 10
      {
         a.clear()
         int2str( a, "%x ", res[i,j].state )
         print( a )
      }
      print( "\n" )
   }
   */ 
   res->buf.write("sp.tbl")
   a.clear()
   fornum j=0, 255
   {      
      a@" "
      if j >= 0x20 : a.appendch( j )
      else : a@" "      
   }
   a@"\n"
   fornum i=0, *res/$NUMSYM
   {   
      fornum j=0, 255
      {
         //a.clear()
         a.out4( "%2x", res[i,j].state )
         //print( a )
      }
      a@"\n"
   }
   a.write( "spt.txt")
   getch()
}
