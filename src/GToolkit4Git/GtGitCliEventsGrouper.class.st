Class {
	#name : #GtGitCliEventsGrouper,
	#superclass : #GtBeaconEventsGrouper,
	#category : #'GToolkit4Git-Libgit-CLI'
}

{ #category : #accessing }
GtGitCliEventsGrouper >> createDefaultEventsGroup [
	^GtGitCliEventsGroup new
]
