# Publishing a static website with goHugo.io and dagger.io

Example project demonstrating [Dagger.io](https://dagger.io) CI/CD pipelines by building
and optimizing a website with the [Hugo](https://gohugo.io) static site generator and
optimizing PNG images via pngquant.

This example was used for the introductory talk on dagger.io at the
[Technology Day 2022](https://www.innoq.com/en/talks/2022/11/ci-cd-pipelines-with-dagger-io/)

## Preparation

- Clone this repository
- Install a docker compatible engine (I successfully used
  [Rancher Desktop](https://rancherdesktop.io/))
- [Install the dagger-cue sdk](https://docs.dagger.io/sdk/cue/526369/install)
- Get some webspace, which you can access via ssh and a public/private key pair.
  - I can recommend [Uberspace](https://uberspace.de/en)
  - Create a dedicated key-pair for the deployment of the site without a passphrase): `ssh-keygen -N "" -q -f ~/.ssh/id_rsa_deploy`

## Change config and deploy your content

- Make sure the valid SSH private key lives under `~/.ssh/id_rsa_deploy` or adapt the path
- Adapt the remote configuration in `blog.cue` line 32
  ```
  remoteUser: "remote_user"
  remoteHost: "remote.host.local"
  remotePath: "/home/remote_user/html"
  ```
- Change and uncomment the baseUrl / host in the Hugo `config.toml` to generate correct internal links.
- Add / modify content for your site. Start at hugoContent/content/posts/hello/index.md

## Do the deployment

- `dagger-cue do deploy`
- Change some content and deploy again ...

