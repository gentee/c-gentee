include { "internet.g" }

import "ws2_32.dll" {
   
   int  setsockopt( uint, int, int, uint, int )
   int  getsockopt( uint, int, int, uint, uint )                 
   int sendto( uint, uint, int, int, uint, int )            
   int recvfrom( uint, uint, int, int, uint, uint )
   uint WSASocketA( uint, uint, uint, uint, uint, uint )->WSASocket
   uint getprotobyname( uint )
}

import "kernel32.dll" {
   uint GetTickCount()
   Sleep( uint )
   uint GetCurrentProcessId()
}

define {
   SOL_SOCKET   =   0xFFFF
   SO_SNDTIMEO  =   0x1005          /* send timeout */
   SO_RCVTIMEO  =   0x1006          /* receive timeout */
   
   ICMP_ECHO      = 8
   ICMP_ECHOREPLY = 0
   
   MAX_PACKET = 1024   
   
   INADDR_ANY   =  0x00000000
   WSAETIMEDOUT =  10060
}

type icmphdr { 
  byte   icmp_type     /* type of message */ 
  byte   icmp_code     /* type sub code */ 
  ushort icmp_cksum    /* ones complement cksum */ 
  ushort icmp_id       /* identifier */ 
  ushort icmp_seq      /* sequence number */
  uint   timestamp
}

type protoent {
    uint  p_name
    uint  p_aliases
    short p_proto;
};


func ushort checksum( uint b, uint len ) 
{ 
  uint lsum = 0
  uint m = b + len
  
  while b < m 
  { 
    lsum += b->ushort /* add word value to sum */
    b += 2
  }
 
  /*if( len % 1 ) 
  {     
     lsum += ( b - 1 )->ushort;
  }*/
 
  lsum = (lsum & 0xffff) + (lsum>>16) 
  lsum += (lsum >> 16)
 
  return ( ~lsum ) 
}

func uint ping( str hostname, uint timeout, uint datasize, uint repeat, 
                uint perrcode )
{  
   uint sock
   uint hp, addr
   uint seq_no
   int bwrote, bread
   uint i   
   sockaddr_in dest from
   uint tmp
   buf  icmp recv
   uint icmp_d recv_d   
   timeout = max( timeout, 100 )
   datasize = max( datasize, 1 )
   uint pr
   uint he
   uint tmperror
 
   if !perrcode : perrcode = &tmperror 
   
   pr as getprotobyname("icmp".ptr())->protoent
   if !&pr
   {
      perrcode->uint = 1 
      return 0 
   } 

   sock = createsocket( $AF_INET, $SOCK_RAW, pr.p_proto)//$IPPROTO_ICMP 
   
   if sock == $INVALID_SOCKET 
   {
      perrcode->uint = 2 
      return 0 
   }
    
   if setsockopt( sock, $SOL_SOCKET, $SO_RCVTIMEO, &timeout, 4 ) == $SOCKET_ERROR ||
      setsockopt( sock, $SOL_SOCKET, $SO_SNDTIMEO, &timeout, 4 ) == $SOCKET_ERROR 
   {      
      perrcode->uint = 3 
      return 0   
   }  
   
   dest.sin_addr = inet_addr( hostname.ptr() )
   if dest.sin_addr == 0xFFFFFFFF 
   {
      he = gethostbyname( hostname.ptr() )
      if !he
      { 
         perrcode->uint = 4
         return 0
      }
      dest.sin_addr = ( he->hostent.h_addr_list->uint)->uint
   }
   dest.sin_family = $AF_INET;
   
   datasize += sizeof( icmphdr ); 
   datasize = min( $MAX_PACKET, datasize )
   
   icmp.expand($MAX_PACKET);
   recv.expand($MAX_PACKET);
     
   icmp_d as icmp.ptr()->icmphdr 
   
   icmp_d.icmp_type = $ICMP_ECHO;
   
   icmp_d.icmp_id = ushort( GetCurrentProcessId() );
   
   fornum i = sizeof( icmphdr ), datasize
   {
     icmp[i] = i % 256  
   }
   
   from.sin_addr = $INADDR_ANY
   from.sin_family = $AF_INET
      
   repeat = max( 1, repeat )
   while( repeat-- ) 
   {    
      icmp_d.icmp_cksum = 0;
      icmp_d.timestamp = GetTickCount();
      icmp_d.icmp_seq = seq_no++;
      icmp_d.icmp_cksum = checksum( &icmp_d, datasize );
      
      bwrote = sendto( sock, &icmp_d, datasize, 0, &dest, sizeof(sockaddr_in) )
      if ( bwrote == $SOCKET_ERROR )
      {      
         perrcode->uint = 5
         break   
      }
      bwrote = sizeof( sockaddr_in )
      bread = recvfrom( sock, recv.ptr(), $MAX_PACKET, 0, &from, &bwrote )
         
      if bread == $SOCKET_ERROR  
      {
         if WSAGetLastError() == $WSAETIMEDOUT && repeat : continue
         perrcode->uint = 6
         break  
      }
      recv_d = recv.ptr()
      recv.use = bread         
      recv_d += ( recv_d->byte & 0x0F ) * 4
         
      recv_d as icmphdr
      i = GetTickCount() - recv_d.timestamp
      
      if recv_d.icmp_type != $ICMP_ECHOREPLY 
      {
         perrcode->uint = 7
         break  
      }
      if recv_d.icmp_id == icmp_d.icmp_id && 
         recv_d.icmp_seq == icmp_d.icmp_seq
      {
         return max( 1, i ) 
      }
      Sleep( 1000 )
   }
   return 0;
}

