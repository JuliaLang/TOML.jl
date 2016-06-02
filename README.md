# TOML

A [TOML v0.4.0](https://github.com/toml-lang/toml) parser for Julia.

[![Build Status](https://travis-ci.org/wildart/TOML.jl.svg?branch=master)](https://travis-ci.org/wildart/TOML.jl)

[![Coverage Status](https://coveralls.io/repos/wildart/TOML.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/wildart/TOML.jl?branch=master)

## Usage

```julia

julia> using TOML

julia> TOML.parse("""
       name = "value"
       """)
Dict{AbstractString,Any} with 1 entry:
  "name" => "value"

julia> TOML.parsefile("etc/example.toml")
```
