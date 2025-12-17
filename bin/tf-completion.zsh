#compdef tf
# Zsh completion for tf wrapper
# Add to ~/.zshrc: source /path/to/tf-completion.zsh
# Or place in $fpath directory as _tf

_tf() {
    local -a commands
    commands=(
        'plan:Save plan to file with timestamp'
        'apply:Apply most recent saved plan'
        'show:Show latest plan, specific plan file, or state'
        'summary:Show high-level summary of plan changes'
        'list:List saved plan files'
        'diff:Compare two plans'
        'current:Show current plan metadata'
        'clean:Remove old plan files'
        'run-all:Run terragrunt command across all layers'
        'help:Show help message'
        # Terraform pass-through commands
        'init:Initialize terraform directory'
        'validate:Validate configuration'
        'fmt:Format configuration files'
        'console:Interactive console'
        'import:Import existing infrastructure'
        'output:Show output values'
        'providers:Show required providers'
        'refresh:Update state file'
        'state:State management'
        'taint:Mark resource for recreation'
        'untaint:Remove taint from resource'
        'workspace:Workspace management'
        'graph:Generate dependency graph'
        'destroy:Destroy infrastructure'
    )

    local -a list_opts
    list_opts=(
        '-n:Show names only'
        '--names-only:Show names only'
    )

    local -a run_all_cmds
    run_all_cmds=(
        'init:Initialize all layers'
        'validate:Validate all layers'
        'plan:Plan all layers'
        'apply:Apply all layers'
        'destroy:Destroy all layers'
        'output:Show outputs from all layers'
    )

    local -a state_cmds
    state_cmds=(
        'list:List resources in state'
        'show:Show resource in state'
        'mv:Move resource in state'
        'rm:Remove resource from state'
        'pull:Pull current state'
        'push:Push state'
        'replace-provider:Replace provider in state'
    )

    local -a workspace_cmds
    workspace_cmds=(
        'list:List workspaces'
        'select:Select workspace'
        'new:Create workspace'
        'delete:Delete workspace'
        'show:Show current workspace'
    )

    _arguments -C \
        '1: :->command' \
        '*: :->args'

    case $state in
        command)
            _describe -t commands 'tf command' commands
            ;;
        args)
            case $words[2] in
                list)
                    _describe -t options 'list options' list_opts
                    ;;
                run-all)
                    _describe -t commands 'run-all command' run_all_cmds
                    ;;
                state)
                    _describe -t commands 'state command' state_cmds
                    ;;
                workspace)
                    _describe -t commands 'workspace command' workspace_cmds
                    ;;
                show|diff)
                    # Complete with plan files
                    local plans_dir=".terraform/plans"
                    if [[ -d "$plans_dir" ]]; then
                        local -a plans
                        plans=(${plans_dir}/*.tfplan(:t))
                        _describe -t files 'plan files' plans
                    fi
                    ;;
            esac
            ;;
    esac
}

_tf "$@"
