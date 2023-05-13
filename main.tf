resource "aws_elasticache_subnet_group" "subnet_group" {

  name       = "${var.env}-elasticache-subnet-group"
  subnet_ids = var.subnet_ids
  tags       = merge (local.common_tags, { Name = "${var.env}-elasticache_subnet_group" } )

}

resource "aws_security_group" "elasticache" {
  name        = "${var.env}-elasticache_security_group"
  description = "${var.env}-elasticache_subnet_group"
  vpc_id      = var.vpc_id


  ingress {
    description      = "elasticache"
    from_port        = 6379
    to_port          = 6379
    protocol         = "tcp"
    cidr_blocks      = var.allow_cidr

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge (local.common_tags, { Name = "${var.env}-elasticache_subnet_group" } )

}
#
#resource "aws_elasticache_replication_group" "elasticache" {
#  replication_group_id       = "${var.env}-elasticache-cluster"
#  description                = "${var.env}-elasticache-cluster"
#  node_type                  = var.node_type
#  port                       = 6379
#  automatic_failover_enabled = true
#  subnet_group_name          = aws_elasticache_subnet_group.subnet_group.name
#  security_group_ids         = [aws_security_group.elasticache.id]
#  num_node_groups            = var.num_node_groups
#  replicas_per_node_group    = var.replicas_per_node_group
#
#  tags                       = merge (local.common_tags, { Name = "${var.env}-elasticache_subnet_group" } )
#
#}

resource "aws_elasticache_cluster" "elastic_cache" {
  cluster_id           = "${var.env}-elasticache-cluster"
  engine               = "redis"
  node_type            = var.node_type
  num_cache_nodes      = var.num_cache_nodes
  engine_version       = var.engine_version
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.subnet_group.name
  security_group_ids   = [aws_security_group.elasticache.id]
  tags                 = merge (local.common_tags, { Name = "${var.env}-elasticache_subnet_group" } )

}


resource "aws_ssm_parameter" "elastic_point" {
  name  = "${var.env}.elastic_cache.endpoint"
  type  = "String"
  value = aws_elasticache_cluster.elastic_cache.cache_nodes[0].address
}