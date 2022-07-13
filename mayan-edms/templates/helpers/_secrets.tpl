{/* vim: set filetype=mustache: */}}

{{- define "mayan.secretsName" -}}
{{- $name := "mayan-edms" }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}-secrets
{{- end }}
{{- end }}

{{/*
Generate extra secrets, not managed by the _helpers
*/}}
{{- define "mayan.secrets.unmanaged" -}}
{{- range $key, $val := .Values.secrets -}}
{{ $key }}: {{ $val | quote }}
{{- "\n" -}}
{{- end -}}
{{- end -}}

{{- define "mayan.secrets.managed" -}}
{{ include "mayan.secrets.celeryBrokerUrl" . }}
{{ include "mayan.secrets.celeryResultBackend" . }}
{{ include "mayan.secrets.databases" . }}
{{ include "mayan.secrets.documentsVersionPageImageCacheStorageBackendArguments" . }}
{{ include "mayan.secrets.lockManagerBackendArguments" . }}
{{ include "mayan.secrets.searchBackendArguments" . }}
{{- end -}}

{{/*
Generate the MAYAN_SEARCH_BACKEND_ARGUMENTS environment variable
*/}}
{{- define "mayan.secrets.searchBackendArguments" -}}
{{- if .Values.elasticsearch.enabled -}}
MAYAN_SEARCH_BACKEND_ARGUMENTS: "{'client_host':'{{ template "mayan.elasticsearch.fullname" . }}'}"
{{- else -}}
MAYAN_SEARCH_BACKEND_ARGUMENTS: "{{ .Values.secrets.MAYAN_SEARCH_BACKEND_ARGUMENTS }}"
{{- end -}}
{{- end -}}

