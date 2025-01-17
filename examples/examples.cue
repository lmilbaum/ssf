package ssf

_IMAGE: name: string

_REPOSITORY: *"ttl.sh" | string @tag(repository)
_APP_IMAGE: *"\(_REPOSITORY)/\(_IMAGE.name)" | string @tag(appImage)

ssf: secret: "kube-api-secret": {
	metadata: annotations: "kubernetes.io/service-account.name": "pipeline-account"
	type: "kubernetes.io/service-account-token"
}

ssf: serviceAccount: "pipeline-account": {
}

ssf: clusterRole: "pipeline-role": rules: [{
	apiGroups: [""]
	resources: ["services"]
	verbs: ["get", "create", "update", "patch"]
}, {
	apiGroups: ["apps"]
	resources: ["deployments"]
	verbs: ["get", "create", "update", "patch"]
}]

ssf: clusterRoleBinding: "pipeline-role-binding": {
	roleRef: {
		apiGroup: "rbac.authorization.k8s.io"
		kind:     "ClusterRole"
		name:     "pipeline-role"
	}
	subjects: [{
		kind: "ServiceAccount"
		namespace: "default"
		name: "pipeline-account"
	}]
}

// generate a PVC for each pipelineRun
for pr in ssf.pipelineRun {
	ssf: persistentVolumeClaim: "\(pr.metadata.generateName)source-ws-pvc": {
		spec: {
			accessModes: ["ReadWriteOnce"]
			resources: requests: storage: "500Mi"
		}
	}
}

ssf: pipelineRun: [Name=_]: spec: workspaces: [{
	name: *"\(Name)ws" | string
	persistentVolumeClaim: claimName: "\(Name)source-ws-pvc"
}, ...]

ssf: task: "grype-vulnerability-scan": {
	spec: {
		params: [{
			description: "image reference"
			name:        "image-ref"
		}, {
			description: "image digest"
			name:        "image-digest"
		}, {
			default:     "0"
			description: "toggles debug mode for the pipeline"
			name:        "pipeline-debug"
		}, {
			name: "fail-on"
			description: "set the return code to 1 if a vulnerability is found with a severity >= the given severity, options=[negligible low medium high critical]"
			default: "medium"
		}, {
			name: "only-fixed"
			description: "ignore matches for vulnerabilities that are not fixed (blank to disable)"
			default: "--only-fixed"
		}]
		stepTemplate: {
			name: "PIPELINE_DEBUG"
			env: [{
				name:  "PIPELINE_DEBUG"
				value: "$(params.pipeline-debug)"
			}]
		}
		steps: [{
			args: [
				"$(params.image-ref)@$(params.image-digest)",
				"-v",
				"$(params.only-fixed)",
				"--fail-on",
				"$(params.fail-on)",
			]
			image: "anchore/grype:v0.35.0@sha256:857934a54874b7efe3d6964851ce54abb5a36d6200cdb62383990a5c7c8d748e"
			name:  "grype-scanner"
		}]
	}
}
