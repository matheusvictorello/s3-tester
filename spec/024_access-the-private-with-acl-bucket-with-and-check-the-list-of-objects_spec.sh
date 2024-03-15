Describe 'Access the Private with ACL bucket with and check the list of objects:' category:"Bucket Permission"
  setup(){
    bucket_name="test-024-$(date +%s)"
    file1_name="LICENSE"
  }
  Before 'setup'
  Parameters:matrix
    $PROFILES
    $CLIENTS
  End
  Example "on profile $1 using client $2" id:"024"
    profile=$1
    client=$2  
    id="fake-user"
    case "$client" in
    "aws-s3api" | "aws")
    aws --profile $profile s3 mb s3://$bucket_name
    aws --profile $profile s3 cp $file1_name s3://$bucket_name
    aws s3api --profile $profile put-bucket-acl --bucket $bucket_name --grant-read id=$id
    When run aws --profile $profile-second s3api list-objects-v2 --bucket $bucket_name
    The output should include "$file1_name"
    aws s3 rb s3://$bucket_name --profile $profile --force
      ;;
    "aws-s3")
    aws --profile $profile s3 mb s3://$bucket_name
    aws --profile $profile s3 cp $file1_name s3://$bucket_name
    aws s3api --profile $profile put-bucket-acl --bucket $bucket_name --grant-read id=$id
    When run aws --profile $profile-second s3api list-objects-v2 --bucket $bucket_name
    The output should include "$file1_name"
    aws s3 rb s3://$bucket_name --profile $profile --force
      ;;
    "rclone")
    aws --profile $profile s3 mb s3://$bucket_name
    aws --profile $profile s3 cp $file1_name s3://$bucket_name
    aws s3api --profile $profile put-bucket-acl --bucket $bucket_name --grant-read id=$id
    When run rclone ls $profile-second:$bucket_name
    The output should include "$file1_name"
    aws s3 rb s3://$bucket_name --profile $profile --force
      ;;
    esac
  End
End
