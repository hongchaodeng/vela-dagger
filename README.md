# Vela Dagger

This project shows how to implement KubeVela operations in Dagger.

## Deploy Components and Traits

Save the following to `app.yaml`:

```yaml
apiVersion: core.oam.dev/v1beta1
kind: Application
metadata:
  name: demo
spec:
  components:
    - name: express-server
      type: webservice
      properties:
        image: crccheck/hello-world
        port: 8000
        # It will prompt error if you specify invalid properties:
        # invalid: "something"
      traits:
        - type: ingress
          properties:
            domain: testsvc.example.com
            http:
              "/": 8000
```

Setup dagger environment:

```shell
dagger init
dagger new test -p plans/comp_trait
```

Input user values:

```shell
dagger input yaml app -f app.yaml
dagger input secret kubeconfig -f ${KUBECONFIG}
```

Deploy the app:

```shell
dagger up
```

Output:

```shell
[✔] applyResources."express-server-Deployment-ingress-Ingress"
[✔] applyResources."express-server-Deployment"
[✔] applyResources."express-server-Deployment-ingress-Service"
```

Check the deployment:

```shell
kubectl get deploy
```

Output:

```shell
NAME             READY   UP-TO-DATE   AVAILABLE   AGE
express-server   1/1     1            1           4m17s
```

## Deploy Workflows

Save the following to `app.yaml`:

```yaml
apiVersion: core.oam.dev/v1beta1
kind: Application
metadata:
  name: first-vela-workflow
  namespace: default
spec:
  components:
  - name: express-server
    type: webservice
    properties:
      image: crccheck/hello-world
      port: 8000
  workflow:
    steps:
      - name: slack-msg-start
        type: notification
        properties:
          slack:
            # Slack Webhook：https://api.slack.com/messaging/webhooks
            url:
              secretRef:
                name: <the secret name that stores your slack url>
                key: <the secret key that stores your slack url>
            message:
              text: Workflow starts
      - name: application
        type: apply-application
      - name: slack-msg-finish
        type: notification
        properties:
          slack:
            # Slack Webhook：https://api.slack.com/messaging/webhooks
            url:
              secretRef:
                name: <the secret name that stores your slack url>
                key: <the secret key that stores your slack url>
            message:
              text: Workflow finishes
```
