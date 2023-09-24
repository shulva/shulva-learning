<TeXmacs|2.1.2>

<style|<tuple|generic|chinese>>

<\body>
  <doc-data|<doc-title|\<#7B97\>\<#6CD5\>\<#5BFC\>\<#8BBA\>>>

  <section|\<#7B97\>\<#6CD5\>\<#5728\>\<#8BA1\>\<#7B97\>\<#4E2D\>\<#7684\>\<#4F5C\>\<#7528\>>

  <subsection|\<#8BFE\>\<#540E\>\<#4E60\>\<#9898\>>

  1.2-2(Exercises)\<#FF1A\>

  <\eqnarray*>
    <tformat|<table|<row|<cell|\<#5373\>>|<cell|8n<rsup|2>\<less\>64nlog<rsub|2><around*|(|n|)>>|<cell|>>|<row|<cell|>|<cell|n\<less\>8log<rsub|2><around*|(|n|)>>|<cell|\<#4E66\>\<#4E2D\>lg<around*|(|n|)>=log<rsub|2><around*|(|n|)>>>|<row|<cell|>|<cell|>|<cell|>>>>
  </eqnarray*>

  <\with|par-mode|center>
    n\<#5C5E\>\<#4E8E\>\<#81EA\>\<#7136\>\<#6570\>\<#FF0C\>\<#6545\>n\<less\>43\<#65F6\>\<#7B49\>\<#5F0F\>\<#6210\>\<#7ACB\>
  </with>

  \<#601D\>\<#8003\>\<#9898\>1-1(Problems)\<#FF1A\>

  \<#6211\>\<#4EEC\>\<#5148\>\<#5F97\>\<#51FA\>n\<#884C\>\<#7684\>\<#6570\>\<#636E\>\<#FF0C\>\<#5176\>\<#4ED6\>\<#4EE5\>\<#6B64\>\<#7C7B\>\<#63A8\>\<#5373\>\<#53EF\>\<#3002\>

  <\big-table|<block|<tformat|<table|<row|<cell|>|<cell|1\<#79D2\>>|<cell|1\<#5206\>>|<cell|1\<#5C0F\>\<#65F6\>>|<cell|1\<#5929\>>|<cell|1\<#6708\>>|<cell|1\<#5E74\>>|<cell|1\<#4E16\>\<#754C\>>>|<row|<cell|<math|lg<around*|(|n|)>>>|<cell|<math|10<rsup|301030>>>|<cell|>|<cell|>|<cell|>|<cell|>|<cell|>|<cell|>>|<row|<cell|<math|<sqrt|n>>>|<cell|<math|10<rsup|12>>>|<cell|>|<cell|>|<cell|>|<cell|<math|6.9\<times\>10<rsup|24>>>|<cell|>|<cell|>>|<row|<cell|<math|n>>|<cell|<math|10<rsup|6>>>|<cell|<math|6\<times\>10<rsup|7>>>|<cell|<math|3.6\<times\>10<rsup|9>>>|<cell|<math|8.6\<times\>10<rsup|10>>>|<cell|<math|2.6\<times\>10<rsup|12>>>|<cell|<math|3.2\<times\>10<rsup|13>>>|<cell|<math|3.2\<times\>10<rsup|15>>>>|<row|<cell|<math|n
  lg<around*|(|n|)>>>|<cell|<math|6.27\<times\>10<rsup|5>>>|<cell|>|<cell|>|<cell|>|<cell|>|<cell|>|<cell|>>|<row|<cell|<math|n<rsup|2>>>|<cell|<math|10<rsup|3>>>|<cell|>|<cell|>|<cell|>|<cell|>|<cell|>|<cell|>>|<row|<cell|<math|n<rsup|3>>>|<cell|<math|10<rsup|2>>>|<cell|>|<cell|>|<cell|>|<cell|>|<cell|>|<cell|>>|<row|<cell|<math|2<rsup|n>>>|<cell|19>|<cell|>|<cell|>|<cell|>|<cell|>|<cell|>|<cell|>>|<row|<cell|<math|n!>>|<cell|9>|<cell|>|<cell|>|<cell|>|<cell|>|<cell|>|<cell|>>>>>>
    problem 1-1
  </big-table>

  \;

  <section|\<#7B97\>\<#6CD5\>\<#57FA\>\<#7840\>>

  <subsection|\<#8BFE\>\<#540E\>\<#4E60\>\<#9898\>>

  2.1-4:

  <\python-code>
    search(array,v) //array = a1..an

    \ \ \ \ for(int i=1,i\<less\>n+1,i++)

    \ \ \ \ \ \ \ \ if(v == array[i])

    \ \ \ \ \ \ \ \ \ \ \ \ return i

    \ \ \ \ return NIL
  </python-code>

  loop invariant \<#5FAA\>\<#73AF\>\<#4E0D\>\<#53D8\>\<#91CF\>\<#8BC1\>\<#660E\>:

  <space|2em>initialisation: \<#5FAA\>\<#73AF\>\<#5F00\>\<#59CB\>\<#65F6\>\<#FF0C\>

  \;

  <\python>
    \;
  </python>

  <section|\<#51FD\>\<#6570\>\<#7684\>\<#589E\>\<#957F\>>

  <subsection|\<#8BFE\>\<#540E\>\<#4E60\>\<#9898\>>

  3.3-4\<#FF1A\>

  b:

  <\eqnarray*>
    <tformat|<table|<row|<cell|>|<cell|n!=o<around*|(|n<rsup|n>|)>>|<cell|<around*|(|3.26|)>>>|<row|<cell|\<#8BC1\>:>|<cell|\<forall\>c\<gtr\>0:\<exists\>n<rsub|0>:\<forall\>n\<geqslant\>n<rsub|0>:0\<leqslant\>f<around*|(|n|)>\<less\>c
    g<around*|(|n|)>>|<cell|>>|<row|<cell|>|<cell|0\<leqslant\>n!\<less\>c
    n<rsup|n>>|<cell|>>|<row|<cell|>|<cell|n\<gtr\><frac|1|c>\<geqslant\><frac|n!|c
    n<rsup|n-1>>>|<cell|>>|<row|<cell|>|<cell|1\<times\><frac|2|n>\<ldots\>\<times\><frac|n|n>=<frac|n!|n<rsup|n-1>>\<leqslant\>1>|<cell|>>|<row|<cell|>|<cell|n<rsub|0>\<gtr\><frac|1|c>
    \<#5373\>\<#53EF\>>|<cell|>>|<row|<cell|>|<cell|>|<cell|>>|<row|<cell|>|<cell|n!=\<omega\><around*|(|2<rsup|n>|)>>|<cell|<around*|(|3.27|)>>>|<row|<cell|\<#8BC1\>:>|<cell|\<forall\>c\<gtr\>0:\<exists\>n<rsub|0>:\<forall\>n\<geqslant\>n<rsub|0>:0\<leqslant\>c
    g<around*|(|n|)>\<less\>f<around*|(|n|)>>|<cell|>>|<row|<cell|>|<cell|0\<leqslant\>c
    2<rsup|n>\<less\>n!>|<cell|>>|<row|<cell|>|<cell|n\<gtr\>4c\<geqslant\><frac|c
    2<rsup|n>|<around*|(|n-1|)>!>>|<cell|>>|<row|<cell|>|<cell|2\<times\><frac|2|1>\<times\><frac|2|2>\<times\><frac|2|3>\<ldots\>.\<times\><frac|2|n-1>=<frac|2<rsup|n>|<around*|(|n-1|)>!>\<leqslant\>4>|<cell|>>|<row|<cell|>|<cell|n<rsub|0>\<gtr\>4c
    \<#5373\>\<#53EF\>>|<cell|>>|<row|<cell|>|<cell|>|<cell|>>|<row|<cell|>|<cell|lg<around*|(|n!|)>=\<Theta\><around*|(|n
    lg n|)>>|<cell|<around*|(|3.28|)>>>|<row|<cell|\<#8BC1\>:>|<cell|<around*|\<nobracket\>|n!=<sqrt|2\<mathpi\>n
    >\<times\><around*|(|n/e|\<nobracket\>>|)><rsup|n>\<times\><around*|(|1+\<Theta\><around*|(|1/n|)>|\<nobracket\>>>|<cell|Stirling>>|<row|<cell|>|<cell|lg<around*|(|<sqrt|2\<mathpi\>n
    >|)>+n lg<around*|(|n/e|)>+lg<around*|(|1+\<Theta\><around*|(|1/n|)>|)>=\<Theta\><around*|(|n
    lg n|)>>|<cell|>>>>
  </eqnarray*>

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
    <associate|auto-2|<tuple|1.1|1>>
    <associate|auto-3|<tuple|1|1>>
    <associate|auto-4|<tuple|2|1>>
    <associate|auto-5|<tuple|2.1|?>>
    <associate|auto-6|<tuple|3|?>>
    <associate|auto-7|<tuple|3.1|?>>
  </collection>
</references>

<\auxiliary>
  <\collection>
    <\associate|toc>
      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|1<space|2spc>\<#7B97\>\<#6CD5\>\<#5728\>\<#8BA1\>\<#7B97\>\<#4E2D\>\<#7684\>\<#4F5C\>\<#7528\>>
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-1><vspace|0.5fn>

      <with|par-left|<quote|1tab>|1.1<space|2spc>\<#8BFE\>\<#540E\>\<#4E60\>\<#9898\>
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-2>>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|2<space|2spc>\<#7B97\>\<#6CD5\>\<#57FA\>\<#7840\>>
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-3><vspace|0.5fn>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|3<space|2spc>\<#51FD\>\<#6570\>\<#7684\>\<#589E\>\<#957F\>>
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-4><vspace|0.5fn>
    </associate>
  </collection>
</auxiliary>