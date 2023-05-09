"""
Interact with the JPL HORIZONS REST API.

# Extended Help

$(README)

## License

$(LICENSE)

## Exports

$(EXPORTS)

## Imports

$(IMPORTS)
"""
module HorizonsEphemeris

export NAIF, ephemeris

using DocStringExtensions

@template (FUNCTIONS, METHODS, MACROS) = """
                                         $(SIGNATURES)
                                         $(DOCSTRING)
                                         """

@template (TYPES, CONSTANTS) = """
                               $(TYPEDEF)
                               $(DOCSTRING)
                               """

import JSON
import HTTP

using CSV
using Dates
using SPICE: bodc2n, bodn2c
using HorizonsAPI: fetch_vectors

"""
The Horizons API can only process so many discrete time points at once!

# Extended Help

See [#2](https://github.com/cadojo/HorizonsEphemeris.jl/issues/2).
"""
const MAX_TLIST_LENGTH = 30

"""
Given a NAIF ID, return the associated name, if one exists. If the ID provided cannot be
found, a `KeyError` is thrown.
"""
function NAIF(name::AbstractString)::Int

    code = bodn2c(name)

    if !isnothing(code)
        return code
    else
        throw(KeyError(name))
    end

end

"""
If a name is given, return the associated NAIF ID, if one exists. If the name provided
cannot be found, a `KeyError` is thrown.
"""
function NAIF(code::Integer)::String

    name = bodc2n(code)

    if !isnothing(name)
        return name
    else
        throw(KeyError(code))
    end

end

"""
Parse the body of a `HTTP.Response` for CSV content, and any returned notes about the CSV content.
"""
function parse_response(response::HTTP.Response; start="\$\$SOE", stop="\$\$EOE")

    content = JSON.parse(String(response.body))

    result = content["result"]

    if occursin(start, result) && occursin(stop, result)
        _, ephemeris = split(result, start)
        ephemeris, notes = split(ephemeris, stop)

        ephemeris = strip(ephemeris)

        notes = join(
            filter(
                line -> !all(char -> char == '*', collect(strip(line))),
                collect(eachline(IOBuffer(notes))),
            ), "\n"
        ) |> strip

        return ephemeris, notes
    else
        if "error" in keys(content)
            error("The data delimiters ($start, $stop) were not found in the response! \n\n\t$(content["error"])")
        else
            error("The data delimiters ($start, $stop) were not found in the response!")
        end
    end

end

"""
A supertype for all celestial ephemeris data.
"""
abstract type AbstractEphemeris end

"""
Cartesian ephemeris data for a Celestial body.
"""
struct CartesianEphemeris{L,D} <: AbstractEphemeris
    """The core ephemeris data."""
    data::NamedTuple{L,D}

    """The notes sent alongside the ephemeris data."""
    note::String

    CartesianEphemeris(data::NamedTuple{L,D}, note) where {L,D} = new{L,D}(data, String(note))
end

Base.getproperty(eph::CartesianEphemeris, name::Symbol) = getproperty(getfield(eph, :data), name)


function Base.show(io::IO, ::MIME"text/plain", eph::CartesianEphemeris{L},) where {L}
    print(io, "CartesianEphemeris with fields $(join(":" .* string.(L), ", "))")
end

function Base.show(io::IO, ::MIME"text/html", eph::CartesianEphemeris{L},) where {L}
    print(io, "<p>")
    Base.show(io, MIME"text/plain", eph)
    print(io, "</p>")
    println(io, "<details> \n\n <summary>Ephemeris Notes</summary> \n\n $(getfield(eph, :note)) \n\n </details>")
end

"""
Pull ephemeris data for the provided celestial body, or celestial system.
"""
function ephemeris(
    body, start, stop, intervol;
    site="",
    wrt="ssb",
    mjd=true,
    file=nothing,
    units="AU-D",
    header=[:t, :cal, :x, :y, :z, :δx, :δy, :δz]
)
    code = body isa Integer ? body : NAIF(body)

    if !(uppercase(strip(units)) in ("AU-D", "KM-D", "KM-S"))
        error("The only acceptable inputs for the units keyword argument are: KM-S, KM-D, AU-D.")
    end

    response = fetch_vectors(
        code;
        format="json",
        CENTER="$(site)@$(NAIF(wrt))",
        START_TIME=Dates.format(DateTime(start), "yyyy-mm-dd HH:MM:SS.sss"),
        STOP_TIME=Dates.format(DateTime(stop), "yyyy-mm-dd HH:MM:SS.sss"),
        STEP_SIZE=string(intervol),
        REF_PLANE="FRAME",
        CSV_FORMAT=true,
        VEC_TABLE=2,
        VEC_CORR="NONE",
        OUT_UNITS=units,
        VEC_LABELS=false,
        VEC_DELTA_T=false,
        TIME_DIGITS="FRACSEC",
        TLIST_TYPE=(mjd ? "MJD" : "JD")
    )

    ephemeris, notes = parse_response(response; start="\$\$SOE", stop="\$\$EOE")

    csv = CSV.File(IOBuffer(ephemeris); header=false, drop=[9])
    output = NamedTuple(label => csv[column] for (label, column) in zip(header, csv.names))

    if !isnothing(file)
        CSV.write(file, csv; header=header)
        @info "Ephemeris data for object with NAIF ID $code has been written to $file."
    end

    return CartesianEphemeris(
        output, notes,
    )
end


function ephemeris(
    body, times;
    site="",
    wrt="ssb",
    mjd=true,
    file=nothing,
    units="AU-D",
    header=[:t, :cal, :x, :y, :z, :ẋ, :ẏ, :ż]
)
    code = body isa Integer ? body : NAIF(body)

    if !(uppercase(strip(units)) in ("AU-D", "KM-D", "KM-S"))
        throw(ErrorException("The only acceptable inputs for the units keyword argument are: KM-S, KM-D, AU-D."))
    end

    #
    # TODO: Add time formatting to HorizonsAPI
    #

    times = (times isa AbstractString ? times : [Dates.format(DateTime(time), "yyyy-mm-dd HH:MM:SS.sss") for time in times])

    if !(t isa AbstractString) && length(t) > MAX_TLIST_LENGTH
        chunks = map(
            t -> ephemeris(body, t; site=site, wrt=wrt, mjd=mjd, file=nothing, units=units, header=header),
            Iterators.partition(times, MAX_TLIST_LENGTH)
        )

        eph
    end

    response = fetch_vectors(
        code;
        format="json",
        CENTER="$(site)@$(NAIF(wrt))",
        TLIST=(times isa AbstractString ? times : [Dates.format(DateTime(time), "yyyy-mm-dd HH:MM:SS.sss") for time in times]),
        TLIST_TYPE=(mjd ? "MJD" : "JD"),
        REF_PLANE="FRAME",
        CSV_FORMAT=true,
        VEC_TABLE="2",
        VEC_CORR="NONE",
        OUT_UNITS=units,
        VEC_LABELS=false,
        VEC_DELTA_T=false,
        TIME_DIGITS="FRACSEC"
    )

    ephemeris, notes = parse_response(response; start="\$\$SOE", stop="\$\$EOE")

    csv = CSV.File(IOBuffer(ephemeris); header=false, drop=[9])
    output = NamedTuple(label => csv[column] for (label, column) in zip(header, csv.names))

    if !isnothing(file)
        CSV.write(file, csv; header=header)
        @info "Ephemeris data for object with NAIF ID $code has been written to $file."
    end

    return CartesianEphemeris(
        output, notes,
    )
end

end # module HorizonsEphemeris
