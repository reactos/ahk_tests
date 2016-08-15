file(GLOB EXTRA_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}/AHK-Tests/ ${CMAKE_CURRENT_SOURCE_DIR}/AHK-Tests/*_test.exe)
foreach(item ${EXTRA_FILES})
    add_cd_file(FILE ${CMAKE_CURRENT_SOURCE_DIR}/AHK-Tests/${item} DESTINATION AHK-Tests NO_CAB NAME_ON_CD ${item} FOR bootcd regtest)
endforeach(item)
#removed and fetched from SVN as a temporary mesure
#add_cd_file(FILE ${CMAKE_CURRENT_SOURCE_DIR}/AHK-Tests/rosautotest.exe DESTINATION reactos/system32 FOR bootcd regtest)

file(GLOB EXTRA_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}/Apps/ ${CMAKE_CURRENT_SOURCE_DIR}/Apps/*)
foreach(item ${EXTRA_FILES})
    add_cd_file(FILE ${CMAKE_CURRENT_SOURCE_DIR}/Apps/${item} DESTINATION AHK-Tests/Apps NO_CAB NAME_ON_CD ${item} FOR bootcd regtest)
endforeach(item)

file(GLOB EXTRA_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}/Media/ ${CMAKE_CURRENT_SOURCE_DIR}/Media/*)
foreach(item ${EXTRA_FILES})
    add_cd_file(FILE ${CMAKE_CURRENT_SOURCE_DIR}/Media/${item} DESTINATION AHK-Tests/Media NO_CAB NAME_ON_CD ${item} FOR bootcd regtest)
endforeach(item)

