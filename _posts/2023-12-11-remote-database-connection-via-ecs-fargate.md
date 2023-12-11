---
title: Remote Database Connection via ECS Fargate
description: Learn how to set up IAM permissions and use ecsta for port forwarding to connect to a remote database via ECS for backup or local development.
keywords: IAM Permissions, ECS, ecsta, Port Forwarding, Remote Database, Backup, Local Development
tags: AWS, ECS Fargate, SSM
---

In [a previous
post](/2023/07/08/execute-pg-dump-against-remote-database/)
I wrote about using an SSH tunnel to perform a `pg_dump` on a remote database.
One issue with that approach is it requires modifying the security group of an
EC2 instance to allow SSH traffic and act as the bastion or jump host.

That can be a hassle and potentially not allowed for security reasons.

Another shortcoming of this approach is it doesn't really work well with ECS
where the IP address of your bastion or jump host may not be very static.

Luckily the same thing can be accomplished using AWS Systems Manager.

## Assumptions

1. You have a task that connects to an RDS database (in this case MySQL)
1. You are running ECS Fargate on Platform version 1.4 or greater (This version comes preconfigured with ECS exec)

## Setup IAM Permissions

Create an IAM policy with the below permissions and attach it to a user or
profile you use locally.

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ssm:StartSession"
            ],
            "Resource": [
                "arn:aws:ssm:*::document/AWS-StartPortForwardingSessionToRemoteHost",
                "arn:aws:ssm:*::document/AWS-StartPortForwardingSession",
                "arn:aws:ecs:*:*:task/*"
            ]
        }
    ]
}
```

## Use ecsta for Port Forwarding

You can use the AWS CLI directly, but [ecsta](https://github.com/fujiwara/ecsta)
is a useful tool for other ECS tasks and makes it a little bit easier to specify
the task to forward through.

Install ecsta using Homebrew:

```
brew install fujiwara/tap/ecsta
```

Run the following command to start port forwarding:

```
ecsta portforward
    --local-port=3307 \
    --remote-port=3306 \
    --remote-host [DATABASE_URL] \
    --cluster [ECS_CLUSTER] \
    --container [CONTAINER_NAME] \
    --id $(aws --profile [AWS_PROFILE] ecs list-tasks --cluster [ECS_CLUSTER] --service-name [ECS_SERVICE] | jq -r '.taskArns[0] | split("/") | last')
```

1. `local-port` is the port you want to connect to locally when using the tunnel.
1. `remote-port` is the port you want to connect to via the port forward.
1. `remote-host` is the host name you want to connect to via the port forward.
1. `cluster` is the name of your ECS cluster.
1. `container` is the name of the container with database connectivity.
1. `id` is the ID of the task with connectivity to the database. Here we're
   using the AWS CLI and jq to grab the ID for us.

Replace the bracketed items with your values:

1. `[DATABASE_URL]` is the URL of your RDS database.
1. `[ECS_CLUSTER]` is the name of your ECS cluster.
1. `[CONTAINER_NAME]` is the name of the container with database connectivity.
1. `[AWS_PROFILE]` is the name of the profile you have configured in
   `~/.aws/credentials` with ECS permissions and the IAM policy we added earlier.
1. `[ECS_SERVICE]` is the name of the ECS service that your task is part of.

After running the ecsta command you should see something like the following:

    Starting session with SessionId: default-001d9e8b8f35cebb3
    Port 3307 opened for sessionId default-001d9e8b8f35cebb3.
    Waiting for connections...

You're ready to connect via the port forward.

## Connect to the Database

Use a database client to connect to the port-forwarded port (in this case 3307).

```
mysql -u [USERNAME] -h 127.0.0.1 -P 3307 -p [DATABASE_NAME]
```

## Run application using the remote database

Alternatively, you can also use this approach to run your application locally while connected to the remote database:

```
DATABASE_URL=mysql2://USER:PASSWORD@127.0.0.1:3307/my_database_name bundle exec rails s -p 3000
```

Adapt the commands and parameters according to your specific setup and requirements.

Happy coding!

### Resources

* [ecsta - The ECS Task Assistant](https://github.com/fujiwara/ecsta)
* [Securely connect to an Amazon RDS using ECS Fargate as a bastion](https://zenn.dev/quiver/articles/d01aa276eded6d)
* [Port Forwarding Using AWS System Manager Session Manager](https://aws.amazon.com/blogs/aws/new-port-forwarding-using-aws-system-manager-sessions-manager/)
