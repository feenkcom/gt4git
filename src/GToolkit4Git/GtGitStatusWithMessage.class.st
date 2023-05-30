Class {
	#name : #GtGitStatusWithMessage,
	#superclass : #GtGitStatus,
	#instVars : [
		'message'
	],
	#category : #'GToolkit4Git-Model'
}

{ #category : #accessing }
GtGitStatusWithMessage >> label [
	^ self message
]

{ #category : #accessing }
GtGitStatusWithMessage >> message [
	^ message
]

{ #category : #accessing }
GtGitStatusWithMessage >> message: aString [
	message := aString
]
