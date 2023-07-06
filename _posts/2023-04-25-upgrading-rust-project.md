---
title: Upgrading a Rust Project
subtitle: Stepping through minor upgrade issues
tags: rust, cargo
---

I was having an issue when upgrading a Rust project from 1.46 to 1.65.
The motivation for the upgrade was only to have a working build for Mac M1/M2.

First, I started by just updating to the Rust version that I setup already
(that being version 1.65). I didn't want to downgrade or install multiple versions.

I poked around at build errors and googled if anyone had a similar issue.

Prior to upgrading, the project dependencies looked like this:

```
[dependencies]
dirs = "2.0.2"
docopt = "1"
port_scanner = "0.1.5"
rusoto_core = "0.44.0"
rusoto_credential="0.44.0"
rusoto_ec2_instance_connect="0.44.0"
rusoto_s3 = "0.44.0"
rusoto_opsworks = { version = "0.44.0", features = ["serialize_structs"] }
tokio = "0.2.21"
serde = { version = "1", features = ["derive"] }
serde_yaml = "0.8"
serde_json = "1.0"
ssh2 = "0.5"
```

After:

```
[dependencies]
dirs = "2.0.2"
docopt = "1"
port_scanner = "0.1.5"
rusoto_core = "0.48.0"
rusoto_credential="0.48.0"
rusoto_ec2_instance_connect="0.48.0"
rusoto_s3 = "0.44.0"
rusoto_opsworks = { version = "0.48.0", features = ["serialize_structs"] }
tokio = "0.2.21"
serde = { version = "1", features = ["derive"] }
serde_yaml = "0.8"
serde_json = "1.0"
ssh2 = "0.5"
```

After some flailing, I noticed that somehow in the upgrading of libraries
`rusoto_s3` didn't get bumped to 0.48.0, even though the other rusoto libraries
were bumped.

After changing that, now it builds.

New error means progress!

```
thread 'main' panicked at 'there is no reactor running, must be called from the context of a Tokio 1.x runtime',
.cargo/registry/src/github.com-1ecc6299db9ec823/hyper-0.14.26/src/client/connect/dns.rs:121:24
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
```

It looks like based off of this result we need to update to tokio 1.28.

> [Why do I get the error "there is no reactor running, must be called from the context of Tokio runtime"](https://stackoverflow.com/questions/64779920/why-do-i-get-the-error-there-is-no-reactor-running-must-be-called-from-the-con)

I also updated ssh2 to 0.9.4. I don't think I hit any errors here, just updating
to later versions to integrate changes and not need to do it later.

Final `Cargo.toml` dependencies.

```
[dependencies]
dirs = "2.0.2"
docopt = "1"
port_scanner = "0.1.5"
rusoto_core = "0.48.0"
rusoto_credential="0.48.0"
rusoto_ec2_instance_connect="0.48.0"
rusoto_s3 = "0.48.0"
rusoto_opsworks = { version = "0.48.0", features = ["serialize_structs"] }
tokio = "1.28"
serde = { version = "1", features = ["derive"] }
serde_yaml = "0.8"
serde_json = "1.0"
ssh2 = "0.9.4"
```

Build works and it's runnable!

This was my first time upgrading a Rust project to a new Rust version, I'm happy
to write that it was a relatively pain free experience after I got past the self
inflicted rusoto version mismatch.

## Resources

- [Why do I get the error "there is no reactor running, must be called from the context of Tokio runtime"](https://stackoverflow.com/questions/64779920/why-do-i-get-the-error-there-is-no-reactor-running-must-be-called-from-the-con)
