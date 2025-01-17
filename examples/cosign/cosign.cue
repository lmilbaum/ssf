package ssf

_IMAGE: name: "slsa"


ssf: pipelineRun: "ko-pipelinerun-": spec: {
	pipelineRef: name: "ko"
	params: [ {
		name:  "APP_IMAGE"
		value: _APP_IMAGE
	}, {
		name:  "SOURCE_URL"
		value: "https://github.com/sigstore/cosign"
	}, {
		name:  "SOURCE_SUBPATH"
		value: "./cmd/cosign"
	},{
    name: "KO_DOCKER_REPO"
    value: _REPOSITORY
  },]
	workspaces: [{
		name:    "source-ws"
		subPath: "source"
	}, {
		// NOTE: Pipeline hangs if optional cache workspace is missing so we provide an empty directory
		name: "cache-ws"
		emptyDir: {}
	}]
}
