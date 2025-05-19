def sysctl_actions [] { ["status", "start", "stop", "enable", "disable"] }
extern systemctl [
    action: string@"sysctl_actions"
    service: string
]
alias sc = systemctl
