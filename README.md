# Private Cloud runtime images

This repository contains reference Dockerfiles used by the Mendix Operator to build an image of a Mendix app.

This repository can be cloned to create custom base images.

**Note**: these images are intended to be used by the Mendix Operator from the Mendix Private Cloud offering. An external component, the m2ee sidecar, is required to actually initialize and start an app. For running Mendix apps in a standalone configuration, the [Docker Mendix Buildpack](https://github.com/mendix/docker-mendix-buildpack) should be used.

## Details

### Base Image

The base image contains the Mendix Runtime and all dependencies required to build and run it.

Currently, there are two types of base images:

* `rhel` (based on [Red Hat Universal Base Image 8 Minimal](https://access.redhat.com/containers/#/registry.access.redhat.com/ubi8/ubi-minimal))
* `bionic` (based on [adoptopenjdk/openjdk8](https://hub.docker.com/r/adoptopenjdk/openjdk8) for Mendix 7 and [adoptopenjdk/openjdk11](https://hub.docker.com/r/adoptopenjdk/openjdk11) for Mendix 8)

A base image can be shared across multiple Mendix App images, helping to reduce build time and space usage.

To build a base image, run:

```
docker build -t mendix/runtime-base:<mendix runtime version>-<distro> -f base/<distro>/<java version>.dockerfile base/<distro> --build-arg MX_VERSION=<mendix runtime version>
```

using the following parameters:

| Parameter              | Possible values |
|-|-|
| distro                 | rhel<br>bionic  |
| java version           | openjdk8 (Mendix 7.23.\*)<br>openjdk11 (Mendix 8.\*) |
| mendix runtime version | any released Mendix version (7.23.0.46034 and above) |

Example: 

```
docker build -t mendix/runtime-base:7.23.3.48173-rhel -f base/rhel/openjdk8.dockerfile base/rhel --build-arg MX_VERSION=7.23.3.48173
```

These images are built and published to the [mendix/runtime-base](https://hub.docker.com/r/mendix/runtime-base) repository on a regular basis.

### Mendix App Dockerfile

Once the base images are ready for use, a Mendix App image can be built. This process is done automatically by the Mendix Operator when it is deploying a new Mendix App MDA.

Internally, the operator will
1. Download the MDA
2. Extract the MDA
3. Add the extracted MDA contents on top of the base image

The Mendix Operator can be configured to use a custom Dockerfile for building a Mendix App. For more information, refer to the Mendix Operator documentation.

Two base images are provided by Mendix, they're identical in everything exept the base image: [bionic.dockerfile](apps/bionic.dockerfile) is based on the `bionic` base image, while [rhel.dockerfile](apps/rhel.dockerfile) is based on the `rhel` base image.

The URLs which can be used in the Mendix Operator are:
- https://raw.githubusercontent.com/mendix/privatecloud-runtime-images/v1.0.0/app/bionic.dockerfile
- https://raw.githubusercontent.com/mendix/privatecloud-runtime-images/v1.0.0/app/rhel.dockerfile
