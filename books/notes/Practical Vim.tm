<TeXmacs|2.1.2>

<style|<tuple|article|chinese>>

<\body>
  <doc-data|<doc-title|Practical Vim>>

  \;

  <abstract-data|<abstract|<space|2em>\<#5BF9\>\<#4E8E\>vim\<#6765\>\<#8BF4\>\<#FF0C\>\<#719F\>\<#7EC3\>\<#7684\>\<#76F2\>\<#6253\>\<#662F\>\<#5F88\>\<#91CD\>\<#8981\>\<#7684\>\<#3002\>\<#4E00\>\<#65E6\>\<#5B8C\>\<#6210\>\<#4E86\>vimtutor\<#7684\>\<#8BAD\>\<#7EC3\>\<#FF0C\>\<#5E76\>\<#4E86\>\<#89E3\>\<#5982\>\<#4F55\>\<#4E3A\>vimrc\<#914D\>\<#7F6E\>\<#4E00\>\<#4E9B\>\<#57FA\>\<#672C\>\<#9009\>\<#9879\>\<#4E4B\>\<#540E\>\<#FF0C\>\<#5C31\>\<#53EF\>\<#4EE5\>\<#7528\>vim\<#5B8C\>\<#6210\>\<#5B9E\>\<#9645\>\<#5DE5\>\<#4F5C\>\<#4E86\>\<#3002\>\<#867D\>\<#7136\>\<#6B65\>\<#5C65\>\<#8E52\>\<#8DDA\>\<#FF0C\>\<#4F46\>\<#7EC8\>\<#6709\>\<#56DE\>\<#62A5\>\<#3002\>>>

  <section|Appendix 1 Vimtutor>

  <space|2em>\<#5728\>\<#7EC8\>\<#7AEF\>\<#4E2D\>\<#952E\>\<#5165\>vimtutor\<#5373\>\<#53EF\>\<#8FDB\>\<#5165\>\<#6559\>\<#7A0B\>\<#3002\>

  <\big-table|<tabular|<tformat|<table|<row|<cell|>>>>><block|<tformat|<table|<row|<cell|Lesson1>|<cell|>>|<row|<cell|q!>|<cell|\<#5F3A\>\<#5236\>\<#9000\>\<#51FA\>\<#7F16\>\<#8F91\>\<#5668\>\<#5E76\>\<#4E0D\>\<#4FDD\>\<#5B58\>\<#4EFB\>\<#4F55\>\<#6539\>\<#52A8\>>>|<row|<cell|x>|<cell|\<#666E\>\<#901A\>\<#6A21\>\<#5F0F\>\<#4E0B\>\<#5220\>\<#9664\>\<#5B57\>\<#7B26\>>>|<row|<cell|A>|<cell|\<#5728\>\<#5F53\>\<#524D\>\<#53E5\>\<#7684\>\<#6700\>\<#540E\>\<#6DFB\>\<#52A0\>\<#5B57\>\<#7B26\>(append)>>|<row|<cell|Lesson2>|<cell|>>|<row|<cell|d>|<cell|d
  is the delete opreator>>|<row|<cell|dw >|<cell|\<#5220\>\<#9664\>\<#4E00\>\<#4E2A\>\<#5355\>\<#8BCD\>>>|<row|<cell|d<math|$>>|<cell|\<#5220\>\<#9664\>\<#4ECE\>\<#5149\>\<#6807\>\<#5230\>\<#53E5\>\<#5C3E\>\<#7684\>\<#4E00\>\<#5207\>>>|<row|<cell|de>|<cell|\<#5220\>\<#9664\>\<#4ECE\>\<#5149\>\<#6807\>\<#5230\>\<#5355\>\<#8BCD\>\<#5C3E\>\<#7684\>\<#4E00\>\<#5207\>>>|<row|<cell|w>|<cell|\<#79FB\>\<#52A8\>\<#5230\>\<#4E0B\>\<#4E00\>\<#4E2A\>\<#5355\>\<#8BCD\>(word)>>|<row|<cell|e>|<cell|\<#79FB\>\<#52A8\>\<#5230\>\<#4E0B\>\<#4E00\>\<#4E2A\>\<#5355\>\<#8BCD\>\<#5C3E\>(end
  of the word)>>|<row|<cell|0>|<cell|\<#79FB\>\<#52A8\>\<#5230\>\<#53E5\>\<#5B50\>\<#5F00\>\<#5934\>>>|<row|<cell|\<#6570\>\<#5B57\>numbers>|<cell|\<#91CD\>\<#590D\>\<#64CD\>\<#4F5C\>\<#7684\>\<#6B21\>\<#6570\>>>|<row|<cell|eg:d2w>|<cell|\<#5220\>\<#9664\>\<#4E24\>\<#4E2A\>\<#5355\>\<#8BCD\>>>|<row|<cell|dd>|<cell|\<#5220\>\<#9664\>\<#4E00\>\<#6574\>\<#884C\>>>|<row|<cell|u>|<cell|\<#64A4\>\<#9500\>\<#4E0A\>\<#4E00\>\<#4E2A\>\<#547D\>\<#4EE4\>(undo)>>|<row|<cell|U>|<cell|\<#64A4\>\<#9500\>\<#5BF9\>\<#5F53\>\<#524D\>\<#884C\>\<#7684\>\<#6240\>\<#6709\>\<#64CD\>\<#4F5C\>>>|<row|<cell|\<less\>C-R\<gtr\>>|<cell|\<#64A4\>\<#9500\>undo>>|<row|<cell|Lesson3>|<cell|>>|<row|<cell|P>|<cell|\<#5C06\>\<#5220\>\<#9664\>\<#7684\>\<#6587\>\<#672C\>\<#590D\>\<#5236\>\<#5728\>\<#5149\>\<#6807\>\<#5904\>>>|<row|<cell|r>|<cell|\<#66FF\>\<#6362\>\<#5149\>\<#6807\>\<#5904\>\<#7684\>\<#5B57\>\<#7B26\>>>|<row|<cell|c>|<cell|(change)\<#7528\>\<#7684\>\<#65B9\>\<#5F0F\>\<#4E0E\>d(delete)\<#76F8\>\<#540C\>\<#FF0C\>\<#53EA\>\<#662F\>\<#64CD\>\<#4F5C\>\<#540E\>\<#4F1A\>\<#8FDB\>\<#5165\>insert\<#6A21\>\<#5F0F\>>>|<row|<cell|<subtable|<tformat|<table|<row|<cell|cc>>>>>>|<cell|\<#5220\>\<#9664\>\<#6574\>\<#53E5\>\<#540E\>\<#8F93\>\<#5165\>>>|<row|<cell|Lesson4>|<cell|>>|<row|<cell|\<less\>C-G\<gtr\>>|<cell|\<#663E\>\<#793A\>\<#5F53\>\<#524D\>\<#6587\>\<#4EF6\>\<#540D\>\<#4EE5\>\<#53CA\>\<#5149\>\<#6807\>\<#5728\>\<#6587\>\<#4EF6\>\<#4E2D\>\<#7684\>\<#4F4D\>\<#7F6E\>>>|<row|<cell|G>|<cell|\<#79FB\>\<#52A8\>\<#5230\>\<#6587\>\<#4EF6\>\<#5C3E\>\<#90E8\>>>|<row|<cell|gg>|<cell|\<#79FB\>\<#52A8\>\<#5230\>\<#6587\>\<#4EF6\>\<#5934\>\<#90E8\>>>|<row|<cell|numbers+G>|<cell|\<#8DF3\>\<#5230\>numbers\<#6240\>\<#6307\>\<#7684\>\<#884C\>\<#6570\>>>|<row|<cell|/(word)>|<cell|\<#4F7F\>\<#7528\>/\<#8FDB\>\<#884C\>\<#5355\>\<#8BCD\>\<#641C\>\<#7D22\>>>|<row|<cell|/(word)+n>|<cell|\<#641C\>\<#7D22\>\<#5230\>\<#76F8\>\<#5E94\>\<#5355\>\<#8BCD\>\<#540E\>\<#6309\>n\<#4F1A\>\<#8DF3\>\<#8F6C\>\<#5230\>\<#4E0B\>\<#4E00\>\<#4E2A\>\<#76F8\>\<#5E94\>\<#5355\>\<#8BCD\>>>|<row|<cell|/(word)+N>|<cell|\<#53CD\>\<#65B9\>\<#5411\>\<#8DF3\>\<#8F6C\>>>|<row|<cell|?(word)>|<cell|\<#641C\>\<#7D22\>\<#5230\>\<#76F8\>\<#5E94\>\<#5355\>\<#8BCD\>\<#540E\>\<#6309\>n\<#4F1A\>\<#8DF3\>\<#8F6C\>\<#5230\>\<#4E0A\>\<#4E00\>\<#4E2A\>\<#76F8\>\<#5E94\>\<#5355\>\<#8BCD\>>>|<row|<cell|\<less\>C-O\<gtr\>>|<cell|\<#56DE\>\<#5230\>\<#8DF3\>\<#8F6C\>\<#524D\>\<#7684\>\<#4F4D\>\<#7F6E\>>>|<row|<cell|\<less\>C-I\<gtr\>>|<cell|\<less\>C-O\<gtr\>\<#7684\>\<#9006\>\<#8FC7\>\<#7A0B\>>>|<row|<cell|%>|<cell|\<#5728\>{\<#FF0C\>[\<#FF0C\>(\<#4E0A\>\<#4F7F\>\<#7528\>\<#4F1A\>\<#8DF3\>\<#8F6C\>\<#5230\>\<#5BF9\>\<#5E94\>\<#7684\>\<#62EC\>\<#53F7\>\<#3002\>\<#5BF9\>\<#4E8E\>\<#62EC\>\<#53F7\>\<#7C7B\>debug\<#5F88\>\<#6709\>\<#7528\>>>|<row|<cell|:s/old/new>|<cell|\<#4EC5\>\<#6539\>\<#52A8\>\<#5F53\>\<#524D\>\<#53E5\>\<#5B50\>\<#4E2D\>\<#7684\>\<#7B2C\>\<#4E00\>\<#4E2A\>old\V\<gtr\>new>>|<row|<cell|:s/old/new/g>|<cell|\<#4EC5\>\<#6539\>\<#52A8\>\<#5F53\>\<#524D\>\<#53E5\>\<#5B50\>\<#4E2D\>\<#7684\>\<#5168\>\<#90E8\>\<#7684\>old\V\<gtr\>new>>|<row|<cell|:#,#s/old/new/g>|<cell|\<#4EC5\>\<#6539\>\<#52A8\>\<#4ECE\>#\V#\<#53E5\>\<#5B50\>\<#4E2D\>\<#7684\>\<#5168\>\<#90E8\>\<#7684\>old\V\<gtr\>new\<#FF08\>\<#4E24\>\<#4E2A\>#\<#662F\>\<#884C\>\<#53F7\>)>>|<row|<cell|:%s/old/new/g>|<cell|\<#6539\>\<#52A8\>\<#5F53\>\<#524D\>\<#6587\>\<#4EF6\>\<#4E2D\>\<#7684\>\<#5168\>\<#90E8\>\<#7684\>old\V\<gtr\>new>>|<row|<cell|:%s/old/new/gc>|<cell|\<#6539\>\<#52A8\>\<#5F53\>\<#524D\>\<#6587\>\<#4EF6\>\<#4E2D\>\<#7684\>\<#5168\>\<#90E8\>\<#7684\>old\V\<gtr\>new\<#FF0C\>\<#4F46\>\<#6539\>\<#52A8\>\<#524D\>\<#4F1A\>\<#5148\>\<#8BF7\>\<#6C42\>\<#8BB8\>\<#53EF\>>>>>>>
    vimtutor
  </big-table>

  <\small-table>
    <block|<tformat|<twith|table-vmode|auto>|<twith|table-hyphen|y>|<table|<row|<cell|Lesson5>|<cell|>>|<row|<cell|:!>|<cell|\<#540E\>\<#9762\>\<#53EF\>\<#4EE5\>\<#8DDF\>\<#968F\>shell\<#547D\>\<#4EE4\>
    eg: :!ls>>|<row|<cell|:w [filename]>|<cell|\<#5C06\>\<#5F53\>\<#524D\>\<#6587\>\<#4EF6\>\<#4FDD\>\<#5B58\>>>|<row|<cell|V>|<cell|\<#8FDB\>\<#5165\>visual\<#6A21\>\<#5F0F\>\<#FF0C\>\<#53EF\>\<#4EE5\>\<#4EE5\>\<#6587\>\<#4EF6\>\<#5757\>\<#7684\>\<#5F62\>\<#5F0F\>\<#5927\>\<#9762\>\<#79EF\>\<#5730\>\<#9009\>\<#4E2D\>\<#6587\>\<#672C\>>>|<row|<cell|:r
    [filename]>|<cell|\<#5C06\>filename\<#4E2D\>\<#7684\>\<#5185\>\<#5BB9\>\<#7C98\>\<#8D34\>\<#5728\>\<#5149\>\<#6807\>\<#5904\>>>|<row|<cell|:r
    ![shell command]>|<cell|\<#5C06\>shell\<#4E2D\>\<#7684\>\<#5185\>\<#5BB9\>\<#7C98\>\<#8D34\>\<#5728\>\<#5149\>\<#6807\>\<#5904\>
    eg: :r !dir>>|<row|<cell|Lesson6>|<cell|>>|<row|<cell|o>|<cell|\<#65B0\>\<#5F00\>\<#4E00\>\<#884C\>\<#5E76\>\<#76F4\>\<#63A5\>\<#8FDB\>\<#5165\>\<#63D2\>\<#5165\>\<#6A21\>\<#5F0F\>>>|<row|<cell|a>|<cell|\<#5728\>\<#5F53\>\<#524D\>\<#5149\>\<#6807\>\<#7684\>\<#540E\>\<#65B9\>\<#63D2\>\<#5165\>>>|<row|<cell|R>|<cell|\<#8FDB\>\<#5165\>replace\<#6A21\>\<#5F0F\>\<#FF0C\>\<#53EF\>\<#4EE5\>\<#66FF\>\<#6362\>\<#591A\>\<#4E2A\>\<#5B57\>\<#7B26\>>>|<row|<cell|v>|<cell|\<#4EE5\>\<#5149\>\<#6807\>\<#79FB\>\<#52A8\>\<#7684\>\<#65B9\>\<#5F0F\>\<#9009\>\<#4E2D\>\<#5B57\>\<#7B26\>>>|<row|<cell|y>|<cell|\<#590D\>\<#5236\>\<#9009\>\<#4E2D\>\<#7684\>\<#6587\>\<#672C\>>>|<row|<cell|yw>|<cell|\<#590D\>\<#5236\>\<#5355\>\<#8BCD\>>>|<row|<cell|yy>|<cell|\<#590D\>\<#5236\>\<#6574\>\<#884C\>>>|<row|<cell|p>|<cell|\<#7C98\>\<#8D34\>>>|<row|<cell|:set>|<cell|\<#8BBE\>\<#7F6E\>vim\<#914D\>\<#7F6E\>>>|<row|<cell|Lesson7>|<cell|>>|<row|<cell|:help>|<cell|\<#67E5\>\<#8BE2\>
    eg: :help w>>|<row|<cell|:+\<less\>C-D\<gtr\>>|<cell|\<#663E\>\<#793A\>\<#53EF\>\<#6267\>\<#884C\>\<#547D\>\<#4EE4\>
    eg: :e+\<less\>C-D\<gtr\>>>|<row|<cell|tab>|<cell|\<#81EA\>\<#52A8\>\<#8865\>\<#5168\>>>>>>

    \;
  </small-table|vimtutor>

  \;

  \;

  \;

  <\with|par-mode|center>
    <small-table|<block|<tformat|<table|<row|<cell|w>|<cell|\<#4E0B\>\<#4E00\>\<#4E2A\>\<#8BCD\>
    next word>>|<row|<cell|b>|<cell|\<#5355\>\<#8BCD\>\<#5F00\>\<#5934\>(\<#5411\>\<#524D\>)
    begining of word>>|<row|<cell|e>|<cell|\<#5355\>\<#8BCD\>\<#5C3E\>\<#90E8\>(\<#5411\>\<#540E\>)
    end of word>>|<row|<cell|0>|<cell|\<#884C\>\<#5F00\>\<#5934\>>>|<row|<cell|^>|<cell|\<#6B64\>\<#884C\>\<#7B2C\>\<#4E00\>\<#4E2A\>\<#975E\>\<#7A7A\>\<#5B57\>\<#7B26\>>>|<row|<cell|$>|<cell|\<#884C\>\<#5C3E\>>>|<row|<cell|H>|<cell|\<#7A97\>\<#53E3\>\<#9876\>\<#90E8\>>>|<row|<cell|M>|<cell|\<#7A97\>\<#53E3\>\<#4E2D\>\<#90E8\>>>|<row|<cell|L>|<cell|\<#7A97\>\<#53E3\>\<#5E95\>\<#90E8\>>>|<row|<cell|\<less\>C-u\<gtr\>>|<cell|\<#5411\>\<#4E0A\>\<#6EDA\>\<#52A8\>(up)>>|<row|<cell|\<less\>C-d\<gtr\>>|<cell|\<#5411\>\<#4E0B\>\<#6EDA\>\<#52A8\>(down)>>|<row|<cell|gg>|<cell|\<#6587\>\<#4EF6\>\<#5F00\>\<#5934\>>>|<row|<cell|G>|<cell|\<#6587\>\<#4EF6\>\<#5C3E\>\<#90E8\>>>|<row|<cell|{number}G>|<cell|\<#8DF3\>\<#5230\>\<#76F8\>\<#5E94\>\<#884C\>>>|<row|<cell|%>|<cell|\<#5728\>{\<#FF0C\>[\<#FF0C\>(\<#4E0A\>\<#4F7F\>\<#7528\>\<#4F1A\>\<#8DF3\>\<#8F6C\>\<#5230\>\<#5BF9\>\<#5E94\>\<#7684\>\<#62EC\>\<#53F7\>>>|<row|<cell|f{character}>|<cell|\<#5411\>\<#540E\>\<#8DF3\>\<#8F6C\>\<#5230\>\<#6B64\>\<#5B57\>\<#7B26\>>>|<row|<cell|t{character}>|<cell|\<#5411\>\<#540E\>\<#8DF3\>\<#8F6C\>\<#5230\>\<#6B64\>\<#5B57\>\<#7B26\>\<#524D\>>>|<row|<cell|F{character}>|<cell|\<#5411\>\<#524D\>\<#8DF3\>\<#8F6C\>\<#5230\>\<#6B64\>\<#5B57\>\<#7B26\>>>|<row|<cell|T{character}>|<cell|\<#5411\>\<#524D\>\<#8DF3\>\<#8F6C\>\<#5230\>\<#6B64\>\<#5B57\>\<#7B26\>\<#540E\>>>|<row|<cell|/(word)>|<cell|\<#4F7F\>\<#7528\>/\<#8FDB\>\<#884C\>\<#5355\>\<#8BCD\>\<#641C\>\<#7D22\>\<#FF0C\>\<#6309\>\<#4E0B\>\<#56DE\>\<#8F66\>\<#540E\>\<#4F1A\>\<#8DF3\>\<#8F6C\>\<#5230\>\<#76F8\>\<#5E94\>\<#5904\>>>>>>|Vim
    movement from 6.null>
  </with>

  \;

  \;

  \;

  <\with|par-mode|center>
    <small-table|<block|<tformat|<table|<row|<cell|~>|<cell|\<#7FFB\>\<#8F6C\>\<#5927\>\<#5C0F\>\<#5199\>>>|<row|<cell|ci[>|<cell|\<#4FEE\>\<#6539\>[
    ]\<#4E2D\>\<#7684\>\<#5185\>\<#5BB9\>>>|<row|<cell|da(>|<cell|\<#5220\>\<#9664\>\<#5305\>\<#62EC\>(
    ) \<#5728\>\<#5185\>\<#7684\>\<#6240\>\<#6709\>\<#5185\>\<#5BB9\>>>>>>|Vim
    modify from 6.null>
  </with>
</body>

<\initial>
  <\collection>
    <associate|page-medium|paper>
  </collection>
</initial>

<\references>
  <\collection>
    <associate|auto-1|<tuple|1|1>>
    <associate|auto-2|<tuple|1|1>>
    <associate|auto-3|<tuple|2|2>>
    <associate|auto-4|<tuple|3|?>>
    <associate|auto-5|<tuple|4|?>>
  </collection>
</references>

<\auxiliary>
  <\collection>
    <\associate|table>
      <tuple|normal|<\surround|<hidden-binding|<tuple>|1>|>
        \;
      </surround>|<pageref|auto-2>>

      <tuple|normal|<surround|<hidden-binding|<tuple>|2>||>|<pageref|auto-3>>
    </associate>
    <\associate|toc>
      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|1<space|2spc>Appendix
      1 Vimtutor> <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-1><vspace|0.5fn>
    </associate>
  </collection>
</auxiliary>