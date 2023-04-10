Class {
	#name : #GtGitStatusUnknownCommitState,
	#superclass : #GtGitStatusWithMessage,
	#category : #'GToolkit4Git-Model'
}

{ #category : #accessing }
GtGitStatusUnknownCommitState class >> color [
	^ BrGlamorousColors errorBackgroundColor
]

{ #category : #accessing }
GtGitStatusUnknownCommitState >> icon [
	^ BrGlamorousVectorIcons cancel
]
