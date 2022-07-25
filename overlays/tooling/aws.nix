{nixpkgs, ...}: final: prev: let
  aws = "${final.awscli2}/bin/aws";

  buckets.ami = "profian-amis";
  buckets.vhd = "profian-vhds";

  # Based on https://docs.aws.amazon.com/vm-import/latest/userguide/vmie_prereqs.html#vmimport-role
  aws-create-vmimport-role = let
    policy = final.writeText "trust-policy.json" (builtins.toJSON {
      Version = "2012-10-17";
      Statement = [
        {
          Effect = "Allow";
          Principal.Service = "vmie.amazonaws.com";
          Action = "sts:AssumeRole";
          Condition.StringEquals."sts:Externalid" = "vmimport";
        }
      ];
    });
  in
    final.writeShellScriptBin "aws-create-vmimport-role" ''
      set -xe

      ${aws} iam create-role --role-name vmimport --assume-role-policy-document "file://${policy}"
    '';

  aws-put-vmimport-role-policy = let
    policy = final.writeText "role-policy.json" (builtins.toJSON {
      Version = "2012-10-17";
      Statement = [
        {
          Effect = "Allow";
          Action = [
            "s3:GetBucketLocation"
            "s3:GetObject"
            "s3:ListBucket"
          ];
          Resource = [
            "arn:aws:s3:::${buckets.vhd}"
            "arn:aws:s3:::${buckets.vhd}/*"
          ];
        }
        {
          Effect = "Allow";
          Action = [
            "s3:GetBucketLocation"
            "s3:GetObject"
            "s3:ListBucket"
            "s3:PutObject"
            "s3:GetBucketAcl"
          ];
          Resource = [
            "arn:aws:s3:::${buckets.ami}"
            "arn:aws:s3:::${buckets.ami}/*"
          ];
        }
        {
          Effect = "Allow";
          Action = [
            "ec2:ModifySnapshotAttribute"
            "ec2:CopySnapshot"
            "ec2:RegisterImage"
            "ec2:Describe*"
          ];
          Resource = "*";
        }
      ];
    });
  in
    final.writeShellScriptBin "aws-put-vmimport-role-policy" ''
      set -xe

      ${aws} iam put-role-policy --role-name vmimport --policy-name vmimport --policy-document "file://${policy}"
    '';

  aws-create-ami = final.writeShellScriptBin "aws-create-ami" ''
    export home_region="us-east-1"
    export bucket="profian-amis"
    export regions="us-east-1"

    ${nixpkgs}/nixos/maintainers/scripts/ec2/create-amis.sh ''${@}
  '';
in {
  inherit
    aws-create-ami
    aws-create-vmimport-role
    aws-put-vmimport-role-policy
    ;
}
