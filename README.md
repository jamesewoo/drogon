# drogon
Drogon simplifies the usage of Apache Joshua by providing Docker images with Joshua and all of its dependencies. Simply pull the latest runtime container from Docker Hub, and you're ready to get started.
```bash
docker run -it jwoo11/drogon:runtime
```

The above command drops you into a container in which `$JOSHUA` is installed at `/opt/joshua`. You can now train models as usual using the [Joshua pipeline](https://cwiki.apache.org/confluence/pages/viewpage.action?pageId=65871630). If your data is on the host machine, you can make it accessible to the container by mounting a volume:
```bash
docker run -it -v /path/to/data:/data jwoo11/drogon:runtime
```

If you don't have a model readily available, you can play with the test image, which includes a Spanish-English model trained on the [Fisher and CALLHOME dataset](https://github.com/joshua-decoder/fisher-callhome-corpus). Running the following command sends the test data through the translation engine. It takes a while to run, but it can be interrupted at any time with `Ctrl+C`.
```bash
docker run -it jwoo11/drogon:test
```

You can execute commands in the container by appending them to the run command as follows:
```bash
docker run -it jwoo11/drogon:test bash
```
This command drops you into the container, where you can see the trained model `/models/es-en/1/test/model` along with the associated dataset `/models/es-en/1/data` and language pack `/models/es-en/releases/`.
