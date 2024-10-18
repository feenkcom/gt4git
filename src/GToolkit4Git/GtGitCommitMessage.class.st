Class {
	#name : #GtGitCommitMessage,
	#superclass : #Object,
	#traits : 'TGtUniqueInstance',
	#classTraits : 'TGtUniqueInstance classTrait',
	#instVars : [
		'lastMessage'
	],
	#category : #'GToolkit4Git-UI - View Model'
}

{ #category : #initialization }
GtGitCommitMessage >> initialize [
	super initialize.
	lastMessage := ''.
]

{ #category : #accessing }
GtGitCommitMessage >> lastMessage [
	^ lastMessage
]

{ #category : #accessing }
GtGitCommitMessage >> lastMessage: anObject [
	lastMessage := anObject
]
