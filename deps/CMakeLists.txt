include(FetchContent)

# Setup directory to which dependencies will be downloaded
# If we do not specify this our dependencies will be downloaded to the build folder
# and every time after cleaning the build directory and reconfigure cmake project dependencies will be re-downloaded
# but we should not forget to add "deps_content" to .gitignore to reduce our project size and lets everyone download dependencies by his own
# at configure stage
get_filename_component(deps_content "../deps_content"
                       REALPATH BASE_DIR "${CMAKE_BINARY_DIR}")
set(FETCHCONTENT_BASE_DIR ${deps_content})

# If dependencies are not available then download it and make available
FetchContent_Declare(
	curl
	GIT_REPOSITORY https://github.com/curl/curl.git
	GIT_TAG        c7aef0a945f9b6fb6d3f91716a21dfe2f4ea635f
)

FetchContent_Declare(
	tinyxml2
    GIT_REPOSITORY https://github.com/leethomason/tinyxml2.git
    GIT_TAG        a9773976845b19e89020c1215781e71116477ef1
)

# If necessary it's possible to use tinyxml2 from different location(it can be downloaded from GitHub too) instead of downloaded from GitHub
# in this case we could for example change some sources in tinyxml2 and try it out
# string(TOUPPER tinyxml2 UP_tinyxml2)
# set(FETCHCONTENT_SOURCE_DIR_${UP_tinyxml2} ${CMAKE_CURRENT_LIST_DIR}/../../tinyxml2)

FetchContent_MakeAvailable(tinyxml2)

# If use IDE add curl and tinyxml2 target into deps source group
set_target_properties(tinyxml2 PROPERTIES FOLDER deps)