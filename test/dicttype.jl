using TOML, Test

@testset "TOML.(try)parse(file) entrypoints with dicttype" begin
    dicttype = Test.IdDict{String,Any}
    invalid_dicttype = Test.IdDict{Any, Any}
    dict = dicttype("a" => 1)
    str = "a = 1"; invalid_str = "a"
    path, io = mktemp(); write(io, str); close(io)
    invalid_path, io = mktemp(); write(io, invalid_str); close(io)
    p = TOML.Parser()
    # TOML.parse
    @test TOML.parse(str; dicttype=dicttype) == TOML.parse(SubString(str); dicttype=dicttype) ==
          TOML.parse(IOBuffer(str); dicttype=dicttype) ==
          TOML.parse(p, str; dicttype=dicttype) == TOML.parse(p, SubString(str); dicttype=dicttype) ==
          TOML.parse(p, IOBuffer(str); dicttype=dicttype) == dict
    @test_throws TOML.ParserError TOML.parse(invalid_str; dicttype=dicttype)
    @test_throws TOML.ParserError TOML.parse(SubString(invalid_str); dicttype=dicttype)
    @test_throws TOML.ParserError TOML.parse(IOBuffer(invalid_str); dicttype=dicttype)
    @test_throws TOML.ParserError TOML.parse(p, invalid_str; dicttype=dicttype)
    @test_throws TOML.ParserError TOML.parse(p, SubString(invalid_str); dicttype=dicttype)
    @test_throws TOML.ParserError TOML.parse(p, IOBuffer(invalid_str); dicttype=dicttype)
    @test_throws MethodError TOML.parse(str; dicttype=invalid_dicttype) 
    # TOML.tryparse
    @test TOML.tryparse(str; dicttype=dicttype) == TOML.tryparse(SubString(str); dicttype=dicttype) ==
          TOML.tryparse(IOBuffer(str); dicttype=dicttype) ==
          TOML.tryparse(p, str; dicttype=dicttype) == TOML.tryparse(p, SubString(str); dicttype=dicttype) ==
          TOML.tryparse(p, IOBuffer(str); dicttype=dicttype) == dict
    @test TOML.tryparse(invalid_str; dicttype=dicttype) isa TOML.ParserError
    @test TOML.tryparse(SubString(invalid_str); dicttype=dicttype) isa TOML.ParserError
    @test TOML.tryparse(IOBuffer(invalid_str); dicttype=dicttype) isa TOML.ParserError
    @test TOML.tryparse(p, invalid_str; dicttype=dicttype) isa TOML.ParserError
    @test TOML.tryparse(p, SubString(invalid_str); dicttype=dicttype) isa TOML.ParserError
    @test TOML.tryparse(p, IOBuffer(invalid_str); dicttype=dicttype) isa TOML.ParserError
    # TOML.parsefile
    @test TOML.parsefile(path; dicttype=dicttype) == TOML.parsefile(SubString(path); dicttype=dicttype) ==
          TOML.parsefile(p, path; dicttype=dicttype) == TOML.parsefile(p, SubString(path); dicttype=dicttype) == dict
    @test_throws TOML.ParserError TOML.parsefile(invalid_path; dicttype=dicttype)
    @test_throws TOML.ParserError TOML.parsefile(SubString(invalid_path); dicttype=dicttype)
    @test_throws TOML.ParserError TOML.parsefile(p, invalid_path; dicttype=dicttype)
    @test_throws TOML.ParserError TOML.parsefile(p, SubString(invalid_path); dicttype=dicttype)
    @test_throws MethodError TOML.parsefile(path; dicttype=invalid_dicttype) 
    # TOML.tryparsefile
    @test TOML.tryparsefile(path; dicttype=dicttype) == TOML.tryparsefile(SubString(path); dicttype=dicttype) ==
          TOML.tryparsefile(p, path; dicttype=dicttype) == TOML.tryparsefile(p, SubString(path); dicttype=dicttype) == dict
    @test TOML.tryparsefile(invalid_path; dicttype=dicttype) isa TOML.ParserError
    @test TOML.tryparsefile(SubString(invalid_path); dicttype=dicttype) isa TOML.ParserError
    @test TOML.tryparsefile(p, invalid_path; dicttype=dicttype) isa TOML.ParserError
    @test TOML.tryparsefile(p, SubString(invalid_path); dicttype=dicttype) isa TOML.ParserError
end