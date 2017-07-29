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

version(LDC)
{
    struct ModuleInfo
    { 
        uint _flags;
        uint _index;
    }

    class TypeInfo
    { 
        TypeInfo base;
        string   name;
        void[] m_init;
    }

    class TypeInfo_Class : TypeInfo
    {
        byte[]                init;
        string                name;
        void*[]               vtbl;
        void*[]               interfaces;
        TypeInfo_Class        base;
        void*                 destructor;
        void function(Object) classInvariant;
        uint                  m_flags;
        void*                 deallocator;
        void*[]               m_offTi;
        void function(Object) defaultConstructor;  
        immutable(void)* m_RTInfo; 
    }
    
    alias TypeInfo_Class ClassInfo;

    class TypeInfo_AssociativeArray : TypeInfo
    {
        TypeInfo value;
        TypeInfo key;
    }

    class TypeInfo_Struct : TypeInfo
    {
        string name;
        void[] m_init;

        @safe pure nothrow
        {
            size_t   function(in void*)           xtoHash;
            bool     function(in void*, in void*) xopEquals;
            int      function(in void*, in void*) xopCmp;
            string   function(in void*)           xtoString;
            uint m_flags;
        }
        union
        {
            void function(void*)                xdtor;
            void function(void*, const TypeInfo_Struct ti) xdtorti;
        }
        void function(void*)                    xpostblit;

        uint m_align;
        immutable(void)* m_RTInfo; 
    }
}