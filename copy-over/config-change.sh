#!/bin/bash
# Basic config/creds changer for various Package managers. Relies on other configs being named config.file-something, e.g settings.xml-loren
function copy() {
    options=($(ls $1))
    select opt in "${options[@]}"; do
        original=$(echo $opt | sed 's/-.*$//')
        echo "Copying $opt to $original"
        cp $opt $original
        break
    done

} 

case $1 in 
    mvn)
        copy "$HOME/.m2/settings.xml-*";;
    npm)
        copy "$HOME/.npmrc-*";;
    gradle)
        copy "$HOME/.gradle/gradle.properties-*";;
    gems)
        copy "$HOME/.gemrc-*";;
    nuget)
        copy "$HOME/.config/NuGet/NuGet.Config-*";;
    bower)
        copy "$HOME/.bowerrc-*";;
    pip)
        copy "$HOME/.pip/pip.conf-*";;
    *)
        echo "Enter a valid package manager, like: mvn npm gradle gems nuget bower pip";;
esac
