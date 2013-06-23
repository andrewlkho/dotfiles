# I don't use dashboard
defaults write com.apple.dashboard mcx-disabled -boolean YES
killall Dock

# Show ~/Library
chflags nohidden ~/Library

# The save dialogue should always open in expanded view
defaults write -g NSNavPanelExpandedStateForSaveMode -bool TRUE
