method ustr ustr.replace( uint offset size, ustr value )
{
   if offset >= *this : this += value
   else
   {
      value->buf.use -= 2
      this->buf.replace( offset << 1, size << 1, value->buf )   
      value->buf.use += 2
   }
   return this
}

method ustr ustr.insert( uint offset, ustr value )
{
   return this.replace( offset, 0, value )
}


operator uint ==( ustr left, str right )
{     
   return left == right.ustr()
}

operator uint ==( str left, ustr right )
{     
   return left.ustr() == right
}