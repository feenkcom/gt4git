Class {
	#name : #GtGitCliEventsGrouper,
	#superclass : #GtBeaconEventsGrouper,
	#category : #'GToolkit4Git-Libgit-replace'
}

{ #category : #accessing }
GtGitCliEventsGrouper >> createDefaultEventsGroup [
	^GtGitCliEventsGroup new
]
