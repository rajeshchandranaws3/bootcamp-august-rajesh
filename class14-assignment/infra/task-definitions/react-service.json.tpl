[
  {
    "name": "${container_name}",
    "image": "${aws_ecr_repository}:${tag}",
    "essential": true,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "us-east-1",
        "awslogs-stream-prefix": "${aws_cloudwatch_log_group_name}-service",
        "awslogs-group": "${aws_cloudwatch_log_group_name}"
      }
    },
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80,
        "protocol": "tcp",
        "name": "react",
        "appProtocol": "http"

      }
    ],
    "environment": [
      {
        "name": "ENV",
        "value": "${environment}"
      }
    ]
  }
]