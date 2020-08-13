module TOML

module Internals
    include("parser.jl")
    # We put the printing functionality in a separate module since It
    # defines a function `print` and we don't want that to collide with normal
    # usage of `(Base.)print` in other files
    module Printer
        include("print.jl")
    end
end

"""
    Parser()

Constructor for a TOML `Parser`.  Note that in most cases one does not need to
explicitly create a `Parser` but instead one directly use use
[`TOML.parsefile`](@ref) or [`parsestring`](@ref).  Using an explicit parser
will however reuse some internal data structures which can be beneficial for
performance if a larger number of small files are parsed.
"""
const Parser = Internals.Parser

"""
    parsefile(f::AbstractString)
    parsefile(p::Parser, f::AbstractString)

Parses a file `f` and returns the resulting table (dictionary). Throws a
[`ParserError`](@ref) upon failure.

See also [`TOML.tryparsefile`](@ref)
"""
parsefile(f::AbstractString) =
    Internals.parse(Parser(read(f, String); filepath=abspath(f)); raise=true)
parsefile(p::Parser, f::AbstractString) =
    Internals.parse(Internals.reinit!(p, read(f, String); filepath=abspath(f)); raise=true)

"""
    tryparsefile(f::AbstractString)
    tryparsefile(p::Parser, f::AbstractString)

Parses a file `f` and returns the resulting table (dictionary). Returns a
[`ParserError`](@ref) upon failure.

See also [`TOML.parsefile`](@ref)
"""
tryparsefile(f::AbstractString) =
    Internals.parse(Parser(read(f, String); filepath=abspath(f)); raise=false)
tryparsefile(p::Parser, f::AbstractString) =
    Internals.parse(Internals.reinit!(p, read(f, String); filepath=abspath(f)); raise=false)

"""
    parsestring(str::AbstractString)
    parsestring(p::Parser, str::AbstractString)

Parses a string `str` and returns the resulting table (dictionary). Returns a
[`ParserError`](@ref) upon failure.

See also [`TOML.tryparsestring`](@ref)
"""
parsestring(str::AbstractString) =
    Internals.parse(Parser(String(str)); raise=true)
parsestring(p::Parser, str::AbstractString) =
    Internals.parse(Internals.reinit!(p, String(str)); raise=true)

"""
    tryparsestring(str::AbstractString)
    tryparsestring(p::Parser, str::AbstractString)

Parses a string `str` and returns the resulting table (dictionary). Returns a
[`ParserError`](@ref) upon failure.

See also [`TOML.parsestring`](@ref)
"""
tryparsestring(str::AbstractString) =
    Internals.parse(Parser(String(str)); raise=false)
tryparsestring(p::Parser, str::AbstractString) =
    Internals.parse(Internals.reinit!(p, String(str)); raise=false)

"""
    ParserError

Type that is returned from [`tryparsestring`](@ref) and [`tryparsefile`](@ref)
when parsing fails. It contains (among others) the following fields:

- `pos`, the position in the string when the error happened
- `table`, the result that so far was successfully parsed
- `type`, an error type, different for different types of errors
"""
const ParserError = Internals.ParserError


"""
    print(io::IO, data::AbstractDict)

Writes `data` into TOML syntax to the stream `io`.
"""
const print = Internals.Printer.print

end
