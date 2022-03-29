package ssf

import (
    "strings"

	k8sCoreV1 "k8s.io/api/core/v1"
	k8sRbacV1 "k8s.io/api/rbac/v1"
	kyvernoV1 "github.com/kyverno/kyverno/api/kyverno/v1"
	pipelineV1Beta1 "github.com/tektoncd/pipeline/pkg/apis/pipeline/v1beta1"
)

k8sSet: [
	clusterPolicy,
	configMap,
	secret,
	serviceAccount,
	role,
	clusterRole,
	clusterRoleBinding,
	roleBinding,
	persistentVolumeClaim,
	pipeline,
	pipelineRun,
	task,
]

k8sList: [ for x in k8sSet for y in x if y.kind != _|_ {y}]

k8s: {
    for obj in k8sList if obj.kind != _|_ && obj.metadata != _|_ && (obj.metadata.name != _|_ || obj.metadata.generateName != _|_) {
		(strings.ToCamel(obj.kind)): ("\(obj.metadata.name)" | "\(obj.metadata.generateName)"): obj
	}
}

// Match against existing Go structs
k8s: configMap: [Name=_]: k8sCoreV1.#ConfigMap & {
	apiVersion: "v1"
	kind:       "ConfigMap"
	metadata: name: *Name | string
}

k8s: secret: [Name=_]: k8sCoreV1.#Secret & {
	apiVersion: "v1"
	kind:       "Secret"
	metadata: name: *Name | string
}

k8s: serviceAccount: [Name=_]: k8sCoreV1.#ServiceAccount & {
	apiVersion: "v1"
	kind:       "ServiceAccount"
	metadata: name: *Name | string
}

k8s: role: [Name=_]: k8sRbacV1.#Role & {
	kind:       "Role"
	apiVersion: "rbac.authorization.k8s.io/v1"
	metadata: name: *Name | string
}

k8s: clusterRole: [Name=_]: k8sRbacV1.#ClusterRole & {
	kind:       "ClusterRole"
	apiVersion: "rbac.authorization.k8s.io/v1"
	metadata: name: *Name | string
}

k8s: roleBinding: [Name=_]: k8sRbacV1.#RoleBinding & {
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "RoleBinding"
	metadata: name: *Name | string
}

k8s: clusterRoleBinding: [Name=_]: k8sRbacV1.#ClusterRoleBinding & {
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "ClusterRoleBinding"
	metadata: name: *Name | string
}

k8s: task: [Name=_]: pipelineV1Beta1.#Task & {
	apiVersion: "tekton.dev/v1beta1"
	kind:       "Task"
	metadata: name: *Name | string
}

k8s: taskRun: [Name=_]: pipelineV1Beta1.#TaskRun & {
	apiVersion: "tekton.dev/v1beta1"
	kind:       "TaskRun"
	metadata: name: *Name | string
}

k8s: pipeline: [Name=_]: pipelineV1Beta1.#Pipeline & {
	apiVersion: "tekton.dev/v1beta1"
	kind:       "Pipeline"
	metadata: name: *Name | string
}

k8s: pipelineRun: [GeneratedName=_]: pipelineV1Beta1.#PipelineRun & {
	apiVersion: "tekton.dev/v1beta1"
	kind:       "PipelineRun"
	metadata: {
		generateName: *GeneratedName | string
		labels: "app.kubernetes.io/description": "PipelineRun"
	}
}

k8s: persistentVolumeClaim: [Name=_]: k8sCoreV1.#PersistentVolumeClaim & {
	apiVersion: "v1"
	kind:       "PersistentVolumeClaim"
	metadata: name: *Name | string
}

k8s: clusterPolicy: [Name=_]: kyvernoV1.#ClusterPolicy & {
	apiVersion: "kyverno.io/v1"
	kind:       "ClusterPolicy"
	metadata: name: *Name | string
}