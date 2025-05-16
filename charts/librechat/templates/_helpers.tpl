{{/*
Expand the name of the chart.
*/}}
{{- define "librechat.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "librechat.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "librechat.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "librechat.labels" -}}
helm.sh/chart: {{ include "librechat.chart" . }}
{{ include "librechat.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "librechat.selectorLabels" -}}
app.kubernetes.io/name: {{ include "librechat.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "librechat.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "librechat.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Print string from list split by ,
*/}}
{{- define "model.list" -}}
{{- range $idx, $val := $.Values.configEndpoint.models -}}
{{- if $idx }}
{{- print ", "  -}} 
{{- end -}}
{{- $val -}}
{{- end -}}
{{- end -}}

{{/*
Init container to download document db ca
*/}}
{{- define "librechat.downloadDocumentDbCaContainer" -}}
{{- if .Values.config.downloadDocumentDbCa }}
initContainers:
- image: alpine/curl
  imagePullPolicy: Always
  name: ddb-ca-downloader
  args:
  - -sSL 
  - https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem
  - -o
  - /opt/ddb-ca/global-bundle.pem
  resources:
    limits:
      cpu: 200m
      memory: 128Mi
    requests:
      cpu: "100m"
      memory: 128Mi
  volumeMounts:
  - mountPath: /opt/ddb-ca
    name: ddb-ca
{{- else }}
{{- end }}
{{- end }}

    
