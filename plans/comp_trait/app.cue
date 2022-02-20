package app

app: {
  apiVersion: string
  kind: string
  metadata: {
    name: string
    namespace: string | *"default"
    ...
  }
  spec: {
    components: [...#Component]
    workflow: #Workflow
    ...
  }
  ...
}

#Component: {
  name: string
  type: string
  properties: _
  traits: [...#Trait]
  ...
}

#Trait: {
  type: string
  properties: _
  ...
}

#Workflow: {
  ...
}