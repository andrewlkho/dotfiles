# Augment the default search path for modules.  Don't forget to add this to sudoers:
#   Defaults env_keep += "PYTHONPATH"
export PYTHONPATH=$( find /usr/local/lib -type d -name 'site-packages' )
