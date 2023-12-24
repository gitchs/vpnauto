project(vpnauto)

include_directories(./Common)



find_library(FRAMEWORK_COCOA Cocoa)
find_library(FRAMEWORK_COREWLAN CoreWLAN)
find_library(FRAMEWORK_SYSTEMCONFIGURATION SystemConfiguration)
find_library(FRAMEWORK_FOUNDATION Foundation)
find_library(FRAMEWORK_NETWORKEXTENSION NetworkExtension)
find_library(FRAMEWORK_CORELOCATION CoreLocation)

set(OC_LIBS ${FRAMEWORK_COCOA} ${FRAMEWORK_COREWLAN} ${FRAMEWORK_SYSTEMCONFIGURATION} ${FRAMEWORK_FOUNDATION} ${FRAMEWORK_NETWORKEXTENSION} ${FRAMEWORK_CORELOCATION})

add_library(libcommon
    ./Common/ACConnectionManager.m
    ./Common/ACLocationManager.m
    ./Common/ACNEService.m
    ./Common/ACNEServicesManager.m
    ./Common/ACPreferences.m
)
target_link_libraries(libcommon ${OC_LIBS})

add_executable(vpnauto
    src/main.m
)

target_link_libraries(vpnauto libcommon ${OC_LIBS})
