;Q: cpu执行程序，程序返回前，data段中的数据为？
;A: 2050:0000  23 01 56 04 00 00 00 00
;Q: cpu执行程序，程序返回前，cs= ,ss= ,ds= 
;A: DS=2050  ES=203D  SS=2051  CS=204D
;Q:设程序加载后，code段的段地址为x,则data段的段地址为，stack的段地址为
;A:data=x+3 ,stack=x+4
assume cs:code,ds:data,ss:stack

code segment
    start:
          mov  ax,stack
          mov  ss,ax
          mov  sp,16

          mov  ax,data
          mov  ds,ax

          push ds:[0]
          push ds:[2]
          pop  ds:[2]
          pop  ds:[0]

          mov  ax,4c00h
          int  21h
code ends

data segment
         dw 0123h,0456h
data ends

stack segment
          dw 0,0
stack ends

end start