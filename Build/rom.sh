#!/bin/bash
#
# ROM compilation script
#
# Copyright (C) 2016 Nathan Chancellor
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.


###########
#         #
#  USAGE  #
#         #
###########

# $ rom.sh <me|rom> <device> (person)


############
#          #
#  COLORS  #
#          #
############

RED="\033[01;31m"
BLINK_RED="\033[05;31m"
RESTORE="\033[0m"


###############
#             #
#  FUNCTIONS  #
#             #
###############

# PRINTS A FORMATTED HEADER TO POINT OUT WHAT IS BEING DONE TO THE USER
function echoText() {
   echo -e ${RED}
   echo -e "====$( for i in $( seq ${#1} ); do echo -e "=\c"; done )===="
   echo -e "==  ${1}  =="
   echo -e "====$( for i in $( seq ${#1} ); do echo -e "=\c"; done )===="
   echo -e ${RESTORE}
}


# CREATES A NEW LINE IN TERMINAL
function newLine() {
   echo -e ""
}


################
#              #
#  PARAMETERS  #
#              #
################

# UNASSIGN FLAGS AND RESET ROM_BUILD_TYPE
unset ROM_BUILD_TYPE
PERSONAL=false
SUCCESS=false
SYNC=true

while [[ $# -ge 1 ]]; do
   case "${1}" in
      "me")
         ROM=flash7.1
         DEVICE=angler ;;
      "shamu"|"angler"|"bullhead"|"hammerhead")
         DEVICE=${1} ;;
      "flash7.0"|"flash7.1"|"pn"|"pn-dui"|"du"|"abc"|"maple"|"aosip"|"saosp")
         ROM=${1} ;;
      "nosync")
         SYNC=false ;;
      *)
         echo "Invalid parameter detected!" && exit ;;
   esac

   shift
done

# PARAMETER VERIFICATION
if [[ -z ${DEVICE} || -z ${ROM} ]]; then
   echo "You did not specify a necessary parameter (either ROM, device, or both). Please re-run the script with the necessary parameters!" && exit
fi

###############
#             #
#  VARIABLES  #
#             #
###############

# ANDROID_DIR: Directory that holds all of the Android files (currently my home directory)
# OUT_DIR: Directory that holds the compiled ROM files
# SOURCE_DIR: Directory that holds the ROM source
# ZIP_MOVE: Directory to hold completed ROM zips
# ZIP_FORMAT: The format of the zip file in the out directory for moving to ZIP_MOVE
ANDROID_DIR=${HOME}
ZIP_MOVE_PARENT=${HOME}/Web/.superhidden/ROMs

# Otherwise, define them for our various ROMs
case "${ROM}" in
   "abc")
      SOURCE_DIR=${ANDROID_DIR}/ROMs/ABC
      ZIP_MOVE=${ZIP_MOVE_PARENT}/ABC/${DEVICE}
      ZIP_FORMAT=ABCrom_nexus_${DEVICE}-*.zip ;;
   "aosip")
      SOURCE_DIR=${ANDROID_DIR}/ROMs/AOSiP
      ZIP_MOVE=${ZIP_MOVE_PARENT}/AOSiP/${DEVICE}
      ZIP_FORMAT=AOSiP-*-${DEVICE}-*.zip ;;
   "du")
      SOURCE_DIR=${ANDROID_DIR}/ROMs/DU
      ZIP_MOVE=${ZIP_MOVE_PARENT}/DirtyUnicorns/${DEVICE}
      ZIP_FORMAT=DU_${DEVICE}_*.zip ;;
   "flash7.0")
      SOURCE_DIR=${ANDROID_DIR}/ROMs/Flash7.0
      ZIP_MOVE=${ZIP_MOVE_PARENT}/Flash7.0
      ZIP_FORMAT=flash_rom_${DEVICE}-7.0*.zip ;;
   "flash7.1")
      SOURCE_DIR=${ANDROID_DIR}/ROMs/Flash7.1
      ZIP_MOVE=${ZIP_MOVE_PARENT}/Flash7.1
      ZIP_FORMAT=flash_rom_${DEVICE}-7.1*.zip ;;
   "maple")
      SOURCE_DIR=${ANDROID_DIR}/ROMs/MapleAOSP
      ZIP_MOVE=${ZIP_MOVE_PARENT}/MapleAOSP/${DEVICE}
      ZIP_FORMAT=MapleAOSP*.zip ;;
   "pn")
      SOURCE_DIR=${ANDROID_DIR}/ROMs/PN
      ZIP_MOVE=${ZIP_MOVE_PARENT}/PureNexus/${DEVICE}
      ZIP_FORMAT=pure_nexus_${DEVICE}-7*.zip ;;
   "pn-dui")
      SOURCE_DIR=${ANDROID_DIR}/ROMs/PN-DUI
      ZIP_MOVE=${ZIP_MOVE_PARENT}/PN-DUI
      ZIP_FORMAT=pure_nexus_${DEVICE}-7*.zip ;;
   "saosp")
      SOURCE_DIR=${ANDROID_DIR}/ROMs/SAOSP
      ZIP_MOVE=${ZIP_MOVE_PARENT}/SAOSP/${DEVICE}
      ZIP_FORMAT=saosp_${DEVICE}*.zip ;;
esac

OUT_DIR=${SOURCE_DIR}/out/target/product/${DEVICE}
THREADS_FLAG=-j$( grep -c ^processor /proc/cpuinfo )



################
# SCRIPT START #
################

clear


#######################
# START TRACKING TIME #
#######################

START=$( TZ=MST date +%s )


###########################
# MOVE INTO SOURCE FOLDER #
###########################

cd ${SOURCE_DIR}


#############
# REPO SYNC #
#############

if [[ ${SYNC} = true ]]; then
   echoText "SYNCING LATEST SOURCES"; newLine

   repo sync --force-sync ${THREADS_FLAG}
fi


###########################
# SETUP BUILD ENVIRONMENT #
###########################

echoText "SETTING UP BUILD ENVIRONMENT"; newLine

# CHECK AND SEE IF WE ARE ON ARCH; IF SO, ACTIVARE A VIRTUAL ENVIRONMENT FOR PROPER PYTHON SUPPORT
if [[ -f /etc/arch-release ]]; then
   virtualenv2 venv
   source venv/bin/activate
fi

source build/envsetup.sh


##################
# PREPARE DEVICE #
##################

echoText "PREPARING $( echo ${DEVICE} | awk '{print toupper($0)}' )"; newLine

# NOT ALL ROMS USE BREAKFAST
case "${ROM}" in
   "maple")
      lunch maple_${DEVICE}-userdebug ;;
   "saosp")
      lunch saosp_${DEVICE}-user ;;
   "aosip")
      lunch aosip_${DEVICE}-userdebug ;;
   *)
      breakfast ${DEVICE} ;;
esac


############
# CLEAN UP #
############

echoText "CLEANING UP OUT DIRECTORY"; newLine

make clobber


##################
# START BUILDING #
##################

if [[ ${ROM} == "flash" ]]; then
   echo -e ${RED}
   echo -e "======================================================================"; newLine
   echo -e "  ___________________________________  __   _____________________  ___"
   echo -e "  ___  ____/__  /___    |_  ___/__  / / /   ___  __ \_  __ \__   |/  /"
   echo -e "  __  /_   __  / __  /| |____ \__  /_/ /    __  /_/ /  / / /_  /|_/ / "
   echo -e "  _  __/   _  /___  ___ |___/ /_  __  /     _  _, _// /_/ /_  /  / /  "
   echo -e "  /_/      /_____/_/  |_/____/ /_/ /_/      /_/ |_| \____/ /_/  /_/   "; newLine
   echo -e "======================================================================"; newLine
   echo -e ${RESTORE}
   sleep 5
else
   echoText "MAKING ZIP FILE"; newLine
fi

NOW=$( TZ=MST date +"%Y-%m-%d-%S" )

# NOT ALL ROMS USE MKA OR BACON
case "${ROM}" in
   "saosp")
      time make otapackage ${THREADS_FLAG} ;;
   "aosip")
      time make kronic ${THREADS_FLAG} ;;
   *)
      time mka bacon ;;
esac


###################
# IF ROM COMPILED #
###################

# THERE WILL BE A ZIP IN THE OUT FOLDER IN THE ZIP FORMAT
if [[ $( ls ${OUT_DIR}/${ZIP_FORMAT} 2>/dev/null | wc -l ) != "0" ]]; then
   # MAKE BUILD RESULT STRING REFLECT SUCCESSFUL COMPILATION
   BUILD_RESULT_STRING="BUILD SUCCESSFUL"
   SUCCESS=true


   ##################
   # ZIP_MOVE LOGIC #
   ##################

   # MAKE ZIP_MOVE IF IT DOESN'T EXIST OR CLEAN IT IF IT DOES
   if [[ ! -d "${ZIP_MOVE}" ]]; then
      newLine; echoText "MAKING ZIP_MOVE DIRECTORY"

      mkdir -p "${ZIP_MOVE}"
   else
      newLine; echoText "CLEANING ZIP_MOVE DIRECTORY"; newLine

      rm -vrf "${ZIP_MOVE}"/*${ZIP_FORMAT}*
   fi


   ####################
   # MOVING ROM FILES #
   ####################

   newLine; echoText "MOVING FILES TO ZIP_MOVE DIRECTORY"; newLine

   mv -v ${OUT_DIR}/*${ZIP_FORMAT}* "${ZIP_MOVE}"


###################
# IF BUILD FAILED #
###################

else
   BUILD_RESULT_STRING="BUILD FAILED"
   SUCCESS=false
fi



# DEACTIVATE VIRTUALENV IF WE ARE ON ARCH
if [[ -f /etc/arch-release ]]; then
   echoText "EXITING VIRTUAL ENV"
   deactivate
fi



##############
# SCRIPT END #
##############

END=$( TZ=MST date +%s )
newLine; echoText "${BUILD_RESULT_STRING}!"


######################
# ENDING INFORMATION #
######################

# IF THE BUILD WAS SUCCESSFUL, PRINT FILE LOCATION, AND SIZE
if [[ ${SUCCESS} = true ]]; then
   echo -e ${RED}"FILE LOCATION: $( ls ${ZIP_MOVE}/${ZIP_FORMAT} )"
   echo -e "SIZE: $( du -h ${ZIP_MOVE}/${ZIP_FORMAT} | awk '{print $1}'  )"${RESTORE}
fi

# PRINT THE TIME THE SCRIPT FINISHED
# AND HOW LONG IT TOOK REGARDLESS OF SUCCESS
echo -e ${RED}"TIME FINISHED: $( TZ=MST date +%D\ %r | awk '{print toupper($0)}' )"
echo -e ${RED}"DURATION: $( echo $((${END}-${START})) | awk '{print int($1/60)" MINUTES AND "int($1%60)" SECONDS"}' )"${RESTORE}; newLine



##################
# LOG GENERATION #
##################

# DATE: BASH_SOURCE (PARAMETERS)
case ${PERSONAL} in
   "true")
      echo -e "\n$( TZ=MST date +%H:%M:%S ): ${BASH_SOURCE} me" >> ${LOG} ;;
   *)
      echo -e "\n$( TZ=MST date +%H:%M:%S ): ${BASH_SOURCE} ${ROM} ${DEVICE}" >> ${LOG} ;;
esac

# BUILD <SUCCESSFUL|FAILED> IN # MINUTES AND # SECONDS
echo -e "${BUILD_RESULT_STRING} IN $( echo $((${END}-${START})) | awk '{print int($1/60)" MINUTES AND "int($1%60)" SECONDS"}' )" >> ${LOG}

# ONLY ADD A LINE ABOUT FILE LOCATION IF SCRIPT COMPLETED SUCCESSFULLY
if [[ ${SUCCESS} = true ]]; then
   # FILE LOCATION: <PATH>
   echo -e "FILE LOCATION: $( ls ${ZIP_MOVE}/${ZIP_FORMAT} )" >> ${LOG}
fi


########################
# ALERT FOR SCRIPT END #
########################

echo -e "\a" && cd ${HOME}
