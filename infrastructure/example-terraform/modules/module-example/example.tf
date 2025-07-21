resource "aws_cloudwatch_log_group" "example_lg" {
  name = "/ecs/cluster-lg"
}

resource "aws_ecs_cluster" "example_cluster" {
  name = "cluster"
}


