#!/bin/bash +x

#
# Check /data usage
#
function checking_storage()
{
   result=0
   regexp="([1-9]?\%)"
   percentage=""
   result=`adb -s $1 shell df /data -h`
   for item in $result
   do
     usage=`cut -f1 <<< $item`
     if [[ $usage =~ $regexp ]]; then
        percentage=`cut -d '%' -f1 <<< $usage`
     fi
   done

   # Some devices don't have % return
   if [ "$percentage" == "" ]; then
      echo "[$1] N/A" 
      echo "$result"
      echo ""
      return 1
   elif [ $percentage -gt 80 ]; then
      echo "[$1] Usage : $percentage%                   [ERROR] " 
      echo "$result"
      echo ""
      return 1
   elif [ $percentage -gt 50 ]; then
      echo "[$1] Usage : $percentage%                   [WARNING] " 
      echo "$result"
      echo ""
      return 1
   fi

  return 0
}

#
# main
#
main() {

  error=0
  counter=0
  device_list=`adb devices | tail -n +2 | cut -sf 1`
  echo " ####################################### "
  echo " ##                                   ## "
  echo " ##          Storage Report           ## "
  echo " ##                                   ## "
  echo " ####################################### "
  for device in $device_list
  do 
    checking_storage $device
    error=$(($error+$?))
    counter=$(($counter+1))
  done
  echo ""
  echo " ########### Abnormal : $error devices   ############ "
  echo " ########### Total    : $counter devices ############ "
  echo ""
}

main "$@"

