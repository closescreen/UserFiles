# Other helpers functions on UserFiles and it subtypes

"Returns somthing - filename::AbstractString or Cmd to use this instance user file type as source in pipeline() or open(f::Funct, source)."
source{T<:UserFile}(file::T) = error("Not implemented for $T")
source(file::GzipRows) = `zcat $(file|>name)`
source(file::PlainRows) = file|>name


