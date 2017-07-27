module object;

alias size_t    = typeof(int.sizeof);
alias ptrdiff_t = typeof(cast(void*)0 - cast(void*)0);
alias string    = immutable(char)[];

class Object
{ }

class Throwable
{ }

class Error : Throwable
{ 
    this(string x)
    { }
}