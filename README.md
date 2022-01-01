# Workload Scheduler

![scheduler](diagrams/scheduler.png)

This component is responsible for distributing tasks among workloads. A pod with a pipeline acts as a workload.

The scheduler supports multi-tenant mode. Each client can create one or more applications. Several pipelines can be deployed within one application. Workload scaling is provided independently for each deployed pipeline.

An example of creating a pipeline for application:

```js
var pipeline = {
    name: 'ocr',
    chart: 'https://github.com/RyazanovAlexander/application.ocr/tree/main/chart'
};

http.post('http://localhost/api/applications/myname/pipelines', application, function(res){
    // ...
});
```

When creating this pipeline, a helm chart https://github.com/RyazanovAlexander/application.ocr/tree/main/chart will be deployed, which defines the following pipeline:

```yaml
{
  "commands": [
    {
      "executorName": "wget",
      "commandLines": [
        "wget -O /mnt/pipe/image.png {{url}}"
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

http.post('http://localhost/api/applications/myname/pipelines/ocr', data, function(res){
    // ...
});
```

For each pipeline, a Topic is created in a Kafka, which, in turn, is divided into several Partitions. All events from partitions are loaded using a forwarder into the scheduler of the corresponding pipeline type. The scheduler stores a dictionary of running tasks with their statuses. Dictionary with tasks is saved to the [TiDB](https://github.com/pingcap/tidb) database every few seconds. Scheduler guarantees at least once delivery.

Workers with pipelines periodically poll the scheduler about the availability of tasks for them. When a task is executed, the worker reports the pipeline execution statuses and the result to the scheduler. All communication is done through gRPC.
