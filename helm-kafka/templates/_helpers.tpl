{{- define "broker-advertise-overrides" -}}
  {{- range $broker,$e := until (.Values.kafka.cluster.replicas|int) }}
    - broker: {{ $broker }}
      advertisedHost: barney-kafka-cluster-kafka-{{ $broker }}.{{ $.Values.kafka.cluster.service.domain }}
      advertisedPort: {{ $.Values.kafka.cluster.service.tcp_port }}
      annotations:
        getambassador.io/config: |
          ---
          apiVersion: getambassador.io/v2
          kind:  TCPMapping
          name:  barney_kafka_cluster_kafka_{{ $broker }}_tcp_port_mapping
          ambassador_id:
            - internal_proxy
          port: {{ $.Values.kafka.cluster.service.tcp_port }}
          service: "barney-kafka-cluster-kafka-{{ $broker}}.{{ $.Release.Namespace }}:9094"
          host: barney-kafka-cluster-kafka-{{ $broker }}.{{ $.Values.kafka.cluster.service.domain }}
  {{- end -}}
{{- end }}
