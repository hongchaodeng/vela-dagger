package app

import (
	"encoding/yaml"

	"alpha.dagger.io/dagger"
	"alpha.dagger.io/kubernetes"
)

// set with `dagger input secret kubeconfig -f "$HOME"/.kube/config`
kubeconfig: {dagger.#Secret} & dagger.#Input

// The resources to apply
applyResources: {
	for i, c in app.spec.components {
		for ii, cm in c.manifests {
			"\(c.name)-\(cm.kind)": kubernetes.#Resources & {
				"kubeconfig": kubeconfig
				version:      "v1.23.3"
				namespace:    app.metadata.namespace
				manifest:     yaml.Marshal(cm)
			}
			for j, t in c.traits {
				for jj, tm in t.manifests {
					"\(c.name)-\(cm.kind)-\(t.type)-\(tm.kind)": kubernetes.#Resources & {
						"kubeconfig": kubeconfig
						version:      "v1.23.3"
						namespace:    app.metadata.namespace
						manifest:     yaml.Marshal(tm)
					}
				}
			}
		}
	}
}
