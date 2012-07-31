
import "user32.dll"
{
	uint MessageBoxA(uint, uint , uint, uint);
}

global{
    str gStr;// ="jhgh\)"
}

type rrr1{
int rr_i;
int rr_d
}

method uint rrr1.write(rrr1 a0, str filename )
{
    int ff = 8
    dbgBreak();
    return ff+a0.rr_i;
}


func hello <main>
{
    rrr1  testT;
    gStr = "jhgh)";
    dbgPrint("test... ok\ntest new ... ok");//перчать текста в лог "debug"
    dbgBreak();//остановка скрипта на следущей строке
    MessageBoxA(0, "Test\"".ptr(), "ge".ptr(), 0);
    testT.write(testT, "yfhgfh");

}