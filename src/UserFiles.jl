module UserFiles

"Common abstract type for files"
abstract UserFile
typealias UF UserFile

"Returns file name"
name{U<:UserFile}(file::U) = file.match.match.string
export name

"Abstract for row-based (line-by-line) readable files"
abstract RowFile <: UF
typealias RF RowFile


"Abstract type for gzip-compressed row-based files."
abstract GzipRows<:RF


"Abstract type for non-compressed row-based text files."
abstract PlainRows<:RF

export UserFile, RowFile, GzipRows, PlainRows

"Return explained string for error if function on type not implemented"
function _not_defined_on_type_text( funcname::AbstractString, T::Type, funcdesc::AbstractString, short=false)::AbstractString
    """Function $funcname(T::Type{$T}) not implemented by you. Define it as sample below:\n"""*
    _define_on_type_text( funcname, T, funcdesc, short)
end

function _define_on_type_text( funcname::AbstractString, T::Type, funcdesc::AbstractString, short=false )::AbstractString
"""\"$funcdesc\n\""""*
(short?
"""$funcname(T::Type{$T}) = \"Fix me! (type=$T)\" # <--- fix me"""
:"""
function $funcname(T::Type{$T}) 
        #...fix me! 
end
"""
)
end

function _define_on_value_text( funcname::AbstractString, T::Type, funcdesc::AbstractString,  short=false )::AbstractString
"""\"$funcdesc\n\""""*
(short?
"""$funcname(x::T) = \"Fix me! (type=$T)\" # <--- fix me"""
:"""
function $funcname(x::T) 
        #...fix me! 
end
"""
)
end



"""Create new T<:UserFile if filename is match to regexp from re(), defined on T
    Otherwise return nothing
"""
function new_if_match{ U<:UserFile }( T::Type{U}, filename::AbstractString)
 m = match( T|>re, filename)
 if m!=nothing
    T(m)
 end
end
export new_if_match



"""Returns regexp for concrete user file type instance or file type.
    Must be redefined on concrete user file type.
"""
re{U<:UserFile}(T::Type{U}) = _not_defined_on_type_text( "re", T, "returns Regex for any matched filenames", true)|>error
re(file::UserFile) = re(typeof(file))
export re



"""Returns Dict( groupname =>[ fileslist]) describing files needed as sources for create this file.
    Must be redefined on concrete user file type
"""
needfiles(userfile::UserFile)::Dict = error("needfiles() not implemented yet for $userfile")
export needfiles



"""Side-effect user file creation procedure.
    Must be redefined for concrete user file type.
    Takes concrete filename as parameter.
"""
create{T<:UserFile}(userfile::T)::Bool = 
    "create() not implemented yet for $userfile. You must define it. Sample:"*
    _define_on_value_text( "create", T, "Side-effect procedure to create file." )
export create



"""Returns field separator.
    Must be redefined on concrete user file type.
"""
fs{T<:UserFile}(::Type{T}) = _not_defined_on_type_text( "fs", T, "Returns field separator.", true)|>error
fs(f::UserFile) = fs(typeof(f)) 
export fs



"""Returns field list as symbols tuple.
    Must be redefined on concrete user file type.
"""
fields{T<:UserFile}(::Type{T}) = _not_defined_on_type_text( fields, T, "Returns fields list", true)|>error
fields(f::UserFile)::Tuple{Vararg{Symbol}} = fields(typeof(f))::Tuple{Vararg{Symbol}}
export fields



"""Side-effect procedure.
    Takes concrete file type instance. 
    Check for ready file (goodsize by default implementation).
    Call create(filename) if file not ready.
    Returns given file instance if it ready.
    Otherwise:
        If optional parameter strict=true (by default) then throw error if can't create file.
        If strict=false return nothing.
"""
function getready{T<:UserFile}(userfile::T; strict=true)::T 
 goodsize(userfile) && return userfile
      if strict
        create( userfile) || error("Can't create $userfile")
      else
        try 
            create( userfile) 
        catch 
            return nothing 
        end
      end
 goodsize( userfile)? userfile: error("File $userfile not ready after create()")
end
export getready



"Primitive size-based file-ready-test."
goodsize(f::GzipRows)::Bool = filesize(f|>name)>20
goodsize(f::PlainRows)::Bool = filesize(f|>name)>0
export goodsize


"""Takes list of file names with user file type definitions, 
    include them and return describing array or place result to destination.
"""
function types{S<:AbstractString}( files_for_include::Array{S}, destination::Array)::Void
 for f in files_for_include
  t = include(f) # f должен возвращать последним выражением тип <:UserFile
  if Type(t)!=DataType
    warn("""File $f skipped! It must return defined type as last expression.
    But now returned value = $t. """)
    if PROGRAM_FILE==""
        info("""Use
            edit(\"$t\") # if you now in REPL
            and then save it and recall include(list of files)""")
    end
    continue
  end
  push!(destination, t)
 end
end


function types{S<:AbstractString}(files_for_include::Array{S})::Array
    rv = []
    types(files_for_include, rv)
    rv
end
export types


include("add_functions.jl")
include("templates.jl")
end # module


