Class {
	#name : #GtGitStatusUnknownError,
	#superclass : #GtGitStatusError,
	#instVars : [
		'message'
	],
	#category : #'GToolkit4Git-Model'
}

{ #category : #accessing }
GtGitStatusUnknownError >> label [
	^ self message
]

{ #category : #accessing }
GtGitStatusUnknownError >> message [
	^ message
]

{ #category : #accessing }
GtGitStatusUnknownError >> message: aString [
	message := aString
]
