# Workload scheduler

This component is responsible for distributing tasks among workloads. A pod with a pipeline acts as a workload.

The scheduler supports multi-tenant mode. Each client can create one or more applications. Each application can run only one type of pipeline. Workload scaling is provided independently for each application.

An example of creating an application with a pipeline:

```js
var application = {
    name: 'OCR',
    pipeline: {
        chart: 'https://github.com/RyazanovAlexander/application.ocr/tree/main/chart'
    }
};

http.post('http://localhost/application', application, function(res){
    // ...
});
```

When creating this application, a helm chart https://github.com/RyazanovAlexander/application.ocr/tree/main/chart will be deployed, which defines the following pipeline:

```yaml
{
  "commands": [
    {
      "executorName": "wget",
      "commandLines": [
        "wget -O /mnt/pipe/image.png {{URL}}"
      ]
    },
    {
      "executorName": "tesseract",
      "commandLines": [
        "tesseract /mnt/pipe/image.png /mnt/pipe/result",
        "cat /mnt/pipe/result.txt",
        "rm /mnt/pipe/result.txt"
      ]
    }
  ]
}
```

After successfully deploying the helm chart, we can send tasks for the pipelines through the workload scheduler:

```js
var data = {
    url: 'https://some-addr.com/pic.png'
};

http.post('http://localhost/application/ocr', data, function(res){
    // ...
});
```

Workload scheduler guarantees at least once delivery.