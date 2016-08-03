"Identify if character in subset of bare key symbols"
isbare(c::Char) = 'A' <= c <= 'Z' || 'a' <= c <= 'z' || isdigit(c) || c == '-' || c == '_'

function printkey(io::IO, keys::Vector{String})
    for (i,k) in enumerate(keys)
        i != 1 && Base.print(io, ".")
        if length(k) == 0
            # empty key
            Base.print(io, "\"\"")
        elseif !all([isbare(c) for c in k])
            # quoted key
            Base.print(io, "\"$(escape_string(k))\"")
        else
            Base.print(io, k)
        end
    end
end

function printvalue(io::IO, value; sorted=false)
    if isa(value, Associative)
        _print(io, value, sorted=sorted)
    elseif isa(value, Array)
        Base.print(io, "[")
        for (i, e) in enumerate(value)
            i != 1 && Base.print(io, ", ")
            if isa(e, Associative)
                _print(io, e, sorted=sorted)
            else
                printvalue(io, e, sorted=sorted)
            end
        end
        Base.print(io, "]")
    elseif isa(value, AbstractString)
        Base.print(io, "\"$(escape_string(value))\"")
    elseif isa(value, DateTime)
        Base.print(io, Dates.format(value, "YYYY-mm-ddTHH:MM:SS.sssZ"))
    else
        Base.print(io, value)
    end
end

function _print(io::IO, a::Associative, ks=String[]; sorted=false)
  akeys = keys(a)
  if sorted
      akeys = sort!(collect(akeys))
  end

  for key in akeys
        value = a[key]
        # skip tables
        isa(value, Associative) && continue # skip tables
        # skip arrays of tabels
        isa(value, Array) && length(value)>0 && isa(value[1], Associative) && continue

        printkey(io, [key])
        Base.print(io, " = ") # print separator
        printvalue(io, value, sorted=sorted)
        Base.print(io, "\n")  # new line?
    end

    for key in akeys
        value = a[key]
        if isa(value, Associative)
            # print table
            push!(ks, key)
            Base.print(io,"[")
            printkey(io, ks)
            Base.print(io,"]\n")
            _print(io, value, ks, sorted=sorted)
            pop!(ks)
        elseif isa(value, Array) && length(value)>0 && isa(value[1], Associative)
            # print array of tables
            push!(ks, key)
            for v in value
                Base.print(io,"[[")
                printkey(io, ks)
                Base.print(io,"]]\n")
                !isa(v, Associative) && error("array should contain only tables")
                _print(io, v, ks, sorted=sorted)
            end
            pop!(ks)
        end
    end
end

print(io::IO, a::Associative; sorted=false) = _print(io, a, sorted=sorted)
print(a::Associative; sorted=false) = print(STDOUT, a, sorted=sorted)
