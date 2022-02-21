package app

app: {
	apiVersion: string
	kind:       string
	metadata: {
		name:      string
		namespace: string | *"default"
		...
	}
	spec: {
		components: [...Component]
		...
	}
	...
}
