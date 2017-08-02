#!/usr/bin/env bash

curdir="$(pwd)"


MONTHS=(ZERO January February March April May June July August September October November December)
export PATH=/afs/cern.ch/cms/common:${PATH}

#help
if [[ "$#" == "0" ]]; then
    echo "This command produces the prompt feedback plots. It takes 3 arguments + 1 optional argument.";
    echo "Usage: 'producePromptFeedbackPlots.sh StreamExpress|StreamExpressCosmics runNumber reference option'";
    echo "The optional argument can be used to force the reproduction of the tracker maps (by default if the directory is found, the tracker maps are not reproduced)";
    echo "Example: sh producePromptFeedbackPlots.sh StreamExpressCosmics 281078 278297 force" 
    exit 1;
fi

#check CMSSW
if [ "$CMSSW_BASE" == "" ]; then
    echo "Please set up a cmsenv (the same as the one used for Tracker maps generation - see instructions)"
    exit 0
fi


dataset=$1
if [[ $dataset != "StreamExpressCosmics" && $dataset != "StreamExpress" ]]; then
    echo "Please select a correct dataset (StreamExpressCosmics or StreamExpress)"
    exit 0
fi
Run_numb=$2
Ref_numb=$3
if [[ ! -z "$4" ]]; then echo "Tracker maps will be reproduced, no matter if they already exist or not"; fi


now="$(date +'%d/%m/%Y')"
hour=$(date "+%H")
if [ $hour -lt 12 ]; then
    ampm="AM"
    ampm_name="MORNING"
else
    ampm="PM"
    ampm_name="AFTERNOON"
fi
echo "Are you creating the prompt feedback report for the $ampm_name ($ampm) of $now (i.e. now) ? [y/N]" 
read answer
if [[ $answer == "y" ]]; then
    year="$(date +'%Y')"
    month="$(date +'%m')"
    day="$(date +'%d')"
else
    echo "PLEASE ENTER THE YEAR [$(date +'%Y')]"         #using custom date
    read year
    if [[ $year == "" ]]; then year="$(date +'%Y')"; echo "Year taken by default: $year"; fi    #if nothing is specified, assume the automatic date was ok
    echo "ENTER THE CURRENT MONTH (the number, not the name. And it has to be made of 2 numbers! Ex: 01, 02, 03... 09, 10, 11, 12) [$(date +'%m')]"
    read month
    if [[ $month == "" ]]; then month="$(date +'%m')"; echo "Month taken by default: $month"; fi
    echo "ENTER THE CURRENT DAY (the number, not the name. And it has to be made of 2 numbers! Ex: 01, 02, 03... 31) [$(date +'%d')]"
    read day
    if [[ $day == "" ]]; then day="$(date +'%d')"; echo "Day taken by default: $day"; fi
    echo "Is it the morning (AM) or the afternoon (PM) ? [$ampm]"
    read ampm
    if [[ $ampm == "" ]]; then
        if [ $hour -lt 12 ]; then
            ampm="AM"
        else
            ampm="PM"
        fi
    elif [[ $ampm != "AM" && $ampm != "PM" ]]; then
        echo "Please select a correct option (AM or PM, caps are important)"
        exit 0
    fi
    if [[ $ampm == "AM" ]]; then ampm_name="MORNING"; fi
    if [[ $ampm == "PM" ]]; then ampm_name="AFTERNOON"; fi
    echo "CREATE THE REPORT FOR THE $ampm_name of $day/$month/$year ? [N/y]"
    read answer
    if [[ $answer != "y" ]]; then
        echo "Exiting..."
        exit 0
    fi
fi
fulldate=$year-$month-$day
dayOfWeek=$(date --date $fulldate +%A)
monthIndex=$((10#$month)) #The number entered (01, 04...) starts with a 0. This is (unfortunatly) the bash convention to write octal numbers. This line is therefore here to convert those numbers in decimal numbers.



shortRun=`echo $Run_numb | awk '{print substr($0,0,3)}'`
nnn=`echo $Run_numb | awk '{print substr($0,0,4)}'` 

shortRef=`echo $Ref_numb | awk '{print substr($0,0,3)}'`
ref_nnn=`echo $Ref_numb | awk '{print substr($0,0,4)}'` 




if [[ $dataset =~ "Cosmics" ]]; then
    mode="Cosmics"
    mode_ref="Cosmics"
else
#    if [ $Run_numb -lt 280385 ]; then
#        mode="BeamReReco23Sep"
#    else
#        mode="Beam"
#    fi
#    if [ $Ref_numb -lt 280385 ]; then
#        mode_ref="BeamReReco23Sep"
#    else
#        mode_ref="Beam"
#    fi
    mode="Beam"
    mode_ref="Beam"
fi

#0. Create the directory that we fill fill with our plots
foldername="${Run_numb}_comparedTo_${Ref_numb}"
if [ -d "$foldername" ]; then rm -rf $foldername; fi
mkdir $foldername
referenceRunsDir="/data/users/ReferenceRuns"

#
##
### 1. Produce the DQM GUI related files
##
#

#
## 1.a) Download the DQM file for the run and the ref
#


DataLocalDir=''
DataOflineDir=''

#1.a -- download the ref
if [ $Ref_numb -gt 294645 ]; then

        DataLocalDir_ref='Data2017'
        DataOfflineDir_ref='Run2017'
else

if [ $Ref_numb -gt 287000 ]; then

    DataLocalDir_ref='Data2017'
    DataOfflineDir_ref='Commissioning2017'
else


if [ $Ref_numb -gt 284500 ]; then

    DataLocalDir_ref='Data2016'
    DataOfflineDir_ref='PARun2016'
else

##2016 data taking period run > 271024
if [ $Ref_numb -gt 271024 ]; then

    DataLocalDir_ref='Data2016'
    DataOfflineDir_ref='Run2016'
else

#2016 - Commissioning period                                                                                                                               
if [ $Ref_numb -gt 264200 ]; then

    DataLocalDir_ref='Data2016'
    DataOfflineDir_ref='Commissioning2016'
else

#Run2015A
if [ $Ref_numb -gt 246907 ]; then
    DataLocalDir_ref='Data2015'
    DataOfflineDir_ref='Run2015'
else

#2015 Commissioning period (since January)
if [ $Ref_numb -gt 232881 ]; then
    DataLocalDir_ref='Data2015'
    DataOfflineDir_ref='Commissioning2015'
else
#2013 pp run (2.76 GeV)
    if [ $Ref_numb -gt 211658 ]; then
        DataLocalDir_ref='Data2013'
        DataOfflineDir_ref='Run2013'
    else
#2013 HI run
        if [ $Ref_numb -gt 209634 ]; then
    	DataLocalDir_ref='Data2013'
    	DataOfflineDir_ref='HIRun2013'
        else
    	if [ $Ref_numb -gt 190450 ]; then
    	    DataLocalDir_ref='Data2012'
    	    DataOfflineDir_ref='Run2012'
    	fi
        fi
    fi
fi
fi
fi
fi
fi
fi
fi


#Check if known reference
refCheck=`ls ${referenceRunsDir}/ | grep ${Ref_numb}`
if [ -z "$refCheck" ]; then
    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    echo -e "\n WARNING: You asked for a reference run (runnumber - dataset) that was never used before. Please check with your Shift Leader if your reference run is correct. \n Is it correct ? [N/y]" 
    read answer
    if [[ $answer == "y" ]]; then
        echo "A new reference will be downloaded to ${referenceRunsDir}"
        echo "Please realize that this reference has to be added to the twiki: https://twiki.cern.ch/twiki/bin/view/CMS/TrackerOfflineReferenceRuns. Check this with the Shift Leader"
        echo "I have read this, and added the reference in the right twiki: [N/y]"
        read answer_twiki
        if [[ $answer_twiki == "y" ]]; then
            echo "Downloading new reference..."
        else
            echo "Abording script due to weird behaviour with references..."
            exit 0
        fi
        #Downloading the ref
        
        
        echo 'Directory to fetch the DQM file from: https://cmsweb.cern.ch/dqm/offline/data/browse/ROOT/OfflineData/'${DataOfflineDir_ref}'/'$dataset'/000'${ref_nnn}'xx/'
        
        
        curl -k --cert /data/users/cctrkdata/current/auth/proxy/proxy.cert --key /data/users/cctrkdata/current/auth/proxy/proxy.cert -X GET 'https://cmsweb.cern.ch/dqm/offline/data/browse/ROOT/OfflineData/'${DataOfflineDir_ref}'/'$dataset'/000'${ref_nnn}'xx/' > index.html
        
        dqmFileNames=`cat index.html | grep ${Ref_numb} | egrep "_DQM.root|_DQMIO.root" | egrep "Prompt|Express|22Jan2013" | sed 's/.*>\(.*\)<\/a.*/\1/' `
        dqmFileName=`expr "$dqmFileNames" : '\(DQM[A-Za-z0-9_/.\-]*root\)'`
        echo ' dqmFileNames = '$dqmFileNames
        echo ' dqmFileName = ['$dqmFileName']'
        curl -k --cert /data/users/cctrkdata/current/auth/proxy/proxy.cert --key /data/users/cctrkdata/current/auth/proxy/proxy.cert -X GET https://cmsweb.cern.ch/dqm/offline/data/browse/ROOT/OfflineData/$DataOfflineDir_ref/$dataset/000${ref_nnn}xx/${dqmFileName} > /${referenceRunsDir}/${dqmFileName}
    else
        echo "Please select a correct reference"
        exit 0
    fi
else
    echo "You have selected a known reference, don't forget to check it corresponds to the same conditions that the actual run."
fi
refFile=`ls ${referenceRunsDir}/ | grep ${Ref_numb}`

#1.b -- download the run
if [ $Run_numb -gt 294645 ]; then

        DataLocalDir='Data2017'
        DataOfflineDir='Run2017'
else

if [ $Run_numb -gt 287000 ]; then

    DataLocalDir='Data2017'
    DataOfflineDir='Commissioning2017'
else


if [ $Run_numb -gt 284500 ]; then

    DataLocalDir='Data2016'
    DataOfflineDir='PARun2016'
else

##2016 data taking period run > 271024
if [ $Run_numb -gt 271024 ]; then

    DataLocalDir='Data2016'
    DataOfflineDir='Run2016'
else

#2016 - Commissioning period                                                                                                                               
if [ $Run_numb -gt 264200 ]; then

    DataLocalDir='Data2016'
    DataOfflineDir='Commissioning2016'
else

#Run2015A
if [ $Run_numb -gt 246907 ]; then
    DataLocalDir='Data2015'
    DataOfflineDir='Run2015'
else

#2015 Commissioning period (since January)
if [ $Run_numb -gt 232881 ]; then
    DataLocalDir='Data2015'
    DataOfflineDir='Commissioning2015'
else
#2013 pp run (2.76 GeV)
    if [ $Run_numb -gt 211658 ]; then
        DataLocalDir='Data2013'
        DataOfflineDir='Run2013'
    else
#2013 HI run
        if [ $Run_numb -gt 209634 ]; then
    	DataLocalDir='Data2013'
    	DataOfflineDir='HIRun2013'
        else
    	if [ $Run_numb -gt 190450 ]; then
    	    DataLocalDir='Data2012'
    	    DataOfflineDir='Run2012'
    	fi
        fi
    fi
fi
fi
fi
fi
fi
fi
fi
echo 'Directory to fetch the DQM file from: https://cmsweb.cern.ch/dqm/offline/data/browse/ROOT/OfflineData/'${DataOfflineDir}'/'$dataset'/000'${nnn}'xx/'


curl -k --cert /data/users/cctrkdata/current/auth/proxy/proxy.cert --key /data/users/cctrkdata/current/auth/proxy/proxy.cert -X GET 'https://cmsweb.cern.ch/dqm/offline/data/browse/ROOT/OfflineData/'${DataOfflineDir}'/'$dataset'/000'${nnn}'xx/' > index.html

dqmFileNames=`cat index.html | grep ${Run_numb} | egrep "_DQM.root|_DQMIO.root" | egrep "Prompt|Express|22Jan2013" | sed 's/.*>\(.*\)<\/a.*/\1/' `
dqmFileName=`expr "$dqmFileNames" : '\(DQM[A-Za-z0-9_/.\-]*root\)'`
echo ' dqmFileNames = '$dqmFileNames
echo ' dqmFileName = ['$dqmFileName']'
curl -k --cert /data/users/cctrkdata/current/auth/proxy/proxy.cert --key /data/users/cctrkdata/current/auth/proxy/proxy.cert -X GET https://cmsweb.cern.ch/dqm/offline/data/browse/ROOT/OfflineData/$DataOfflineDir/$dataset/000${nnn}xx/${dqmFileName} > /${curdir}/${dqmFileName}
runFile=`ls ${curdir}/${dqmFileName} | grep ${Run_numb}`






#
## 1.b) Produce the DQM GUI related plots with the two downloaded root files
#
echo "python MakeDQMGUI_promptfeedbackPlots.py $runFile ${referenceRunsDir}/$refFile $foldername"
python MakeDQMGUI_promptfeedbackPlots.py $runFile ${referenceRunsDir}/$refFile $foldername 


#
##
### 2. Produce the prompt feedback for the Tracker map related plots
##
#

#
## 2.a) Produce the tracker maps
#
trackerMap_directory="/data/users/event_display/$DataLocalDir/$mode/$shortRun/$Run_numb/$dataset/"
trackerMap_directory_ref="/data/users/event_display/$DataLocalDir_ref/$mode_ref/$shortRef/$Ref_numb/$dataset/"
if [ ! -z "$4" ]; then
    sh TkMap_script_automatic_DB.sh $dataset f $Run_numb $Ref_numb 
else
    if [ -d "$trackerMap_directory" ]; then
        echo "Tracker maps for run $Run_numb seem to be already produced, so we don't reproduce them. If you want to force to reproduce them, launch this script with the force option"
    else
        sh TkMap_script_automatic_DB.sh $dataset f $Run_numb    
    fi
    if [ -d "$trackerMap_directory_ref" ]; then
        echo "Tracker maps for run $Ref_numb seem to be already produced, so we don't reproduce them. If you want to force to reproduce them, launch this script with the force option"
    else
        echo "sh TkMap_script_automatic_DB.sh $dataset f $Ref_numb   " 
        sh TkMap_script_automatic_DB.sh $dataset f $Ref_numb    
    fi

fi


#
## 2.b) Copy them here
#
cp ${trackerMap_directory}/StoNCorrOnTrack.png ${foldername}/Strip_TkMap_run_${Run_numb}_StoNCorrOnTrack.png
cp ${trackerMap_directory_ref}/StoNCorrOnTrack.png ${foldername}/Strip_TkMap_ref_${Ref_numb}_StoNCorrOnTrack.png

#
##
### 3. copy everything in a web folder with nice rendering
##
#
#now="$(date +'%d/%m/%Y')"

#
## Produce run conditions
#
Run_dataset=$(echo $runFile | grep -Po '^.*?\K(?<=__).*?(?=__)')
Ref_dataset=$(echo $runFile | grep -Po '^.*?\K(?<=__).*?(?=__)')
Run_era=$(echo $runFile | grep -Po '^.*?\K(?<=__).*?(?=-)' | grep -Po '^.*?\K(?<=__).*' )
Ref_era=$(echo $refFile | grep -Po '^.*?\K(?<=__).*?(?=-)' | grep -Po '^.*?\K(?<=__).*' )
run_apv_page="$(curl http://ebutz.web.cern.ch/ebutz/cgi-bin/getReadOutmode.pl?RUN=${Run_numb} ) "
ref_apv_page="$(curl http://ebutz.web.cern.ch/ebutz/cgi-bin/getReadOutmode.pl?RUN=${Ref_numb} ) "
Run_apv_mode=$(echo $run_apv_page | grep -o -P '(?<=,").*(?=")')
Ref_apv_mode=$(echo $run_apv_page | grep -o -P '(?<=,").*(?=")')

#DQM GUI Link
beginning="https:\/\/cmsweb.cern.ch\/dqm\/offline\/start?runnr=${Run_numb};dataset=\/"
middle="\/DQMIO;sampletype=offline_data;filter=all;referencepos=overlay;referenceshow=customise;referenceNorm=True;referenceobj1=other%3A${Ref_numb}%3A\/"
#directory="\/DQMIO%3A;referenceobj2=none;referenceobj3=none;referenceobj4=none;search=;striptype=object;stripruns=;stripaxis=run;stripomit=none;workspace=SiStrip;size=M;root=SiStrip\/Layouts"
directory="\/DQMIO%3A;referenceobj2=none;referenceobj3=none;referenceobj4=none;search=;striptype=object;stripruns=;stripaxis=run;stripomit=none;workspace=Summary;size=M;root="
end=";focus=;zoom=no;"


Run_dataset_type=$(echo $runFile | grep -o -P '(?<=__).*(?=__)' | grep -o -P '(?<=__).*(?=)')
Ref_dataset_type=$(echo $refFile | grep -o -P '(?<=__).*(?=__)' | grep -o -P '(?<=__).*(?=)')

Gui_link="${beginning}${Run_dataset}\/${Run_dataset_type}${middle}${Ref_dataset}\/${Ref_dataset_type}${directory}${end}"

sed s/RUN_NUMBER/${Run_numb}/g conditions.txt.template | \
sed s/REF_NUMBER/${Ref_numb}/g | \
sed s/RUN_DATASET/${Run_dataset}/g | \
sed s/REF_DATASET/${Ref_dataset}/g | \
sed s/RUN_ERA/${Run_era}/g | \
sed s/REF_ERA/${Ref_era}/g | \
sed s/RUN_APV_MODE/${Run_apv_mode}/g | \
sed s/REF_APV_MODE/${Ref_apv_mode}/g | \
sed "s/GUI_LINK/${Gui_link}/g" \
> conditions.txt


cd $foldername
perl ../makeIndexForPromptFeedback.pl -c 2 -t "Run ${Run_numb} compared to ref ${Ref_numb} -- Prompt Feedback plots"
cd -

#create the year directory
PREPATH="/data/users/event_display/PromptFeedback"
mkdir -p $PREPATH/$year/${month}_${MONTHS[$monthIndex]}/${day}_$dayOfWeek/$ampm/
final_directory="$PREPATH/$year/${month}_${MONTHS[$monthIndex]}/${day}_$dayOfWeek/$ampm/"



 rm -rf ${final_directory}/$foldername #clean directory in case it already existnme 
 cp -r $foldername $final_directory #/data/users/event_display/tmp/. #WARNING: When testing, please comment this line to not upload your restuls on event_display
echo 'Please check the plots created in http://vocms061.cern.ch/event_display/PromptFeedback/'$year/${month}_${MONTHS[$monthIndex]}/${day}_$dayOfWeek/$ampm/$foldername



#Cleaning
rm -f $runFile
rm -f runsNotComplete_tmp.txt
rm -f index.html
rm -rf $foldername
rm -f conditions.txt
