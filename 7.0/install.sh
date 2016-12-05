#!/bin/bash

phpExtensionDir=$(/usr/local/bin/php-config --extension-dir)

# ZendGuardLoader
if [ -f "${phpExtensionDir}/ZendGuardLoader.so" ];then
    cat > $PHP_INSTALL_DIR/etc/php.d/ext-ZendGuardLoader.ini << EOF
[Zend Guard Loader]
zend_extension=${phpExtensionDir}/ZendGuardLoader.so
zend_loader.enable=1
zend_loader.disable_licensing=0
zend_loader.obfuscation_level_support=3
EOF
fi

# ioncube
if [ -f "${phpExtensionDir}/ioncube_loader.so" ];then
    cat > $PHP_INSTALL_DIR/etc/php.d/ext-0ioncube.ini << EOF
[ionCube Loader]
zend_extension=${phpExtensionDir}/ioncube_loader.so
EOF
fi
