var documenterSearchIndex = {"docs":
[{"location":"#HorizonsEphemeris.jl","page":"HorizonsEphemeris.jl","title":"HorizonsEphemeris.jl","text":"","category":"section"},{"location":"","page":"HorizonsEphemeris.jl","title":"HorizonsEphemeris.jl","text":"Solar system ephemeris data for free!","category":"page"},{"location":"","page":"HorizonsEphemeris.jl","title":"HorizonsEphemeris.jl","text":"While HorizonsAPI.jl provides a precise interface which matches the JPL Horizons API, HorizonsEphemeris.jl provides a more user-friendly way to request solar system ephemeris data. This package is in its early stages! The API will stabilize at v1.0. For now,  treat minor version bumps as breaking changes. Patch updates are non-breaking changes.","category":"page"},{"location":"","page":"HorizonsEphemeris.jl","title":"HorizonsEphemeris.jl","text":"warning: Warning\nMore documentation will come, but for now, HorizonsEphemeris only has humble docstrings! For more information, take a look at the project's GitHub repository. There, and in docstrings, you'll find a recurring warning which is reiterated here: this project is not affiliated with or endorsed by NASA, JPL, Caltech, or any other organization!","category":"page"},{"location":"docstrings/#Documentation","page":"Documentation","title":"Documentation","text":"","category":"section"},{"location":"docstrings/","page":"Documentation","title":"Documentation","text":"All docstrings!","category":"page"},{"location":"docstrings/","page":"Documentation","title":"Documentation","text":"Modules = [\n    HorizonsEphemeris,\n]\nOrder = [:module, :type, :function, :constant]","category":"page"},{"location":"docstrings/#HorizonsEphemeris.HorizonsEphemeris","page":"Documentation","title":"HorizonsEphemeris.HorizonsEphemeris","text":"Interact with the JPL HORIZONS REST API.\n\nExtended Help\n\n(Image: Tests) (Image: Docs) (Image: SciML Code Style)\n\nHorizonsEphemeris\n\nA wrapper around the wrapper around JPL's REST API for the HORIZONS solar system ephemeris platform!\n\nWarningThis package is not affiliated with or endorsed by NASA, JPL, Caltech, or any other organization! This is an independently written package by an astrodynamics hobbyist. For more information about code sharing and usage, see the HorizonsEphemeris.jl license file.\n\nInstallation\n\nChoose one of the following two lines!\n\njulia> ]add HorizonsEphemeris\n\njulia> import Pkg; Pkg.add(\"HorizonsEphemeris\");\n\nUsage\n\nAs of v0.1, only Cartesian vectors are supported. You can query the ephemeris function with any solar system body name, or NAIF code; HorizonsEphemeris uses SPICE under the hood to return the appropriate Horizons-compatible NAIF code. After providing the desired solar system body, specify the start time, stop time, and step size for which you want ephemeris data. You'll receive a NamedTuple in return, with keys defaulting to: [:MJD, :Calendar, :X, :Y, :Z, :ΔX, :ΔY, :ΔZ]. The labels for each key can be changed with the header keyword. For example, to get rid of the Unicode character keys, specify header=[:MJD, :Calendar, :X, :Y, :Z, :DX, :DY, :DZ]. This NamedTuple output is automatically compatible with DataFrames. Finally, use the file keyword argument to write the resulting ephemeris data, with labels, to a provided filename as a CSV file.\n\njulia> using Plots, Dates, HorizonsEphemeris\n\njulia> earth = let start = now() - Year(50), stop = now() + Year(50), step = Day(1)\n           @time ephemeris(\"earth\", start, stop, step; wrt=\"jupiter\", units=\"AU-D\");\n       end\n  6.376672 seconds (19.78 k allocations: 21.253 MiB)\n\njulia> plot(\n           earth.X, earth.Y;\n           aspect_ratio = 1,\n           linewidth = 1.5,\n           border = :none,\n           size = (600, 600),\n           dpi = 200,\n           grid = false,\n           axis = nothing,\n           title = \"\",\n           label=:none,\n           color = \"green\",\n           background=:transparent,\n       )\n\n(Image: )\n\nLicense\n\nMIT License\n\nCopyright (c) 2023 Joe Carpinelli\n\nPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.\n\nExports\n\nNAIF\nephemeris\n\nImports\n\nBase\nCSV\nCore\nDates\nDocStringExtensions\n\n\n\n\n\n","category":"module"},{"location":"docstrings/#HorizonsEphemeris.NAIF-Tuple{AbstractString}","page":"Documentation","title":"HorizonsEphemeris.NAIF","text":"NAIF(name)\n\n\nGiven a NAIF ID, return the associated name, if one exists. If the ID provided cannot be found, a KeyError is thrown.\n\n\n\n\n\n","category":"method"},{"location":"docstrings/#HorizonsEphemeris.NAIF-Tuple{Integer}","page":"Documentation","title":"HorizonsEphemeris.NAIF","text":"NAIF(code)\n\n\nIf a name is given, return the associated NAIF ID, if one exists. If the name provided cannot be found, a KeyError is thrown.\n\n\n\n\n\n","category":"method"},{"location":"docstrings/#HorizonsEphemeris.ephemeris-NTuple{4, Any}","page":"Documentation","title":"HorizonsEphemeris.ephemeris","text":"ephemeris(\n    body,\n    start,\n    stop,\n    intervol;\n    site,\n    wrt,\n    timeformat,\n    file,\n    units,\n    header\n)\n\n\nPull ephemeris data for the provided celestial body, or celestial system.\n\n\n\n\n\n","category":"method"}]
}
