Describe 'Set the versioning for a public bucket:' category:"Object Versioning"
  setup(){
    bucket_name="test-039-$(date +%s)"
    file1_name="LICENSE"
  }
  Before 'setup'
  Parameters:matrix
    $PROFILES
    $CLIENTS
  End
  Example "on profile $1 using client $2" id:"039"
    profile=$1
    client=$2
    aws --profile $profile s3api create-bucket --bucket $bucket_name-$client --acl public-read  > /dev/null
    case "$client" in
    "aws-s3api" | "aws" | "aws-s3")
    When run aws s3api --profile $profile put-bucket-versioning --bucket $bucket_name-$client --versioning-configuration Status=Enabled
    The output should include ""
      ;;
    "rclone")
      Skip "Skipped test to $client"
      ;;
    "mgc")
    mgc workspace set $profile > /dev/null
    When run bash ./spec/retry_command.sh "mgc object-storage buckets versioning enable $bucket_name-$client --raw"
    # When run mgc object-storage buckets versioning enable $bucket_name-$client --raw
    The output should include "$bucket_name-$client"
      ;;
    esac
    The status should be success
    rclone purge --log-file /dev/null "$profile:$bucket_name-$client" > /dev/null
  End
End
