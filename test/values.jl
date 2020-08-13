using Test
using TOML
using TOML: Internals

macro testval(s, v)
    f = "foo = $s"
    :( @test TOML.parsestring($f)["foo"] == $v )
end

macro failval(s, v)
    f = "foo = $s"
    :( err = TOML.tryparsestring($f);
       @test err isa TOML.Internals.ParserError;
       @test err.type == $v;
    )
end

@testset "Numbers" begin
    @failval("00"                   , Internals.ErrParsingDateTime)
    @failval("-00"                  , Internals.ErrParsingDateTime)
    @failval("+00"                  , Internals.ErrParsingDateTime)
    @failval("00.0"                 , Internals.ErrParsingDateTime)
    @failval("-00.0"                , Internals.ErrParsingDateTime)
    @failval("+00.0"                , Internals.ErrParsingDateTime)
    @failval("9223372036854775808"  , Internals.ErrOverflowError)
    @failval("-9223372036854775809" , Internals.ErrOverflowError)

    @failval("0."        , Internals.ErrNoTrailingDigitAfterDot)
    @failval("0.e"       , Internals.ErrNoTrailingDigitAfterDot)
    @failval("0.E"       , Internals.ErrNoTrailingDigitAfterDot)
    @failval("0.0E"      , Internals.ErrGenericValueError)
    @failval("0.0e"      , Internals.ErrGenericValueError)
    @failval("0.0e-"     , Internals.ErrGenericValueError)
    @failval("0.0e+"     , Internals.ErrGenericValueError)
    # @failval("0.0e+00" , Internals.ErrGenericValueError)

    @testval("1.0"         , 1.0)
    @testval("1.0e0"       , 1.0)
    @testval("1.0e+0"      , 1.0)
    @testval("1.0e-0"      , 1.0)
    @testval("1.001e-0"    , 1.001)
    @testval("2e10"        , 2e10)
    @testval("2e+10"       , 2e10)
    @testval("2e-10"       , 2e-10)
    @testval("2_0.0"       , 20.0)
    @testval("2_0.0_0e0_0" , 20.0)
    @testval("2_0.1_0e1_0" , 20.1e10)

    @testval("1_0"    , 10)
    @testval("1_0_0"  , 100)
    @testval("1_000"  , 1000)
    @testval("+1_000" , 1000)
    @testval("-1_000" , -1000)

    @failval("0_"     , Internals.ErrLeadingZeroNotAllowedInteger)
    @failval("0__0"   , Internals.ErrLeadingZeroNotAllowedInteger)
    @failval("__0"    , Internals.ErrUnexpectedStartOfValue)
    @failval("1_0_"   , Internals.ErrTrailingUnderscoreNumber)
    @failval("1_0__0" , Internals.ErrUnderscoreNotSurroundedByDigits)
end


@testset "Booleans" begin
    @testval("true", true)
    @testval("false", false)

    @failval("true2"  , Internals.ErrExpectedNewLineKeyValue)
    @failval("false2" , Internals.ErrExpectedNewLineKeyValue)
    @failval("talse"  , Internals.ErrGenericValueError)
    @failval("frue"   , Internals.ErrGenericValueError)
    @failval("t1"     , Internals.ErrGenericValueError)
    @failval("f1"     , Internals.ErrGenericValueError)
end

@testset "Datetime" begin
    @testval("2016-09-09T09:09:09"     , DateTime(2016 , 9 , 9 , 9 , 9 , 9))
    @testval("2016-09-09T09:09:09Z"    , DateTime(2016 , 9 , 9 , 9 , 9 , 9))
    @testval("2016-09-09T09:09:09.0Z"  , DateTime(2016 , 9 , 9 , 9 , 9 , 9))
    @testval("2016-09-09T09:09:09.012" , DateTime(2016 , 9 , 9 , 9 , 9 , 9  , 12))

    @failval("2016-09-09T09:09:09.0+10:00"   , Internals.ErrOffsetDateNotSupported)
    @failval("2016-09-09T09:09:09.012-02:00" , Internals.ErrOffsetDateNotSupported)
    @failval("2016-09-09T09:09:09.0+10:00"   , Internals.ErrOffsetDateNotSupported)
    @failval("2016-09-09T09:09:09.012-02:00" , Internals.ErrOffsetDateNotSupported)

    @failval("2016-09-09T09:09:09.Z" , Internals.ErrParsingDateTime)
    @failval("2016-9-09T09:09:09Z"   , Internals.ErrParsingDateTime)
    @failval("2016-13-09T09:09:09Z"  , Internals.ErrParsingDateTime)
    @failval("2016-02-31T09:09:09Z"  , Internals.ErrParsingDateTime)
    @failval("2016-09-09T09:09:09x"  , Internals.ErrParsingDateTime)
    @failval("2016-09-09s09:09:09Z"  , Internals.ErrParsingDateTime)
    @failval("2016-09-09T09:09:09x"  , Internals.ErrParsingDateTime)
end

@testset "Time" begin
    @testval("09:09:09.99"    , Time(9 , 9 , 9 , 99))
    @testval("09:09:09.99999" , Time(9 , 9 , 9 , 999))

    @failval("09:09x09", Internals.ErrParsingDateTime)
end

# TODO: Add more dedicated value tests

@testset "String" begin
    @failval("\"foooo", Internals.ErrUnexpectedEndString)

    #=
    Found these examples of string tests somewhere
    quot0=""" """    # valid
    quot1=""" """"   # valid
    quot2=""" """""  # valid
    quot3=""" """""" # invalid
    apos0=''' '''    # valid
    apos1=''' ''''   # valid
    apos2=''' '''''  # valid
    apos3=''' '''''' # invalid

    quot4=""""""     # valid (6 in a row, empty string)
    quot5="""" """   # valid
    quot6=""""" """  # valid
    quot7="""""" """ # invalid
    apos4=''''''     # valid (6 in a row, empty string)
    apos5='''' '''   # valid
    apos6=''''' '''  # valid
    apos7='''''' ''' # invalid

    quot8="""""\""""""     # valid (5 at start, 6 at end)
    quot9="""""\"""\"""""" # valid (3 in the middle 5 at start, 6 at end)

    =#
end
