# azure-arm-dump
Dump all your Azure subscriptions into ARM exports that could be used as archived

## Build
```
docker build -t azure-arm-dump  .
```

## Run
```
docker run -it -v ~/output:/output azure-arm-dump
```

