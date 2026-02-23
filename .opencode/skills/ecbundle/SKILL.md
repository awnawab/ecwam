---
name: ecbundle
description: How to build ecWAM using the ecbundle package manager
---

ecbundle
------

ecbundle is a very basic package manager. All of the dependencies of a project are specified in a bundle.yml, with their versions
and cmake options. To build a project, all of the dependencies are first downloaded, then packaged into one super cmake project
that is eventually built. A checkout of ecbundle is stored in package/bundle, and package/bundle/ecwam-bundle script is the entry point.
Typically, a bundle build has three main steps:

1. create - download all dependencies specified in bundle.yml to source/
2. populate - download configure time dependencies, e.g. python wheels. The user can also specify options during this step,
   exposed via populate_options in the bundle.yml.
3. build - build the package. CMake options are exposed in bundle.yml, additional cmake flags can also be set via --cmake="".
   The cmake_build_type is specified via --build-type=<build-type>. By default, bit is used. the use of the ninja generator is enabled
   via --ninja
