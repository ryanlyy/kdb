# 1 Helm Commands
helm get manifest releasename: show chart resource of this release
helm install --debug --dry-run --name my-release ./mychart
# 2 Helm Objects
Major Built-in Objects: Release, Values, Chart, Files, Capabilities, Template

Built-in Functions: quote, repeat, upper, default, eq, ne, lt, gt, and, or etc.
Flow-Control: 
