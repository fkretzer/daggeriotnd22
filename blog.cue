package blog

import (
	"dagger.io/dagger"
)

dagger.#Plan & {
	client: {
		filesystem: {
			"./hugoContent": read: {
				contents: dagger.#FS
				exclude: [".DS_Store"]
			}
			"~/.ssh/id_rsa_deploy": read: contents: dagger.#Secret
		}
	}
	actions: {
		// run PNGs through pngquant
		optimize: #OptimizePNG & {
			speed: 3
			contents: client.filesystem."./hugoContent".read.contents
		}
		// build site using goHugo
		run: #Run & {
			hugoSource: optimize.output
		}
		// deploy via rsync
		deploy: #RsyncDeploy & {
			folderToDeploy: run.output

			remoteUser: "remote_user"
			remoteHost: "remote.host.local"
			remotePath: "/home/remote_user/html"

			privateKey: client.filesystem."~/.ssh/id_rsa_deploy".read.contents
		}

	}
}