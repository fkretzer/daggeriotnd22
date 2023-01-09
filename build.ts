import Client, { connect } from "@dagger.io/dagger"
// initialize Dagger client
connect(async (client: Client) => {
    const hugoSrcDir = client.host().directory("./hugoContent")
    const hugo = await client
        .container()
        .from("klakegg/hugo:0.101.0")
        .withMountedDirectory("/src", hugoSrcDir)
        .withExec(["-s",".","-d","/output"])
        .directory("/output")
        .export("./html")
})