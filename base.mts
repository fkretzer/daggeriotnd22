import Client, {Container, Directory} from "@dagger.io/dagger";

export interface AlpinePackage {
    name: string
}

export function alpineContainer(client: Client, packages: AlpinePackage[]): Container {
    let packagesString: string[] = packages.map(alpinePackage => alpinePackage.name)
    return client.pipeline("alpineBaseImage")
        .container().from("instrumentisto/rsync-ssh:alpine3.16")
        .withExec(["apk", "add", "-U", "--no-cache", ...packagesString])

}

export function pngQuantContainer(client: Client): Container {
    return alpineContainer(client, [{name: "bash"}, {name: "pngquant"}])

}

export function getPngQuantImages(client: Client, directory: Directory) {
    return pngQuantContainer(client.pipeline("images"))
        .withDirectory("/workdir", directory)
        .withExec(["bash", "-c", "find /workdir -name \"*.png\" -exec /usr/bin/pngquant --quality=65-80 -v --ext .png -f --speed 1 {} \\;"])
        .directory("/workdir");
}