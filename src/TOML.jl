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
[`TOML.parsefile`](@ref) or [`TOML.parse`](@ref).  Using an explicit parser
will however reuse some internal data structures which can be beneficial for
performance if a larger number of small files are parsed.
"""
const Parser = Internals.Parser

"""
    parsefile(f::AbstractString)
    parsefile(p::Parser, f::AbstractString)

Parse file `f` and return the resulting table (dictionary). Throw a
[`ParserError`](@ref) upon failure.

See also: [`TOML.tryparsefile`](@ref)
"""
parsefile(f::AbstractString) =
    Internals.parse(Parser(read(f, String); filepath=abspath(f)))
parsefile(p::Parser, f::AbstractString) =
    Internals.parse(Internals.reinit!(p, read(f, String); filepath=abspath(f)))

"""
    tryparsefile(f::AbstractString)
    tryparsefile(p::Parser, f::AbstractString)

Parse file `f` and return the resulting table (dictionary). Return a
[`ParserError`](@ref) upon failure.

See also: [`TOML.parsefile`](@ref)
"""
tryparsefile(f::AbstractString) =
    Internals.tryparse(Parser(read(f, String); filepath=abspath(f)))
tryparsefile(p::Parser, f::AbstractString) =
    Internals.tryparse(Internals.reinit!(p, read(f, String); filepath=abspath(f)))

"""
    parse(x::Union{AbstractString, IO})
    parse(p::Parser, x::Union{AbstractString, IO})

Parse the string  or stream `x`, and return the resulting table (dictionary).
Throw a [`ParserError`](@ref) upon failure.

See also: [`TOML.tryparse`](@ref)
"""
parse(str::AbstractString) =
    Internals.parse(Parser(String(str)))
parse(p::Parser, str::AbstractString) =
    Internals.parse(Internals.reinit!(p, String(str)))
parse(io::IO) = parse(read(io, String))
parse(p::Parser, io::IO) = parse(p, read(io, String))

"""
    tryparse(x::Union{AbstractString, IO})
    tryparse(p::Parser, x::Union{AbstractString, IO})

Parse the string or stream `x`, and return the resulting table (dictionary).
Return a [`ParserError`](@ref) upon failure.

See also: [`TOML.parse`](@ref)
"""
tryparse(str::AbstractString) =
    Internals.tryparse(Parser(String(str)))
tryparse(p::Parser, str::AbstractString) =
    Internals.tryparse(Internals.reinit!(p, String(str)))
tryparse(io::IO) = tryparse(read(io, String))
tryparse(p::Parser, io::IO) = tryparse(p, read(io, String))

"""
    ParserError

Type that is returned from [`tryparse`](@ref) and [`tryparsefile`](@ref)
when parsing fails. It contains (among others) the following fields:

- `pos`, the position in the string when the error happened
- `table`, the result that so far was successfully parsed
- `type`, an error type, different for different types of errors
"""
const ParserError = Internals.ParserError


"""
    print([to_toml::Function], io::IO [=stdout], data::AbstractDict; sort=false, by=identity)

Writes `data` as TOML syntax to the stream `io`. The keyword argument `sort`
sorts the output on the keys of the tables with the top level tables are
sorted according to the keyword argument `by`.

The following data types are supported: `AbstractDict`, `AbstractVector`, `AbstractString`, `Integer`, `AbstractFloat`, `Bool`,
`Dates.DateTime`, `Dates.Time`, `Dates.Date`. Note that the integers and floats
need to be convertible to `Float64` and `Int64` respectively. For other data types,
pass the function `to_toml` that takes the data types and returns a value of a
supported type.
"""
const print = Internals.Printer.print

end
