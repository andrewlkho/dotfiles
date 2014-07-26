# I don't use dashboard
defaults write com.apple.dashboard mcx-disabled -bool true
killall Dock

# Show ~/Library
chflags nohidden ~/Library

# The save dialogue should always open in expanded view
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true

# Expand print dialogue by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
