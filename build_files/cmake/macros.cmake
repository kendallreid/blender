MACRO(BLENDERLIB_NOLIST
	name
	sources
	includes)

	# Gather all headers
	FILE(GLOB_RECURSE INC_ALL *.h)
		 
	INCLUDE_DIRECTORIES(${includes})
	ADD_LIBRARY(${name} ${INC_ALL} ${sources})

	# Group by location on disk
	SOURCE_GROUP(Files FILES CMakeLists.txt)
	SET(ALL_FILES ${sources} ${INC_ALL})
	FOREACH(SRC ${ALL_FILES})
		STRING(REGEX REPLACE ${CMAKE_CURRENT_SOURCE_DIR} "Files" REL_DIR "${SRC}")
		STRING(REGEX REPLACE "[\\\\/][^\\\\/]*$" "" REL_DIR "${REL_DIR}")
		STRING(REGEX REPLACE "^[\\\\/]" "" REL_DIR "${REL_DIR}")
		IF(REL_DIR)
			SOURCE_GROUP(${REL_DIR} FILES ${SRC})
		ELSE(REL_DIR)
			SOURCE_GROUP(Files FILES ${SRC})
		ENDIF(REL_DIR)
	ENDFOREACH(SRC)

	MESSAGE(STATUS "Configuring library ${name}")
ENDMACRO(BLENDERLIB_NOLIST)

MACRO(BLENDERLIB
	name
	sources
	includes)

	BLENDERLIB_NOLIST(${name} "${sources}" "${includes}")

	# Add to blender's list of libraries
	FILE(APPEND ${CMAKE_BINARY_DIR}/cmake_blender_libs.txt "${name};")
ENDMACRO(BLENDERLIB)

MACRO(SETUP_LIBDIRS)
	# see "cmake --help-policy CMP0003"
	if(COMMAND cmake_policy)
		CMAKE_POLICY(SET CMP0003 NEW)
	endif(COMMAND cmake_policy)
	
	LINK_DIRECTORIES(${JPEG_LIBPATH} ${PNG_LIBPATH} ${ZLIB_LIBPATH} ${FREETYPE_LIBPATH} ${LIBSAMPLERATE_LIBPATH})
	
	IF(WITH_PYTHON)
		LINK_DIRECTORIES(${PYTHON_LIBPATH})
	ENDIF(WITH_PYTHON)
	IF(WITH_INTERNATIONAL)
		LINK_DIRECTORIES(${ICONV_LIBPATH})
		LINK_DIRECTORIES(${GETTEXT_LIBPATH})
	ENDIF(WITH_INTERNATIONAL)
	IF(WITH_SDL)
		LINK_DIRECTORIES(${SDL_LIBPATH})
	ENDIF(WITH_SDL)
	IF(WITH_FFMPEG)
		LINK_DIRECTORIES(${FFMPEG_LIBPATH})
	ENDIF(WITH_FFMPEG)
	IF(WITH_OPENEXR)
		LINK_DIRECTORIES(${OPENEXR_LIBPATH})
	ENDIF(WITH_OPENEXR)
	IF(WITH_TIFF)
		LINK_DIRECTORIES(${TIFF_LIBPATH})
	ENDIF(WITH_TIFF)
	IF(WITH_LCMS)
		LINK_DIRECTORIES(${LCMS_LIBPATH})
	ENDIF(WITH_LCMS)
	IF(WITH_QUICKTIME)
		LINK_DIRECTORIES(${QUICKTIME_LIBPATH})
	ENDIF(WITH_QUICKTIME)
	IF(WITH_OPENAL)
		LINK_DIRECTORIES(${OPENAL_LIBPATH})
	ENDIF(WITH_OPENAL)
	IF(WITH_JACK)
		LINK_DIRECTORIES(${JACK_LIBPATH})
	ENDIF(WITH_JACK)
	IF(WITH_SNDFILE)
		LINK_DIRECTORIES(${SNDFILE_LIBPATH})
	ENDIF(WITH_SNDFILE)
	IF(WITH_FFTW3)
		LINK_DIRECTORIES(${FFTW3_LIBPATH})
	ENDIF(WITH_FFTW3)
	IF(WITH_OPENCOLLADA)
		LINK_DIRECTORIES(${OPENCOLLADA_LIBPATH})
		LINK_DIRECTORIES(${PCRE_LIBPATH})
		LINK_DIRECTORIES(${EXPAT_LIBPATH})
	ENDIF(WITH_OPENCOLLADA)

	IF(WIN32)
		LINK_DIRECTORIES(${PTHREADS_LIBPATH})
	ENDIF(WIN32)
ENDMACRO(SETUP_LIBDIRS)

MACRO(SETUP_LIBLINKS
	target)
	SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${PLATFORM_LINKFLAGS} ")

	TARGET_LINK_LIBRARIES(${target} ${OPENGL_gl_LIBRARY} ${OPENGL_glu_LIBRARY} ${JPEG_LIBRARY} ${PNG_LIBRARIES} ${ZLIB_LIBRARIES} ${LLIBS})

	# since we are using the local libs for python when compiling msvc projects, we need to add _d when compiling debug versions
	IF(WITH_PYTHON)
		TARGET_LINK_LIBRARIES(${target} ${PYTHON_LINKFLAGS})

		IF(WIN32)
			TARGET_LINK_LIBRARIES(${target} debug ${PYTHON_LIB}_d)
			TARGET_LINK_LIBRARIES(${target} optimized ${PYTHON_LIB})
		ELSE(WIN32)
			TARGET_LINK_LIBRARIES(${target} ${PYTHON_LIB})
		ENDIF(WIN32)
	ENDIF(WITH_PYTHON)

	TARGET_LINK_LIBRARIES(${target} ${OPENGL_glu_LIBRARY} ${JPEG_LIB} ${PNG_LIB} ${ZLIB_LIB})
	TARGET_LINK_LIBRARIES(${target} ${FREETYPE_LIBRARY} ${LIBSAMPLERATE_LIB})

	IF(WITH_INTERNATIONAL)
		TARGET_LINK_LIBRARIES(${target} ${GETTEXT_LIB})

		IF(WIN32)
			TARGET_LINK_LIBRARIES(${target} ${ICONV_LIB})
		ENDIF(WIN32)
	ENDIF(WITH_INTERNATIONAL)

	IF(WITH_OPENAL)
		TARGET_LINK_LIBRARIES(${target} ${OPENAL_LIBRARY})
	ENDIF(WITH_OPENAL)
	IF(WITH_FFTW3)	
		TARGET_LINK_LIBRARIES(${target} ${FFTW3_LIB})
	ENDIF(WITH_FFTW3)
	IF(WITH_JACK)
		TARGET_LINK_LIBRARIES(${target} ${JACK_LIB})
	ENDIF(WITH_JACK)
	IF(WITH_SNDFILE)
		TARGET_LINK_LIBRARIES(${target} ${SNDFILE_LIB})
	ENDIF(WITH_SNDFILE)
	IF(WITH_SDL)
		TARGET_LINK_LIBRARIES(${target} ${SDL_LIBRARY})
	ENDIF(WITH_SDL)
	IF(WITH_QUICKTIME)
		TARGET_LINK_LIBRARIES(${target} ${QUICKTIME_LIB})
	ENDIF(WITH_QUICKTIME)
	IF(WITH_TIFF)
		TARGET_LINK_LIBRARIES(${target} ${TIFF_LIBRARY})
	ENDIF(WITH_TIFF)
	IF(WITH_OPENEXR)
		IF(WIN32)
			FOREACH(loop_var ${OPENEXR_LIB})
				TARGET_LINK_LIBRARIES(${target} debug ${loop_var}_d)
				TARGET_LINK_LIBRARIES(${target} optimized ${loop_var})
			ENDFOREACH(loop_var)
		ELSE(WIN32)
			TARGET_LINK_LIBRARIES(${target} ${OPENEXR_LIB})
		ENDIF(WIN32)
	ENDIF(WITH_OPENEXR)
	IF(WITH_LCMS)
		TARGET_LINK_LIBRARIES(${target} ${LCMS_LIBRARY})
	ENDIF(WITH_LCMS)
	IF(WITH_FFMPEG)
		TARGET_LINK_LIBRARIES(${target} ${FFMPEG_LIB})
	ENDIF(WITH_FFMPEG)
	IF(WITH_OPENCOLLADA)
		IF(WIN32)
			FOREACH(loop_var ${OPENCOLLADA_LIB})
				TARGET_LINK_LIBRARIES(${target} debug ${loop_var}_d)
				TARGET_LINK_LIBRARIES(${target} optimized ${loop_var})
			ENDFOREACH(loop_var)
			TARGET_LINK_LIBRARIES(${target} debug ${PCRE_LIB}_d)
			TARGET_LINK_LIBRARIES(${target} optimized ${PCRE_LIB})
			IF(EXPAT_LIB)
				TARGET_LINK_LIBRARIES(${target} debug ${EXPAT_LIB}_d)
				TARGET_LINK_LIBRARIES(${target} optimized ${EXPAT_LIB})
			ENDIF(EXPAT_LIB)
		ELSE(WIN32)
		TARGET_LINK_LIBRARIES(${target} ${OPENCOLLADA_LIB})
			TARGET_LINK_LIBRARIES(${target} ${PCRE_LIB})
			TARGET_LINK_LIBRARIES(${target} ${EXPAT_LIB})
		ENDIF(WIN32)
	ENDIF(WITH_OPENCOLLADA)
	IF(WIN32)
		TARGET_LINK_LIBRARIES(${target} ${PTHREADS_LIB})
	ENDIF(WIN32)
ENDMACRO(SETUP_LIBLINKS)

MACRO(TEST_SSE_SUPPORT)
	INCLUDE(CheckCXXSourceCompiles)

	MESSAGE(STATUS "Detecting SSE support")
	IF(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
		SET(CMAKE_REQUIRED_FLAGS "-msse -msse2")
	ELSEIF(MSVC)
		SET(CMAKE_REQUIRED_FLAGS "/arch:SSE2")
	ENDIF()

	CHECK_CXX_SOURCE_COMPILES("
		#include <xmmintrin.h>
		int main() { __m128 v = _mm_setzero_ps(); return 0; }"
	SUPPORT_SSE_BUILD)
ENDMACRO(TEST_SSE_SUPPORT)

MACRO(GET_BLENDER_VERSION)
	FILE(READ ${CMAKE_SOURCE_DIR}/source/blender/blenkernel/BKE_blender.h CONTENT)
	STRING(REGEX REPLACE "\n" ";" CONTENT "${CONTENT}")
	STRING(REGEX REPLACE "\t" ";" CONTENT "${CONTENT}")
	STRING(REGEX REPLACE " " ";" CONTENT "${CONTENT}")

	FOREACH(ITEM ${CONTENT})
		IF(LASTITEM MATCHES "BLENDER_VERSION")
			MATH(EXPR BLENDER_VERSION_MAJOR "${ITEM} / 100")
			MATH(EXPR BLENDER_VERSION_MINOR "${ITEM} % 100")
			SET(BLENDER_VERSION "${BLENDER_VERSION_MAJOR}.${BLENDER_VERSION_MINOR}")
		ENDIF(LASTITEM MATCHES "BLENDER_VERSION")
		
		IF(LASTITEM MATCHES "BLENDER_SUBVERSION")
			SET(BLENDER_SUBVERSION ${ITEM})
		ENDIF(LASTITEM MATCHES "BLENDER_SUBVERSION")
		
		IF(LASTITEM MATCHES "BLENDER_MINVERSION")
			MATH(EXPR BLENDER_MINVERSION_MAJOR "${ITEM} / 100")
			MATH(EXPR BLENDER_MINVERSION_MINOR "${ITEM} % 100")
			SET(BLENDER_MINVERSION "${BLENDER_MINVERSION_MAJOR}.${BLENDER_MINVERSION_MINOR}")
		ENDIF(LASTITEM MATCHES "BLENDER_MINVERSION")
		
		IF(LASTITEM MATCHES "BLENDER_MINSUBVERSION")
			SET(BLENDER_MINSUBVERSION ${ITEM})
		ENDIF(LASTITEM MATCHES "BLENDER_MINSUBVERSION")

		SET(LASTITEM ${ITEM})
	ENDFOREACH(ITEM ${CONTENT})
	
	MESSAGE(STATUS "Version major: ${BLENDER_VERSION_MAJOR}, Version minor: ${BLENDER_VERSION_MINOR}, Subversion: ${BLENDER_SUBVERSION}, Version: ${BLENDER_VERSION}")
	MESSAGE(STATUS "Minversion major: ${BLENDER_MINVERSION_MAJOR}, Minversion minor: ${BLENDER_MINVERSION_MINOR}, MinSubversion: ${BLENDER_MINSUBVERSION}, Minversion: ${BLENDER_MINVERSION}")
ENDMACRO(GET_BLENDER_VERSION)
