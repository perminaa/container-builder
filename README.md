# Singularity Builder Circle-CI

![.circleci/sregistry-circle.png](.circleci/sregistry-circle.png)

This is a simple example of how you can achieve:

 - version control of your recipes
 - versioning to include image hash *and* commit id
 - build of associated container and
 - push to a storage endpoint

for a reproducible build workflow. Specifically, this example will use a *single repository*
as a base to build *multiple containers* and push to a shared [Singularity Registry Server](https://www.github.com/singularityhub/sregistry) based on the namespace organization.

**Why should this be managed via Github?**

Github, by way of easy integration with continuous integration, is an easy way
to have a workflow set up where multiple people can collaborate on a container recipe,
the recipe can be tested (with whatever testing you need), discussed in pull requests,
and then finally pushed to your storage of choice or Singularity Registry. 
Importantly, you don't need to give your entire team manager permissions 
to the registry. An encrypted credential that only is accessible to 
administrators can do the push upon merge of a discussed change.

**Why should I use this instead of a service?**

You could use a remote builder, but if you do the build in a continuous integration
service you get complete control over it. This means everything from the version of
Singularity to use, to the tests that you run for your container. You have a lot more
freedom in the rate of building, and organization of your repository, because it's you
that writes the configuration. Although the default would work for most, you can 
edit the build, setup, and circle configuration file in the 
[.circleci](.circleci) folder to fit your needs.

## Quick Start

The [circle-ci-sregistry](https://github.com/singularityhub/circle-ci-sregistry) repository is 
an example repository that will allow you to store multiple recipes within, and then deploy
to a [Singularity Registey Server](https://www.github.com/singularityhub/sregistry).
We use CircleCI to build and push to your Singularity Registry. You have the freedom
to store as many recipes in one repository as you please, with the understanding that one
repository maps to one builder on CircleCI (in terms of time allowed). However, you should
also realize that since the build and deploy happens with pull requests, you can have the bulids
going in parallel (up to the time limit, of course). You are also free to have multiple repositories
to deploy separate containers, but you would then need to ensure that the namespaces (the folders 
named inside that map to collection names) do not overlap.

### 1. Setup

To deploy this template for your registry you can:

 - Fork or download [singularityhub/circle-ci-sregistry](https://www.github.com/singularityhub/circle-ci-sregistry) to your own GitHub account. Since the container namespace comes from the folders within, the name of the repository itself is not incredibly important. 
 - [Connect your repository](https://circleci.com/docs/2.0/getting-started/#setting-up-your-build-on-circleci) to CircleCI

### 2. Adding Containers

How does building work? Each folder represents a namespace. For example, the folder `vanessa/greeting` maps to a container collection `vanessa/greeting`. 

#### Add a New Container

This means that to add a new container collection namespace, just create a folder for it.

```bash
$ mkdir -p vanessa/greeting
```

How do tags work? The tags within the folder correspond to the tags for the container namespace. For example, here
is how to create the tag "pancakes" for the container collection "vanessa/greeting." 

```bash
$ touch vanessa/greeting/Singularity.pancakes
```

The Singularity file without any tags maps to the tag "latest"

```bash
$ touch vanessa/greeting/Singularity
```

That's it! Write your recipe there, and then open a pull request to build the container. Once the container is built, you need to approve the Hold in the continuous integration, and then the container will be pushed.
Merging (or generally pushing to master) doesn't do any deployment. All deployments must happen
through this pull request and approve process.

#### Freezing a Container

If you don't want a container collection to build, just put a .frozen file in the collection folder.
If you want to freeze the entire collection namespace, just put the .frozen file:

```bash
touch vanessa/greeting/.frozen
```

If you want to freeze a particular container, add an equivalently named empty file with frozen as
an extension.

```bash
touch vanessa/greeting/Singularity.pancakes.frozen
```

It's a very manual way of doing it, but importantly, the status of your building is
reflected in the repository (version controlled!).

#### Custom Build for a Container

If you want to custom build a container, just add a build.sh file to the directory with the recipe.
It will be used instead of the default build.sh provided with the repository.

### 3. Connect to CircleCI

If you go to your [Circle Dashboard](https://circleci.com/dashboard) you can usually select a Github organization (or user) and then the repository, and then click the toggle button to activate it to build on commit --> push.

### 4. CircleCI Environment

In order to communicate with your Singularity Registry Server, you should generate a
token (a credential to push) in your $HOME/.sregistry file. Then you should add the entire
contents of this file to an encrypted CircleCI environment variable (just copy paste in the entire thing)

```
cat $HOME/.sregistry
```

write this to the environment variable `SREGISTRY_SECRETS` in CircleCI.
 
That should be it! You should then open pull requests to build containers,
and then approve the Holds in the CircleCI interface to push to your registry.
If you are interested in learning more about CircleCI (extra features!) continue
reading below.


### Extra: Get to Know CircleCi

As we are working with [Circle CI](https://www.circleci.com), here are some other features
that might be of interest.

 - Circle offers [scheduled builds](https://support.circleci.com/hc/en-us/articles/115015481128-Scheduling-jobs-cron-for-builds-).
 - CircleCI also offers [GPU Builders](https://circleci.com/docs/enterprise/gpu-configuration/) if you want/need that sort of thing.
 - If you don't want to use the [sregistry](https://singularityhub.github.io/sregistry-cli) to push to Google Storage, Drive, Globus, Dropbox, or your personal Singularity Registry, CircleCI will upload your artifacts directly to your [deployment](https://circleci.com/docs/2.0/deployment-integrations/#section=deployment) location of choice.
