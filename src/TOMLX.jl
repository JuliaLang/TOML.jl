module TOMLX

module Internals

const ENABLE_ASSERTS = false

macro TOML_assert(ex, msgs...)
    if ENABLE_ASSERTS
        msg = isempty(msgs) ? string(ex) : msgs[1]
        return :($(esc(ex)) ? $(nothing) : throw(AssertionError($msg)))
    else
        return :($(esc(ex)))
    end
end

const HAVE_DATES = true

include("parser.jl")

end # module

"""
    parsefile(f::AbstractString)

Parses a file `f` and returns the resulting
table (dictionary). Throws a [`ParserError`](@ref)
upon failure.

See also [`tryparsefile`](@ref)
"""
parsefile(f::AbstractString) =
    parse(Parser(read(f, String); filepath=abspath(f)); raise=true)

"""
    tryparsefile(f::AbstractString)

Parses a file `f` and returns the resulting
table (dictionary). Returns a [`ParserError`](@ref)
upon failure.

See also [`parsefile`](@ref)
"""
tryparsefile(f::AbstractString) =
    parse(Parser(read(f, String); filepath=abspath(f)); raise=false)

"""
    parsestring(str::AbstractString)

Parses a string `str` and returns the resulting
table (dictionary). Returns a [`ParserError`](@ref)
upon failure.

See also [`tryparsestring`](@ref)
"""
parsestring(str::AbstractString) =
    parse(Parser(String(str)); raise=true)

"""
    tryparsestring(str::AbstractString)

Parses a string `str` and returns the resulting
table (dictionary). Returns a [`ParserError`](@ref)
upon failure.

See also [`parsestring`](@ref)
"""
tryparsestring(str::AbstractString) =
    parse(Parser(String(str)); raise=false)

"""
    Parser()

Constructor for a TOML `Parser`. After creation the
functoin [`TOML.reinit!`](@ref) is used to initialize
the parser and then `TOML.parse` is called to parse
the data.

Note that in most cases one does not need to explicitly create
a `Parser` but instead one directly use
use [`parsefile`](@ref) or [`parsestring`](@ref).
"""
const Parser = Internals.Parser

"""
    TOML.reinit!(p::Parser, str::String; [filepath::String])

`reinit!` allows one to use the same `Parser` to parse
multiple files after each other. This can be useful for
performance since the internal data structures of the
parser does not need to be recreated for every file.
The `filepath` keyword sets the path to the file which
is used in error messages.

Typical use looks like:

```julia
p = TOML.Parser()
for file in files_to_parse
    TOML.reinit!(p, read(file, String); file)
    toml_table = TOML.parse(p)
    # do something with `toml_table`
end
"""
const reinit! = Internals.reinit!

"""
    parse(p::Parser; raise=false)

Execute the parsing with the `Parser` `p`.

See also [`reinit!`](@ref)
"""
const parse = Internals.parse


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

end # module
