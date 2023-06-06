Class {
	#name : #GtGitStatusConflicting,
	#superclass : #GtGitStatusIncoming,
	#category : #'GToolkit4Git-Model'
}

{ #category : #accessing }
GtGitStatusConflicting class >> color [
	^ BrGlamorousColors errorBackgroundColor
]

{ #category : #accessing }
GtGitStatusConflicting >> label [
	^ count asString, ' conflicting incoming ', self changesInflection
]
