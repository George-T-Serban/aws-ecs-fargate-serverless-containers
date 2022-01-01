aws ecs execute-command  \
    --region us-east-1 \
    --cluster  cluster-name\
    --task arn\
    --container container-name\
    --command "/bin/bash" \
    --interactive
