<h1>Reverse Engineering Challenge 2</h2>
<i>What does this code do?<br>(Optimising GCC 4.8.2 -m32)<br></i>
<pre><code>

&ltf&gt:
   0:          mov    eax,DWORD PTR [esp+0x4]
   4:          bswap  eax
   6:          mov    edx,eax
   8:          and    eax,0xf0f0f0f
   d:          and    edx,0xf0f0f0f0
  13:          shr    edx,0x4
  16:          shl    eax,0x4
  19:          or     eax,edx
  1b:          mov    edx,eax
  1d:          and    eax,0x33333333
  22:          and    edx,0xcccccccc
  28:          shr    edx,0x2
  2b:          shl    eax,0x2
  2e:          or     eax,edx
  30:          mov    edx,eax
  32:          and    eax,0x55555555
  37:          and    edx,0xaaaaaaaa
  3d:          add    eax,eax
  3f:          shr    edx,1
  41:          or     eax,edx
  43:          ret
</code></pre>
<h3>Analysis</h3>
<h4>ASM Syntax</h4>
<b>MOV:</b>Move value in source register to destination register<br>
<b>BSWAP:</b>Byte Swap. Swap the byte ordering<br>
<b>AND:</b>Bitwise AND operation. result goes in destination<br>
<b>OR</b>Bitwise OR operation. result goes in destination<br>
<b>SHR:</b> Right Shift toward LSB. Moves 0 in to MSB<br>
<b>SHL:</b> Left shift towar MSB. Moves 0 in to LSB<br>
<b>RET:</b> function Return<br>
<h4>Registers</h4>
<b>EAX:</b>32 bit General Purpose register<br>
<b>EDX:</b>32 bit General Purpose register<br>
<h3>What does this function do</h3>
This is 32 bit compiled - function args are passed via the stack. There is one argument.<br>
As revealed in the code below this function takes a single argument and reverses the order of the individual bits.
It does this by first swapping the bytes then swapping smaller groups of bits.
<pre><code>
foo(int x){

//swap byte order line 4 BSWAP eg x=abcd->dcba
//swap byte 3|2 with 1|0 x=cdab
	y=x
	x=x<<16
	y=y>>16
	x=x|y
	
//swap byte 3 with byte 2 and byte 1 with byte 0 x=dcba
	y=x
	x=(x&0x00ff00ff)<<8
	y=(y&0xff00ff00)>>8
	x=x|y

//lines 6 to 1b take groupings of 4 bits and swap with the nextdoor group
	y=x;

//line 8 & line d
	x=x&0x0f0f0f0f;  //x=0000???? 0000???? 0000???? 0000????
	y=y&0xf0f0f0f0;  //y=????0000 ????0000 ????0000 ????0000

//line 13, line 16
	y=y>>4;  //y=0000???? 0000???? 0000???? 0000????
	x=x<<4;  //x=????0000 ????0000 ????0000 ????0000

//line 19, line 1b
	x=x|y;

lines 1b to line 30 take groupings of 2 bits and swap with the nextdoor group
	y=x

//line 1d, line 22
	x=x&0x33333333  //x=00??00?? 00??00?? 00??00?? 00??00??
	y=y&0xcccccccc  //y=??00??00 ??00??00 ??00??00 ??00??00

//line 28, line 2b
	y=y>>2  //y=00??00?? 00??00?? 00??00?? 00??00??
	x=x<<2  //x=??00??00 ??00??00 ??00??00 ??00??00

//line 2e, line 30
	x=y|x;

lines 32 to 41 swap individual bits with nextdoor bits
	y=x;

//line 32, line 37
	x=x&0x55555555  //x=0?0?0?0? 0?0?0?0? 0?0?0?0? 0?0?0?0?
	y=y&0xaaaaaaaa  //y=?0?0?0?0 ?0?0?0?0 ?0?0?0?0 ?0?0?0?0

//line 3d - x+x results in left shift by 1 
	x=x+x;  //x=?0?0?0?0 ?0?0?0?0 ?0?0?0?0 ?0?0?0?0
	y=y>1   //y=0?0?0?0? 0?0?0?0? 0?0?0?0? 0?0?0?0?
	x=y|x;	


//in summary this program reverses the order at the bit level (eg 01101001 -> 10010110)

}
</code></pre>
