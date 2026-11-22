# create elastic file system (Pro feature - wrapped)
resource "aws_efs_file_system" "ACS-efs" {
  count      = var.enable_pro_services ? 1 : 0
  encrypted  = true
  kms_key_id = aws_kms_key.ACS-kms.arn

  tags = merge(
    var.tags,
    {
      Name = "ACS-efs"
    },
  )
}

# set up target mounts for the private subnets (wrapped, referencing [0])
resource "aws_efs_mount_target" "target-1" {
  count           = var.enable_pro_services ? 1 : 0
  file_system_id  = aws_efs_file_system.ACS-efs[0].id
  subnet_id       = aws_subnet.private[0].id
  security_groups = [aws_security_group.datalayer-sg.id]
}

resource "aws_efs_mount_target" "target-2" {
  count           = var.enable_pro_services ? 1 : 0
  file_system_id  = aws_efs_file_system.ACS-efs[0].id
  subnet_id       = aws_subnet.private[1].id
  security_groups = [aws_security_group.datalayer-sg.id]
}

# create efs access point for wordpress (wrapped, referencing [0])
resource "aws_efs_access_point" "wordpress" {
  count          = var.enable_pro_services ? 1 : 0
  file_system_id = aws_efs_file_system.ACS-efs[0].id

  posix_user {
    gid = 33
    uid = 33
  }

  root_directory {
    path = "/wordpress"
    creation_info {
      owner_gid   = 33
      owner_uid   = 33
      permissions = "0755"
    }
  }
}

# create efs access point for tooling (wrapped, referencing [0])
resource "aws_efs_access_point" "tooling" {
  count          = var.enable_pro_services ? 1 : 0
  file_system_id = aws_efs_file_system.ACS-efs[0].id

  posix_user {
    gid = 33
    uid = 33
  }

  root_directory {
    path = "/tooling"
    creation_info {
      owner_gid   = 33
      owner_uid   = 33
      permissions = "0755"
    }
  }
}