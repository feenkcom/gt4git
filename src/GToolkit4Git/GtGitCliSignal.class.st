Class {
	#name : #GtGitCliSignal,
	#superclass : #BeaconSignal,
	#instVars : [
		'args'
	],
	#category : #'GToolkit4Git-Libgit-replace'
}

{ #category : #'instance creation' }
GtGitCliSignal class >> args: aCollection [
	^self new args: aCollection
]

{ #category : #accessing }
GtGitCliSignal >> args [
	^ args
]

{ #category : #accessing }
GtGitCliSignal >> args: anObject [
	args := anObject
]

{ #category : #printing }
GtGitCliSignal >> printOneLineContentsOn: aStream [
	args do: [ :arg | aStream print: arg ] separatedBy: [ aStream nextPut: $  ]
]
