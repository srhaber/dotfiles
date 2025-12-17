# Bash completion for tf wrapper
# Source this file: source tf-completion.bash
# Or add to ~/.bashrc: source /path/to/tf-completion.bash

_tf_completions() {
    local cur prev words cword
    _init_completion || return

    # tf subcommands
    local tf_commands="plan apply show summary list diff current clean run-all help init validate fmt console import output providers refresh state taint untaint workspace graph"

    # Terragrunt specific commands
    local tg_commands="run-all render-json output-module-groups"

    # terraform/terragrunt subcommands (pass-through)
    local terraform_commands="init validate plan apply destroy console fmt force-unlock get graph import login logout metadata output providers refresh show state taint test untaint version workspace"

    case "$prev" in
        tf)
            COMPREPLY=($(compgen -W "$tf_commands" -- "$cur"))
            return
            ;;
        run-all)
            # run-all takes terraform commands
            COMPREPLY=($(compgen -W "init validate plan apply destroy output" -- "$cur"))
            return
            ;;
        show)
            # show can take plan files or 'state'
            local plans_dir=".terraform/plans"
            if [[ -d "$plans_dir" ]]; then
                local plans=$(find "$plans_dir" -name "*.tfplan" -type f 2>/dev/null | xargs -I{} basename {})
                COMPREPLY=($(compgen -W "state $plans" -- "$cur"))
            else
                COMPREPLY=($(compgen -W "state" -- "$cur"))
            fi
            return
            ;;
        diff)
            # diff takes plan files
            local plans_dir=".terraform/plans"
            if [[ -d "$plans_dir" ]]; then
                local plans=$(find "$plans_dir" -name "*.tfplan" -type f 2>/dev/null | xargs -I{} basename {})
                COMPREPLY=($(compgen -W "$plans" -- "$cur"))
            fi
            return
            ;;
        list)
            COMPREPLY=($(compgen -W "-n --names-only" -- "$cur"))
            return
            ;;
        state)
            COMPREPLY=($(compgen -W "list show mv rm pull push replace-provider" -- "$cur"))
            return
            ;;
        workspace)
            COMPREPLY=($(compgen -W "list select new delete show" -- "$cur"))
            return
            ;;
    esac

    # Default: complete with tf commands
    if [[ ${cword} -eq 1 ]]; then
        COMPREPLY=($(compgen -W "$tf_commands" -- "$cur"))
    fi
}

complete -F _tf_completions tf
