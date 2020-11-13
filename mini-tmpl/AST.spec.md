
0) AST 2020-11-12

An AST can be:
- any lua string
- a table with the following structure :

{
	AST_TYPE,
	AST_ARGS,
	AST_CONTENT,
}

1) AST_TYPE

AST_TYPE must be a number
For now I start at 1, I avoid the 0 number.

2) AST_ARGS

AST_ARGS can be :
- a list of AST_ARGS_ITEM with an indexed table
- empty with a EMPTY value (See EMPTY, AST_ARGS_EMPTY)

2.1) AST_ARGS_ITEM

An AST_ARGS_ITEM item can be *any value* (needed by the AST_TYPE render).
AST_ARGS_ITEM can be a nil, boolean, string, function, table, AST value, etc.

3) AST_CONTENT

AST_CONTENT can be :
- a list of AST_CONTENT_ITEM with an indexed table
- empty with a EMPTY value (See EMPTY, AST_CONTENT_EMPTY)

3.2) AST_CONTENT_ITEM

An AST_CONTENT_ITEM must be a value AST value.


X) EMPTY

EMPTY value can be
- a `nil` value
- the `0` number value
- a empty table (`{}`)

X.2) AST_ARGS_EMPTY

The AST_ARGS_EMPTY is `0`.

X.3) AST_CONTENT_EMPTY

The AST_CONTENT_EMPTY is `nil`.

