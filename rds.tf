resource "aws_db_subnet_group" "acs-rds" {
  count       = var.enable_pro_services ? 1 : 0
  name        = "acs-rds"
  subnet_ids  = [aws_subnet.private[2].id, aws_subnet.private[3].id]
  tags        = merge(var.tags, { Name = "ACS-DB-Subnet-Group" })
}

resource "aws_db_instance" "acs-rds" {
  count                  = var.enable_pro_services ? 1 : 0
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  db_name                = "wordpress"
  username               = var.master-username
  password               = var.master-password
  db_subnet_group_name   = aws_db_subnet_group.acs-rds[0].name
  vpc_security_group_ids = [aws_security_group.datalayer-sg.id]
  skip_final_snapshot    = true
  tags                   = merge(var.tags, { Name = "ACS-RDS-MySQL" })
}