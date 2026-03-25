## Step-by-Step Deployment

### 1. Create Builder Image

```bash
oc new-build https://github.com/<your-user>/split-build-demo.git \
  --name=builder-demo \
  --strategy=docker \
  --context-dir=builder
```

---

### 2. Create App Build

```bash
oc new-build https://github.com/<your-user>/split-build-demo.git \
  --name=app-demo \
  --strategy=docker
```

This will fail withy error:

```bash 
STEP 2/7: WORKDIR /app
--> ea50c7cd1e01
STEP 3/7: COPY /deps /usr/local
error: build error: building at STEP "COPY /deps /usr/local": checking on sources under "/tmp/build/inputs": copier: stat: "/deps": no such file or directory
```

---

The following pathc needed to fix to find the source image builder context.

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

### 6. Create Route

```bash
oc create route edge app-demo \
  --service=app-demo \
  --port=8080
```

---

### 7. Access Application

```bash
oc get route
```

Then:

```bash
curl https://<ROUTE_URL>; echo
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


