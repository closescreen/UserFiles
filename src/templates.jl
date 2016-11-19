"""Add skeleton text to file myfile .
skelet(\"myfile\", true, GzipRow, source1=\"file1\", source2=\"file2\")
\"myfile\" |> skelet( true, GzipRow, source1=\"file1\", source2=\"file2\")
"""
skelet{ U<:UserFile }( wr::Bool, T::Type{U} ; need... ) = f::AbstractString->skelet(f, wr, T; need...)


"""
Returns new type definitions text as string.
\"myfile\"|> skelet(GzipRow, source1=\"file1\", source2=\"file2\")
"""
skelet{ U<:UserFile }( T::Type{U}; need... ) = f::AbstractString->skelet(f, false, T; need...)

"""
skelet(\"myfile\", GzipRow, source1=\"file1\", source2=\"file2\")
"""
function skelet{ U<:UserFile }(file::AbstractString, wr::Bool, T::Type{U}; need...)

newtype = file |>
    _->replace(_, r"\..+?$", "")|>
    _->replace(_, r"(?<=\W)\w", uppercase)|>
    _->replace(_,r"\W","")|> 
    _->replace(_,r"\w",uppercase,1)
    
needstr = Dict( Symbol(k)=>v for (k,v) in need )

rv = """
type $newtype <: $T
    match::RegexMatch
end

typealias F $newtype

re(T::Type{F}) = r\"$file\" # <-- fix me

function needfiles(f::F) # <-- check me 
 $needstr
end

function create(f::F) # <-- redefine me
 pipeline()|>run 
end

"""

if T<:RowFile rv = rv*"""
fs(T::Type{F}) = \"\\s\" # <--- redefine me!
fields(T::Type{F}) = [:a, :b] # <--- redefine me!
""" end



if wr 
    f = ismatch(r"\.jl$", file) ? file : newtype*".jl"
    open(_->print(_,"# Added $(now())\n", rv), f, "a")
    info("Definitions for $newtype was added to file $f")
else
    rv
end

end # function
export skelet

