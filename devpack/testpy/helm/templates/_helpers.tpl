{{/*
Generate kubeconfig for service account
*/}}
{{- define "myapp.generateKubeconfig" -}}
{{- printf "#!/bin/sh\n" -}}
{{- printf "kubectl config set-cluster local --server=https://%s --certificate-authority=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt\n" (include "myapp.getKubernetesAPIHost" .) -}}
{{- printf "kubectl config set-credentials sa-%s --token=%s\n" .Release.Namespace (include "myapp.getServiceAccountToken" .) -}}
{{- printf "kubectl config set-context local --cluster=local --user=sa-%s --namespace=%s\n" .Release.Namespace .Release.Namespace -}}
{{- printf "kubectl config use-context local\n" -}}
{{- end -}}

{{/*
Get Kubernetes API host
*/}}
{{- define "myapp.getKubernetesAPIHost" -}}
{{- printf "%s" .Values.kubernetesAPIHost | quote -}}
{{- end -}}

{{/*
Get service account token
*/}}
{{- define "myapp.getServiceAccountToken" -}}
{{- printf "%s" (include "myapp.executeServiceAccountToken" .) -}}
{{- end -}}

{{/*
Execute script to get service account token
*/}}
{{- define "myapp.executeServiceAccountToken" -}}
{{- printf "$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" -}}
{{- end -}}
