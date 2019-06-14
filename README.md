# drogon
Drogon simplifies the installation of Apache Joshua by providing prebuilt Docker images with Joshua and all of its dependencies. Simply pull the latest runtime container from Docker Hub, and you're ready to get started with training new models.
```bash
docker run -it jwoo11/drogon:runtime
```

A test image is also provided which includes a pretrained Spanish to English model.
```bash
docker run -it jwoo11/drogon:test
```
