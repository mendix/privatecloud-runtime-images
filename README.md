# Private Cloud runtime images

This repository contains reference Dockerfiles used by the Mendix Operator to build an image of a Mendix app.

This repository can be cloned to create custom base images.

**Note**: these images are intended to be used by the Mendix Operator from the Mendix Private Cloud offering. An external component, the m2ee sidecar, is required to actually initialize and start an app. For running Mendix apps in a standalone configuration, the [Docker Mendix Buildpack](https://github.com/mendix/docker-mendix-buildpack) should be used.

## Details

### Base Image

The base image contains the Mendix Runtime and all dependencies required to build and run it.

Currently, there are two types of base images:

* `rhel` (based on [Red Hat Universal Base Image 8 Minimal](https://access.redhat.com/containers/#/registry.access.redhat.com/ubi8/ubi-minimal))

A base image can be shared across multiple Mendix App images, helping to reduce build time and space usage.

To build a base image, run:

```
docker build -t mendix/runtime-base:<mendix runtime version>-<distro> -f base/<distro>/<java version>.dockerfile base/<distro> --build-arg MX_VERSION=<mendix runtime version>
```

using the following parameters:

| Parameter              | Possible values |
|-|-|
| distro                 | rhel |
| java version           | openjdk8 (Mendix 7.23.\*)<br>openjdk11 (Mendix 8.\*) |
| mendix runtime version | any released Mendix version (7.23.0.46034 and above) |

Example: 

```
docker build -t mendix/runtime-base:7.23.3.48173-rhel -f base/rhel/openjdk8.dockerfile base/rhel --build-arg MX_VERSION=7.23.3.48173
```

These images are built and published to the `private-cloud.registry.mendix.com/runtime-base` repository on a regular basis.
