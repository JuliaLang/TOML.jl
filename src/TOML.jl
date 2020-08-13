module TOML

using Dates

module Internals
    include("parser.jl")
    include("print.jl")
end # module

"""
    Parser()

Constructor for a TOML `Parser`. After creation the
function [`TOML.reinit!`](@ref) is used to initialize
the parser and then `TOML.parse` is called to parse
the data.
Note that in most cases one does not need to explicitly create
a `Parser` but instead one directly use
use [`parsefile`](@ref) or [`parsestring`](@ref).
"""
const Parser = Internals.Parser

"""
    parsefile(f::AbstractString)
    parsefile(p::Parser, f::AbstractString)

Parses a file `f` and returns the resulting
table (dictionary). Throws a [`ParserError`](@ref)
upon failure.

See also [`tryparsefile`](@ref)
"""
parsefile(f::AbstractString) =
    Internals.parse(Parser(read(f, String); filepath=abspath(f)); raise=true)
parsefile(p::Parser, f::AbstractString) =
    Internals.parse(Internals.reinit!(p, read(f, String); filepath=abspath(f)); raise=true)

"""
    tryparsefile(f::AbstractString)
    tryparsefile(p::Parser, f::AbstractString)

Parses a file `f` and returns the resulting
table (dictionary). Returns a [`ParserError`](@ref)
upon failure.

See also [`parsefile`](@ref)
"""
tryparsefile(f::AbstractString) =
    Internals.parse(Parser(read(f, String); filepath=abspath(f)); raise=false)
tryparsefile(p::Parser, f::AbstractString) =
    Internals.parse(Internals.reinit!(p, read(f, String); filepath=abspath(f)); raise=false)

"""
    parsestring(str::AbstractString)
    parsestring(p::Parser, str::AbstractString)

Parses a string `str` and returns the resulting
table (dictionary). Returns a [`ParserError`](@ref)
upon failure.

See also [`tryparsestring`](@ref)
"""
parsestring(str::AbstractString) =
    Internals.parse(Parser(String(str)); raise=true)
parsestring(p::Parser, str::AbstractString) =
    Internals.parse(Internals.reinit!(p, String(str)); raise=true)

"""
    tryparsestring(str::AbstractString)
    tryparsestring(p::Parser, str::AbstractString)

Parses a string `str` and returns the resulting
table (dictionary). Returns a [`ParserError`](@ref)
upon failure.
1
See also [`parsestring`](@ref)
"""
tryparsestring(str::AbstractString) =
    Internals.parse(Parser(String(str)); raise=false)
tryparsestring(p::Parser, str::AbstractString) =
    Internals.parse(Internals.reinit!(p, String(str)); raise=false)

"""
    ParserError
Type that is returned from [`tryparsestring`](@ref) and
[`tryparsefile`](@ref) when parsing fails. It contains the following 
fields:
- `pos`, the position in the string when the error happened
- `table`, the result that so far was successfully parsed
- `type`, an error type, different for different type of errors
"""
const ParserError = Internals.ParserError

end
