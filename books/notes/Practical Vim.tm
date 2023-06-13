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
    \;
  </big-table>

  <small-table|<block|<tformat|<twith|table-vmode|auto>|<twith|table-hyphen|y>|<table|<row|<cell|Lesson5>|<cell|>>|<row|<cell|:!>|<cell|\<#540E\>\<#9762\>\<#53EF\>\<#4EE5\>\<#8DDF\>\<#968F\>shell\<#547D\>\<#4EE4\>
  eg: :!ls>>|<row|<cell|:w [filename]>|<cell|\<#5C06\>\<#5F53\>\<#524D\>\<#6587\>\<#4EF6\>\<#4FDD\>\<#5B58\>>>|<row|<cell|V>|<cell|\<#8FDB\>\<#5165\>visual\<#6A21\>\<#5F0F\>\<#FF0C\>\<#53EF\>\<#4EE5\>\<#4EE5\>\<#6587\>\<#4EF6\>\<#5757\>\<#7684\>\<#5F62\>\<#5F0F\>\<#5927\>\<#9762\>\<#79EF\>\<#5730\>\<#9009\>\<#4E2D\>\<#6587\>\<#672C\>>>|<row|<cell|:r
  [filename]>|<cell|\<#5C06\>filename\<#4E2D\>\<#7684\>\<#5185\>\<#5BB9\>\<#7C98\>\<#8D34\>\<#5728\>\<#5149\>\<#6807\>\<#5904\>>>|<row|<cell|:r
  ![shell command]>|<cell|\<#5C06\>shell\<#4E2D\>\<#7684\>\<#5185\>\<#5BB9\>\<#7C98\>\<#8D34\>\<#5728\>\<#5149\>\<#6807\>\<#5904\>
  eg: :r !dir>>|<row|<cell|Lesson6>|<cell|>>|<row|<cell|o>|<cell|\<#65B0\>\<#5F00\>\<#4E00\>\<#884C\>\<#5E76\>\<#76F4\>\<#63A5\>\<#8FDB\>\<#5165\>\<#63D2\>\<#5165\>\<#6A21\>\<#5F0F\>>>|<row|<cell|a>|<cell|\<#5728\>\<#5F53\>\<#524D\>\<#5149\>\<#6807\>\<#7684\>\<#540E\>\<#65B9\>\<#63D2\>\<#5165\>>>|<row|<cell|R>|<cell|\<#8FDB\>\<#5165\>replace\<#6A21\>\<#5F0F\>\<#FF0C\>\<#53EF\>\<#4EE5\>\<#66FF\>\<#6362\>\<#591A\>\<#4E2A\>\<#5B57\>\<#7B26\>>>|<row|<cell|v>|<cell|\<#4EE5\>\<#5149\>\<#6807\>\<#79FB\>\<#52A8\>\<#7684\>\<#65B9\>\<#5F0F\>\<#9009\>\<#4E2D\>\<#5B57\>\<#7B26\>>>|<row|<cell|y>|<cell|\<#590D\>\<#5236\>\<#9009\>\<#4E2D\>\<#7684\>\<#6587\>\<#672C\>>>|<row|<cell|yw>|<cell|\<#590D\>\<#5236\>\<#5355\>\<#8BCD\>>>|<row|<cell|yy>|<cell|\<#590D\>\<#5236\>\<#6574\>\<#884C\>>>|<row|<cell|p>|<cell|\<#7C98\>\<#8D34\>>>|<row|<cell|:set>|<cell|\<#8BBE\>\<#7F6E\>vim\<#914D\>\<#7F6E\>>>|<row|<cell|Lesson7>|<cell|>>|<row|<cell|:help>|<cell|\<#67E5\>\<#8BE2\>
  eg: :help w>>|<row|<cell|:+\<less\>C-D\<gtr\>>|<cell|\<#663E\>\<#793A\>\<#53EF\>\<#6267\>\<#884C\>\<#547D\>\<#4EE4\>
  eg: :e+\<less\>C-D\<gtr\>>>|<row|<cell|tab>|<cell|\<#81EA\>\<#52A8\>\<#8865\>\<#5168\>>>>>>|>

  \;

  \;

  <section|lazyvim keyshorts>

  <space|2em><hlink|\<#2328\>\<#FE0F\> \<#6309\>\<#952E\>\<#6620\>\<#5C04\>
  \| LazyVim (lazyvim-github-io.vercel.app)|https://lazyvim-github-io.vercel.app/zh-Hans/keymaps>

  \<#5EFA\>\<#8BAE\>\<#5728\>\<#5B89\>\<#88C5\>\<#540E\>\<#8FD0\>\<#884C\>:checkhealt\<#67E5\>\<#770B\>\<#5B89\>\<#88C5\>\<#95EE\>\<#9898\>\<#3002\>

  <strong|<strong|<strong|Lazyvim>>><nbsp>\<#4F7F\>\<#7528\><nbsp><hlink|which-key.nvim<nbsp>|https://github.com/folke/which-key.nvim>\<#6765\>\<#5E2E\>\<#52A9\>\<#60A8\>\<#8BB0\>\<#4F4F\>\<#60A8\>\<#7684\>\<#6309\>\<#952E\>\<#6620\>\<#5C04\>\<#3002\>
  \<#53EA\>\<#9700\>\<#6309\>\<#4E0B\>\<#7C7B\>\<#4F3C\><nbsp><code*|\<less\>space\<gtr\>><nbsp>\<#7B49\>\<#4EFB\>\<#4F55\>\<#6309\>\<#952E\>\<#FF0C\>\<#60A8\>\<#5C31\>\<#4F1A\>\<#770B\>\<#5230\>\<#4E00\>\<#4E2A\>\<#5F39\>\<#51FA\>\<#7684\>\<#5305\>\<#542B\>\<#6240\>\<#6709\>\<#53EF\>\<#80FD\>\<#4EE5\><nbsp><code*|\<less\>space\<gtr\>><nbsp>\<#5F00\>\<#5934\>\<#7684\>\<#6309\>\<#952E\>\<#6620\>\<#5C04\>\<#3002\>

  <\big-table|<tabular|<tformat|<table|<row|<cell|<block|<tformat|<twith|table-hmode|min>|<twith|table-width|1par>|<cwith|1|-1|1|-1|cell-hyphen|t>|<table|<row|<\cell>
    Neo-tree
  </cell>|<\cell>
    \;
  </cell>|<\cell>
    \;
  </cell>>|<row|<\cell>
    <code*|\<less\>leader\<gtr\>fe>
  </cell>|<\cell>
    Explorer NeoTree (root dir)
  </cell>|<\cell>
    <strong|n>
  </cell>>|<row|<\cell>
    <code*|\<less\>leader\<gtr\>fE>
  </cell>|<\cell>
    Explorer NeoTree (cwd)
  </cell>|<\cell>
    <strong|n>
  </cell>>|<row|<\cell>
    <code*|\<less\>leader\<gtr\>e>
  </cell>|<\cell>
    Explorer NeoTree (root dir)
  </cell>|<\cell>
    <strong|n>
  </cell>>|<row|<\cell>
    <code*|<code*|\<less\>leader\<gtr\>E>>
  </cell>|<\cell>
    Explorer NeoTree (cwd)
  </cell>|<\cell>
    <strong|n>
  </cell>>|<row|<\cell>
    buffer line
  </cell>|<\cell>
    \;
  </cell>|<\cell>
    \;
  </cell>>|<row|<\cell>
    <code*|\<less\>leader\<gtr\>bp>
  </cell>|<\cell>
    Toggle pin
  </cell>|<\cell>
    <strong|n>
  </cell>>|<row|<\cell>
    <code*|\<less\>leader\<gtr\>bP>
  </cell>|<\cell>
    <tabular|<tformat|<twith|table-hmode|min>|<twith|table-width|1par>|<cwith|1|-1|1|-1|cell-hyphen|t>|<table|<row|<cell|Delete
    non-pinned buffers>>>>>
  </cell>|<\cell>
    <strong|n>
  </cell>>|<row|<\cell>
    mason
  </cell>|<\cell>
    \;
  </cell>|<\cell>
    \;
  </cell>>|<row|<\cell>
    <code*|\<less\>leader\<gtr\>cm>
  </cell>|<\cell>
    \<#6253\>\<#5F00\>MASON
  </cell>|<\cell>
    <strong|n>
  </cell>>>>>>>>>>>
    Neo-tree , buffer line ,mason
  </big-table>

  <\big-table|<tabular|<tformat|<table|<row|<cell|<block|<tformat|<twith|table-hmode|min>|<twith|table-width|1par>|<cwith|1|-1|1|-1|cell-hyphen|t>|<table|<row|<cell|Key>|<cell|Description>|<cell|Mode>>|<row|<cell|<code*|\<less\>leader\<gtr\>cd>>|<cell|Line
  Diagnostics>|<cell|<strong|n>>>|<row|<cell|<code*|\<less\>leader\<gtr\>cl>>|<cell|LSP
  \<#4FE1\>\<#606F\>>|<cell|<strong|n>>>|<row|<cell|<code*|gd>>|<cell|\<#8F6C\>\<#5230\>\<#5B9A\>\<#4E49\>>|<cell|<strong|n>>>|<row|<cell|<code*|gr>>|<cell|References>|<cell|<strong|n>>>|<row|<cell|<code*|gD>>|<cell|\<#8F6C\>\<#5230\>\<#58F0\>\<#660E\>>|<cell|<strong|n>>>|<row|<cell|<code*|gI>>|<cell|\<#8F6C\>\<#5230\>\<#5B9E\>\<#73B0\>>|<cell|<strong|n>>>|<row|<cell|<code*|gt>>|<cell|\<#8F6C\>\<#5230\>\<#7C7B\>\<#578B\>\<#5B9A\>\<#4E49\>>|<cell|<strong|n>>>|<row|<cell|<code*|K>>|<cell|\<#60AC\>\<#505C\>>|<cell|<strong|n>>>|<row|<cell|<code*|gK>>|<cell|Signature
  Help>|<cell|<strong|n>>>|<row|<cell|<code*|\<less\>c-k\<gtr\>>>|<cell|Signature
  Help>|<cell|<strong|i>>>|<row|<cell|<code*|]d>>|<cell|Next
  Diagnostic>|<cell|<strong|n>>>|<row|<cell|<code*|[d>>|<cell|Prev
  Diagnostic>|<cell|<strong|n>>>|<row|<cell|<code*|]e>>|<cell|\<#4E0B\>\<#4E00\>\<#4E2A\>\<#9519\>\<#8BEF\>>|<cell|<strong|n>>>|<row|<cell|<code*|[e>>|<cell|\<#4E0A\>\<#4E00\>\<#4E2A\>\<#9519\>\<#8BEF\>>|<cell|<strong|n>>>|<row|<cell|<code*|]w>>|<cell|\<#4E0B\>\<#4E00\>\<#4E2A\>\<#8B66\>\<#544A\>>|<cell|<strong|n>>>|<row|<cell|<code*|[w>>|<cell|\<#4E0A\>\<#4E00\>\<#4E2A\>\<#8B66\>\<#544A\>>|<cell|<strong|n>>>|<row|<cell|<code*|\<less\>leader\<gtr\>ca>>|<cell|Code
  Action>|<cell|<strong|n>,<nbsp><strong|v>>>|<row|<cell|<code*|\<less\>leader\<gtr\>cf>>|<cell|Format
  Document>|<cell|<strong|n>>>|<row|<cell|<code*|\<less\>leader\<gtr\>cf>>|<cell|Format
  Range>|<cell|<strong|v>>>|<row|<cell|<code*|\<less\>leader\<gtr\>cr>>|<cell|\<#91CD\>\<#547D\>\<#540D\>>|<cell|<strong|n>>>>>>>>>>>>
    LSP
  </big-table>

  <\big-table|<block|<tformat|<cwith|1|52|1|3|cell-hyphen|t>|<table|<row|<\cell>
    \<#6309\>\<#952E\>
  </cell>|<\cell>
    \<#63CF\>\<#8FF0\>
  </cell>|<\cell>
    \<#6A21\>\<#5F0F\>
  </cell>>|<row|<\cell>
    <code*|\<less\>C-h\<gtr\>>
  </cell>|<\cell>
    \<#8F6C\>\<#5230\>\<#5DE6\>\<#8FB9\>\<#7A97\>\<#53E3\>
  </cell>|<\cell>
    <strong|n>
  </cell>>|<row|<\cell>
    <code*|\<less\>C-j\<gtr\>>
  </cell>|<\cell>
    \<#8F6C\>\<#5230\>\<#4E0B\>\<#8FB9\>\<#7A97\>\<#53E3\>
  </cell>|<\cell>
    <strong|n>
  </cell>>|<row|<\cell>
    <code*|\<less\>C-k\<gtr\>>
  </cell>|<\cell>
    \<#8F6C\>\<#5230\>\<#4E0A\>\<#8FB9\>\<#7A97\>\<#53E3\>
  </cell>|<\cell>
    <strong|n>
  </cell>>|<row|<\cell>
    <code*|\<less\>C-l\<gtr\>>
  </cell>|<\cell>
    \<#8F6C\>\<#5230\>\<#53F3\>\<#8FB9\>\<#7A97\>\<#53E3\>
  </cell>|<\cell>
    <strong|n>
  </cell>>|<row|<\cell>
    <code*|\<less\>C-Up\<gtr\>>
  </cell>|<\cell>
    \<#589E\>\<#5927\>\<#7A97\>\<#53E3\>\<#9AD8\>\<#5EA6\>
  </cell>|<\cell>
    <strong|n>
  </cell>>|<row|<\cell>
    <code*|\<less\>C-Down\<gtr\>>
  </cell>|<\cell>
    \<#51CF\>\<#5C0F\>\<#7A97\>\<#53E3\>\<#9AD8\>\<#5EA6\>
  </cell>|<\cell>
    <strong|n>
  </cell>>|<row|<\cell>
    <code*|\<less\>C-Left\<gtr\>>
  </cell>|<\cell>
    \<#51CF\>\<#5C0F\>\<#7A97\>\<#53E3\>\<#5BBD\>\<#5EA6\>
  </cell>|<\cell>
    <strong|n>
  </cell>>|<row|<\cell>
    <code*|\<less\>C-Right\<gtr\>>
  </cell>|<\cell>
    \<#589E\>\<#5927\>\<#7A97\>\<#53E3\>\<#5BBD\>\<#5EA6\>
  </cell>|<\cell>
    <strong|n>
  </cell>>|<row|<\cell>
    <code*|\<less\>A-j\<gtr\>>
  </cell>|<\cell>
    \<#5411\>\<#4E0B\>\<#79FB\>\<#52A8\>
  </cell>|<\cell>
    <strong|n>,<nbsp><strong|i>,<nbsp><strong|v>
  </cell>>|<row|<\cell>
    <code*|\<less\>A-k\<gtr\>>
  </cell>|<\cell>
    \<#5411\>\<#4E0A\>\<#79FB\>\<#52A8\>
  </cell>|<\cell>
    <strong|n>,<nbsp><strong|i>,<nbsp><strong|v>
  </cell>>|<row|<\cell>
    <code*|\<less\>S-h\<gtr\>>
  </cell>|<\cell>
    \<#4E0A\>\<#4E00\>\<#4E2A\>\<#7F13\>\<#51B2\>\<#533A\>
  </cell>|<\cell>
    <strong|n>
  </cell>>|<row|<\cell>
    <code*|\<less\>S-l\<gtr\>>
  </cell>|<\cell>
    \<#4E0B\>\<#4E00\>\<#4E2A\>\<#7F13\>\<#51B2\>\<#533A\>
  </cell>|<\cell>
    <strong|n>
  </cell>>|<row|<\cell>
    <code*|[b>
  </cell>|<\cell>
    \<#4E0A\>\<#4E00\>\<#4E2A\>\<#7F13\>\<#51B2\>\<#533A\>
  </cell>|<\cell>
    <strong|n>
  </cell>>|<row|<\cell>
    <code*|]b>
  </cell>|<\cell>
    \<#4E0B\>\<#4E00\>\<#4E2A\>\<#7F13\>\<#51B2\>\<#533A\>
  </cell>|<\cell>
    <strong|n>
  </cell>>|<row|<\cell>
    <code*|\<less\>leader\<gtr\>bb>
  </cell>|<\cell>
    \<#5207\>\<#6362\>\<#5230\>\<#5176\>\<#4ED6\>\<#7F13\>\<#5B58\>\<#533A\>
  </cell>|<\cell>
    <strong|n>
  </cell>>|<row|<\cell>
    <code*|\<less\>leader\<gtr\>`>
  </cell>|<\cell>
    \<#5207\>\<#6362\>\<#5230\>\<#5176\>\<#4ED6\>\<#7F13\>\<#5B58\>\<#533A\>
  </cell>|<\cell>
    <strong|n>
  </cell>>|<row|<\cell>
    <code*|\<less\>esc\<gtr\>>
  </cell>|<\cell>
    Escape and clear hlsearch
  </cell>|<\cell>
    <strong|i>,<nbsp><strong|n>
  </cell>>|<row|<\cell>
    <code*|\<less\>leader\<gtr\>ur>
  </cell>|<\cell>
    Redraw / clear hlsearch / diff update
  </cell>|<\cell>
    <strong|n>
  </cell>>|<row|<\cell>
    <code*|gw>
  </cell>|<\cell>
    \<#641C\>\<#7D22\>\<#5149\>\<#6807\>\<#9501\>\<#5728\>\<#7684\>\<#5355\>\<#8BCD\>
  </cell>|<\cell>
    <strong|n>,<nbsp><strong|x>
  </cell>>|<row|<\cell>
    <code*|n>
  </cell>|<\cell>
    \<#4E0B\>\<#4E00\>\<#4E2A\>\<#641C\>\<#7D22\>\<#7ED3\>\<#679C\>
  </cell>|<\cell>
    <strong|n>,<nbsp><strong|x>,<nbsp><strong|o>
  </cell>>|<row|<\cell>
    <code*|N>
  </cell>|<\cell>
    \<#4E0A\>\<#4E00\>\<#4E2A\>\<#641C\>\<#7D22\>\<#7ED3\>\<#679C\>
  </cell>|<\cell>
    <strong|n>,<nbsp><strong|x>,<nbsp><strong|o>
  </cell>>|<row|<\cell>
    <code*|\<less\>C-s\<gtr\>>
  </cell>|<\cell>
    \<#4FDD\>\<#5B58\>\<#6587\>\<#4EF6\>
  </cell>|<\cell>
    <strong|i>,<nbsp><strong|v>,<nbsp><strong|n>,<nbsp><strong|s>
  </cell>>|<row|<\cell>
    <code*|\<less\>leader\<gtr\>l>
  </cell>|<\cell>
    \<#6253\>\<#5F00\> lazy \<#63D2\>\<#4EF6\>\<#9762\>\<#677F\>
  </cell>|<\cell>
    <strong|n>
  </cell>>|<row|<\cell>
    <code*|\<less\>leader\<gtr\>fn>
  </cell>|<\cell>
    \<#65B0\>\<#5EFA\>\<#6587\>\<#4EF6\>
  </cell>|<\cell>
    <strong|n>
  </cell>>|<row|<\cell>
    <code*|\<less\>leader\<gtr\>xl>
  </cell>|<\cell>
    Location List
  </cell>|<\cell>
    <strong|n>
  </cell>>|<row|<\cell>
    <code*|\<less\>leader\<gtr\>xq>
  </cell>|<\cell>
    Quickfix List
  </cell>|<\cell>
    <strong|n>
  </cell>>|<row|<\cell>
    <code*|\<less\>leader\<gtr\>uf>
  </cell>|<\cell>
    Toggle format on Save
  </cell>|<\cell>
    <strong|n>
  </cell>>|<row|<\cell>
    <code*|\<less\>leader\<gtr\>us>
  </cell>|<\cell>
    Toggle Spelling
  </cell>|<\cell>
    <strong|n>
  </cell>>|<row|<\cell>
    <code*|\<less\>leader\<gtr\>uw>
  </cell>|<\cell>
    Toggle Word Wrap
  </cell>|<\cell>
    <strong|n>
  </cell>>|<row|<\cell>
    <code*|\<less\>leader\<gtr\>ul>
  </cell>|<\cell>
    Toggle Line Numbers
  </cell>|<\cell>
    <strong|n>
  </cell>>|<row|<\cell>
    <code*|\<less\>leader\<gtr\>ud>
  </cell>|<\cell>
    Toggle Diagnostics
  </cell>|<\cell>
    <strong|n>
  </cell>>|<row|<\cell>
    <code*|\<less\>leader\<gtr\>uc>
  </cell>|<\cell>
    Toggle Conceal
  </cell>|<\cell>
    <strong|n>
  </cell>>|<row|<\cell>
    <code*|\<less\>leader\<gtr\>gg>
  </cell>|<\cell>
    Lazygit (root dir)
  </cell>|<\cell>
    <strong|n>
  </cell>>|<row|<\cell>
    <code*|\<less\>leader\<gtr\>gG>
  </cell>|<\cell>
    Lazygit (cwd)
  </cell>|<\cell>
    <strong|n>
  </cell>>|<row|<\cell>
    <code*|\<less\>leader\<gtr\>qq>
  </cell>|<\cell>
    Quit all
  </cell>|<\cell>
    <strong|n>
  </cell>>|<row|<\cell>
    <code*|\<less\>leader\<gtr\>ui>
  </cell>|<\cell>
    Inspect Pos
  </cell>|<\cell>
    <strong|n>
  </cell>>|<row|<\cell>
    <code*|\<less\>leader\<gtr\>ft>
  </cell>|<\cell>
    Terminal (root dir)
  </cell>|<\cell>
    <strong|n>
  </cell>>|<row|<\cell>
    <code*|\<less\>leader\<gtr\>fT>
  </cell>|<\cell>
    Terminal (cwd)
  </cell>|<\cell>
    <strong|n>
  </cell>>|<row|<\cell>
    <code*|\<less\>esc\<gtr\>\<less\>esc\<gtr\>>
  </cell>|<\cell>
    Enter Normal Mode
  </cell>|<\cell>
    <strong|t>
  </cell>>|<row|<\cell>
    <code*|\<less\>leader\<gtr\>ww>
  </cell>|<\cell>
    \<#5176\>\<#5B83\>\<#7A97\>\<#53E3\>
  </cell>|<\cell>
    <strong|n>
  </cell>>|<row|<\cell>
    <code*|\<less\>leader\<gtr\>wd>
  </cell>|<\cell>
    \<#5220\>\<#9664\>\<#7A97\>\<#53E3\>
  </cell>|<\cell>
    <strong|n>
  </cell>>|<row|<\cell>
    <code*|\<less\>leader\<gtr\>w->
  </cell>|<\cell>
    \<#5728\>\<#4E0B\>\<#65B9\>\<#5206\>\<#5272\>\<#7A97\>\<#53E3\>
  </cell>|<\cell>
    <strong|n>
  </cell>>|<row|<\cell>
    <code*|\<less\>leader\<gtr\>w\|>
  </cell>|<\cell>
    \<#5728\>\<#53F3\>\<#4FA7\>\<#5206\>\<#5272\>\<#7A97\>\<#53E3\>
  </cell>|<\cell>
    <strong|n>
  </cell>>|<row|<\cell>
    <code*|\<less\>leader\<gtr\>->
  </cell>|<\cell>
    \<#5728\>\<#53F3\>\<#4FA7\>\<#5206\>\<#5272\>\<#7A97\>\<#53E3\>
  </cell>|<\cell>
    <strong|n>
  </cell>>|<row|<\cell>
    <code*|\<less\>leader\<gtr\>\|>
  </cell>|<\cell>
    \<#5728\>\<#4E0B\>\<#65B9\>\<#5206\>\<#5272\>\<#7A97\>\<#53E3\>
  </cell>|<\cell>
    <strong|n>
  </cell>>|<row|<\cell>
    <code*|\<less\>leader\<gtr\>\<less\>tab\<gtr\>l>
  </cell>|<\cell>
    \<#6700\>\<#540E\>\<#4E00\>\<#4E2A\>\<#6807\>\<#7B7E\>
  </cell>|<\cell>
    <strong|n>
  </cell>>|<row|<\cell>
    <code*|\<less\>leader\<gtr\>\<less\>tab\<gtr\>f>
  </cell>|<\cell>
    \<#7B2C\>\<#4E00\>\<#4E2A\>\<#6807\>\<#7B7E\>\<#9875\>
  </cell>|<\cell>
    <strong|n>
  </cell>>|<row|<\cell>
    <code*|\<less\>leader\<gtr\>\<less\>tab\<gtr\>\<less\>tab\<gtr\>>
  </cell>|<\cell>
    \<#65B0\>\<#5EFA\>\<#6807\>\<#7B7E\>\<#9875\>
  </cell>|<\cell>
    <strong|n>
  </cell>>|<row|<\cell>
    <code*|\<less\>leader\<gtr\>\<less\>tab\<gtr\>]>
  </cell>|<\cell>
    \<#4E0B\>\<#4E00\>\<#4E2A\>\<#6807\>\<#7B7E\>\<#9875\>
  </cell>|<\cell>
    <strong|n>
  </cell>>|<row|<\cell>
    <code*|\<less\>leader\<gtr\>\<less\>tab\<gtr\>d>
  </cell>|<\cell>
    \<#5173\>\<#95ED\>\<#6807\>\<#7B7E\>\<#9875\>
  </cell>|<\cell>
    <strong|n>
  </cell>>|<row|<\cell>
    <code*|\<less\>leader\<gtr\>\<less\>tab\<gtr\>[>
  </cell>|<\cell>
    \<#4E0A\>\<#4E00\>\<#4E2A\>\<#6807\>\<#7B7E\>\<#9875\>
  </cell>|<\cell>
    <strong|n>
  </cell>>>>>>
    \<#901A\>\<#7528\>
  </big-table>

  <\big-table|<block|<tformat|<twith|table-hmode|min>|<twith|table-width|1par>|<cwith|1|-1|1|-1|cell-hyphen|t>|<table|<row|<cell|Key>|<cell|Description>|<cell|Mode>>|<row|<cell|<code*|\<less\>leader\<gtr\>,>>|<cell|\<#5207\>\<#6362\>\<#7F13\>\<#51B2\>\<#533A\>>|<cell|<strong|n>>>|<row|<cell|<code*|\<less\>leader\<gtr\>/>>|<cell|\<#5728\>\<#6587\>\<#4EF6\>\<#4E2D\>\<#67E5\>\<#627E\>(Grep)>|<cell|<strong|n>>>|<row|<cell|<code*|\<less\>leader\<gtr\>:>>|<cell|\<#547D\>\<#4EE4\>\<#5386\>\<#53F2\>\<#8BB0\>\<#5F55\>>|<cell|<strong|n>>>|<row|<cell|<code*|\<less\>leader\<gtr\>\<less\>space\<gtr\>>>|<cell|\<#67E5\>\<#627E\>\<#6587\>\<#4EF6\>
  (root \<#76EE\>\<#5F55\>)>|<cell|<strong|n>>>|<row|<cell|<code*|\<less\>leader\<gtr\>fb>>|<cell|Buffers>|<cell|<strong|n>>>|<row|<cell|<code*|\<less\>leader\<gtr\>ff>>|<cell|\<#67E5\>\<#627E\>\<#6587\>\<#4EF6\>
  (root \<#76EE\>\<#5F55\>)>|<cell|<strong|n>>>|<row|<cell|<code*|\<less\>leader\<gtr\>fF>>|<cell|\<#67E5\>\<#627E\>\<#6587\>\<#4EF6\>
  (cwd \<#76EE\>\<#5F55\>)>|<cell|<strong|n>>>|<row|<cell|<code*|\<less\>leader\<gtr\>fr>>|<cell|Recent>|<cell|<strong|n>>>|<row|<cell|<code*|\<less\>leader\<gtr\>gc>>|<cell|commits>|<cell|<strong|n>>>|<row|<cell|<code*|\<less\>leader\<gtr\>gs>>|<cell|status>|<cell|<strong|n>>>|<row|<cell|<code*|\<less\>leader\<gtr\>sa>>|<cell|Auto
  Commands>|<cell|<strong|n>>>|<row|<cell|<code*|\<less\>leader\<gtr\>sb>>|<cell|\<#5728\>\<#5F53\>\<#524D\>\<#7F13\>\<#51B2\>\<#533A\>\<#4E2D\>\<#641C\>\<#7D22\>>|<cell|<strong|n>>>|<row|<cell|<code*|\<less\>leader\<gtr\>sc>>|<cell|\<#547D\>\<#4EE4\>\<#5386\>\<#53F2\>>|<cell|<strong|n>>>|<row|<cell|<code*|\<less\>leader\<gtr\>sC>>|<cell|\<#6240\>\<#6709\>\<#547D\>\<#4EE4\>\<#5217\>\<#8868\>>|<cell|<strong|n>>>|<row|<cell|<code*|\<less\>leader\<gtr\>sd>>|<cell|Diagnostics>|<cell|<strong|n>>>|<row|<cell|<code*|\<less\>leader\<gtr\>sg>>|<cell|Grep
  (root dir)>|<cell|<strong|n>>>|<row|<cell|<code*|\<less\>leader\<gtr\>sG>>|<cell|Grep
  (cwd)>|<cell|<strong|n>>>|<row|<cell|<code*|\<less\>leader\<gtr\>sh>>|<cell|\<#5168\>\<#5C40\>\<#5E2E\>\<#52A9\>\<#9875\>>|<cell|<strong|n>>>|<row|<cell|<code*|\<less\>leader\<gtr\>sH>>|<cell|Search
  Highlight Groups>|<cell|<strong|n>>>|<row|<cell|<code*|\<less\>leader\<gtr\>sk>>|<cell|\<#6309\>\<#952E\>\<#6620\>\<#5C04\>>|<cell|<strong|n>>>|<row|<cell|<code*|\<less\>leader\<gtr\>sM>>|<cell|Man
  Pages>|<cell|<strong|n>>>|<row|<cell|<code*|\<less\>leader\<gtr\>sm>>|<cell|Jump
  to Mark>|<cell|<strong|n>>>|<row|<cell|<code*|\<less\>leader\<gtr\>so>>|<cell|Options>|<cell|<strong|n>>>|<row|<cell|<code*|\<less\>leader\<gtr\>sR>>|<cell|Resume>|<cell|<strong|n>>>|<row|<cell|<code*|\<less\>leader\<gtr\>sw>>|<cell|Word
  (root dir)>|<cell|<strong|n>>>|<row|<cell|<code*|\<less\>leader\<gtr\>sW>>|<cell|Word
  (cwd)>|<cell|<strong|n>>>|<row|<cell|<code*|\<less\>leader\<gtr\>uC>>|<cell|\<#9884\>\<#89C8\>\<#989C\>\<#8272\>\<#65B9\>\<#6848\>(\<#4E3B\>\<#9898\>)>|<cell|<strong|n>>>|<row|<cell|<code*|\<less\>leader\<gtr\>ss>>|<cell|Goto
  Symbol>|<cell|<strong|n>>>|<row|<cell|<code*|\<less\>leader\<gtr\>sS>>|<cell|Goto
  Symbol (Workspace)>|<cell|<strong|n>>>>>>>
    telescope
  </big-table>
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
    <associate|auto-4|<tuple|2|?>>
    <associate|auto-5|<tuple|3|?>>
    <associate|auto-6|<tuple|4|?>>
    <associate|auto-7|<tuple|5|?>>
    <associate|auto-8|<tuple|6|?>>
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