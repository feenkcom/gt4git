Class {
	#name : #GtGitCliEventsGrouper,
	#superclass : #GtBeaconEventsGrouper,
	#category : #'GToolkit4Git-Libgit-CLI-GT'
}

{ #category : #accessing }
GtGitCliEventsGrouper >> createDefaultEventsGroup [
	^GtGitCliEventsGroup new
]
