# TOML

TOML.jl is a Julia standard library for parsing and writing [TOML
v1.0](https://toml.io/en/) files.

## Parsing TOML data

```jldoctest
julia> using TOML

julia> data = """
           [database]
           server = "192.168.1.1"
           ports = [ 8001, 8001, 8002 ]
       """;

julia> TOML.parsestring(data)
Dict{String,Any} with 1 entry:
  "database" => Dict{String,Any}("server"=>"192.168.1.1","ports"=>Any[8001, 800…
```

To parse a file, use [`TOML.parsefile`](@ref). If the file has a syntax error,
an exception is thrown:

```jldoctest
julia> using TOML

julia> TOML.parsestring("""
           value = 0.0.0
       """)
ERROR: TOML Parser error:
none:1:16 error: failed to parse value
      value = 0.0.0
                 ^
[...]
```

There are other versions of the parse functions ([`TOML.tryparsestring`](@ref)
and [`TOML.tryparsefile`]) that instead of throwing exceptions on parser error
returns a [`TOML.ParserError`](@ref) with information:

```jldoctest
julia> using TOML

julia> err = TOML.tryparsestring("""
           value = 0.0.0
       """);

julia> err.type
ErrGenericValueError::ErrorType = 14

julia> err.line
1

julia> err.column
16
```


## Exporting data to TOML file

The [`TOML.print`](@ref) function is used to print (or serialize) data into TOML
format.

```jldoctest
julia> using TOML

julia> fname = tempname();

julia> data = Dict(
          "names" => ["Julia", "Julio"],
          "age" => [10, 20],
       );

julia> open(fname, "w") do io
           TOML.print(io, data)
       end;

julia> print(read(fname, String))
names = ["Julia", "Julio"]
age = [10, 20]
```



## References
```@docs
TOML.parsestring
TOML.parsefile
TOML.tryparsestring
TOML.tryparsefile
TOML.print
TOML.Parser
TOML.ParserError
```
