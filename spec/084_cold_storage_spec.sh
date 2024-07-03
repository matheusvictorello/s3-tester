% UNIQUE_SUFIX: $(date +%s)

# import functions: get_test_bucket_name, get_uploaded_key, remove_test_bucket
Include ./spec/053_utils.sh
# import functions: exist_var create_file
Include ./spec/054_utils.sh

Describe 'Setup 84, 85, 86, 87, 88'
  Parameters:matrix
    $PROFILES
  End
  Example "create test bucket using rclone" id:"084" id:"085" id:"086" id:"087" id:"088"
    profile=$1
    bucket_name=$(get_test_bucket_name)
    When run rclone mkdir "$profile:$bucket_name"
    The status should be success
  End
End

Describe 'Put object with storage class' category:"Cold Storage" id:"084" id:"085" id:"087"
  Parameters:matrix
    $PROFILES
    $CLIENTS
  End
  Example "default, on profile $1 using client $2"
    profile=$1
    client=$2
    bucket_name=$(get_test_bucket_name)
    object_key=$(get_uploaded_key "default-class")
    file="LICENSE"
    case "$client" in
    "aws-s3api" | "aws")
      When run aws --profile "$profile" s3api put-object --bucket "$bucket_name" --key "$object_key" --body "$file"
      The status should be success
      The output should include "\"ETag\":"
      ;;
    "aws-s3")
      When run aws --profile "$profile" s3 cp "$file" "s3://$bucket_name/$object_key"
      The status should be success
      The output should include "upload: ./$file to s3://$bucket_name/$object_key"
      ;;
    "rclone")
      When run rclone copyto "$file" "$profile:$bucket_name/$object_key" -v
      The status should be success
      The error should include "INFO  : $file: Copied"
      ;;
    "mgc")
      ;;
    esac
  End
  Example "STANDARD, on profile $1 using client $2"
    profile=$1
    client=$2
    bucket_name=$(get_test_bucket_name)
    object_key=$(get_uploaded_key "standard-class")
    file="LICENSE"
    case "$client" in
    "aws-s3api" | "aws")
      When run aws --profile "$profile" s3api put-object --bucket "$bucket_name" --key "$object_key" --storage-class "STANDARD" --body "$file"
      The status should be success
      The output should include "\"ETag\":"
      ;;
    "aws-s3")
      When run aws --profile "$profile" s3 cp "$file" "s3://$bucket_name/$object_key" --storage-class "STANDARD"
      The status should be success
      The output should include "upload: ./$file to s3://$bucket_name/$object_key"
      ;;
    "rclone")
      When run rclone copyto "$file" "$profile:$bucket_name/$object_key" --s3-storage-class "STANDARD" -v
      The status should be success
      The error should include "INFO  : $file: Copied"
      ;;
    "mgc")
      ;;
    esac
  End
  Example "GLACIER_IR, on profile $1 using client $2"
    profile=$1
    client=$2
    bucket_name=$(get_test_bucket_name)
    object_key=$(get_uploaded_key "glacier-ir-class")
    file="LICENSE"
    case "$client" in
    "aws-s3api" | "aws")
      When run aws --profile "$profile" s3api put-object --bucket "$bucket_name" --key "$object_key" --storage-class "GLACIER_IR" --body "$file"
      The status should be success
      The output should include "\"ETag\":"
      ;;
    "aws-s3")
      When run aws --profile "$profile" s3 cp "$file" "s3://$bucket_name/$object_key" --storage-class "GLACIER_IR"
      The status should be success
      The output should include "upload: ./$file to s3://$bucket_name/$object_key"
      ;;
    "rclone")
      When run rclone copyto "$file" "$profile:$bucket_name/$object_key" --s3-storage-class "GLACIER_IR" -v
      The status should be success
      The error should include "INFO  : $file: Copied"
      ;;
    "mgc")
      ;;
    esac
  End
End

Describe 'List object with storage class' category:"Cold Storage" id:"085"
  Parameters:matrix
    $PROFILES
    $CLIENTS
  End
  Example "default, on profile $1 using client $2"
    profile=$1
    client=$2
    bucket_name=$(get_test_bucket_name)
    object_key=$(get_uploaded_key "default-class")
    case "$client" in
    "aws-s3api" | "aws" | "aws-s3")
      When run aws s3api list-objects-v2 --profile "$profile" --bucket "$bucket_name" --prefix "$object_key" --query "Contents[*].StorageClass"
      The status should be success
      The output should include "\"STANDARD\""
      ;;
    "rclone")
      When run rclone lsjson --metadata "$profile:$bucket_name/$object_key"
      The status should be success
      The output should include "STANDARD"
      ;;
    "mgc")
      ;;
    esac
  End
  Example "STANDARD, on profile $1 using client $2"
    profile=$1
    client=$2
    bucket_name=$(get_test_bucket_name)
    object_key=$(get_uploaded_key "standard-class")
    case "$client" in
    "aws-s3api" | "aws" | "aws-s3")
      When run aws s3api list-objects-v2 --profile "$profile" --bucket "$bucket_name" --prefix "$object_key" --query "Contents[*].StorageClass"
      The status should be success
      The output should include "\"STANDARD\""
      ;;
    "rclone")
      When run rclone lsjson --metadata "$profile:$bucket_name/$object_key"
      The status should be success
      The output should include "STANDARD"
      ;;
    "mgc")
      ;;
    esac
  End
  Example "GLACIER_IR, on profile $1 using client $2"
    profile=$1
    client=$2
    bucket_name=$(get_test_bucket_name)
    object_key=$(get_uploaded_key "glacier-ir-class")
    case "$client" in
    "aws-s3api" | "aws" | "aws-s3")
      When run aws s3api list-objects-v2 --profile "$profile" --bucket "$bucket_name" --prefix "$object_key" --query "Contents[*].StorageClass"
      The status should be success
      The output should include "\"GLACIER_IR\""
      ;;
    "rclone")
      When run rclone lsjson --metadata "$profile:$bucket_name/$object_key"
      The status should be success
      The output should include "GLACIER_IR"
      ;;
    "mgc")
      ;;
    esac
  End
End

Describe 'Object custom metadata with storage class' category:"Cold Storage" id:"088"
  Parameters:matrix
    $PROFILES
    $CLIENTS
  End
  Example "PUT GLACIER_IR, on profile $1 using client $2"
    profile=$1
    client=$2
    bucket_name=$(get_test_bucket_name)
    object_key=$(get_uploaded_key "glacier-ir-class-with-metadata")
    file="LICENSE"
    case "$client" in
    "aws-s3api" | "aws")
      When run aws --profile "$profile" s3api put-object --bucket "$bucket_name" --key "$object_key" --storage-class "GLACIER_IR" --body "$file" --metadata "metadata1=foo,metadata2=bar"
      The status should be success
      The output should include "\"ETag\":"
      ;;
    "aws-s3")
      When run aws --profile "$profile" s3 cp "$file" "s3://$bucket_name/$object_key" --storage-class "GLACIER_IR"
      The status should be success
      The output should include "upload: ./$file to s3://$bucket_name/$object_key"
      ;;
    "rclone")
      When run rclone copyto "$file" "$profile:$bucket_name/$object_key" --s3-storage-class "GLACIER_IR" -v
      The status should be success
      The error should include "INFO  : $file: Copied"
      ;;
    "mgc")
      ;;
    esac
  End
  Example "HEAD GLACIER_IR with metadata, on profile $1 using client $2"
    profile=$1
    client=$2
    bucket_name=$(get_test_bucket_name)
    object_key=$(get_uploaded_key "glacier-ir-class-with-metadata")
    case "$client" in
    "aws-s3api" | "aws" | "aws-s3")
      When run aws s3api head-object --profile "$profile" --bucket "$bucket_name" --key "$object_key"
      The status should be success
      The output should include "\"StorageClass\": \"GLACIER_IR\""
      The output should include "\"metadata1\": \"foo\""
      The output should include "\"metadata2\": \"bar\""
      ;;
    "rclone")
      When run rclone lsjson --metadata "$profile:$bucket_name/$object_key"
      The status should be success
      The output should include "GLACIER_IR"
      ;;
    "mgc")
      ;;
    esac
  End
End

Describe 'Multipart upload' category:"Cold Storage" id:"086"
  Parameters:matrix
    $PROFILES
    $CLIENTS
  End

  Example "create with storage class default, on profile $1 using client $2"
    profile=$1
    client=$2
    bucket_name=$(get_test_bucket_name)
    object_key=$(get_uploaded_key "multipart-default-class")
    case "$client" in
    "aws-s3api" | "aws" | "aws-s3")

    # initiates a multipart upload without passing a storage class argument
    create_multipart() {
      aws s3api create-multipart-upload --profile "$profile" --bucket "$bucket_name" --key "$object_key" | jq .UploadId -r | tee "/tmp/$object_key.upload_id"
    }
    When call create_multipart
    The status should be success
    The output should not equal ""
      ;;
    "rclone")
      ;;
    "mgc")
      ;;
    esac
  End

  Example "create with storage class STANDARD, on profile $1 using client $2"
    profile=$1
    client=$2
    bucket_name=$(get_test_bucket_name)
    object_key=$(get_uploaded_key "multipart-standard-class")
    case "$client" in
    "aws-s3api" | "aws" | "aws-s3")
    # initiates a multipart upload passing a standard storage class argument
    create_standard_multipart() {
      aws s3api create-multipart-upload --profile "$profile" --bucket "$bucket_name" --key "$object_key" --storage-class "STANDARD" | jq .UploadId -r | tee "/tmp/$object_key.upload_id"
    }
    When call create_standard_multipart
    The status should be success
    The output should not equal ""
      ;;
    "rclone")
      ;;
    "mgc")
      ;;
    esac
  End

  Example "create with storage class GLACIER_IR, on profile $1 using client $2"
    profile=$1
    client=$2
    bucket_name=$(get_test_bucket_name)
    object_key=$(get_uploaded_key "multipart-glacier-ir-class")
    case "$client" in
    "aws-s3api" | "aws" | "aws-s3")
    # initiates a multipart upload passing a cold storage class argument
    create_cold_multipart() {
      aws s3api create-multipart-upload --profile "$profile" --bucket "$bucket_name" --key "$object_key" --storage-class "GLACIER_IR" | jq .UploadId -r | tee "/tmp/$object_key.upload_id"
    }
    When call create_cold_multipart
    The status should be success
    The output should not equal ""
      ;;
    "rclone")
      ;;
    "mgc")
      ;;
    esac
  End

  Example "list uploads should list 3 with the expected storage classes, on profile $1 using client $2"
    profile=$1
    client=$2
    bucket_name=$(get_test_bucket_name)
    case "$client" in
    "aws-s3api" | "aws" | "aws-s3")
    count_standard() {
      aws s3api list-multipart-uploads --profile $profile --bucket $bucket_name | jq '[.Uploads[].StorageClass] | sort' | tr -d "\n"
    }
    When call count_standard
    The status should be success
    The output should equal "[  \"GLACIER_IR\",  \"STANDARD\",  \"STANDARD\"]"
      ;;
    "rclone")
      ;;
    "mgc")
      ;;
    esac
  End

  Example "upload parts with storage class default, on profile $1 using client $2"
    profile=$1
    client=$2
    bucket_name=$(get_test_bucket_name)
    object_key=$(get_uploaded_key "multipart-default-class")
    upload_id=$(cat "/tmp/$object_key.upload_id")
    local_file="" # will be overwritten by the function below
    file_size=6
    file_unit="mb"
    create_file "$file_size" "$file_unit"
    case "$client" in
    "aws-s3api" | "aws" | "aws-s3")
    # upload two parts
    aws s3api upload-part --profile "$profile" --bucket "$bucket_name" --key "$object_key" --upload-id "$upload_id" --body "$local_file" --part-number 1
    When run aws s3api upload-part --profile "$profile" --bucket "$bucket_name" --key "$object_key" --upload-id "$upload_id" --body "$local_file" --part-number 2
    The status should be success
    The output should include "\"ETag\":"
      ;;
    "rclone")
      ;;
    "mgc")
      ;;
    esac
  End

  Example "upload parts with storage class STANDARD, on profile $1 using client $2"
    profile=$1
    client=$2
    bucket_name=$(get_test_bucket_name)
    object_key=$(get_uploaded_key "multipart-standard-class")
    upload_id=$(cat "/tmp/$object_key.upload_id")
    local_file="" # will be overwritten by the function below
    file_size=6
    file_unit="mb"
    create_file "$file_size" "$file_unit"
    case "$client" in
    "aws-s3api" | "aws" | "aws-s3")
    # upload two parts
    aws s3api upload-part --profile "$profile" --bucket "$bucket_name" --key "$object_key" --upload-id "$upload_id" --body "$local_file" --part-number 1
    When run aws s3api upload-part --profile "$profile" --bucket "$bucket_name" --key "$object_key" --upload-id "$upload_id" --body "$local_file" --part-number 2
    The status should be success
    The output should include "\"ETag\":"
      ;;
    "rclone")
      ;;
    "mgc")
      ;;
    esac
  End

  Example "upload parts with storage class GLACIER_IR, on profile $1 using client $2"
    profile=$1
    client=$2
    bucket_name=$(get_test_bucket_name)
    object_key=$(get_uploaded_key "multipart-glacier-ir-class")
    upload_id=$(cat "/tmp/$object_key.upload_id")
    local_file="" # will be overwritten by the function below
    file_size=6
    file_unit="mb"
    create_file "$file_size" "$file_unit"
    case "$client" in
    "aws-s3api" | "aws" | "aws-s3")
    # upload two parts
    aws s3api upload-part --profile "$profile" --bucket "$bucket_name" --key "$object_key" --upload-id "$upload_id" --body "$local_file" --part-number 1
    When run aws s3api upload-part --profile "$profile" --bucket "$bucket_name" --key "$object_key" --upload-id "$upload_id" --body "$local_file" --part-number 2
    The status should be success
    The output should include "\"ETag\":"
      ;;
    "rclone")
      ;;
    "mgc")
      ;;
    esac
  End


  Example "list parts with default storage, on profile $1 using client $2"
    profile=$1
    client=$2
    bucket_name=$(get_test_bucket_name)
    object_key=$(get_uploaded_key "multipart-default-class")
    upload_id=$(cat "/tmp/$object_key.upload_id")
    case "$client" in
    "aws-s3api" | "aws" | "aws-s3")
    # upload two parts
    When run aws s3api list-parts --profile "$profile" --bucket "$bucket_name" --key "$object_key" --upload-id "$upload_id"
    The status should be success
    The output should include "\"STANDARD\""
      ;;
    "rclone")
      ;;
    "mgc")
      ;;
    esac
  End
  Example "list parts with storage class STANDARD, on profile $1 using client $2"
    profile=$1
    client=$2
    bucket_name=$(get_test_bucket_name)
    object_key=$(get_uploaded_key "multipart-standard-class")
    upload_id=$(cat "/tmp/$object_key.upload_id")
    case "$client" in
    "aws-s3api" | "aws" | "aws-s3")
    # upload two parts
    When run aws s3api list-parts --profile "$profile" --bucket "$bucket_name" --key "$object_key" --upload-id "$upload_id"
    The status should be success
    The output should include "\"STANDARD\""
      ;;
    "rclone")
      ;;
    "mgc")
      ;;
    esac
  End
  Example "list parts with storage class GLACIER_IR, on profile $1 using client $2"
    profile=$1
    client=$2
    bucket_name=$(get_test_bucket_name)
    object_key=$(get_uploaded_key "multipart-glacier-ir-class")
    upload_id=$(cat "/tmp/$object_key.upload_id")
    case "$client" in
    "aws-s3api" | "aws" | "aws-s3")
    # upload two parts
    When run aws s3api list-parts --profile "$profile" --bucket "$bucket_name" --key "$object_key" --upload-id "$upload_id"
    The status should be success
    The output should include "\"GLACIER_IR\""
      ;;
    "rclone")
      ;;
    "mgc")
      ;;
    esac
  End


  Example "complete with storage class default, on profile $1 using client $2"
    profile=$1
    client=$2
    bucket_name=$(get_test_bucket_name)
    object_key=$(get_uploaded_key "multipart-default-class")
    upload_id=$(cat "/tmp/$object_key.upload_id")
    case "$client" in
    "aws-s3api" | "aws" | "aws-s3")
    aws s3api list-parts --profile "$profile" --bucket "$bucket_name" --key "$object_key" --upload-id "$upload_id" | jq '{"Parts": [.Parts[] | {"PartNumber": .PartNumber, "ETag": .ETag}]}' > /tmp/parts.json
    When run aws s3api complete-multipart-upload --profile "$profile" --bucket "$bucket_name" --key "$object_key" --upload-id $upload_id --multipart-upload file:///tmp/parts.json
    The status should be success
    The output should include "\"Key\": \"$object_key\""
      ;;
    "rclone")
      ;;
    "mgc")
      ;;
    esac
  End

  Example "complete with storage class STANDARD, on profile $1 using client $2"
    profile=$1
    client=$2
    bucket_name=$(get_test_bucket_name)
    object_key=$(get_uploaded_key "multipart-standard-class")
    upload_id=$(cat "/tmp/$object_key.upload_id")
    case "$client" in
    "aws-s3api" | "aws" | "aws-s3")
    # generates a parts list json file
    aws s3api list-parts --profile "$profile" --bucket "$bucket_name" --key "$object_key" --upload-id "$upload_id" | jq '{"Parts": [.Parts[] | {"PartNumber": .PartNumber, "ETag": .ETag}]}' > /tmp/parts.json
    # complete the multipart upload
    When run aws s3api complete-multipart-upload --profile "$profile" --bucket "$bucket_name" --key "$object_key" --upload-id $upload_id --multipart-upload file:///tmp/parts.json
    The status should be success
    The output should include "\"Key\": \"$object_key\""
      ;;
    "rclone")
      ;;
    "mgc")
      ;;
    esac
  End

  Example "complete with storage class GLACIER_IR, on profile $1 using client $2"
    profile=$1
    client=$2
    bucket_name=$(get_test_bucket_name)
    object_key=$(get_uploaded_key "multipart-glacier-ir-class")
    upload_id=$(cat "/tmp/$object_key.upload_id")
    case "$client" in
    "aws-s3api" | "aws" | "aws-s3")
    # generates a parts list json file
    aws s3api list-parts --profile "$profile" --bucket "$bucket_name" --key "$object_key" --upload-id "$upload_id" | jq '{"Parts": [.Parts[] | {"PartNumber": .PartNumber, "ETag": .ETag}]}' > /tmp/parts.json
    # complete the multipart upload
    When run aws s3api complete-multipart-upload --profile "$profile" --bucket "$bucket_name" --key "$object_key" --upload-id $upload_id --multipart-upload file:///tmp/parts.json
    The status should be success
    The output should include "\"Key\": \"$object_key\""
      ;;
    "rclone")
      ;;
    "mgc")
      ;;
    esac
  End
End

Describe 'List multipart object with storage class' category:"Cold Storage" id:"086"
  Parameters:matrix
    $PROFILES
    $CLIENTS
  End
  Example "default, on profile $1 using client $2"
    profile=$1
    client=$2
    bucket_name=$(get_test_bucket_name)
    object_key=$(get_uploaded_key "multipart-default-class")
    case "$client" in
    "aws-s3api" | "aws" | "aws-s3")
      When run aws s3api list-objects-v2 --profile "$profile" --bucket "$bucket_name" --prefix "$object_key" --query "Contents[*].StorageClass"
      The status should be success
      The output should include "\"STANDARD\""
      ;;
    "rclone")
      # When run rclone lsjson --metadata "$profile:$bucket_name/$object_key"
      # The status should be success
      # The output should include "STANDARD"
      ;;
    "mgc")
      ;;
    esac
  End
  Example "STANDARD, on profile $1 using client $2"
    profile=$1
    client=$2
    bucket_name=$(get_test_bucket_name)
    object_key=$(get_uploaded_key "multipart-standard-class")
    case "$client" in
    "aws-s3api" | "aws" | "aws-s3")
      When run aws s3api list-objects-v2 --profile "$profile" --bucket "$bucket_name" --prefix "$object_key" --query "Contents[*].StorageClass"
      The status should be success
      The output should include "\"STANDARD\""
      ;;
    "rclone")
      # When run rclone lsjson --metadata "$profile:$bucket_name/$object_key"
      # The status should be success
      # The output should include "STANDARD"
      ;;
    "mgc")
      ;;
    esac
  End
  Example "GLACIER_IR, on profile $1 using client $2"
    profile=$1
    client=$2
    bucket_name=$(get_test_bucket_name)
    object_key=$(get_uploaded_key "multipart-glacier-ir-class")
    case "$client" in
    "aws-s3api" | "aws" | "aws-s3")
      When run aws s3api list-objects-v2 --profile "$profile" --bucket "$bucket_name" --prefix "$object_key" --query "Contents[*].StorageClass"
      The status should be success
      The output should include "\"GLACIER_IR\""
      ;;
    "rclone")
      # When run rclone lsjson --metadata "$profile:$bucket_name/$object_key"
      # The status should be success
      # The output should include "GLACIER_IR"
      ;;
    "mgc")
      ;;
    esac
  End
End

Describe 'Change the storage class of an existing…' category:"Cold Storage" id:"087"
  Parameters:matrix
    $PROFILES
    $CLIENTS
  End

  Example "STANDARD object to GLACIER_IR on $1 using $2"
    profile=$1
    client=$2
    bucket_name=$(get_test_bucket_name)
    object_key=$(get_uploaded_key "standard-class")
    new_object_key=$(get_uploaded_key "standard-class")
    case "$client" in
    "aws-s3api" | "aws")
      When run aws --profile "$profile" s3api copy-object --bucket "$bucket_name" --key "$new_object_key" --storage-class "GLACIER_IR" --copy-source "$bucket_name/$object_key"
      The status should be success
      The output should include "\"ETag\":"
      ;;
    "aws-s3")
      When run aws --profile "$profile" s3 cp "s3://$bucket_name/$object_key" "s3://$bucket_name/$new_object_key" --storage-class "GLACIER_IR"
      The status should be success
      The output should include "copy: s3://$bucket_name/$object_key to s3://$bucket_name/$new_object_key"
      ;;
    "rclone")
      When run rclone settier "GLACIER_IR" "$profile:$bucket_name/$object_key" --dump headers
      The status should be success
      The error should include "X-Amz-Storage-Class: GLACIER_IR"
      ;;
    "mgc")
      ;;
    esac
  End
  Example "GLACIER_IR object to STANDARD on $1 using $2"
    profile=$1
    client=$2
    bucket_name=$(get_test_bucket_name)
    object_key=$(get_uploaded_key "glacier-ir-class")
    new_object_key=$(get_uploaded_key "glacier-ir-class")
    case "$client" in
    "aws-s3api" | "aws")
      When run aws --profile "$profile" s3api copy-object --bucket "$bucket_name" --key "$new_object_key" --storage-class "STANDARD" --copy-source "$bucket_name/$object_key"
      The status should be success
      The output should include "\"ETag\":"
      ;;
    "aws-s3")
      When run aws --profile "$profile" s3 cp "s3://$bucket_name/$object_key" "s3://$bucket_name/$new_object_key" --storage-class "STANDARD"
      The status should be success
      The output should include "copy: s3://$bucket_name/$object_key to s3://$bucket_name/$new_object_key"
      ;;
    "rclone")
      When run rclone settier "STANDARD" "$profile:$bucket_name/$object_key" --dump headers
      The status should be success
      The error should include "X-Amz-Storage-Class: STANDARD"
      ;;
    "mgc")
      ;;
    esac
  End
End

Describe 'List object with changed storage class' category:"Cold Storage" id:"087"
  Parameters:matrix
    $PROFILES
    $CLIENTS
  End
  Example "old STANDARD, now GLACIER_IR on profile $1 using client $2"
    profile=$1
    client=$2
    bucket_name=$(get_test_bucket_name)
    object_key=$(get_uploaded_key "standard-class")
    case "$client" in
    "aws-s3api" | "aws" | "aws-s3")
      When run aws s3api list-objects-v2 --profile "$profile" --bucket "$bucket_name" --prefix "$object_key" --query "Contents[*].StorageClass"
      The status should be success
      The output should include "\"GLACIER_IR\""
      ;;
    "rclone")
      When run rclone lsjson --metadata "$profile:$bucket_name/$object_key"
      The status should be success
      The output should include "GLACIER_IR"
      ;;
    "mgc")
      ;;
    esac
  End
  Example "old GLACIER_IR, now STANDARD on profile $1 using client $2"
    profile=$1
    client=$2
    bucket_name=$(get_test_bucket_name)
    object_key=$(get_uploaded_key "glacier-ir-class")
    case "$client" in
    "aws-s3api" | "aws" | "aws-s3")
      When run aws s3api list-objects-v2 --profile "$profile" --bucket "$bucket_name" --prefix "$object_key" --query "Contents[*].StorageClass"
      The status should be success
      The output should include "\"STANDARD\""
      ;;
    "rclone")
      When run rclone lsjson --metadata "$profile:$bucket_name/$object_key"
      The status should be success
      The output should include "STANDARD"
      ;;
    "mgc")
      ;;
    esac
  End
End

teardown(){
  remove_test_bucket $profile $UNIQUE_SUFIX
}
Describe 'Teardown 84, 85, 86, 87, 88'
  Parameters:matrix
    $PROFILES
  End
  Example "remove test bucket or test bucket contents" id:"085" id:"085" id:"086" id:"087" id:"088"
    profile=$1
    When call teardown
    The status should be success
  End
End
