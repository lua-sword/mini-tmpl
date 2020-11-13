Current issue:

how to define and manage post-template transformation like:

!{ v1|f1 > t1|f2 }



!{ v1|f1 > t1 } it is like render template=t1 env=(f1(v1))

we what post rendering stuff ? like
	f2( render( template=t1, env=(f1(v1)) )






Well defined
============


The is 2 step

1) convert template to lua string and ast items.

2) detect start and stop ast to convert to a new ast type containing the items between the both marks.

Sample: !{name} bla !{1} !{/name}


How to define a template on the fly

!{name}
here is the template named "name" content 
!{/name}

!{name}
here is the template named "name" content
!{/name}


Render a template with specified value/env:

!{varname>name}

!{varname<values}

Render a template with the current value/env:

!{>name}
!{<name}

Define a Anonymous template

!{<}
here is the anonymous template content
!{/}

Render a anonymous template with specified value/env:

!{<varname}
here is the anonymous template content
!{/}

!{varname>}
here is the anonymous template content
!{/}



EQUAL TO

!{value("varname")|template("")}
!{/""}
