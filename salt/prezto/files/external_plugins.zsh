# inspiration: https://github.com/mattmc3/zsh_unplugged

external_plugins=(
{%- for plugin extplugins %}
  {{ plugin }}
{%- endfor %}
)

for repo in $external_plugins; do
  if [[ ! -d $ZPREZTODIR/contrib/${repo:t} ]]; then
    git clone --recursive https://github.com/${repo} {{ extplugins_target }}/${repo:t} # prezto modules might have a git submodule
    # prezto now looks for <name>.plugin.zsh as well: https://github.com/sorin-ionescu/prezto/commit/029414581e54f5b63156f81acd0d377e8eb78883
    # if [[ ! -f  {{ extplugins_target }}/${repo:t}/init.zsh ]]; then                    # if it's not a prezto module, create a skeleton one on the fly
    #   git mv {{ extplugins_target }}/${repo:t}/* {{ extplugins_target }}/${repo:t}/external/
    #   echo "source \${0:A:h}/external/${repo:t}.plugin.zsh" > $ZPREZTODIR/contrib/${repo:t}/init.zsh
    # fi
  fi
done
