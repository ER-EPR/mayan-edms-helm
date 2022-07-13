{/* vim: set filetype=mustache: */}}

{{- define "mayan.configMapName" -}}
{{- $name := "mayan-edms" }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}-configmap
{{- end }}
{{- end }}

{{/*
Generate extra configuation, not managed by the _helpers
*/}}
{{- define "mayan.configuration.unmanaged" -}}
{{- $managedKeys := list "MAYAN_DOCUMENTS_FILE_STORAGE_BACKEND" "DOCUMENTS_FILE_PAGE_IMAGE_CACHE_STORAGE_BACKEND" "DOCUMENTS_VERSION_PAGE_IMAGE_CACHE_STORAGE_BACKEND" "MAYAN_PIP_INSTALLS" -}}
{{- range $key, $val := .Values.configuration -}}
{{- $keyFound := has $key $managedKeys -}}
{{- if not $keyFound -}}
{{ $key }}: {{ $val | quote }}
{{- "\n" -}}
{{- end -}}
{{- end -}}
{{- end -}}

