Class {
	#name : #GitCliFileHandle,
	#superclass : #FileSystemHandle,
	#instVars : [
		'entry'
	],
	#category : #'GToolkit4Git-Libgit-CLI'
}

{ #category : #accessing }
GitCliFileHandle >> binaryReadStream [
	^ reference fileSystem store binaryReadStreamOn: self
]

{ #category : #accessing }
GitCliFileHandle >> entry [
	^ entry
]

{ #category : #accessing }
GitCliFileHandle >> entry: anObject [
	entry := anObject
]

{ #category : #accessing }
GitCliFileHandle >> open [
	entry := self basicOpen
]

{ #category : #accessing }
GitCliFileHandle >> readStream [
	^ reference fileSystem store readStreamOn: self
]
