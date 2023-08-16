Class {
	#name : #GtGitCliEvent,
	#superclass : #GtBeaconLogEvent,
	#category : #'GToolkit4Git-Libgit-replace'
}

{ #category : #accessing }
GtGitCliEvent class >> eventLabel [
	^'Git Cli Event'
]

{ #category : #accessing }
GtGitCliEvent >> args [
	^ self eventStartedSignal args
]
