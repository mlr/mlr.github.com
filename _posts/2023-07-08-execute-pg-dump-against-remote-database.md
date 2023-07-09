---
title: Execute pg_dump against a remote database
tags: postgresql, ssh, tunnel, runbook
---

You may run into a situation where you need to grab a backup of a remotely
running database which is not accessible to the public internet.

You can do this by using a jump host, or bastion host, to connect via an SSH
tunnel to the remote database.

To perform a PostgreSQL database backup using pg_dump through an SSH tunnel to a jump host,
follow these steps:

1. Open an SSH connection on the security group:

    - Log in to the AWS Management Console.
    - Go to the EC2 service and select the security group associated with the jump host instance.
    - Edit the inbound rules and add a new rule for SSH (TCP, port 22) with the appropriate source (your IP address or IP range).
    - Save the changes.

2. Establish an SSH tunnel to the jump host:

    - Open your local terminal.
    - Execute the following command:

    ```
    ssh -f -N -L <local_port>:<postgres_host>:<postgres_port> \
        <jump_host_username>@<jump_host_ip>
    ```

    `-f -N` will background the command and will not execute a remote command,
    so you aren't given a shell. The tunnel will open and remain running until
    it is stopped.

    `-L` and the options that follow specify the tunnel local port, remote host, and remote port.

    - Replace `<local_port>` with a local port number (e.g., 5433) where the PostgreSQL connection will be forwarded.
    - Replace `<postgres_host>` with the hostname or IP address of the PostgreSQL server.
    - Replace `<postgres_port>` with the port number used by the PostgreSQL server (default: 5432).
    - Replace `<jump_host_username>` with the username for the jump host.
    - Replace `<jump_host_ip>` with the IP address or hostname of the jump host.
    - Enter the jump host password when prompted.

3. Perform the pg_dump backup:

    - Open a new terminal session.
    - Execute the following command:

    ```
    pg_dump -h localhost -p <local_port> -U <postgres_username> -W \
        -f <backup_file_name.sql> <database_name>
    ```

    - Replace `<local_port>` with the same local port number used in the previous step.
    - Replace `<postgres_username>` with the username for the PostgreSQL server.
    - Replace `<backup_file_name.sql>` with the desired name of the backup file (include the .sql extension).
    - Replace `<database_name>` with the name of the database you want to back up.
    - Enter the PostgreSQL user's password when prompted.
    - Wait for the backup process to complete.

Remember to close the SSH tunnel and remove the security group rule after completing the backup.

Assuming `5433` was used for the tunnel port, you can use this command to close
the tunnel:

```
kill -9 $(lsof -i :5433 | tail -n 1 | awk -F' ' '{print $2}')
```
