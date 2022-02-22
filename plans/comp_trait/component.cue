package app

#WebService: {
		image: string
		port:  int | *"80"
		cmd?: [...string]
}

#Component: {
	name: string
	traits: [...Trait]
	type: "webservice"
	properties: #WebService

	manifests: [{
		apiVersion: "apps/v1"
		kind:       "Deployment"
		metadata: {
			"name":    name
			namespace: app.metadata.namespace
			labels: "app.oam.dev/component": name
		}
		spec: {
			selector: matchLabels: "app.oam.dev/component": name
			template: {
				metadata: labels: "app.oam.dev/component": name

				spec: containers: [{
					"name": name
					image:  properties.image
					ports: [{
						containerPort: properties.port
					}]

					if properties["cmd"] != _|_ {
						command: properties.cmd
					}

					resources: {
						requests: {
							memory: "1Gi"
							cpu:    "500m"
						}
						limits: {
							memory: "2Gi"
							cpu:    "1000m"
						}
					}

					livenessProbe: {
						httpGet: {
							path: "/"
							port: properties.port
						}
						initialDelaySeconds: 3
						periodSeconds:       10
					}
				}]
			}
		}
	}]

	Trait: {
		type: "ingress"
		properties: {
			domain: string
			http: [string]: int
		}
		manifests: [{
			apiVersion: "v1"
			kind:       "Service"
			metadata: {
				"name":    name
				namespace: app.metadata.namespace
				labels: "app.oam.dev/component": name
			}
			spec: {
				selector: "app.oam.dev/component": name
				ports: [
					for k, v in properties.http {
						port:       v
						targetPort: v
					},
				]
			}
		}, {
			apiVersion: "networking.k8s.io/v1"
			kind:       "Ingress"
			metadata: {
				"name":    name
				namespace: app.metadata.namespace
				labels: "app.oam.dev/component":                           name
				annotations: "nginx.ingress.kubernetes.io/rewrite-target": "/"
			}
			spec: rules: [{
				host: properties.domain
				http: paths: [
					for k, v in properties.http {
						path:     k
						pathType: "Prefix"
						backend: service: {
							"name": name
							port: number: v
						}
					},
				]
			}]
		}]
	}
}
