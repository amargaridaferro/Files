#!/bin/bash

#########################################################################
#                                                                       #
# Script for download YT videos and transcriptions                      #
# --------------------------------------------------------------------- #
# Date: June 2022        based on Catarina Botelho work                                              #
#                                                                       #
#########################################################################

# config
video_info_path=$1 #"videos_tmp_7.csv"  # this file has the header:
                    # "yt_id,channel,wsm_keyword,speaker_id,diagnosis,gender,age"
data_partition=$2 #"_tmp_0"
root="Tese/OSA/"
video_preproces_dir=$root/"video_preprocess/WOSA/"

# stages
STEP0a=1  # downloads yt videos and trasncrptions,
          #   segments videos using transcription information
STEP0b=0  # Segments video using vad. *Use either STEP0a or STEP0b.*



# Check if no more than one segmentation step is selected
check=$(($STEP0a+$STEP0b))
if [ $check -gt "1" ]; then
  echo "Select only one sectmentaion step. Both STEP0a and STEP0b were set to 1."
  exit 1
fi


if [ $STEP0a -eq "1" ]; then
  echo "----------- Starting step 0. ----------- "

  # creating necessary folders
  mkdir -p ${video_preproces_dir}/raw_transcriptions/
  mkdir -p ${video_preproces_dir}/raw_videos/
  mkdir -p ${video_preproces_dir}/processed_transcriptions/
  mkdir -p ${video_preproces_dir}/segmented_videos/

  {
    while read line; do
      id=`echo -n "$line" | cut -d "," -f 1`
      speakerID=`echo -n "$line" | cut -d "," -f 7` #takes the incremental speaker id and the flag c (control)
      ti=`echo -n "$line" | cut -d "," -f 8`
      tf=`echo -n "$line" | cut -d "," -f 9`

      echo "Downloading video $id form speaker $speakerID with ti=$ti and tf=$tf."

      # download - force to be in vtt format and mp4
      #youtube-dl --write-auto-sub --sub-format vtt -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]" "https://www.youtube.com/watch?v="${id} -o ${video_preproces_dir}/yt_files/'/%(id)s.%(ext)s'
      ffmpeg -i ${video_preproces_dir}/yt_files/${id}.mp4 -ss 00:00:10 -to 00:00:30 -c:v copy -c:a copy ${video_preproces_dir}/raw_videos/${speakerID}.mp4

      # continue only if download was successful:
      if test -f "${video_preproces_dir}/yt_files/${id}.en.vtt"; then
        # rename to speaker ID and change the directory of the specific file
        #mv ${video_preproces_dir}/yt_files/${id}.en.vtt ${video_preproces_dir}/raw_transcriptions/${speakerID}.vtt
        #mv ${video_preproces_dir}/yt_files/${id}.mp4 ${video_preproces_dir}/raw_videos/${speakerID}.mp4

        # check if file type is really vtt, or src
        #is_vtt=`grep "</c>" ${video_preproces_dir}/raw_transcriptions/${speakerID}.vtt | wc -l`


        # process captions
        #if [ ${is_vtt} -eq "0" ]; then ## means that the format ir not really vtt, but src
          #python3 utils/process_captions.py -t 'srt' -f ${video_preproces_dir}/raw_transcriptions/${speakerID}.vtt > ${video_preproces_dir}/processed_transcriptions/${speakerID}.rt
        #else
          #python3 utils/process_captions.py -t 'vtt' -f ${video_preproces_dir}/raw_transcriptions/${speakerID}.vtt > ${video_preproces_dir}/processed_transcriptions/${speakerID}.rt
        #fi

        # segment videos
        #python3 utils/segment_videos_w_trasncription.py --vid ${video_preproces_dir}/raw_videos/${speakerID}.mp4 \
                                  #--rt ${video_preproces_dir}/processed_transcriptions/${speakerID}.rt \
                                  #--poi ${speakerID} \
                                  #--output ${video_preproces_dir}/segmented_videos/ \
                                  #--datainfodir ${video_preproces_dir}/segmented_videos_info/
        # segment audios
        #python3 utils/segment_wavs_w_transc.py --vid ${wav_dir}/${speakerID}.wav \
                                      #--rt ${video_preproces_dir}/processed_transcriptions/${speakerID}.rt \
                                      #--poi ${speakerID} \
                                      #--output ${wav_segmnet_dir}/ \
                                      #--datainfodir ${wav_segmnet_infodir}


        echo "Completed processing video of subjected ${speakerID}"

      else
        echo "Could not find ${speakerID} transcription file. Download was not successful. Fix this yourself." >> ${root}/video_segmenttaion_log.log
      fi

    done
  } < ${video_info_path}
fi
