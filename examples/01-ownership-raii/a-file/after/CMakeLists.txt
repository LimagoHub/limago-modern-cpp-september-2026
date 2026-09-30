cmake_minimum_required(VERSION 3.21)

# Projektname aus dem Pfad: <baustein>-<before|after|start|solution>.
# Die Datei ist in allen Teilprojekten identisch (siehe sync-templates.ps1).
cmake_path(GET CMAKE_CURRENT_SOURCE_DIR FILENAME _variant)
cmake_path(GET CMAKE_CURRENT_SOURCE_DIR PARENT_PATH _parent)
cmake_path(GET _parent FILENAME _baustein)
project(${_baustein}-${_variant} LANGUAGES CXX)

# before/ ist absichtlich schlecht und baut ohne Warnstufe.
if(_variant STREQUAL "before")
  set(_warnings_default OFF)
else()
  set(_warnings_default ON)
endif()
option(SEMINAR_WARNINGS "Hohe Warnstufe fuer dieses Target" ${_warnings_default})

file(GLOB _sources CONFIGURE_DEPENDS *.cpp)
add_executable(${PROJECT_NAME} ${_sources})
target_compile_features(${PROJECT_NAME} PRIVATE cxx_std_17)

if(SEMINAR_WARNINGS)
  set(_gcc "$<CXX_COMPILER_ID:GNU>")
  target_compile_options(${PROJECT_NAME} PRIVATE
    "$<$<CXX_COMPILER_ID:MSVC>:/W4;/permissive->"
    "$<${_gcc}:-Wall;-Wextra;-Wpedantic>"
    "$<$<AND:${_gcc},$<VERSION_GREATER_EQUAL:$<CXX_COMPILER_VERSION>,12>>:-Wuse-after-free>"
    "$<$<AND:${_gcc},$<VERSION_GREATER_EQUAL:$<CXX_COMPILER_VERSION>,13>>:-Wdangling-reference>")
endif()
