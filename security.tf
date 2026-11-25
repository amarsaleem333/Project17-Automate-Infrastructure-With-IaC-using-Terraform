# Security Group for External Application Load Balancer
resource "aws_security_group" "ext-alb-sg" {
  name        = "ext-alb-sg"
  description = "Allow inbound external traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "ext-alb-sg" })
}

# Security Group for Nginx / Web Tier
resource "aws_security_group" "web-sg" {
  name        = "web-sg"
  description = "Allow HTTP from External ALB to Nginx web tier"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP from External ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.ext-alb-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "web-sg" })
}

# Security Group for Internal Application Load Balancer
resource "aws_security_group" "int-alb-sg" {
  name        = "int-alb-sg"
  description = "Allow inbound internal traffic from web tier"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP from Web Tier"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "int-alb-sg" })
}

# Security Group for Application Tier
resource "aws_security_group" "app-sg" {
  name        = "app-sg"
  description = "Allow HTTP from Internal ALB to application tier"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP from Internal ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.int-alb-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "app-sg" })
}

# Security Group for Data Layer (RDS and EFS)
resource "aws_security_group" "datalayer-sg" {
  name        = "datalayer-sg"
  description = "Allow MySQL and NFS traffic only from application tier"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow MySQL traffic from App Tier"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app-sg.id]
  }

  ingress {
    description     = "Allow NFS/EFS traffic from App Tier"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.app-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "datalayer-sg" })
}
