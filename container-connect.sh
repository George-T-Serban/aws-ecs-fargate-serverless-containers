#!/bin/bash
# Connect to a container for troubleshooting
aws ecs execute-command  \
    --region region \
    --cluster  cluster-name\
    --task arn\
    --container container-name\
    --command "/bin/bash" \
    --interactive
