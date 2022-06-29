#!/bin/bash -e

# Xilinx 2017.3 include path
export PATH=/opt/Xilinx/SDK/2017.3/gnu/aarch64/lin/aarch64-linux/bin:$PATH
# export PATH=/opt/Xilinx/SDK/2017.3/gnu/aarch64/lin/aarch64-linux/bin:/opt/Xilinx/SDK/2017.3/gnu/aarch64/lin/aarch64-none/bin:$PATH

# get current folder path
SOURCE_HOME_PATH=$(readlink -f $(dirname "$0"))
echo ${SOURCE_HOME_PATH}

MAKERECIPECONF_NAME=makerecipeconf
MAINPGM_NAME=mainpgm
MASTERCTRL_NAME=master_ctrl
TESTITEM_NAME=testitem

#Binary name

MAINPGM_BIN_FILE_NAME=92KMainPgm_Test.tso

TESTITEM_ELF_FILE_NAME=testitem.elf

TESTITEM_MD2ELF_FILE_NAME=testitem_md2.elf
TESTITEM_UD2ELF_FILE_NAME=testitem_ud2.elf
TESTITEM_AICELF_FILE_NAME=testitem_aic.elf

TESTITEM_MD2RECIPE_FILE_NAME=recipepara_MD2.conf
TESTITEM_UD2RECIPE_FILE_NAME=recipepara_UD2.conf
TESTITEM_AICRECIPE_FILE_NAME=recipepara_AIC.conf

#Source Path
MASTERCTRL_SOURCE_PATH=$SOURCE_HOME_PATH/$MASTERCTRL_NAME/src
TESTITEM_SOURCE_PATH=$SOURCE_HOME_PATH/$TESTITEM_NAME/src

#Build Path
MAKERECIPECONF_BUILD_PATH=$SOURCE_HOME_PATH/$MAKERECIPECONF_NAME/Debug
MAINPGM_BUILD_PATH=$SOURCE_HOME_PATH/$MAINPGM_NAME
MASTERCTRL_BUILD_PATH=$SOURCE_HOME_PATH/$MASTERCTRL_NAME/Release
TESTITEM_BUILD_PATH=$SOURCE_HOME_PATH/$TESTITEM_NAME/Release

#Copy Image Path
MAINPGM_COPY_IMAGE_PATH=$SOURCE_HOME_PATH/image
if [ ! -d $MAINPGM_COPY_IMAGE_PATH ]; then
	mkdir $MAINPGM_COPY_IMAGE_PATH
fi

#Copy Recipe Path
RECIPE_ZONE1_PATH=/home/uni92k/zone1/UNI92K_maint/conf/utility
RECIPE_ZONE2_PATH=/home/uni92k/zone2/UNI92K_maint/conf/utility

###############################################################################################################
# Compile Option #
if [ -z "$1" ]
    then
    echo "No arguments for Compile Target are provided ==> UNI92K_SYS"
    USER_DEFS_SYSTEM=UNI92K_SYS
else
    echo "Compile target is set to "$1
    USER_DEFS_SYSTEM=$1
fi

if [ -z "$2" ]
    then
    echo "No arguments for FormFactor are provided ==> ALL"
    USER_DEFS_FF=ALL
else
    echo "Form factor is set to "$2
    USER_DEFS_FF=$2
fi


if [[ ${USER_DEFS_SYSTEM} = "UNI92K_SYS" ]] || [[ ${USER_DEFS_SYSTEM} = "UNI92K_BT" ]] || [[ ${USER_DEFS_SYSTEM} = "UNI92K_RACK" ]] 
    then
    echo
    echo "***************************************************************"
    echo "                        $USER_DEFS_SYSTEM"
    echo "***************************************************************"
    echo

	if [[ ${USER_DEFS_SYSTEM} = "UNI92K_SYS" ]]
		then
		TESTITEM_MD2ELF_FILE_NAME=testitem_system_md2.elf
		TESTITEM_UD2ELF_FILE_NAME=testitem_system_ud2.elf
		TESTITEM_AICELF_FILE_NAME=testitem_system_aic.elf
		MAINPGM_COPY_IMAGE_PATH=$SOURCE_HOME_PATH/image/system
	fi
	if [[ ${USER_DEFS_SYSTEM} = "UNI92K_BT" ]]
		then
		TESTITEM_MD2ELF_FILE_NAME=testitem_bencthtop_md2.elf
		TESTITEM_UD2ELF_FILE_NAME=testitem_bencthtop_ud2.elf
		TESTITEM_AICELF_FILE_NAME=testitem_bencthtop_aic.elf
		MAINPGM_COPY_IMAGE_PATH=$SOURCE_HOME_PATH/image/benchtop
	fi
	if [[ ${USER_DEFS_SYSTEM} = "UNI92K_RACK" ]]
		then
		TESTITEM_MD2ELF_FILE_NAME=testitem_rack_md2.elf
		TESTITEM_UD2ELF_FILE_NAME=testitem_rack_ud2.elf
		TESTITEM_AICELF_FILE_NAME=testitem_rack_aic.elf
		MAINPGM_COPY_IMAGE_PATH=$SOURCE_HOME_PATH/image/rack
	fi
	
	if [ ! -d $MAINPGM_COPY_IMAGE_PATH ]; then
		mkdir $MAINPGM_COPY_IMAGE_PATH
	fi
		
	echo
	echo "*********************** Binery clean **************************"
	echo
	
	# Mainpgm clean
	rm -rf $MAINPGM_COPY_IMAGE_PATH/$MAINPGM_BIN_FILE_NAME 
	
	if [[ ${USER_DEFS_FF} = "MD2" ||  ${USER_DEFS_FF} = "ALL" ]]
		then
	# MD2 clean
		rm -rf $MAINPGM_COPY_IMAGE_PATH/$TESTITEM_MD2ELF_FILE_NAME 
		rm -rf $MAINPGM_COPY_IMAGE_PATH/$TESTITEM_MD2RECIPE_FILE_NAME 
	fi
	
	if [[ ${USER_DEFS_FF} = "UD2" ||  ${USER_DEFS_FF} = "ALL" ]]
		then
		# UD2 clean
		rm -rf $MAINPGM_COPY_IMAGE_PATH/$TESTITEM_UD2ELF_FILE_NAME 
		rm -rf $MAINPGM_COPY_IMAGE_PATH/$TESTITEM_UD2RECIPE_FILE_NAME 
	fi
	
	if [[ ${USER_DEFS_FF} = "AIC" ||  ${USER_DEFS_FF} = "ALL" ]]
		then
		# AIC clean
		rm -rf $MAINPGM_COPY_IMAGE_PATH/$TESTITEM_AICELF_FILE_NAME 
		rm -rf $MAINPGM_COPY_IMAGE_PATH/$TESTITEM_AICRECIPE_FILE_NAME 
	fi
	
	echo
	echo "*********************** MAINPGM BUILD **************************"
	echo

	cd $MAINPGM_BUILD_PATH
	make clean
	make all USER_DEFS="-D"$USER_DEFS_SYSTEM

	if [[ ${USER_DEFS_FF} = "MD2" ||  ${USER_DEFS_FF} = "ALL" ]]
		then
		echo
		echo "********************** Test Item BUILD (MD2) ***********************"
		echo

		cd $TESTITEM_BUILD_PATH 
		make clean
		make all USER_DEFS="-DPCIE_MD2 -D"$USER_DEFS_SYSTEM
		cp -rf $TESTITEM_BUILD_PATH/$TESTITEM_ELF_FILE_NAME		$TESTITEM_BUILD_PATH/$TESTITEM_MD2ELF_FILE_NAME

		cd $TESTITEM_BUILD_PATH
		./makerecipeconf $TESTITEM_SOURCE_PATH $TESTITEM_MD2RECIPE_FILE_NAME FALSE PCIE_MD2
	fi	

	if [[ ${USER_DEFS_FF} = "UD2" ||  ${USER_DEFS_FF} = "ALL" ]]
		then
		echo
		echo "********************** Test Item BUILD (UD2) ***********************"
		echo

		cd $TESTITEM_BUILD_PATH 
		make clean
		make all USER_DEFS="-DPCIE_UD2 -D"$USER_DEFS_SYSTEM
		cp -rf $TESTITEM_BUILD_PATH/$TESTITEM_ELF_FILE_NAME		$TESTITEM_BUILD_PATH/$TESTITEM_UD2ELF_FILE_NAME

		cd $TESTITEM_BUILD_PATH
		./makerecipeconf $TESTITEM_SOURCE_PATH $TESTITEM_UD2RECIPE_FILE_NAME FALSE PCIE_UD2
	fi

	if [[ ${USER_DEFS_FF} = "AIC" ||  ${USER_DEFS_FF} = "ALL" ]]
		then
		echo
		echo "********************** Test Item BUILD (AIC) ***********************"
		echo

		cd $TESTITEM_BUILD_PATH 
		make clean
		make all USER_DEFS="-DPCIE_AIC -D"$USER_DEFS_SYSTEM
		cp -rf $TESTITEM_BUILD_PATH/$TESTITEM_ELF_FILE_NAME     $TESTITEM_BUILD_PATH/$TESTITEM_AICELF_FILE_NAME

		cd $TESTITEM_BUILD_PATH
		./makerecipeconf $TESTITEM_SOURCE_PATH $TESTITEM_AICRECIPE_FILE_NAME FALSE PCIE_AIC
	fi

	#echo
	#echo "******************** Doxygen BUILD ***********************"
	#echo
	
	#cd $TESTITEM_SOURCE_PATH
	#echo ${TESTITEM_SOURCE_PATH}
	#doxygen

	echo
	echo "*********************** Binery COPY **************************"
	echo
	
	# Mainpgm
	cp -rf $MAINPGM_BUILD_PATH/$MAINPGM_BIN_FILE_NAME 			$MAINPGM_COPY_IMAGE_PATH
	
	# MD2
	if [[ ${USER_DEFS_FF} = "MD2" ||  ${USER_DEFS_FF} = "ALL" ]]
		then
		cp -rf $TESTITEM_BUILD_PATH/$TESTITEM_MD2ELF_FILE_NAME 		$MAINPGM_COPY_IMAGE_PATH
		cp -rf $TESTITEM_BUILD_PATH/$TESTITEM_MD2RECIPE_FILE_NAME	$MAINPGM_COPY_IMAGE_PATH
		if [ -d "/home/uni92k/zone1" ]; then
			cp -rf $TESTITEM_BUILD_PATH/$TESTITEM_MD2RECIPE_FILE_NAME	$RECIPE_ZONE1_PATH
		else 
			cp -rf $TESTITEM_BUILD_PATH/$TESTITEM_MD2RECIPE_FILE_NAME	$RECIPE_ZONE2_PATH
		fi
		cp -rf $TESTITEM_BUILD_PATH/$TESTITEM_MD2RECIPE_FILE_NAME	/home/uni92k/Client/Common_Shared/
		
		echo "****************** list_md2.txt ******************************"
		rm -f $MAINPGM_COPY_IMAGE_PATH/list_md2.txt		
		/opt/Xilinx/SDK/2017.3/gnu/aarch64/lin/aarch64-linux/bin/aarch64-linux-gnu-objdump -S $MAINPGM_COPY_IMAGE_PATH/$TESTITEM_MD2ELF_FILE_NAME >> $MAINPGM_COPY_IMAGE_PATH/list_md2.txt
	fi

		# UD2
	if [[ ${USER_DEFS_FF} = "UD2" ||  ${USER_DEFS_FF} = "ALL" ]]
		then
		cp -rf $TESTITEM_BUILD_PATH/$TESTITEM_UD2ELF_FILE_NAME 		$MAINPGM_COPY_IMAGE_PATH
		cp -rf $TESTITEM_BUILD_PATH/$TESTITEM_UD2RECIPE_FILE_NAME	$MAINPGM_COPY_IMAGE_PATH
		if [ -d "/home/uni92k/zone1" ]; then
			cp -rf $TESTITEM_BUILD_PATH/$TESTITEM_UD2RECIPE_FILE_NAME	$RECIPE_ZONE1_PATH
		else 
			cp -rf $TESTITEM_BUILD_PATH/$TESTITEM_UD2RECIPE_FILE_NAME	$RECIPE_ZONE2_PATH
		fi
		cp -rf $TESTITEM_BUILD_PATH/$TESTITEM_UD2RECIPE_FILE_NAME	/home/uni92k/Client/Common_Shared/
	fi

	# AIC
	if [[ ${USER_DEFS_FF} = "AIC" ||  ${USER_DEFS_FF} = "ALL" ]]
		then
		cp -rf $TESTITEM_BUILD_PATH/$TESTITEM_AICELF_FILE_NAME 		$MAINPGM_COPY_IMAGE_PATH
		cp -rf $TESTITEM_BUILD_PATH/$TESTITEM_AICRECIPE_FILE_NAME	$MAINPGM_COPY_IMAGE_PATH
		if [ -d "/home/uni92k/zone1" ]; then
			cp -rf $TESTITEM_BUILD_PATH/$TESTITEM_AICRECIPE_FILE_NAME	$RECIPE_ZONE1_PATH
		else 
			cp -rf $TESTITEM_BUILD_PATH/$TESTITEM_AICRECIPE_FILE_NAME	$RECIPE_ZONE2_PATH
		fi
		cp -rf $TESTITEM_BUILD_PATH/$TESTITEM_AICRECIPE_FILE_NAME	/home/uni92k/Client/Common_Shared/
	fi

	# TEMP

	
elif [[ ${USER_DEFS_SYSTEM} = "clean" ]]
	then
	echo
	echo "*********************** MAINPGM CLEAN **************************"
	echo

	cd $MAINPGM_BUILD_PATH
	make clean

	echo
	echo "******************** Test Item CLEAN (MD2) ***********************"
	echo

	cd $TESTITEM_BUILD_PATH 
	make clean
	rm -r *.conf
	rm -r *.txt
	rm -r *.elf
	rm -r *.size

else
	echo "Wrong arguments : [ $USER_DEFS ]"
	exit 1
fi
###############################################################################################################


