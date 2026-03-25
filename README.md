## Step-by-Step Deployment

### 1. Create Builder Image

```bash
oc new-build https://github.com/<your-user>/split-build-demo.git \
  --name=builder-demo \
  --strategy=docker \
  --context-dir=builder
```

Run build:

```bash
oc start-build builder-demo --follow
```

---

### 2. Create App Build

```bash
oc new-build https://github.com/<your-user>/split-build-demo.git \
  --name=app-demo \
  --strategy=docker
```

---

### 3. Connect Builder → App (Cache Reuse)

```bash
oc patch bc app-demo --type='merge' -p '{
  "spec": {
    "source": {
      "images": [
        {
          "from": {
            "kind": "ImageStreamTag",
            "name": "builder-demo:latest"
          },
          "paths": [
            {
              "sourcePath": "/deps",
              "destinationDir": "."
            }
          ]
        }
      ]
    }
  }
}'
```

---

### 4. Build App

```bash
oc start-build app-demo --follow
```

---

### 5. Deploy Application

```bash
oc new-app --image-stream=app-demo:latest --name=app-demo
```

```bash
oc expose deployment app-demo --port=8080
```

---

### 6. Expose Route

```bash
oc expose svc app-demo
```

---

### 7. Access Application

```bash
oc get route
```

Then:

```bash
curl http://<ROUTE_URL>; echo
```

---

## Expected Output

```
Hello from split build
```

---

## Debug Commands

```bash
oc logs -f build/app-demo-1
oc get pods
oc describe pod <pod-name>
```


