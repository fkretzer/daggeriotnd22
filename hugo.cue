package blog

import (
	"dagger.io/dagger"
	"universe.dagger.io/docker"
	"universe.dagger.io/alpine"
)

#Run: {
	hugoSource: dagger.#FS

	_pullHugo: docker.#Pull & {
		source: "klakegg/hugo:0.101.0"
	}

	_build: docker.#Run & {
		input: _pullHugo.output
		command: {
			name: "-s"
			args: [".", "-d", "/output"]
		}

		mounts: {
			"hugo sources": {
				contents: hugoSource
				dest:     "/src"
			}
		}
		export: {
			directories: "/output": _
		}
	}

	output: _build.export.directories."/output"
}

#RsyncDeploy: {

	folderToDeploy:  dagger.#FS

	remoteUser: string
	remoteHost: string
	remotePath: string
	remotePort: int | *22

	//SSH private key for deployment
	privateKey: dagger.#Secret

	_pullSshRsync: docker.#Pull & {
		source: "instrumentisto/rsync-ssh:alpine3.16"
	}

	deploy: docker.#Run & {
		input: *_pullSshRsync.output | docker.#Image

		mounts: {
			"generated site": {
				contents: folderToDeploy
				dest:     "/mnt"
			}
			"ssh key": {
				dest:     "/id_rsa"
				contents: privateKey
			}
		}

		command: {
			name: "rsync"
			args: [
				"/mnt/",
				"\(remoteUser)@\(remoteHost):\(remotePath)",
			]
			flags: {
				"-avz":                true
				"--delete":            true
				"--exclude=.DS_Store": true
				"-e":                  "/usr/bin/ssh -p \(remotePort) -i /id_rsa -o StrictHostKeyChecking=no"
			}
		}
	}
}

#OptimizePNG: {
	//contents to scan for png images to optimize
	contents: dagger.#FS

	speed: >= 1 & <= 10 | *3
	quality: {
		min: >=0 & <= 100 | *65
		max: >=0 & <= 100 | *80
	}

	_build: alpine.#Build & {
				packages: {
					bash: {}
					pngquant: {}
				}
			}

	_copySource: docker.#Copy & {
		input: _build.output
		"contents": contents
		dest: "/workdir"
	}

	optimize: docker.#Run & {
		input: _copySource.output

		command: {
			name :"bash"
			args: []
			"flags": {
				"-c": "find /workdir -name *.png -exec /usr/bin/pngquant --quality \(quality.min)-\(quality.max) -v --ext .png -f --speed \(speed) {} \\;"
			}
		}
		export: directories: "/workdir": _
	}
	output: optimize.export.directories."/workdir"
}
