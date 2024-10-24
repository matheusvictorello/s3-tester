# import functions: wait_command
Include ./spec/019_utils.sh
is_variable_null() {
  [ -z "$1" ]
}

Describe 'Put bucket tagging:' category:"Bucket Management"
  setup(){
    bucket_name="test-092-$(date +%s)"
    file1_name="LICENSE"
  }
  Before 'setup' 
  Parameters:matrix
    $PROFILES
    $CLIENTS
  End
  Example "on profile $1 using client $2" id:"092"
    profile=$1
    client=$2
    tag='TagSet=[{Key=organization,Value=marketing}]'
    aws --profile $profile s3 mb s3://$bucket_name-$client > /dev/null 
    case "$client" in
    "aws-s3api" | "aws" | "aws-s3")
      When run aws --profile $profile s3api put-bucket-tagging --bucket $bucket_name-$client --tagging $tag
      The stdout should include ""
      The status should be success
      ;;
    "rclone")
      Skip "Skipped test to $client"
      ;;
    "mgc")
      mgc workspace set $profile > /dev/null
      When run bash ./spec/retry_command.sh "mgc object-storage buckets put-bucket-label --bucket $bucket_name-$client --labelling $tag"
      # When run mgc object-storage buckets put-bucket-label --bucket $bucket_name-$client --labelling $tag
      The stdout should include ""
      The status should be success
      ;;
    esac
    #wait_command bucket-exists "$profile" "$bucket_name-$client"
    rclone purge $profile:$bucket_name-$client > /dev/null
    #wait_command bucket-not-exists "$profile" "$bucket_name-$client"
  End
End

Describe 'Get bucket tagging:' category:"Bucket Management"
  setup(){
    bucket_name="test-092-$(date +%s)"
    file1_name="LICENSE"
  }
  Before 'setup' 
  Parameters:matrix
    $PROFILES
    $CLIENTS
  End
  Example "on profile $1 using client $2" id:"092"
    profile=$1
    client=$2
    tag='TagSet=[{Key=organization,Value=marketing}]'
    aws --profile $profile s3 mb s3://$bucket_name-$client > /dev/null 
    aws --profile $profile s3api put-bucket-tagging --bucket $bucket_name-$client --tagging $tag
    case "$client" in
    "aws-s3api" | "aws" | "aws-s3")
      When run aws --profile $profile s3api get-bucket-tagging --bucket $bucket_name-$client
      The stdout should include "organization"
      The status should be success
      ;;
    "rclone")
      Skip "Skipped test to $client"
      ;;
    "mgc")
      mgc workspace set $profile > /dev/null
      When run bash ./spec/retry_command.sh "mgc object-storage buckets get-bucket-label --bucket $bucket_name-$client"
      # When run mgc object-storage buckets get-bucket-label --bucket $bucket_name-$client
      The stdout should include "organization"
      The status should be success
      ;;
    esac
    #wait_command bucket-exists "$profile" "$bucket_name-$client"
    rclone purge $profile:$bucket_name-$client > /dev/null
    #wait_command bucket-not-exists "$profile" "$bucket_name-$client"
  End
End

Describe 'Delete bucket tagging:' category:"Bucket Management"
  setup(){
    bucket_name="test-092-$(date +%s)"
    file1_name="LICENSE"
  }
  Before 'setup' 
  Parameters:matrix
    $PROFILES
    $CLIENTS
  End
  Example "on profile $1 using client $2" id:"092"
    profile=$1
    client=$2
    tag='TagSet=[{Key=organization,Value=marketing}]'
    aws --profile $profile s3 mb s3://$bucket_name-$client > /dev/null 
    case "$client" in
    "aws-s3api" | "aws" | "aws-s3")
      When run aws --profile $profile s3api delete-bucket-tagging --bucket $bucket_name-$client
      The stdout should include ""
      The status should be success
      ;;
    "rclone")
      Skip "Skipped test to $client"
      ;;
    "mgc")
      mgc workspace set $profile > /dev/null
      When run bash ./spec/retry_command.sh "mgc object-storage buckets delete-bucket-label --bucket $bucket_name-$client"
      # When run mgc object-storage buckets delete-bucket-label --bucket $bucket_name-$client
      The stdout should include ""
      The status should be success
      ;;
    esac
    #wait_command bucket-exists "$profile" "$bucket_name-$client"
    rclone purge $profile:$bucket_name-$client > /dev/null
    #wait_command bucket-not-exists "$profile" "$bucket_name-$client"
  End
End

Describe 'Put bucket tagging wrong json:' category:"Bucket Management"
  setup(){
    bucket_name="test-092-$(date +%s)"
    file1_name="LICENSE"
  }
  Before 'setup' 
  Parameters:matrix
    $PROFILES
    $CLIENTS
  End
  Example "on profile $1 using client $2" id:"092"
    profile=$1
    client=$2
    tag='TagSet=[{Key=organization,Value=marketing]'
    aws --profile $profile s3 mb s3://$bucket_name-$client > /dev/null 
    case "$client" in
    "aws-s3api" | "aws" | "aws-s3")
      When run aws --profile $profile s3api put-bucket-tagging --bucket $bucket_name-$client --tagging $tag
      The stderr should include "Error parsing parameter '--tagging'"
      The status should be failure
      ;;
    "rclone")
      Skip "Skipped test to $client"
      ;;
    "mgc")
      mgc workspace set $profile > /dev/null
      When run bash ./spec/retry_command.sh "mgc object-storage buckets put-bucket-label --bucket $bucket_name-$client --labelling $tag"
      # When run mgc object-storage buckets put-bucket-label --bucket $bucket_name-$client --labelling $tag
      The stdout should include "Error parsing parameter '--tagging'"
      The status should be failure
      ;;
    esac
    #wait_command bucket-exists "$profile" "$bucket_name-$client"
    rclone purge $profile:$bucket_name-$client > /dev/null
    #wait_command bucket-not-exists "$profile" "$bucket_name-$client"
  End
End

Describe 'Put bucket tagging with wrong "value":' category:"Bucket Management"
  setup(){
    bucket_name="test-092-$(date +%s)"
    file1_name="LICENSE"
  }
  Before 'setup' 
  Parameters:matrix
    $PROFILES
    $CLIENTS
  End
  Example "on profile $1 using client $2" id:"092"
    profile=$1
    client=$2
    tag='TagSet=[{key=organization,value=marketing}]'
    aws --profile $profile s3 mb s3://$bucket_name-$client > /dev/null 
    case "$client" in
    "aws-s3api" | "aws" | "aws-s3")
      When run aws --profile $profile s3api put-bucket-tagging --bucket $bucket_name-$client --tagging $tag
      The stderr should include "Missing required parameter in Tagging.TagSet[0]:"
      The status should be failure
      ;;
    "rclone")
      Skip "Skipped test to $client"
      ;;
    "mgc")
      mgc workspace set $profile > /dev/null
      When run bash ./spec/retry_command.sh "mgc object-storage buckets put-bucket-label --bucket $bucket_name-$client --labelling $tag"
      # When run mgc object-storage buckets put-bucket-label --bucket $bucket_name-$client --labelling $tag
      The stdout should include "Missing required parameter in Tagging.TagSet[0]:"
      The status should be failure
      ;;
    esac
    #wait_command bucket-exists "$profile" "$bucket_name-$client"
    rclone purge $profile:$bucket_name-$client > /dev/null
    #wait_command bucket-not-exists "$profile" "$bucket_name-$client"
  End
End

Describe 'Put bucket tagging with file:' category:"Bucket Management"
  setup(){
    bucket_name="test-092-$(date +%s)"
    file1_name="tagging.json"
  }
  Before 'setup' 
  Parameters:matrix
    $PROFILES
    $CLIENTS
  End
  Example "on profile $1 using client $2" id:"092"
    profile=$1
    client=$2
    aws --profile $profile s3 mb s3://$bucket_name-$client > /dev/null 
    case "$client" in
    "aws-s3api" | "aws" | "aws-s3")
      When run aws --profile $profile s3api put-bucket-tagging --bucket $bucket_name-$client --tagging file://$file1_name
      The stderr should include ""
      The status should be success
      ;;
    "rclone")
      Skip "Skipped test to $client"
      ;;
    "mgc")
      mgc workspace set $profile > /dev/null
      When run bash ./spec/retry_command.sh "mgc object-storage buckets put-bucket-label --bucket $bucket_name-$client --labelling $tag"
      # When run mgc object-storage buckets put-bucket-label --bucket $bucket_name-$client --labelling $tag
      The stdout should include "Missing required parameter in Tagging.TagSet[0]:"
      The status should be failure
      ;;
    esac
    #wait_command bucket-exists "$profile" "$bucket_name-$client"
    rclone purge $profile:$bucket_name-$client > /dev/null
    #wait_command bucket-not-exists "$profile" "$bucket_name-$client"
  End
End

Describe 'Put bucket tagging with wrong file:' category:"Bucket Management"
  setup(){
    bucket_name="test-092-$(date +%s)"
    file1_name="LICENSE"
  }
  Before 'setup' 
  Parameters:matrix
    $PROFILES
    $CLIENTS
  End
  Example "on profile $1 using client $2" id:"092"
    profile=$1
    client=$2
    aws --profile $profile s3 mb s3://$bucket_name-$client > /dev/null 
    case "$client" in
    "aws-s3api" | "aws" | "aws-s3")
      When run aws --profile $profile s3api put-bucket-tagging --bucket $bucket_name-$client --tagging file://$file1_name
      The stderr should include ""
      The status should be success
      ;;
    "rclone")
      Skip "Skipped test to $client"
      ;;
    "mgc")
      mgc workspace set $profile > /dev/null
      When run bash ./spec/retry_command.sh "mgc object-storage buckets put-bucket-label --bucket $bucket_name-$client --labelling $tag"
      # When run mgc object-storage buckets put-bucket-label --bucket $bucket_name-$client --labelling $tag
      The stdout should include "Missing required parameter in Tagging.TagSet[0]:"
      The status should be failure
      ;;
    esac
    #wait_command bucket-exists "$profile" "$bucket_name-$client"
    rclone purge $profile:$bucket_name-$client > /dev/null
    #wait_command bucket-not-exists "$profile" "$bucket_name-$client"
  End
End
