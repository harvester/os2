# Harvester Base OS
[![Dev/Daily Build and Publish](https://github.com/harvester/os2/actions/workflows/dev.yml/badge.svg)](https://github.com/harvester/os2/actions/workflows/dev.yml)

The base OS for Harvester, powered by cOS-toolkit.

# Branch

- **sle-micro**: means the development branch.
- **harvester-v1.2.x**: means the v1.2.x stable branch.
- **harvester-v1.1.x**: means the v1.1.x stable branch.

Mostly we will develop on the *sle-micro* branch and backport what we needed to the stable branch.

# How-Tos

## Update luet repository

We pinned the [luet repository version](./files/etc/luet/luet.yaml#L17) to ensure
the version of applications installed via luet remain intact if we only want to upgrade OS.
To update the repository:

1. Visit http://quay.io/costoolkit/releases-green
2. Filter tags with `-repository.yaml`
3. Look for the tag with the latest date, e.g. `20220420151313-repository.yaml`
4. Update [luet repository version](./files/etc/luet/luet.yaml#17) with this tag
5. Build the Base OS container with `./scripts/build`, and the container should have used the repository you specified

If you already have a working Base OS container but you are not sure which repository
it is using, verify its luet "Revision" by running command `luet repo list`:
```
cos
  cOS official
  Revision 287 - 2022-04-20 15:13:13 +0000 UTC
```

After you pinned the repository, run command `luet repo update`, and you will see the revision of the pinned repository:
```
 INFO    Downloading  quay.io/costoolkit/releases-green:20220302065613-repository.yaml
 INFO    Pulled: sha256:ea6279031433166ad887d6922d73f5d42205377b504d827b7fb92a886c4f23cc
 INFO    Size: 673B
 INFO    Downloading  quay.io/costoolkit/releases-green:20220302065613-tree.tar.zst
 INFO    Pulled: sha256:1428d9ae9d6b6d366a00238f37831a8702c4b1a4fef36d22788fcb913373649d
 INFO    Size: 16.26KiB
 INFO    Downloading  quay.io/costoolkit/releases-green:20220302065613-repository.meta.yaml.tar.zst
 INFO    Pulled: sha256:d88c69469efa442bf19c6a470fa89dfc369ca4eaf997209adfc4fd07b2813eb2
 INFO    Size: 1008KiB
 INFO     Repository cOS revision: 250 (2022-03-02 0613 +0000 UTC)
 INFO     Repository: cos Priority: 1 Type: docker
```

If two revision numbers are identical, it means you have pinned the correct repository version.

## Build on local

On the os2 folder, use the following command
``` bash
 # ./scripts/build
```

You will see the following result.
``` text
Successfully tagged rancher/harvester-os:20221230-b655b96-dirty
```

The `rancher/harvester-os:20221230-b655b96-dirty` is the local image you want.