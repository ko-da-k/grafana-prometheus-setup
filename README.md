# grafana-prometheus-setup

## Prometheus
- 時系列データの記録に特化しているサービス監視ツール（アラートはGrafanaで行うため，alertmanagerはInstallしない）
- https://prometheus.io/
- https://github.com/helm/charts/tree/master/stable/prometheus

## Grafana
- 監視Dashboardを提供する．Prometheusが収集した値を可視化，状況に応じたalertingを行う
- https://grafana.com/
- https://github.com/helm/charts/tree/master/stable/grafana
- https://www.terraform.io/docs/providers/grafana/index.html