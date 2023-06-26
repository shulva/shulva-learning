<TeXmacs|2.1.2>

<style|<tuple|article|chinese>>

<\body>
  <doc-data|<doc-title|Automate the boring stuff with python>>

  <\table-of-contents|toc>
    <vspace*|1fn><with|font-series|bold|math-font-series|bold|1<space|2spc>python\<#7F16\>\<#7A0B\>\<#57FA\>\<#7840\>>
    <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
    <no-break><pageref|auto-1><vspace|0.5fn>

    <vspace*|1fn><with|font-series|bold|math-font-series|bold|2<space|2spc>\<#63A7\>\<#5236\>\<#6D41\>>
    <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
    <no-break><pageref|auto-2><vspace|0.5fn>
  </table-of-contents>

  <section|python\<#7F16\>\<#7A0B\>\<#57FA\>\<#7840\>>

  \;

  python\<#7684\>\<#5B57\>\<#7B26\>\<#4E32\>\<#8FDE\>\<#63A5\>\<#4F7F\>\<#7528\>+\<#53F7\>\<#5373\>\<#53EF\>\<#3002\><python|eg:
  'Alice'+'Bob'='AliceBob'>\<#3002\>

  python\<#7684\>\<#5B57\>\<#7B26\>\<#4E32\>\<#53EF\>\<#4EE5\>\<#4E0E\>\<#6574\>\<#578B\>\<#503C\>\<#76F8\>\<#4E58\>\<#3002\><python|eg:
  'Alice'*2='AliceAlice'>\<#3002\>

  \<#4F7F\>\<#7528\>#\<#8FDB\>\<#884C\>\<#6CE8\>\<#91CA\>\<#3002\>

  \<#4F7F\>\<#7528\>input()\<#51FD\>\<#6570\>\<#7B49\>\<#5F85\>\<#7528\>\<#6237\>\<#5728\>\<#952E\>\<#76D8\>\<#4E0A\>\<#8F93\>\<#5165\>\<#4E00\>\<#4E9B\>\<#6587\>\<#672C\>\<#FF0C\>\<#5E76\>\<#6309\>\<#56DE\>\<#8F66\>\<#952E\>\<#3002\>

  len(str)\<#8FD4\>\<#56DE\>\<#5B57\>\<#7B26\>\<#4E32\>str\<#7684\>\<#957F\>\<#5EA6\>\<#3002\>

  str(),float(),int()\<#4F1A\>\<#5C06\>\<#53C2\>\<#6570\>\<#8F6C\>\<#5316\>\<#4E3A\>\<#76F8\>\<#5E94\>\<#7684\>\<#6570\>\<#636E\>\<#7C7B\>\<#578B\>\<#3002\>

  \;

  <section|\<#63A7\>\<#5236\>\<#6D41\>>

  \;

  \<#5728\>python\<#4E2D\>\<#FF0C\>\<#6574\>\<#578B\>\<#4E0E\>\<#6D6E\>\<#70B9\>\<#6570\>\<#7684\>\<#503C\>\<#6C38\>\<#8FDC\>\<#4E0D\>\<#4F1A\>\<#4E0E\>\<#5B57\>\<#7B26\>\<#4E32\>\<#76F8\>\<#7B49\>\<#3002\>

  python\<#53EF\>\<#4EE5\>\<#4F7F\>\<#7528\>not\<#64CD\>\<#4F5C\>\<#7B26\>\<#7FFB\>\<#8F6C\>\<#5E03\>\<#5C14\>\<#503C\>\<#3002\><python|eg:
  not True = False>

  \<#5728\>\<#5176\>\<#4ED6\>\<#6570\>\<#636E\>\<#7C7B\>\<#578B\>\<#4E2D\>\<#7684\>\<#67D0\>\<#4E9B\>\<#503C\>\<#FF0C\>\<#6761\>\<#4EF6\>\<#4F1A\>\<#8BA4\>\<#4E3A\>\<#4ED6\>\<#4EEC\>\<#7B49\>\<#4EF7\>\<#4E8E\>false\<#548C\>true\<#3002\>

  \<#5728\>\<#7528\>\<#4E8E\>\<#6761\>\<#4EF6\>\<#65F6\>\<#FF0C\>0\<#FF0C\>0.0\<#4EE5\>\<#53CA\>'
  '(\<#7A7A\>\<#5B57\>\<#7B26\>\<#4E32\>)\<#88AB\>\<#8BA4\>\<#4E3A\>\<#662F\>false\<#3002\>\<#5176\>\<#4ED6\>\<#5219\>\<#662F\>true\<#3002\>

  python\<#7684\>\<#6761\>\<#4EF6\>\<#4E0E\>\<#5FAA\>\<#73AF\>\<#8BED\>\<#53E5\>\<#5982\>\<#4E0B\>\<#FF1A\>

  <\python-code>
    if a\<less\>1 :

    \ \ \ \ ...

    elif a=1:

    \ \ \ \ ...

    else:

    \ \ \ \ ...

    \ \ \ \ 

    while b\<less\>1:

    \ \ \ \ ...

    \ \ \ \ if b=1:

    \ \ \ \ \ \ \ \ break

    \ \ \ \ elif b\<gtr\>1:

    \ \ \ \ \ \ \ \ continue

    \ \ \ \ ...

    for i in range(5):

    \ \ \ \ ...
  </python-code>

  \;

  range()\<#51FD\>\<#6570\>\<#4E5F\>\<#53EF\>\<#4EE5\>\<#6709\>\<#7B2C\>\<#4E09\>\<#4E2A\>\<#53C2\>\<#6570\>\<#3002\>\<#524D\>\<#4E24\>\<#4E2A\>\<#53C2\>\<#6570\>\<#5206\>\<#522B\>\<#662F\>\<#8D77\>\<#59CB\>\<#503C\>\<#4E0E\>\<#7EC8\>\<#6B62\>\<#503C\>\<#FF0C\>\<#7B2C\>\<#4E09\>\<#4E2A\>\<#53C2\>\<#6570\>\<#5219\>\<#662F\>\<#6B65\>\<#957F\>\<#3002\>

  range(0,8,2)=0\<#FF0C\>2\<#FF0C\>4\<#FF0C\>6\<#FF0C\>8\<#FF0C\>\<#8D1F\>\<#6570\>\<#4E5F\>\<#53EF\>\<#4EE5\>\<#4F5C\>\<#4E3A\>\<#6B65\>\<#957F\>\<#3002\>

  \<#5728\>python\<#4E2D\>\<#5F00\>\<#59CB\>\<#4F7F\>\<#7528\>\<#4E00\>\<#4E2A\>\<#6A21\>\<#5757\>\<#4E2D\>\<#7684\>\<#51FD\>\<#6570\>\<#524D\>\<#FF0C\>\<#5FC5\>\<#987B\>\<#8981\>\<#7528\>import\<#8BED\>\<#53E5\>\<#5BFC\>\<#5165\>\<#8BE5\>\<#6A21\>\<#5757\>\<#3002\>

  <python|eg: import random>

  \<#5982\>\<#679C\>\<#4F60\>\<#4E0D\>\<#5C0F\>\<#5FC3\>\<#5C06\>\<#4E00\>\<#4E2A\>\<#7A0B\>\<#5E8F\>\<#547D\>\<#540D\>\<#4E3A\>random.py\<#FF0C\>\<#90A3\>\<#4E48\>\<#5728\>import\<#65F6\>\<#7A0B\>\<#5E8F\>\<#5C06\>\<#5BFC\>\<#5165\>\<#4F60\>\<#7684\>random.py\<#6587\>\<#4EF6\>\<#FF0C\>\<#800C\>\<#4E0D\>\<#662F\>random\<#6A21\>\<#5757\>\<#3002\>

  import\<#8BED\>\<#53E5\>\<#7684\>\<#53E6\>\<#4E00\>\<#79CD\>\<#5F62\>\<#5F0F\>\<#5305\>\<#542B\>from\<#5173\>\<#952E\>\<#5B57\>\<#3002\><python|eg:
  from random import *>\<#3002\>

  \<#8C03\>\<#7528\>sys.exit()\<#53EF\>\<#4EE5\>\<#63D0\>\<#524D\>\<#7EC8\>\<#6B62\>\<#7A0B\>\<#5E8F\>\<#3002\>

  <section|\<#7A0B\>\<#5E8F\>>

  \;

  \;
</body>

<\initial>
  <\collection>
    <associate|page-medium|paper>
  </collection>
</initial>

<\references>
  <\collection>
    <associate|auto-1|<tuple|1|1>>
    <associate|auto-2|<tuple|2|1>>
    <associate|auto-3|<tuple|3|?>>
  </collection>
</references>

<\auxiliary>
  <\collection>
    <\associate|toc>
      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|1<space|2spc>python\<#7F16\>\<#7A0B\>\<#57FA\>\<#7840\>>
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-1><vspace|0.5fn>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|2<space|2spc>\<#63A7\>\<#5236\>\<#6D41\>>
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-2><vspace|0.5fn>
    </associate>
  </collection>
</auxiliary>