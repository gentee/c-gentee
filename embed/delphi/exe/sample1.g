/*****************************************************************************/
/*                                                                           */
/*                           Sample 1                                        */
/*  Parameters:                                                              */
/*         IN instr - pointer to an ANSI char array that contains string     */
/*  Return: length of output string                                          */
/*                                                                           */
/*****************************************************************************/


func uint sample1Funct(uint instr, uint outstr)
{
    str st1           // a new empty string
    st1.copy(instr)   // place the char array to string
    print(st1)

    
    st1 += " возвращено отправителю"
   
    mcopy(outstr, st1.ptr(), (*st1 + 1))

    return st1.ptr()
}