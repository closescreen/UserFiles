module UserFiles

"Common abstract type for files"
abstract UserFile
typealias UF UserFile


"Abstract for row-based (line-by-line) readable files"
abstract RowFile <: UF
typealias RF RowFile


"Abstract type for gzip-compressed row-based files."
abstract GzipRows<:RF


"Abstract type for non-compressed row-based text files."
abstract PlainRows<:RF

export UserFile, RowFile, GzipRows, PlainRows

"Return explained string for error if function on type not implemented"
function _help_redefine_on_type( funcname::AbstractString, T::Type, funcdesc::AbstractString)::AbstractString
    """Function $funcname(T::Type{$T}) not implemented by you. Define it as sample below:
    \"$funcdesc\"
    $funcname(T::Type{$T}) = ...
    or
    function $funcname(T::Type{$T}) 
        #...    
    end    
    """
end

"""Returns regexp for concrete user file type instance or file type.
    Must be redefined on concrete user file type.
"""
re{U<:UserFile}(T::Type{U}) = _help_redefine_on_type( "re", T, "returns Regex for any matched filenames")|>error
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
create(userfile::UserFile)::Bool = error("create() not implemented yet for $userfile")
export create



"""Returns field separator.
    Must be redefined on concrete user file type.
"""
fs{T<:UserFile}(::Type{T}) = error("fs() not implemented yet for $T") 
fs(f::UserFile) = fs(typeof(f)) 
export fs



"""Returns field list as symbols tuple.
    Must be redefined on concrete user file type.
"""
fields{T<:UserFile}(::Type{T}) = error("fields() not implemented yet for $T")
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
goodsize(f::GzipRows)::Bool = filesize(f.name)>20
goodsize(f::PlainRows)::Bool = filesize(f.name)>0
export goodsize



"Returns RegexMatch (or nothing) as result of match( re(concrete_user_file_type), filename )"
parts{T<:UserFile}( file::T) = match(re(T), file.name) 
export parts



"""Takes list of file names with user file type definitions, 
    include them and return describing array or place result to destination.
"""
function routes( files_for_include::Array, destination::Array)::Void
 for f in files_for_include
  t::Type = include(f) # f должен возвращать последним выражением тип <:UserFile
  push!(destination, t)
 end
 nothing 
end

function routes(files_for_include)::Array
    rv = []
    routes(files_for_include, rv)
    rv
end    
export routes


include("add_functions.jl")
include("templates.jl")
end # module


